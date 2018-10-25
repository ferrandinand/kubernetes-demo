resource "google_cloudbuild_trigger" "build_trigger" {
  project = "${var.project}"
  trigger_template {
    branch_name = "master"
    project = "${var.project}"
    repo_name   = "${var.repo_name}"
  }
  build {
    images = ["gcr.io/$PROJECT_ID/$REPO_NAME:$COMMIT_SHA", "gcr.io/$PROJECT_ID/$REPO_NAME:latest"]
    step {
      name = "gcr.io/cloud-builders/docker"
      args = "build -t gcr.io/$PROJECT_ID/$REPO_NAME:$COMMIT_SHA -t grc.io/$PROJECT_ID/$REPO_NAME:latest -f Dockerfile ."
    }
  }
}

resource "google_cloudbuild_trigger" "build_trigger_canary" {
  project = "${var.project}"
  trigger_template {
    branch_name = "canary"
    project = "${var.project}"
    repo_name   = "${var.repo_name}"
  }
  build {
    images = ["gcr.io/$PROJECT_ID/$REPO_NAME:canary"]
    tags = ["canary"]
    step {
      name = "gcr.io/cloud-builders/docker"
      args = "build -t gcr.io/$PROJECT_ID/$REPO_NAME:canary -f Dockerfile ."
    }
  }
}

