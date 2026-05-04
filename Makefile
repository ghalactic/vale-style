VALE := vale
VALE_FLAGS := --config=testdata/.vale.ini --no-wrap

FIXTURES := $(wildcard testdata/pass/*.md testdata/fail/*.md)

.PHONY: test test-snapshots update-snapshots lint

test: test-snapshots

test-snapshots:
	@fail=0; \
	for file in $(FIXTURES); do \
		snap="$${file%.md}.expected.txt"; \
		if [ ! -f "$$snap" ]; then \
			echo "FAIL: missing snapshot $$snap"; \
			fail=1; \
			continue; \
		fi; \
		actual=$$($(VALE) $(VALE_FLAGS) "$$file" 2>&1 | sed 's/\x1b\[[0-9;]*m//g'); \
		expected=$$(cat "$$snap"); \
		if [ "$$actual" != "$$expected" ]; then \
			echo "FAIL: $$file output differs from snapshot"; \
			echo "Expected:"; \
			cat "$$snap"; \
			echo "Actual:"; \
			echo "$$actual"; \
			echo ""; \
			fail=1; \
		fi; \
	done; \
	if [ "$$fail" -eq 1 ]; then exit 1; fi
	@echo "PASS: all snapshots match"

update-snapshots:
	@for file in $(FIXTURES); do \
		snap="$${file%.md}.expected.txt"; \
		$(VALE) $(VALE_FLAGS) "$$file" 2>&1 | sed 's/\x1b\[[0-9;]*m//g' > "$$snap"; \
		echo "Updated $$snap"; \
	done

lint:
	@$(VALE) --config=.vale.ini README.md CHANGELOG.md
