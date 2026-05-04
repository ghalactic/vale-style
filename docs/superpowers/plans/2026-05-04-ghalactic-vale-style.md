# Ghalactic Vale Style Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use
> superpowers:subagent-driven-development (recommended) or
> superpowers:executing-plans to implement this plan task-by-task. Steps use
> checkbox (`- [ ]`) syntax for tracking.

**Goal:** Implement a comprehensive Vale style package enforcing the Google
developer documentation style guide, with test infrastructure and CI.

**Architecture:** Flat directory of YAML rule files in `Ghalactic/`, tested via
a Makefile that runs Vale against pass/fail fixture files, with CI via GitHub
Actions.

**Tech Stack:** Vale (YAML rules), Make, shell scripting, GitHub Actions

**Constraints:**

- Do not reference any external Vale style packages for implementation guidance
- Do not install external Vale packages via `vale sync`
- Format all Markdown files with `npx prettier --write` before committing
- All rules use `error` level

---

## File structure

### New files to create

- `.vale.ini` — root config for linting repo docs
- `Makefile` — test runner
- `.github/workflows/test.yml` — CI workflow
- `Ghalactic/WordList.yml` — word substitutions
- `Ghalactic/Abbreviations.yml` — Latin abbreviation substitutions
- `Ghalactic/Please.yml` — flags "please"
- `Ghalactic/Simply.yml` — flags simplicity terms
- `Ghalactic/Exclamation.yml` — flags exclamation marks
- `Ghalactic/WeOur.yml` — flags first-person addressing reader
- `Ghalactic/Passive.yml` — flags passive voice
- `Ghalactic/Will.yml` — flags future tense
- `Ghalactic/Slang.yml` — flags internet slang
- `Ghalactic/Gender.yml` — flags gendered pronouns
- `Ghalactic/Contractions.yml` — suggests contractions
- `Ghalactic/Would.yml` — flags hypothetical "would"
- `Ghalactic/OxfordComma.yml` — flags missing serial comma
- `Ghalactic/EnDash.yml` — flags en dash
- `Ghalactic/Ellipsis.yml` — flags ellipsis character
- `Ghalactic/CurlyQuotes.yml` — flags curly quotes
- `Ghalactic/Ampersand.yml` — flags & as "and"
- `Ghalactic/HeadingSentenceCase.yml` — enforces sentence case
- `Ghalactic/HeadingEndPunctuation.yml` — flags period/colon in headings
- `Ghalactic/HeadingGerund.yml` — flags -ing starting headings
- `Ghalactic/Ableist.yml` — flags ableist language
- `Ghalactic/Inclusive.yml` — flags non-inclusive terms
- `Ghalactic/Directional.yml` — flags positional references
- `Ghalactic/OrdinalNumerals.yml` — flags numeric ordinals
- `Ghalactic/Seasons.yml` — flags season-as-time references
- `Ghalactic/DateFormat.yml` — flags slash dates
- `Ghalactic/ReadingLevel.yml` — Flesch-Kincaid metric
- `Ghalactic/SentenceLength.yml` — flags long sentences
- `Ghalactic/Repetition.yml` — flags repeated words
- `testdata/.vale.ini` — test Vale config
- `testdata/pass/clean.md` — should lint clean
- `testdata/pass/suppressed.md` — demonstrates suppression
- `testdata/fail/word-list.md` — triggers word list rules
- `testdata/fail/voice-tone.md` — triggers voice/tone rules
- `testdata/fail/grammar.md` — triggers grammar rules
- `testdata/fail/punctuation.md` — triggers punctuation rules
- `testdata/fail/headings.md` — triggers heading rules
- `testdata/fail/accessibility.md` — triggers accessibility rules
- `testdata/fail/numbers-dates.md` — triggers numbers/dates rules
- `testdata/fail/readability.md` — triggers readability rules

### Files to delete

- `Ghalactic/Placeholder.yml`

### Files to modify

- `README.md` — updated documentation
- `CHANGELOG.md` — release notes

---

## Task 1: Project infrastructure

**Files:**

