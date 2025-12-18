resource "aws_iam_instance_profile" "jenkins_agent" {
  name = "inventory-jenkins-agent-profile"

  lifecycle {
    ignore_changes = [role]
  }
}
