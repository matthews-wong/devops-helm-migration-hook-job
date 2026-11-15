CHART := chart
VALUES := $(CHART)/values-example.yaml

.PHONY: validate lint render hook-test

validate: lint render hook-test

lint:
	helm lint $(CHART) -f $(VALUES)

render:
	helm template t $(CHART) -f $(VALUES) | kubeconform -strict -summary

hook-test:
	tests/hook_ordering.sh