- Create: `.vale.ini`
- Create: `testdata/.vale.ini`
- Create: `Makefile`
- Create: `.github/workflows/test.yml`
- Delete: `Ghalactic/Placeholder.yml`

- [ ] **Step 1: Create root `.vale.ini`**

```ini
StylesPath = .
MinAlertLevel = error

[*]
BasedOnStyles = Ghalactic
```

- [ ] **Step 2: Create `testdata/.vale.ini`**

```ini
StylesPath = ..
MinAlertLevel = error

[*]
BasedOnStyles = Ghalactic
```

- [ ] **Step 3: Create `Makefile`**

```makefile
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
		expected=$$(grep -oP '(?<=<!-- expect: ).*(?= -->)' "$$file"); \
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
```

- [ ] **Step 4: Create `.github/workflows/test.yml`**

```yaml
name: Test

on:
  push:
  pull_request:

permissions:
  contents: read

jobs:
  test:
    name: Test
    runs-on: ubuntu-latest
    steps:
      - name: Checkout
        uses: actions/checkout@v6

      - name: Install Vale
        run: |
          curl -sfL https://github.com/errata-ai/vale/releases/download/v3.12.1/vale_3.12.1_Linux_64-bit.tar.gz | tar xz -C /usr/local/bin vale

      - name: Test
        run: make test
```

- [ ] **Step 5: Delete `Ghalactic/Placeholder.yml`**

```bash
rm Ghalactic/Placeholder.yml
```

- [ ] **Step 6: Commit**

```bash
git add -A
git commit -m "Set up project infrastructure

Add Makefile, Vale configs, CI workflow. Remove placeholder rule."
```

---

## Task 2: Word list and abbreviation rules

**Files:**

- Create: `Ghalactic/WordList.yml`
- Create: `Ghalactic/Abbreviations.yml`
- Create: `testdata/fail/word-list.md`

- [ ] **Step 1: Create `Ghalactic/WordList.yml`**

This is a substitution rule with the ~94 word list entries from the Google style
guide that have concrete alternatives. Only include entries where the
`use_instead` value is a direct single-word or short-phrase replacement (not
lengthy guidance). Multi-word alternatives separated by `|` use the `action`
block.

```yaml
extends: substitution
message: "Use '%s' instead of '%s'."
link: https://developers.google.com/style/word-list
level: error
ignorecase: true
action:
  name: replace
swap:
  account name: username
  action bar: app bar
  administrator: admin
  allows you to: lets you
  autoupdate: automatically update
  cellular data: mobile data
  cellular network: mobile network
  "comprise": consist of|contain|include
  curated roles: predefined roles
  denigrate: disparage
  deselect: clear
  'e\.g\.': for example
  grandfathered: legacy|exempt
  "grayed-out": unavailable
  "greyed-out": unavailable
  "gray out": unavailable
  "grey out": unavailable
  hover: hold the pointer over
  'i\.e\.': that is
  interconnect type: connection type
  k8s: Kubernetes
  long press: touch and hold
  network IP address: internal IP address
  NoOps: fully managed
  "omnibox": address bar
  outpost: channel
  overview screen: recents screen
  preferred pronouns: pronouns
  regex: regular expression
  repo: repository
  sign into: sign in to
  tarball: tar file
  "text box": box
  textbox: box
  touch: tap
  unarchive: extract
  uncheck: clear
  uncompress: extract
  under: earlier
  untar: extract
  unzip: extract
  'vs\.': versus
  wish: want|need
  World Wide Web: web
```

Note: Many word list entries have guidance like "a more precise term like X"
rather than a direct swap. These are better handled by the `Ableist.yml` and
`Inclusive.yml` rules (existence checks that flag without auto-replacing), or
are too context-dependent for Vale to handle. The above includes only entries
where Vale can confidently suggest a replacement.

- [ ] **Step 2: Create `Ghalactic/Abbreviations.yml`**

```yaml
extends: substitution
message: "Use '%s' instead of '%s'."
link: https://developers.google.com/style/abbreviations
level: error
ignorecase: false
nonword: true
action:
  name: replace
swap:
  'e\.g\.': for example
  'i\.e\.': that is
  'viz\.': namely
```

