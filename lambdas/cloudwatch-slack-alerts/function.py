import boto3
import json
import logging
import os
import re

from urllib.request import Request, urlopen
from urllib.error import URLError, HTTPError

SLACK_CHANNEL = os.environ['slackChannel']
HOOK_URL = os.environ['slackHookUrl']

logger = logging.getLogger()
logger.setLevel(logging.INFO)

PIPELINE_STATE_COLOURS = {
  "STARTED": "#439FE0",
  "SUCCEEDED": "good",
  "FAILED": "danger",
}

def pipeline_slack_message(message):
    pipeline = message['detail']['pipeline']
    state = message['detail']['state']
    text = "Pipeline %s %s" % (pipeline, state)
    region = message.get('region')
    execution_id = message['detail'].get('execution-id')
    if region and execution_id:
      url = "https://%s.console.aws.amazon.com/codesuite/codepipeline/pipelines/%s/executions/%s/timeline?region=%s" % (region, pipeline, execution_id, region)
      text = "%s\n<%s|View execution>" % (text, url)
    return {
      'channel': SLACK_CHANNEL,
      'attachments': [
        {
          'text': text,
          'color': PIPELINE_STATE_COLOURS.get(state, "warning")
        }
      ]
    }

AUTOSCALING_DETAIL_TYPES = (
  "CloudWatch Alarm State Change",
  "EC2 Instance Launch Successful",
  "EC2 Instance Terminate Successful",
  "EC2 Instance Launch Unsuccessful",
  "EC2 Instance Terminate Unsuccessful",
  "ECS Service Action",
)

def slack_escape(text):
    return str(text).replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;")

def autoscaling_slack_message(message):
    detail_type = message['detail-type']
    detail = message['detail']
    asg = detail.get('AutoScalingGroupName')
    target_tracking = re.match(r"TargetTracking-service/([^/]+)/(.+)-Alarm(High|Low)-", detail.get('alarmName') or '')
    if detail_type == "CloudWatch Alarm State Change" and target_tracking:
      cluster, service, alarm = target_tracking.groups()
      scaling_out = alarm == "High"
      text = "Service %s (%s) scaling %s" % (slack_escape(service), slack_escape(cluster), "out" if scaling_out else "in")
      color = "#439FE0" if scaling_out else "#9E9E9E"
    elif detail_type in ("EC2 Instance Launch Successful", "EC2 Instance Terminate Successful"):
      launched = detail_type == "EC2 Instance Launch Successful"
      capacity = re.search(r"changing the desired capacity from (\d+) to (\d+)", detail.get('Cause') or '')
      if capacity:
        text = "%s instances %s \u2192 %s (%s %s)" % (asg, capacity.group(1), capacity.group(2), "launched" if launched else "terminated", detail.get('EC2InstanceId'))
      else:
        text = "%s %s" % (asg, slack_escape(detail.get('Description')))
      color = "#439FE0" if launched else "#9E9E9E"
    elif detail_type in ("EC2 Instance Launch Unsuccessful", "EC2 Instance Terminate Unsuccessful"):
      action = "launch" if detail_type == "EC2 Instance Launch Unsuccessful" else "terminate"
      text = "%s %s failed: %s" % (asg, action, slack_escape(detail.get('StatusMessage')))
      color = "danger"
    elif detail_type == "ECS Service Action" and detail.get('eventName') == "SERVICE_TASK_PLACEMENT_FAILURE":
      resources = message.get('resources') or []
      service = resources[0].split('/')[-1] if resources else "unknown"
      text = "Service %s could not place tasks: %s" % (service, slack_escape(detail.get('reason')))
      color = "danger"
    else:
      text = detail_type
      color = "warning"
    return {
      'channel': SLACK_CHANNEL,
      'attachments': [
        {
          'text': text,
          'color': color
        }
      ]
    }

def lambda_handler(event, context):
    logger.info("Event: " + str(event))
    try:
      message = json.loads(event['Records'][0]['Sns']['Message'])
    except ValueError as e:
      message = { "message": event['Records'][0]['Sns']['Message'] }

    if isinstance(message, str):
      message = { "message": event['Records'][0]['Sns']['Message'] }

    logger.info("Message: " + str(message))

    if "AlarmName" in message.keys():
      alarm_name = message['AlarmName']
      new_state = message['NewStateValue']
      reason = message['NewStateReason']
      if new_state == "OK":
        message_color = "good"
      else:
        message_color = "danger"
      slack_message = {
        'channel': SLACK_CHANNEL,
        'attachments': [
          {
            'text': "%s state is now %s:\n %s" % (alarm_name, new_state, reason),
            'color': message_color
          }
        ]
      }
    elif "detail-type" in message.keys():
      detail_type = message['detail-type']
      if detail_type == "CodePipeline Pipeline Execution State Change":
        slack_message = pipeline_slack_message(message)
      elif detail_type in AUTOSCALING_DETAIL_TYPES:
        slack_message = autoscaling_slack_message(message)
    elif "message" in message.keys():
      message_color = "good"
      slack_message = {
        'channel': SLACK_CHANNEL,
        'attachments': [
          {
            'text': message['message'],
            'color': "good"
          }
        ]
      }

    logger.info("Event: " + str(json.dumps(slack_message)))
    req = Request(HOOK_URL, json.dumps(slack_message).encode('utf-8'))
    try:
        response = urlopen(req)
        response.read()
        logger.info("Message posted to %s", slack_message['channel'])
    except HTTPError as e:
        logger.error("Request failed: %d %s", e.code, e.reason)
    except URLError as e:
        logger.error("Server connection failed: %s", e.reason)

'''
*Test examples*

Alarm:
{
  "Records": [
    {
      "EventSource": "aws:sns",
      "EventVersion": "1.0",
      "Sns": {
        "MessageId": "95df01b4-ee98-5cb9-9903-4c221d41eb5e",
        "Message": "{\"AlarmName\": \"Test alarm\",\"NewStateValue\": \"OK\",\"NewStateReason\": \"Testing\"}",
        "Timestamp": "1970-01-01T00:00:00.000Z"
      }
    }
  ]
}

CodePipeline:
{
  "Records": [
    {
      "EventSource": "aws:sns",
      "EventVersion": "1.0",
      "Sns": {
        "MessageId": "95df01b4-ee98-5cb9-9903-4c221d41eb5e",
        "Message": "{\"detail-type\": \"CodePipeline Pipeline Execution State Change\", \"source\": \"aws.codepipeline\", \"region\": \"eu-west-2\", \"detail\": {\"pipeline\": \"Test pipeline\", \"execution-id\": \"01234567-89ab-cdef-0123-456789abcdef\", \"state\": \"STARTED\", \"version\": 1}}",
        "Timestamp": "1970-01-01T00:00:00.000Z"
      }
    }
  ]
}
'''
