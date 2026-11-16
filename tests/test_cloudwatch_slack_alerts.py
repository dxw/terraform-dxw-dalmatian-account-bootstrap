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
  def setUp(self):
    patcher = mock.patch.object(function, "pipeline_source_revision", return_value=None)
    self.source_revision = patcher.start()
    self.addCleanup(patcher.stop)

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

  def test_text_includes_commit_linked_to_revision_url(self):
    self.source_revision.return_value = {
      "revisionId": "0123456789abcdef0123456789abcdef01234567",
      "revisionSummary": json.dumps({"ProviderType": "GitHub", "CommitMessage": "Add widgets\n\nLonger body"}),
      "revisionUrl": "https://github.com/example/app/commit/0123456789abcdef0123456789abcdef01234567",
    }
    text = self.post(pipeline_event("STARTED"))["text"]
    self.assertEqual(
      text.split("\n")[1],
      "Commit <https://github.com/example/app/commit/0123456789abcdef0123456789abcdef01234567|0123456>: Add widgets",
    )
    self.source_revision.assert_called_once_with(
      "eu-west-2", "example-app-staging-ecs-service-app", "01234567-89ab-cdef-0123-456789abcdef", "STARTED"
    )

  def test_plain_revision_summary_is_used_as_is(self):
    self.source_revision.return_value = {"revisionId": "abcdef0123456789", "revisionSummary": "Fix the thing"}
    text = self.post(pipeline_event("SUCCEEDED"))["text"]
    self.assertEqual(text.split("\n")[1], "Commit abcdef0: Fix the thing")

  def test_commit_without_summary(self):
    self.source_revision.return_value = {"revisionId": "abcdef0123456789"}
    self.assertEqual(self.post(pipeline_event("SUCCEEDED"))["text"].split("\n")[1], "Commit abcdef0")

  def test_commit_message_and_revision_are_escaped(self):
    self.source_revision.return_value = {
      "revisionId": "<!here>",
      "revisionSummary": json.dumps({"CommitMessage": "bad <!channel> & <https://example.invalid|x>"}),
    }
    text = self.post(pipeline_event("SUCCEEDED"))["text"]
    self.assertEqual(text.split("\n")[1], "Commit &lt;!here&gt;: bad &lt;!channel&gt; &amp; &lt;https://example.invalid|x&gt;")

  def test_unsafe_revision_url_is_not_linked(self):
    for url in ("javascript:alert(1)", "https://example.invalid/a|b", "https://example.invalid/<!here>", "https://example.invalid/a b"):
      with self.subTest(url=url):
        self.source_revision.return_value = {"revisionId": "abcdef0123456789", "revisionUrl": url}
        self.assertEqual(self.post(pipeline_event("SUCCEEDED"))["text"].split("\n")[1], "Commit abcdef0")

  def connection_revision(self, provider, repository="example-org/example-app", commit="0123456789abcdef0123456789abcdef01234567"):
    return {
      "revisionId": commit,
      "revisionSummary": json.dumps({"ProviderType": provider, "CommitMessage": "Add widgets"}),
      "revisionUrl": "https://eu-west-2.console.aws.amazon.com/codesuite/settings/connections/redirect?"
                     "connectionArn=arn:aws:codestar-connections:eu-west-2:123456789012:connection/"
                     "00000000-0000-0000-0000-000000000000&referenceType=COMMIT"
                     "&FullRepositoryId=%s&Commit=%s" % (repository, commit),
    }

  def commit_line(self, revision):
    self.source_revision.return_value = revision
    return self.post(pipeline_event("SUCCEEDED"))["text"].split("\n")[1]

  def test_connection_commit_links_to_provider(self):
    sha = "0123456789abcdef0123456789abcdef01234567"
    expected = {
      "GitHub": "https://github.com/example-org/example-app/commit/%s" % sha,
      "GitHubEnterpriseServer": None,
      "Bitbucket": "https://bitbucket.org/example-org/example-app/commits/%s" % sha,
      "GitLab": "https://gitlab.com/example-org/example-app/-/commit/%s" % sha,
    }
    for provider, url in expected.items():
      with self.subTest(provider=provider):
        revision = self.connection_revision(provider)
        url = url or revision["revisionUrl"]
        self.assertEqual(self.commit_line(revision), "Commit <%s|0123456>: Add widgets" % url)

  def test_gitlab_subgroup_repository(self):
    revision = self.connection_revision("GitLab", repository="example-org/team/example-app")
    self.assertIn("<https://gitlab.com/example-org/team/example-app/-/commit/", self.commit_line(revision))

  def test_connection_link_kept_when_repository_or_commit_is_unexpected(self):
    for repository, commit in (("example-org/../evil", "0123456789abcdef"), ("evil.example", "0123456789abcdef"),
                               ("example-org/example-app", "not-a-sha"), ("example-org/example-app#x", "0123456789abcdef")):
      with self.subTest(repository=repository, commit=commit):
        revision = self.connection_revision("GitHub", repository=repository, commit=commit)
        self.assertNotIn("github.com", self.commit_line(revision))

  def test_connection_redirect_url_not_rewritten_without_provider(self):
    revision = self.connection_revision("GitHub")
    revision["revisionSummary"] = "Add widgets"
    self.assertIn("<%s|" % revision["revisionUrl"], self.commit_line(revision))

  def test_commit_lookup_skipped_without_execution_id(self):
    event = pipeline_event("STARTED")
    del event["detail"]["execution-id"]
    self.post(event)
    self.source_revision.assert_not_called()


