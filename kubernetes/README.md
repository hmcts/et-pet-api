# API on local Kubernetes

Install shared services from the parent checkout:

```sh
bin/kubernetes ingress
bin/kubernetes postgres
bin/kubernetes azurite
bin/kubernetes support --build
```

From `systems/api`, run:

```sh
../../bin/kubernetes up
../../bin/kubernetes status
../../bin/kubernetes logs
```

Defaults select `orbstack`; `--context`, `--docker-context`, `--domain` and
`--https-port` work as documented in the parent Kubernetes README.
Use `up --build` to build the current checkout instead of using an existing
`et-full-system-servers-api:latest` image.

The health endpoint is <https://api.k8s.orb.local/health>. Separate web and
GoodJob deployments use the application's existing `run.sh` and
`run_queue_worker.sh`, both with `RAILS_ENV=production`. Every `up` first runs a
temporary `et-local-api-db-bootstrap` Job using the rendered web Deployment's
image and configuration. It creates the databases, runs schema/data migrations,
and seeds the primary database. Setup commands stop on failure, and Helm only
deploys after the Job succeeds. Web startup uses `DOCKER_STATE=migrate`, matching
production. The worker does not perform database setup. Charts are unchanged.

The bootstrap Job completes before either Deployment starts on a fresh install,
so the worker sees a migrated database. Job logs are printed by `up`; the Job is
retained for inspection for one day, or until the next `up` replaces it:

```sh
kubectl --context orbstack -n et-full-system logs job/et-local-api-db-bootstrap
kubectl --context orbstack -n et-full-system describe job et-local-api-db-bootstrap
```

Setup runs on every local `up`, so seeds must remain safe to rerun. This does not
stop existing pods during an upgrade; migration compatibility is still required.

Blob traffic uses the internal Azurite Service. Rails upload/download/delete
was verified against both configured containers. The parent initializes the
containers; the API does not run its Compose storage setup task.

Fake ACAS, CCD and Notify use the shared `fake-services` Service in the
infrastructure namespace. SMTP uses shared Mailpit; view mail at
<https://mail.k8s.orb.local/>. The local credentials match the bundled fake-service
defaults. ET1 uses the internal API Service URL. A captured single-claim replay
verified certificate retrieval, file storage, fake CCD export and confirmation
email delivery.

Worker logs:

```sh
kubectl --context orbstack -n et-full-system logs deployment/et-local-api-queue-worker --follow
```

Fake CCD document uploads use its public ingress at
`https://et-ccd.k8s.orb.local/document_store`, because fake CCD derives returned
document URLs from the upload request. This makes subsequent test/browser
downloads accessible outside the cluster. Other CCD API calls remain internal.
Adjust `CCD_DOCUMENT_STORE_BASE_URL` when changing the support ingress domain
or HTTPS port. API pods see a self-signed local ingress certificate, so these
local values set the existing `CCD_SSL_VERIFICATION=false` option for the CCD
client. Production values and global TLS verification are unchanged.
Existing exported records retain their old document URLs; submit a fresh claim
or re-export through admin to generate new URLs.