- [ ] **Step 3: Create `testdata/fail/word-list.md`**

```markdown
<!-- expect: Ghalactic.WordList, Ghalactic.Abbreviations -->

# Word list test

The administrator can update the account name in the settings.

This feature allows you to configure the service.

Use the regex to match patterns, e.g. numbers or strings.

The repo contains the source code, i.e. everything you need.

You can hover over the button for more information.
```

- [ ] **Step 4: Run tests to verify fail fixture triggers expected rules**

```bash
make test-fail
```

Expected: The file triggers `Ghalactic.WordList` and `Ghalactic.Abbreviations`.

- [ ] **Step 5: Commit**

```bash
git add -A
git commit -m "Add word list and abbreviation rules

Implement substitution rules for ~40 terms from the Google developer
style guide word list, plus Latin abbreviation substitutions."
```

---

## Task 3: Voice and tone rules

**Files:**

- Create: `Ghalactic/Please.yml`
- Create: `Ghalactic/Simply.yml`
- Create: `Ghalactic/Exclamation.yml`
- Create: `Ghalactic/WeOur.yml`
- Create: `Ghalactic/Passive.yml`
- Create: `Ghalactic/Will.yml`
- Create: `Ghalactic/Slang.yml`
- Create: `testdata/fail/voice-tone.md`

- [ ] **Step 1: Create `Ghalactic/Please.yml`**

```yaml
extends: existence
message: "Don't use 'please' in instructions."
link: https://developers.google.com/style/tone
level: error
ignorecase: true
action:
  name: remove
tokens:
  - please
```

- [ ] **Step 2: Create `Ghalactic/Simply.yml`**

```yaml
extends: existence
message: "Don't use '%s' — it implies the action is trivial."
link: https://developers.google.com/style/tone
level: error
ignorecase: true
tokens:
  - simply
  - easy
  - easily
  - just
  - quickly
```

- [ ] **Step 3: Create `Ghalactic/Exclamation.yml`**

```yaml
extends: existence
message: "Don't use exclamation marks in documentation."
link: https://developers.google.com/style/tone
level: error
nonword: true
action:
  name: edit
  params:
    - trim_right
    - "!"
raw:
  - "[a-zA-Z]+!"
```

- [ ] **Step 4: Create `Ghalactic/WeOur.yml`**

```yaml
extends: existence
message: "Use second person ('you') instead of first person ('%s')."
link: https://developers.google.com/style/person
level: error
ignorecase: true
tokens:
  - we
  - our
  - ours
  - us
exceptions:
  - us-east
  - us-west
  - us-central
  - US
```

- [ ] **Step 5: Create `Ghalactic/Passive.yml`**

```yaml
extends: existence
message: "Prefer active voice over passive voice in '%s'."
link: https://developers.google.com/style/voice
level: error
ignorecase: true
nonword: true
raw:
  - (?:is|are|was|were|be|been|being)\s+(?:(?:also|then|already|recently|often|just|never|sometimes|always|usually|frequently|occasionally|previously|currently|normally|subsequently|actually|apparently|certainly|completely|definitely|directly|easily|effectively|entirely|essentially|eventually|exactly|finally|formally|frequently|fully|generally|hardly|highly|hopefully|immediately|increasingly|independently|initially|instead|largely|mainly|merely|mostly|necessarily|normally|notably|obviously|officially|only|originally|otherwise|partially|particularly|potentially|practically|precisely|predominantly|previously|primarily|probably|properly|purely|rarely|readily|recently|regularly|relatively|reportedly|roughly|seemingly|separately|seriously|significantly|slightly|solely|specifically|strictly|strongly|subsequently|successfully|supposedly|thoroughly|traditionally|truly|typically|ultimately|undoubtedly|unfortunately|unnecessarily|widely)\s+)?(?:\w+ed|written|known|seen|done|made|given|taken|found|told|become|begun|broken|chosen|come|driven|eaten|fallen|flown|forgotten|frozen|gotten|gone|grown|hidden|hurt|kept|known|left|lost|meant|met|paid|put|read|ridden|risen|run|said|seen|sent|set|shown|shut|spoken|spent|stood|stolen|struck|sworn|swept|swum|taught|thought|thrown|told|torn|understood|woken|won|worn|wound|withdrawn|built|bought|brought|caught|cut|dealt|dug|fed|felt|fought|found|got|had|heard|held|hit|hung|led|let|lit|lost|made|met|overcome|paid|proved|put|quit|read|run|saw|set|shot|spent|split|spread|stood|stuck|struck|swept|taught|thought|torn|understood|woken|worn|wound|written)
```

