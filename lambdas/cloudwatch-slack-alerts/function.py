import boto3
import json
import logging
import os

from urllib.request import Request, urlopen
from urllib.error import URLError, HTTPError

SLACK_CHANNEL = os.environ['slackChannel']
HOOK_URL = os.environ['slackHookUrl']

logger = logging.getLogger()
logger.setLevel(logging.INFO)

def lambda_handler(event, context):
    logger.info("Event: " + str(event))
    try:
      message = json.loads(event['Records'][0]['Sns']['Message'])
    except ValueError as e:
      message = '{"message": "%s"}' (event['Records'][0]['Sns']['Message'].replace('"', '\\"'))
    return True
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
        pipeline = message['detail']['pipeline']
        pipeline_state = message['detail']['state']
        if pipeline_state == "FAILED":
          message_color = "danger"
        else:
          message_color = "good"
        slack_message = {
          'channel': SLACK_CHANNEL,
          'attachments': [
            {
              'text': "Pipeline %s %s" % (pipeline, pipeline_state),
              'color': message_color
            }
          ]
        }
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
        "Message": "{\"detail-type\": \"CodePipeline Pipeline Execution State Change\",\"detail\": {\"pipeline\": \"Test pipeline\", \"state\": \"STARTED\"}}",
        "Timestamp": "1970-01-01T00:00:00.000Z"
      }
    }
  ]
}
'''
