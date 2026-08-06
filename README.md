# Todo App — Workpay DevOps Assignment

Submitted by: Syed Muddassir

---

## Live URLs

| | |
|---|---|
| **Cloud Run URL** | https://todo-app-219904781419.us-central1.run.app |
| **GitHub Repository** | https://github.com/<your-username>/<your-repo> |
| **Successful Cloud Build run** | https://console.cloud.google.com/cloud-build/builds/<BUILD_ID>?project=workpay-01 |

---

## What was built

A full-stack Todo application (Node.js + Express + React + PostgreSQL) containerised with
Docker and deployed to Google Cloud Run, with a Cloud Build CI/CD pipeline and Terraform
managing the infrastructure.

---

## Task checklist

| Task | Done |
|---|---|
| Clone and run the sample app | ✓ |
| Write/improve Dockerfile, push image to Artifact Registry | ✓ |
| Deploy to Cloud Run, verify traffic | ✓ |
| Set up Cloud SQL (PostgreSQL, smallest instance) | ✓ |
| Connect app to database | ✓ |
| Push to own Git repository with README | ✓ |
| CI/CD via Cloud Build — push to main triggers build + deploy | ✓ |
| Manage resources with Terraform | ✓ |
| Restrict access, grant invoker to reviewers, curl proof | ✓ |

---

## Cloud SQL connection method

**Unix socket via Cloud SQL connector.**

Cloud Run mounts the Cloud SQL instance as a Unix socket at
`/cloudsql/workpay-01:us-central1:todo-db` when `--add-cloudsql-instances` is set on the
service. The app connects using that path as `POSTGRES_HOST` — no separate proxy binary or
public IP needed inside Cloud Run.

```bash
# How the Cloud Run service is configured
gcloud run services update todo-app \
  --region us-central1 \
  --set-env-vars "POSTGRES_HOST=/cloudsql/workpay-01:us-central1:todo-db" \
  --add-cloudsql-instances workpay-01:us-central1:todo-db
```

---

## Manual GCP steps done before Terraform

Everything else is managed by Terraform. These steps were done once via console/CLI:

1. Created GCP project `workpay-01`
2. Enabled APIs:
   - Cloud Run Admin API
   - Cloud Build API
   - Cloud SQL Admin API
   - Artifact Registry API
   - IAM API
3. Created a service account `devops-sa` for Cloud Build
4. Connected GitHub repository to Cloud Build via the console OAuth flow

---

## Terraform

Manages three resources as required:

| Resource | Terraform file |
|---|---|
| Artifact Registry repository | `terraform/artifact_registry.tf` |
| Cloud SQL instance + database + user | `terraform/cloudsql.tf` |
| Cloud Run service | `terraform/cloudrun.tf` |

```bash
cd terraform/
terraform init
terraform plan
terraform apply
```

State files (`terraform.tfstate`) are excluded from Git via `.gitignore`.

---

## CI/CD pipeline (Cloud Build)

`cloudbuild.yaml` at the repo root defines three steps triggered on every push to `main`:

```
Step 1 — docker build  →  tags image with $COMMIT_SHA and :latest
Step 2 — docker push   →  pushes both tags to Artifact Registry
Step 3 — gcloud run deploy  →  deploys new image to Cloud Run
```

No manual intervention needed after a push to `main`.

---

## Access restriction

The service was deployed with `--no-allow-unauthenticated`. Invoker access was granted to
both reviewer accounts:

```bash
gcloud run services add-iam-policy-binding todo-app \
  --region=us-central1 \
  --member="user:daniel.anim@myworkpay.com" \
  --role="roles/run.invoker"

gcloud run services add-iam-policy-binding todo-app \
  --region=us-central1 \
  --member="user:vm@myworkpay.com" \
  --role="roles/run.invoker"
```

### Anonymous request — blocked (403)

```bash
curl -i https://todo-app-219904781419.us-central1.run.app/health
```

```
HTTP/2 403
content-type: text/html; charset=UTF-8
<html><head><title>403 Forbidden</title>...
```

### Authenticated request — succeeds (200)

```bash
TOKEN=$(gcloud auth print-identity-token)
curl -i -H "Authorization: Bearer $TOKEN" \
  https://todo-app-219904781419.us-central1.run.app/health
```

```
HTTP/2 200
content-type: application/json
{"success":true,"message":"Server is healthy","timestamp":"..."}
```

### Database connection — `/health/db`

```bash
curl -H "Authorization: Bearer $TOKEN" \
  https://todo-app-219904781419.us-central1.run.app/health/db
```

```json
{"success":true,"message":"Database is healthy","timestamp":"..."}
```


## Architecture

```
GitHub (main branch)
        │  push
        ▼
Cloud Build  ──── docker build + push ──►  Artifact Registry
        │
        │  gcloud run deploy
        ▼
Cloud Run (todo-app)  ◄──── HTTPS ────  Browser / curl
        │
        │  Unix socket /cloudsql/...
        ▼
Cloud SQL (PostgreSQL 16, todo-db)
```

---

## Repository structure

```
├── src/
│   ├── client/          # React 19 frontend
│   └── server/          # Express 5 backend
│       ├── index.ts     # Entry point
│       ├── routes/      # API routes
│       └── database/    # PostgreSQL connection
├── Dockerfile           # Multi-stage production build
├── cloudbuild.yaml      # Cloud Build CI/CD pipeline
├── terraform/           # GCP infrastructure as code
├── compose.yml          # Local development with Docker Compose
├── README.md            # Full technical documentation
└── guide.md             # Step-by-step assignment walkthrough
```