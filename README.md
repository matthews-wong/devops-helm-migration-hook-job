# devops-helm-migration-hook-job

A small Helm chart that runs a database migration as a `pre-install` / `pre-upgrade`
hook Job before the application Deployment rolls out.

The point is the hook plumbing, not the app: ordering via hook weights, cleanup via
delete policies, and a Job that cannot hang a release forever.

## Layout

    chart/    the Helm chart (app Deployment + Service + migration hook)
    tests/    render assertions run by `make validate`

## Usage

    helm upgrade --install demo chart -n demo --create-namespace \
      --set database.existingSecret=demo-db

The migration reads `DATABASE_URL` from the key named by `database.secretKey` in an
existing Secret. The chart never creates credentials.

## Validate

    make validate