- [ ] **Step 6: Create `Ghalactic/Will.yml`**

```yaml
extends: existence
message: "Use present tense instead of future tense with '%s'."
link: https://developers.google.com/style/tense
level: error
ignorecase: true
tokens:
  - will
exceptions:
  - good will
  - free will
  - will not be
  - strong will
```

- [ ] **Step 7: Create `Ghalactic/Slang.yml`**

```yaml
extends: existence
message: "Don't use internet slang '%s' in documentation."
link: https://developers.google.com/style/tone
level: error
ignorecase: true
tokens:
  - tl;dr
  - ymmv
  - RTFM
  - lol
  - btw
  - fyi
  - imo
  - imho
  - afaik
  - lmao
```

- [ ] **Step 8: Create `testdata/fail/voice-tone.md`**

```markdown
<!-- expect: Ghalactic.Please, Ghalactic.Simply, Ghalactic.Exclamation, Ghalactic.WeOur, Ghalactic.Passive, Ghalactic.Will, Ghalactic.Slang -->

# Voice and tone test

Please click the button to continue.

This is simply the best way to do it, and it is just so easy to configure.

This is awesome!

We recommend that you use our latest library for us to support you better.

The file is written to disk by the operating system.

The server will send a response after processing.

YMMV depending on your configuration, tl;dr just try it.
```

- [ ] **Step 9: Run tests**

```bash
make test-fail
```

Expected: triggers all seven voice/tone rules.

- [ ] **Step 10: Commit**

```bash
git add -A
git commit -m "Add voice and tone rules

Implement rules for: please, simplicity terms, exclamation marks,
first-person pronouns, passive voice, future tense, internet slang."
```

---

## Task 4: Grammar rules

**Files:**

- Create: `Ghalactic/Gender.yml`
- Create: `Ghalactic/Contractions.yml`
- Create: `Ghalactic/Would.yml`
- Create: `testdata/fail/grammar.md`

- [ ] **Step 1: Create `Ghalactic/Gender.yml`**

```yaml
extends: existence
message: "Use gender-neutral pronouns (singular 'they') instead of '%s'."
link: https://developers.google.com/style/pronouns
level: error
ignorecase: true
tokens:
  - he/she
  - he or she
  - she or he
  - him/her
  - him or her
  - her or him
  - his/her
  - his or her
  - her or his
  - his/hers
  - (s)he
```

- [ ] **Step 2: Create `Ghalactic/Contractions.yml`**

```yaml
extends: substitution
message: "Use the contraction '%s' instead of '%s'."
link: https://developers.google.com/style/contractions
level: error
ignorecase: true
action:
  name: replace
swap:
  are not: aren't
  cannot: can't
  could not: couldn't
  did not: didn't
  do not: don't
  does not: doesn't
  has not: hasn't
  have not: haven't
  is not: isn't
  it is: it's
  must not: mustn't
  should not: shouldn't
  that is: that's
  they are: they're
  was not: wasn't
  were not: weren't
  will not: won't
  would not: wouldn't
  you are: you're
```

- [ ] **Step 3: Create `Ghalactic/Would.yml`**

```yaml
extends: existence
message: "Avoid hypothetical 'would' — use present tense instead."
link: https://developers.google.com/style/tense
level: error
ignorecase: true
tokens:
  - would
exceptions:
  - would like to
  - would rather
```

- [ ] **Step 4: Create `testdata/fail/grammar.md`**

