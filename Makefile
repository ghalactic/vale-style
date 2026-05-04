VALE := vale
VALE_FLAGS := --config=testdata/.vale.ini --output=JSON

.PHONY: test test-pass test-fail lint

test: test-pass test-fail

test-pass:
	@echo "==> Testing pass fixtures (expecting zero errors)..."
	@$(VALE) $(VALE_FLAGS) testdata/pass/ || \
		(echo "FAIL: pass fixtures produced errors" && exit 1)
	@echo "PASS: all pass fixtures are clean"

test-fail:
	@echo "==> Testing fail fixtures (expecting specific errors)..."
	@fail=0; \
	for file in testdata/fail/*.md; do \
		expected=$$(sed -n 's/^<!-- expect: \(.*\) -->/\1/p' "$$file" | head -1); \
		if [ -z "$$expected" ]; then \
			echo "SKIP: $$file (no expect comment)"; \
			continue; \
		fi; \
		output=$$($(VALE) $(VALE_FLAGS) "$$file" 2>&1 || true); \
		IFS=', ' read -ra rules <<< "$$expected"; \
		for rule in "$${rules[@]}"; do \
			if ! echo "$$output" | grep -q "\"$$rule\""; then \
				echo "FAIL: $$file - expected $$rule not found"; \
				fail=1; \
			fi; \
		done; \
	done; \
	if [ "$$fail" -eq 1 ]; then exit 1; fi
	@echo "PASS: all fail fixtures triggered expected rules"

lint:
	@$(VALE) --config=.vale.ini README.md CHANGELOG.md
