import importlib.util
import json
import os
import sys
import types
import unittest
from pathlib import Path
from unittest import mock

sys.dont_write_bytecode = True

FUNCTION_DIR = Path(__file__).resolve().parent.parent / "lambdas" / "cloudwatch-slack-alerts"


def load_function():
  sys.modules.setdefault("boto3", types.ModuleType("boto3"))
  environment = {"slackChannel": "C0TEST", "slackHookUrl": "https://hooks.example.invalid/test"}
  with mock.patch.dict(os.environ, environment):
    spec = importlib.util.spec_from_file_location("cloudwatch_slack_alerts_function", FUNCTION_DIR / "function.py")
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
  return module


function = load_function()


def sns_event(message):
  return {"Records": [{"EventSource": "aws:sns", "Sns": {"Message": json.dumps(message)}}]}


def pipeline_event(state, **overrides):
  event = {
    "detail-type": "CodePipeline Pipeline Execution State Change",
    "source": "aws.codepipeline",
    "region": "eu-west-2",
    "detail": {
      "pipeline": "example-app-staging-ecs-service-app",
      "execution-id": "01234567-89ab-cdef-0123-456789abcdef",
      "state": state,
      "version": 1,
    },
  }
  event.update(overrides)
  return event


class SlackPostTestCase(unittest.TestCase):
  def post(self, message):
    with mock.patch.object(function, "urlopen") as urlopen:
      function.lambda_handler(sns_event(message), None)
    request = urlopen.call_args.args[0]
    self.assertEqual(request.full_url, "https://hooks.example.invalid/test")
    return json.loads(request.data)["attachments"][0]


class PipelineMessageTest(SlackPostTestCase):
  def test_state_colours(self):
    expected = {
      "STARTED": "#439FE0",
      "SUCCEEDED": "good",
      "FAILED": "danger",
      "STOPPED": "warning",
      "SUPERSEDED": "warning",
      "RESUMED": "warning",
    }
    for state, colour in expected.items():
      with self.subTest(state=state):
        self.assertEqual(self.post(pipeline_event(state))["color"], colour)

  def test_text_names_pipeline_and_state_and_links_to_execution(self):
    text = self.post(pipeline_event("SUCCEEDED"))["text"]
    self.assertEqual(
      text,
      "Pipeline example-app-staging-ecs-service-app SUCCEEDED\n"
      "<https://eu-west-2.console.aws.amazon.com/codesuite/codepipeline/pipelines/"
      "example-app-staging-ecs-service-app/executions/01234567-89ab-cdef-0123-456789abcdef/"
      "timeline?region=eu-west-2|View execution>",
    )

  def test_link_omitted_without_execution_id(self):
    event = pipeline_event("STARTED")
    del event["detail"]["execution-id"]
    self.assertEqual(self.post(event)["text"], "Pipeline example-app-staging-ecs-service-app STARTED")

  def test_link_omitted_without_region(self):
    event = pipeline_event("STARTED")
    del event["region"]
    self.assertEqual(self.post(event)["text"], "Pipeline example-app-staging-ecs-service-app STARTED")


class UnchangedMessageTest(SlackPostTestCase):
  def test_alarm_ok_is_good(self):
    attachment = self.post({"AlarmName": "Test alarm", "NewStateValue": "OK", "NewStateReason": "Testing"})
    self.assertEqual(attachment, {"text": "Test alarm state is now OK:\n Testing", "color": "good"})

  def test_alarm_alarm_is_danger(self):
    attachment = self.post({"AlarmName": "Test alarm", "NewStateValue": "ALARM", "NewStateReason": "Testing"})
    self.assertEqual(attachment["color"], "danger")

  def test_plain_message(self):
    with mock.patch.object(function, "urlopen") as urlopen:
      function.lambda_handler({"Records": [{"Sns": {"Message": "hello"}}]}, None)
    attachment = json.loads(urlopen.call_args.args[0].data)["attachments"][0]
    self.assertEqual(attachment, {"text": "hello", "color": "good"})


class PackagingTest(unittest.TestCase):
  def test_no_bytecode_next_to_function(self):
    self.assertFalse((FUNCTION_DIR / "__pycache__").exists())


if __name__ == "__main__":
  unittest.main()