class PipelineSourceRevisionTest(unittest.TestCase):
  def setUp(self):
    self.client = mock.Mock()
    boto3 = mock.Mock(client=mock.Mock(return_value=self.client))
    for name, value in (("boto3", boto3), ("sleep", mock.Mock())):
      patcher = mock.patch.object(function, name, value, create=True)
      patcher.start()
      self.addCleanup(patcher.stop)
    self.boto3 = boto3

  def execution(self, *revisions):
    return {"pipelineExecution": {"artifactRevisions": list(revisions)}}

  def lookup(self, state="SUCCEEDED"):
    return function.pipeline_source_revision("eu-west-2", "example-pipeline", "exec-1", state)

  def test_returns_first_artifact_revision(self):
    self.client.get_pipeline_execution.return_value = self.execution({"revisionId": "abc"}, {"revisionId": "def"})
    self.assertEqual(self.lookup(), {"revisionId": "abc"})
    self.boto3.client.assert_called_once_with("codepipeline", region_name="eu-west-2")
    self.client.get_pipeline_execution.assert_called_once_with(pipelineName="example-pipeline", pipelineExecutionId="exec-1")

  def test_started_waits_for_source_revision(self):
    self.client.get_pipeline_execution.side_effect = [self.execution(), self.execution(), self.execution({"revisionId": "abc"})]
    self.assertEqual(self.lookup("STARTED"), {"revisionId": "abc"})
    self.assertEqual(self.client.get_pipeline_execution.call_count, 3)

  def test_started_gives_up_after_bounded_attempts(self):
    self.client.get_pipeline_execution.return_value = self.execution()
    self.assertIsNone(self.lookup("STARTED"))
    self.assertEqual(self.client.get_pipeline_execution.call_count, function.SOURCE_REVISION_ATTEMPTS)

  def test_other_states_do_not_retry(self):
    self.client.get_pipeline_execution.return_value = self.execution()
    self.assertIsNone(self.lookup("FAILED"))
    self.client.get_pipeline_execution.assert_called_once()

  def test_api_error_returns_none(self):
    self.client.get_pipeline_execution.side_effect = Exception("AccessDenied")
    with self.assertLogs(function.logger, "WARNING"):
      self.assertIsNone(self.lookup())


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


ASG = "example-app-staging-infrastructure-ecs-cluster"
CLUSTER = "example-app-staging-infrastructure"
POLICY_CAUSE = (
  "At 2026-10-02T14:19:36Z a monitor alarm TargetTracking-%s-AlarmHigh-0000 in state ALARM "
  "triggered policy ECSManagedAutoScalingPolicy-0000 changing the desired capacity from 3 to 4.  "
  "At 2026-10-02T14:19:43Z an instance was started in response to a difference between desired "
  "and actual capacity, increasing the capacity from 3 to 4." % ASG
)


def asg_event(detail_type, **detail):
  base = {"AutoScalingGroupName": ASG, "EC2InstanceId": "i-0123456789abcdef0", "Cause": POLICY_CAUSE,
          "Description": "Launching a new EC2 instance: i-0123456789abcdef0", "StatusMessage": ""}
  base.update(detail)
  return {"detail-type": detail_type, "source": "aws.autoscaling", "region": "eu-west-2", "resources": [], "detail": base}


def alarm_state_change(alarm_name, state="ALARM"):
  return {
    "detail-type": "CloudWatch Alarm State Change",
    "source": "aws.cloudwatch",
    "resources": ["arn:aws:cloudwatch:eu-west-2:123456789012:alarm:%s" % alarm_name],
    "detail": {
      "alarmName": alarm_name,
      "state": {"value": state, "reason": "Threshold Crossed: 3 datapoints were greater than the threshold (300.0)."},
      "previousState": {"value": "OK"},
    },
  }