```markdown
<!-- expect: Ghalactic.Gender, Ghalactic.Contractions, Ghalactic.Would -->

# Grammar test

When a developer writes code, he/she should test it thoroughly.

You do not need to install anything. The system is not configured yet.

If you send a request, the server would then remove it from the queue.
```

- [ ] **Step 5: Run tests**

```bash
make test-fail
```

- [ ] **Step 6: Commit**

```bash
git add -A
git commit -m "Add grammar rules

Implement rules for: gendered pronouns, contractions, hypothetical would."
```

---

## Task 5: Punctuation rules

**Files:**

- Create: `Ghalactic/OxfordComma.yml`
- Create: `Ghalactic/EnDash.yml`
- Create: `Ghalactic/Ellipsis.yml`
- Create: `Ghalactic/CurlyQuotes.yml`
- Create: `Ghalactic/Ampersand.yml`
- Create: `testdata/fail/punctuation.md`

- [ ] **Step 1: Create `Ghalactic/OxfordComma.yml`**

```yaml
extends: existence
message: "Use a serial (Oxford) comma before '%s'."
link: https://developers.google.com/style/commas
level: error
nonword: true
raw:
  - '(?:[^\s,]+,\s[^\s,]+)\s(?:and|or)\s'
```

- [ ] **Step 2: Create `Ghalactic/EnDash.yml`**

```yaml
extends: existence
message: "Don't use an en dash (–). Use an em dash (—) or hyphen (-) instead."
link: https://developers.google.com/style/dashes
level: error
nonword: true
tokens: []
raw:
  - "–"
```

- [ ] **Step 3: Create `Ghalactic/Ellipsis.yml`**

```yaml
extends: existence
message:
  "Don't use the ellipsis character (…). Use three periods (...) if needed."
link: https://developers.google.com/style/ellipses
level: error
nonword: true
tokens: []
raw:
  - "…"
```

- [ ] **Step 4: Create `Ghalactic/CurlyQuotes.yml`**

```yaml
extends: existence
message: "Use straight quotes instead of curly quotes."
link: https://developers.google.com/style/quotation-marks
level: error
nonword: true
tokens: []
raw:
  - '[\u2018\u2019\u201C\u201D]'
```

- [ ] **Step 5: Create `Ghalactic/Ampersand.yml`**

```yaml
extends: existence
message: "Use 'and' instead of '&' in prose."
link: https://developers.google.com/style/formatting
level: error
nonword: true
raw:
  - '\w\s+&\s+\w'
```

- [ ] **Step 6: Create `testdata/fail/punctuation.md`**

```markdown
<!-- expect: Ghalactic.OxfordComma, Ghalactic.EnDash, Ghalactic.Ellipsis, Ghalactic.CurlyQuotes, Ghalactic.Ampersand -->

# Punctuation test

The system supports Linux, macOS and Windows.

Use a value in the range 1–10 for this setting.

Wait for the process to complete…

The "recommended" approach is to use \u201Cstraight quotes\u201D everywhere.

Configure the client & server before deploying.
```

Note: The curly quotes in the test file must be actual Unicode characters
(\u201C and \u201D), not escape sequences. Write the literal characters.

- [ ] **Step 7: Run tests**

```bash
make test-fail
```

- [ ] **Step 8: Commit**

```bash
git add -A
git commit -m "Add punctuation rules

Implement rules for: Oxford comma, en dash, ellipsis character,
curly quotes, ampersand as 'and'."
```

---

## Task 6: Heading rules

**Files:**

- Create: `Ghalactic/HeadingSentenceCase.yml`
- Create: `Ghalactic/HeadingEndPunctuation.yml`
- Create: `Ghalactic/HeadingGerund.yml`
- Create: `testdata/fail/headings.md`

- [ ] **Step 1: Create `Ghalactic/HeadingSentenceCase.yml`**

