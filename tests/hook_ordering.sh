#!/usr/bin/env bash
# Asserts the migration hook is wired so a release cannot hang or leak objects.
set -euo pipefail

CHART=chart
VALUES=$CHART/values-example.yaml

fail() { echo "FAIL: $*" >&2; exit 1; }

job=$(helm template t "$CHART" -f "$VALUES" --show-only templates/migration-job.yaml)
cm=$(helm template t "$CHART" -f "$VALUES" --show-only templates/migration-configmap.yaml)

grep -q 'helm.sh/hook: pre-install,pre-upgrade' <<<"$job" || fail "job is not a pre-install,pre-upgrade hook"
grep -q 'helm.sh/hook-delete-policy: before-hook-creation' <<<"$job" || fail "job lacks before-hook-creation"
grep -q 'activeDeadlineSeconds:' <<<"$job" || fail "job has no activeDeadlineSeconds"
grep -q 'restartPolicy: Never' <<<"$job" || fail "job must use restartPolicy Never"

job_w=$(sed -n 's/.*hook-weight: "\(-\?[0-9]*\)".*/\1/p' <<<"$job")
cm_w=$(sed -n 's/.*hook-weight: "\(-\?[0-9]*\)".*/\1/p' <<<"$cm")
[ "$cm_w" -lt "$job_w" ] || fail "script ConfigMap weight ($cm_w) must be below job weight ($job_w)"

# The Deployment must not itself be a hook, or it would run before its own migration.
dep=$(helm template t "$CHART" -f "$VALUES" --show-only templates/deployment.yaml)
grep -q 'helm.sh/hook' <<<"$dep" && fail "Deployment is annotated as a hook"

if helm template t "$CHART" >/dev/null 2>&1; then
  fail "chart rendered without database.existingSecret"
fi
echo "hook ordering: ok"
