gcloud run deploy api-service-01 \
  --image=us-docker.pkg.dev/project/repo/api-service:$COMMIT_SHA \
  --region=asia-southeast1 \
  --platform=managed \
  --no-traffic  # optional: for canary
  --quiet

  gcloud run deploy YOUR_SERVICE \
  --image=YOUR_IMAGE \
  --vpc-egress=private-ranges-only \  # or omit this line
  --network=sample-vpc \
  --subnet=gke-primary \  # or management, whichever has enough IPs
  --region=asia-southeast1

  gcloud run deploy nginx-direct-vpc2 --image=nginx:latest  --cpu=1  --memory=512Mi  --min-instances=0 --max-instances=2 --vpc-egress=private-ranges-only --no-cpu-always-allocated 

    # module.cloudrun["nginx-direct-vpc"].google_cloud_run_service_iam_member.public_access[0] will be destroyed
  # (because module.cloudrun["nginx-direct-vpc"] is not in configuration)
  - resource "google_cloud_run_service_iam_member" "public_access" {
      - etag     = "BwZHBDbt13Y=" -> null
      - id       = "v1/projects/test-482612/locations/asia-southeast1/services/nginx-direct-vpc/roles/run.invoker/allUsers" -> null    
      - location = "asia-southeast1" -> null
      - member   = "allUsers" -> null
      - project  = "test-482612" -> null
      - role     = "roles/run.invoker" -> null
      - service  = "v1/projects/test-482612/locations/asia-southeast1/services/nginx-direct-vpc" -> null
    }

  # module.cloudrun["nginx-direct-vpc"].google_cloud_run_v2_service.service will be destroyed
  # (because module.cloudrun["nginx-direct-vpc"] is not in configuration)
  - resource "google_cloud_run_v2_service" "service" {
      - annotations             = {} -> null
      - conditions              = [
          - {
              - last_transition_time = "2025-12-28T15:01:28.347713Z"
              - state                = "CONDITION_SUCCEEDED"
              - type                 = "RoutesReady"
                # (5 unchanged attributes hidden)
            },
          - {
              - last_transition_time = "2025-12-28T15:01:27.096288Z"
              - state                = "CONDITION_SUCCEEDED"
              - type                 = "ConfigurationsReady"
                # (5 unchanged attributes hidden)
            },
        ] -> null
      - create_time             = "2025-12-28T14:47:43.926307Z" -> null
      - creator                 = "dtu951@gmail.com" -> null
      - custom_audiences        = [] -> null
      - effective_annotations   = {} -> null
      - effective_labels        = {} -> null
      - etag                    = "\"CL6MxcoGEOD5s9ID/cHJvamVjdHMvdGVzdC00ODI2MTIvbG9jYXRpb25zL2FzaWEtc291dGhlYXN0MS9zZXJ2aWNlcy9uZ2lueC1kaXJlY3QtdnBj\"" -> null
      - generation              = "3" -> null
      - id                      = "projects/test-482612/locations/asia-southeast1/services/nginx-direct-vpc" -> null
      - ingress                 = "INGRESS_TRAFFIC_ALL" -> null
      - labels                  = {} -> null
      - last_modifier           = "dtu951@gmail.com" -> null
      - latest_created_revision = "projects/test-482612/locations/asia-southeast1/services/nginx-direct-vpc/revisions/nginx-direct-vpc-00003-w9k" -> null
      - latest_ready_revision   = "projects/test-482612/locations/asia-southeast1/services/nginx-direct-vpc/revisions/nginx-direct-vpc-00003-w9k" -> null
      - launch_stage            = "GA" -> null
      - location                = "asia-southeast1" -> null
      - name                    = "nginx-direct-vpc" -> null
      - observed_generation     = "3" -> null
      - project                 = "test-482612" -> null
      - reconciling             = false -> null
      - terminal_condition      = [
          - {
              - last_transition_time = "2025-12-28T15:01:28.379144Z"
              - state                = "CONDITION_SUCCEEDED"
              - type                 = "Ready"
                # (5 unchanged attributes hidden)
            },
        ] -> null
      - terraform_labels        = {} -> null
      - traffic_statuses        = [
          - {
              - percent  = 100
              - type     = "TRAFFIC_TARGET_ALLOCATION_TYPE_LATEST"
                # (3 unchanged attributes hidden)
            },
        ] -> null
      - uid                     = "526a2ea2-9aec-444b-9f47-c37f62053918" -> null
      - update_time             = "2025-12-28T15:01:18.978124Z" -> null
      - uri                     = "https://nginx-direct-vpc-xm3ipgbd7q-as.a.run.app" -> null
        # (5 unchanged attributes hidden)

      - template {
          - annotations                      = {} -> null
          - labels                           = {} -> null
          - max_instance_request_concurrency = 80 -> null
          - service_account                  = "cloudrun-sa@test-482612.iam.gserviceaccount.com" -> null
          - session_affinity                 = false -> null
          - timeout                          = "300s" -> null
            # (3 unchanged attributes hidden)

          - containers {
              - args        = [] -> null
              - command     = [] -> null
              - depends_on  = [] -> null
              - image       = "nginx:latest" -> null
                name        = null
                # (1 unchanged attribute hidden)

              - ports {
                  - container_port = 80 -> null
                  - name           = "http1" -> null
                }

              - resources {
                  - cpu_idle          = false -> null
                  - limits            = {
                      - "cpu"    = "1"
                      - "memory" = "512Mi"
                    } -> null
                  - startup_cpu_boost = false -> null
                }

              - startup_probe {
                  - failure_threshold     = 1 -> null
                  - initial_delay_seconds = 0 -> null
                  - period_seconds        = 240 -> null
                  - timeout_seconds       = 240 -> null

                  - tcp_socket {
                      - port = 80 -> null
                    }
                }
            }

          - scaling {
              - max_instance_count = 2 -> null
              - min_instance_count = 0 -> null
            }

          - vpc_access {
              - egress    = "PRIVATE_RANGES_ONLY" -> null
                # (1 unchanged attribute hidden)

              - network_interfaces {
                  - network    = "projects/test-482612/global/networks/sample-vpc" -> null
                  - subnetwork = "projects/test-482612/regions/asia-southeast1/subnetworks/cloudrun" -> null
                  - tags       = [] -> null
                }
            }
        }

      - traffic {
          - percent  = 100 -> null
          - type     = "TRAFFIC_TARGET_ALLOCATION_TYPE_LATEST" -> null
            # (2 unchanged attributes hidden)
        }
    }