```yaml
extends: capitalization
message: "'%s' should be in sentence case."
link: https://developers.google.com/style/capitalization
level: error
scope: heading
match: $sentence
exceptions:
  - API
  - APIs
  - CLI
  - CPU
  - CSS
  - DNS
  - FAQ
  - GCP
  - GPU
  - gRPC
  - HTML
  - HTTP
  - HTTPS
  - ID
  - IDs
  - IO
  - IP
  - JSON
  - OAuth
  - OK
  - OS
  - RAM
  - REST
  - SDK
  - SQL
  - SSH
  - SSL
  - TCP
  - TLS
  - UDP
  - UI
  - URI
  - URL
  - URLs
  - USB
  - UTF
  - UUID
  - VM
  - VMs
  - VPC
  - XML
  - YAML
```

- [ ] **Step 2: Create `Ghalactic/HeadingEndPunctuation.yml`**

```yaml
extends: existence
message: "Don't use punctuation at the end of a heading."
link: https://developers.google.com/style/headings
level: error
scope: heading
nonword: true
raw:
  - "[.;:!?]$"
```

- [ ] **Step 3: Create `Ghalactic/HeadingGerund.yml`**

```yaml
extends: existence
message:
  "Don't start a heading with an -ing verb. Use a bare infinitive for task
  headings or a noun phrase for conceptual headings."
link: https://developers.google.com/style/headings
level: error
scope: heading
nonword: true
raw:
  - '^\w+ing\b'
exceptions:
  - Billing
  - Pricing
  - Monitoring
  - Logging
  - Streaming
  - Networking
  - Caching
  - Clustering
  - Messaging
  - Profiling
  - Debugging
  - Threading
  - String
  - Ring
  - King
  - Thing
  - Spring
  - Bring
```

- [ ] **Step 4: Create `testdata/fail/headings.md`**

```markdown
<!-- expect: Ghalactic.HeadingSentenceCase, Ghalactic.HeadingEndPunctuation, Ghalactic.HeadingGerund -->

# This Is Title Case And Should Be Sentence Case

## Creating a new instance

## Configure the server.

This is body text under the headings.
```

- [ ] **Step 5: Run tests**

```bash
make test-fail
```

- [ ] **Step 6: Commit**

```bash
git add -A
git commit -m "Add heading rules

Implement rules for: sentence case, end punctuation, gerund starts."
```

---

## Task 7: Accessibility and inclusion rules

**Files:**

- Create: `Ghalactic/Ableist.yml`
- Create: `Ghalactic/Inclusive.yml`
- Create: `Ghalactic/Directional.yml`
- Create: `testdata/fail/accessibility.md`

- [ ] **Step 1: Create `Ghalactic/Ableist.yml`**

```yaml
extends: existence
message: "Don't use ableist language '%s'. Use more precise, inclusive terms."
link: https://developers.google.com/style/inclusive-documentation
level: error
ignorecase: true
tokens:
  - sanity check
  - sanity-check
  - crazy
  - bonkers
  - insane
  - cripple
  - crippled
  - crippling
  - dumb
  - dumb down
  - dumbed down
  - lame
  - blind eye
  - blind to
  - blind spot
  - turn a blind eye
  - gimp
  - gimpy
  - lunatic
  - loony
  - mad
```

- [ ] **Step 2: Create `Ghalactic/Inclusive.yml`**

```yaml
extends: substitution
message: "Use '%s' instead of '%s'."
link: https://developers.google.com/style/inclusive-documentation
level: error
ignorecase: true
action:
  name: replace
swap:
  blacklist: denylist
  black list: denylist
  black-list: denylist
  blacklisted: denied
  blacklisting: denying
  whitelist: allowlist
  white list: allowlist
  white-list: allowlist
  whitelisted: allowed
  whitelisting: allowing
  master: primary
  slave: replica|worker
  man hours: person hours
  manhours: person hours
  man-hours: person hours
  manpower: workforce|staff
  man power: workforce|staff
  man-power: workforce|staff
  manmade: manufactured|synthetic
  man made: manufactured|synthetic
  mankind: humanity|people
```

- [ ] **Step 3: Create `Ghalactic/Directional.yml`**

