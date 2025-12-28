gcloud run deploy api-service-01 \
  --image=us-docker.pkg.dev/project/repo/api-service:$COMMIT_SHA \
  --region=asia-southeast1 \
  --platform=managed \
  --no-traffic  # optional: for canary
  --quiet