def placement_failure(resources):
  return {
    "detail-type": "ECS Service Action",
    "source": "aws.ecs",
    "resources": resources,
    "detail": {"eventType": "ERROR", "eventName": "SERVICE_TASK_PLACEMENT_FAILURE",
               "clusterArn": "arn:aws:ecs:eu-west-2:123456789012:cluster/%s" % CLUSTER, "reason": "RESOURCE:MEMORY"},
  }


class AutoscalingMessageTest(SlackPostTestCase):
  def test_service_scaling_out(self):
    event = alarm_state_change("TargetTracking-service/%s/app-AlarmHigh-5939402e-8bb6" % CLUSTER)
    self.assertEqual(self.post(event), {"text": "Service app (%s) scaling out" % CLUSTER, "color": "#439FE0"})

  def test_service_scaling_in(self):
    event = alarm_state_change("TargetTracking-service/%s/app-AlarmLow-d4821d4a-a176" % CLUSTER)
    self.assertEqual(self.post(event), {"text": "Service app (%s) scaling in" % CLUSTER, "color": "#9E9E9E"})

  def test_unrecognised_alarm_name_is_warning(self):
    self.assertEqual(self.post(alarm_state_change("some-other-alarm")),
                     {"text": "CloudWatch Alarm State Change", "color": "warning"})

  def test_alarm_name_parts_are_escaped(self):
    event = alarm_state_change("TargetTracking-service/<!here>/app-AlarmHigh-0000")
    self.assertEqual(self.post(event)["text"], "Service app (&lt;!here&gt;) scaling out")

  def test_unexpected_shape_of_known_type_is_warning(self):
    event = placement_failure([])
    event["detail"]["eventName"] = "SERVICE_STEADY_STATE"
    self.assertEqual(self.post(event), {"text": "ECS Service Action", "color": "warning"})



  def test_instance_launched(self):
    self.assertEqual(self.post(asg_event("EC2 Instance Launch Successful")),
                     {"text": "%s instances 3 \u2192 4 (launched i-0123456789abcdef0)" % ASG, "color": "#439FE0"})

  def test_instance_terminated(self):
    cause = POLICY_CAUSE.replace("from 3 to 4", "from 5 to 4")
    self.assertEqual(self.post(asg_event("EC2 Instance Terminate Successful", Cause=cause)),
                     {"text": "%s instances 5 \u2192 4 (terminated i-0123456789abcdef0)" % ASG, "color": "#9E9E9E"})

  def test_instance_cause_without_counts_falls_back_to_description(self):
    attachment = self.post(asg_event("EC2 Instance Launch Successful", Cause="At 2026-10-02T14:19:36Z a user request update"))
    self.assertEqual(attachment, {"text": "%s Launching a new EC2 instance: i-0123456789abcdef0" % ASG, "color": "#439FE0"})

  def test_launch_unsuccessful(self):
    attachment = self.post(asg_event("EC2 Instance Launch Unsuccessful", StatusMessage="We currently do not have sufficient capacity."))
    self.assertEqual(attachment, {"text": "%s launch failed: We currently do not have sufficient capacity." % ASG, "color": "danger"})

  def test_terminate_unsuccessful(self):
    attachment = self.post(asg_event("EC2 Instance Terminate Unsuccessful", StatusMessage="Instance not found"))
    self.assertEqual(attachment, {"text": "%s terminate failed: Instance not found" % ASG, "color": "danger"})

  def test_unsuccessful_status_message_is_escaped(self):
    attachment = self.post(asg_event("EC2 Instance Launch Unsuccessful", StatusMessage="bad <!channel> & <https://example.invalid|x>"))
    self.assertEqual(attachment["text"], "%s launch failed: bad &lt;!channel&gt; &amp; &lt;https://example.invalid|x&gt;" % ASG)

  def test_placement_failure(self):
    event = placement_failure(["arn:aws:ecs:eu-west-2:123456789012:service/%s/app" % CLUSTER])
    self.assertEqual(self.post(event), {"text": "Service app could not place tasks: RESOURCE:MEMORY", "color": "danger"})

  def test_placement_failure_without_resources(self):
    self.assertEqual(self.post(placement_failure([]))["text"], "Service unknown could not place tasks: RESOURCE:MEMORY")




  def test_instance_with_null_cause_falls_back_to_description(self):
    attachment = self.post(asg_event("EC2 Instance Launch Successful", Cause=None))
    self.assertEqual(attachment["text"], "%s Launching a new EC2 instance: i-0123456789abcdef0" % ASG)



class PackagingTest(unittest.TestCase):
  def test_no_bytecode_next_to_function(self):
    self.assertFalse((FUNCTION_DIR / "__pycache__").exists())


if __name__ == "__main__":
  unittest.main()