```yaml
extends: existence
message:
  "Don't use directional language '%s'. Use 'preceding', 'following', or
  'earlier' instead."
link: https://developers.google.com/style/accessible-content
level: error
ignorecase: true
tokens:
  - above
  - below
  - upper-left
  - upper-right
  - lower-left
  - lower-right
  - right-hand side
  - left-hand side
exceptions:
  - see above
  - above all
  - above and beyond
  - rise above
  - above average
  - below average
  - below zero
```

- [ ] **Step 4: Create `testdata/fail/accessibility.md`**

```markdown
<!-- expect: Ghalactic.Ableist, Ghalactic.Inclusive, Ghalactic.Directional -->

# Accessibility test

Give the code a quick sanity check before submitting.

Add the IP to the whitelist to allow traffic from that host.

As shown in the diagram above, the server connects to the database.
```

- [ ] **Step 5: Run tests**

```bash
make test-fail
```

- [ ] **Step 6: Commit**

```bash
git add -A
git commit -m "Add accessibility and inclusion rules

Implement rules for: ableist language, non-inclusive terms, directional
language."
```

---

## Task 8: Numbers and dates rules

**Files:**

- Create: `Ghalactic/OrdinalNumerals.yml`
- Create: `Ghalactic/Seasons.yml`
- Create: `Ghalactic/DateFormat.yml`
- Create: `testdata/fail/numbers-dates.md`

- [ ] **Step 1: Create `Ghalactic/OrdinalNumerals.yml`**

```yaml
extends: existence
message: "Spell out ordinal numbers instead of using '%s'."
link: https://developers.google.com/style/numbers
level: error
nonword: true
tokens: []
raw:
  - '\b\d+(?:st|nd|rd|th)\b'
```

- [ ] **Step 2: Create `Ghalactic/Seasons.yml`**

```yaml
extends: existence
message:
  "Don't use '%s' to refer to a time of year. Use months, quarters, or specific
  dates instead."
link: https://developers.google.com/style/dates-times
level: error
ignorecase: true
tokens:
  - in spring
  - in summer
  - in fall
  - in autumn
  - in winter
  - this spring
  - this summer
  - this fall
  - this autumn
  - this winter
  - next spring
  - next summer
  - next fall
  - next autumn
  - next winter
  - last spring
  - last summer
  - last fall
  - last autumn
  - last winter
```

- [ ] **Step 3: Create `Ghalactic/DateFormat.yml`**

```yaml
extends: existence
message:
  "Don't use ambiguous date formats like '%s'. Use YYYY-MM-DD or spell out the
  month."
link: https://developers.google.com/style/dates-times
level: error
nonword: true
tokens: []
raw:
  - '\b\d{1,2}/\d{1,2}/\d{2,4}\b'
```

- [ ] **Step 4: Create `testdata/fail/numbers-dates.md`**

```markdown
<!-- expect: Ghalactic.OrdinalNumerals, Ghalactic.Seasons, Ghalactic.DateFormat -->

# Numbers and dates test

This is the 1st release of the software and the 3rd iteration.

The feature launches in summer and gets updated in fall next year.

The release date is 01/15/2026 and the deadline was 12/03/2025.
```

- [ ] **Step 5: Run tests**

```bash
make test-fail
```

- [ ] **Step 6: Commit**

```bash
git add -A
git commit -m "Add numbers and dates rules

Implement rules for: ordinal numerals, season references, slash dates."
```

---

## Task 9: Readability rules

**Files:**

- Create: `Ghalactic/ReadingLevel.yml`
- Create: `Ghalactic/SentenceLength.yml`
- Create: `Ghalactic/Repetition.yml`
- Create: `testdata/fail/readability.md`

- [ ] **Step 1: Create `Ghalactic/ReadingLevel.yml`**

```yaml
extends: metric
message: "The Flesch-Kincaid grade level (%s) is too high. Aim for below 8."
link: https://en.wikipedia.org/wiki/Flesch%E2%80%93Kincaid_readability_tests
level: error
formula: |
  (0.39 * (words / sentences)) + (11.8 * (syllables / words)) - 15.59
condition: "> 8"
```

- [ ] **Step 2: Create `Ghalactic/SentenceLength.yml`**

