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

Runs `helm lint`, renders the chart through `kubeconform -strict`, and runs
`tests/hook_ordering.sh`, which checks:

- the Job is a `pre-install,pre-upgrade` hook with a deadline and `restartPolicy: Never`
- the script ConfigMap hook has a lower weight than the Job, so it exists first
- the Deployment is not a hook
- rendering fails when `database.existingSecret` is unset

## Design notes

- `before-hook-creation,hook-succeeded` clears the old Job before each run and the new
  one after success. A failed Job is kept so its logs can be read.
- `activeDeadlineSeconds` bounds the hook. `helm upgrade --wait` still fails the release
  when the migration fails, leaving the old ReplicaSet serving.
- Hooks are not part of the release manifest, so `helm uninstall` leaves a failed Job
  behind; `ttlSecondsAfterFinished` removes it eventually.
- The migration image runs a script from a ConfigMap. Swap `migration.image` and
  `migration.script` for a real migrator.