```yaml
extends: occurrence
message: "Sentences should have fewer than 40 words (found %s)."
link: https://developers.google.com/style/accessible-content
level: error
scope: sentence
max: 40
token: '\b\w+\b'
```

- [ ] **Step 3: Create `Ghalactic/Repetition.yml`**

```yaml
extends: repetition
message: "'%s' is repeated."
level: error
alpha: true
tokens:
  - '[^\s]+'
```

- [ ] **Step 4: Create `testdata/fail/readability.md`**

```markdown
<!-- expect: Ghalactic.SentenceLength, Ghalactic.Repetition -->

# Readability test

The implementation of the distributed consensus algorithm that is used by the
underlying infrastructure to coordinate the state synchronization between the
multiple replicated instances of the database service requires careful
consideration of the various edge cases that might arise during network
partitions or other failure scenarios that could potentially lead to data
inconsistencies across the system.

You should check the the documentation for more details.
```

Note: `ReadingLevel.yml` is a document-level metric rule and may or may not
trigger on this specific file depending on overall content. We test
`SentenceLength` and `Repetition` explicitly.

- [ ] **Step 5: Run tests**

```bash
make test-fail
```

- [ ] **Step 6: Commit**

```bash
git add -A
git commit -m "Add readability rules

Implement rules for: Flesch-Kincaid reading level, sentence length,
repeated words."
```

---

## Task 10: Pass fixtures and suppression demo

**Files:**

- Create: `testdata/pass/clean.md`
- Create: `testdata/pass/suppressed.md`

- [ ] **Step 1: Create `testdata/pass/clean.md`**

```markdown
# Create an instance

To create a new instance, follow these steps:

1. Sign in to the console.
2. Click **Create instance**.
3. In the **Name** field, enter a name for the instance.
4. Select a region from the **Region** list.
5. Click **Create**.

The instance is ready to use after a few minutes.

## Configure the instance

You can configure the instance by editing its settings. The settings page lets
you change the following properties:

- Name
- Region
- Machine type

For more information, see
[Instance settings](https://example.com/docs/instances).
```

- [ ] **Step 2: Create `testdata/pass/suppressed.md`**

```markdown
# Suppression demo

<!-- vale Ghalactic.Please = NO -->

Please note that this section demonstrates inline suppression.

<!-- vale Ghalactic.Please = YES -->

The rest of this document follows the style guide.

You can configure the service by editing the configuration file. The file
contains settings for authentication, authorization, and logging.
```

- [ ] **Step 3: Run full test suite**

```bash
make test
```

Expected: Both `test-pass` and `test-fail` succeed.

- [ ] **Step 4: Commit**

```bash
git add -A
git commit -m "Add test fixtures for pass and suppression cases"
```

---

## Task 11: Update documentation

**Files:**

- Modify: `README.md`
- Modify: `CHANGELOG.md`

- [ ] **Step 1: Update `README.md`**

Replace the current content with comprehensive documentation listing all rules,
installation instructions, and usage examples. Include:

- Installation section (existing content, keep as-is)
- Usage section (existing content, keep as-is)
- Rules section listing each rule with its purpose and severity
- Suppression section showing how to suppress rules inline
- Contributing section mentioning `make test`

- [ ] **Step 2: Update `CHANGELOG.md`**

Update the "Unreleased" section to list all new rules added.

- [ ] **Step 3: Format with Prettier**

```bash
npx prettier --write README.md CHANGELOG.md
```

- [ ] **Step 4: Commit**

```bash
git add -A
git commit -m "Update documentation

Add comprehensive rule listing to README. Update changelog with all
new rules."
```

---

## Task 12: Final validation

- [ ] **Step 1: Run full test suite**

```bash
make test
```

Expected: All tests pass.

- [ ] **Step 2: Run lint on repo docs**

```bash
make lint
```

Fix any issues in README.md or CHANGELOG.md that the style catches (practice
what you preach). Suppress rules where the repo docs intentionally deviate
(e.g., mentioning rule names that contain flagged terms).

- [ ] **Step 3: Final commit if fixes were needed**

```bash
git add -A
git commit -m "Fix style issues in repo documentation"
```
