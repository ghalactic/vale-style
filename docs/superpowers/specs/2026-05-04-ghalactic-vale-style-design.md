# Ghalactic Vale style — design spec

## Overview

Implement a comprehensive Vale style package called "Ghalactic" that enforces
the Google developer documentation style guide. The style replaces the current
placeholder rule with ~27 real rules covering word choice, voice/tone, grammar,
punctuation, headings, accessibility/inclusion, numbers/dates, and readability.

## Design decisions

### Severity

All rules use `error` level. Writers suppress false positives with Vale's inline
comment mechanism:

```markdown
<!-- vale Ghalactic.RuleName = NO -->

Suppressed content.

<!-- vale Ghalactic.RuleName = YES -->
```

This gives maximum strictness with an explicit opt-out.

### Organization

All rule files live directly in `Ghalactic/` (flat layout, standard for Vale
packages). No subdirectories.

### Fix actions

Rules include automated fix suggestions (Vale "actions") wherever possible —
primarily for substitution rules and some existence rules.

### Scope

Faithfully follows the Google developer style guide except for guidance that
only applies to first-party Google products (e.g., word list entries about
Google-specific products are excluded).

## Rule inventory

### Word list & terminology

| File                | Type         | Purpose                                                                            |
| ------------------- | ------------ | ---------------------------------------------------------------------------------- |
| `WordList.yml`      | substitution | ~94 "not recommended" → preferred term swaps from the Google style guide word list |
| `Abbreviations.yml` | substitution | `e.g.` → "for example", `i.e.` → "that is", `etc.` flagged                         |

### Voice & tone

| File              | Type            | Purpose                                                           |
| ----------------- | --------------- | ----------------------------------------------------------------- |
| `Please.yml`      | existence       | Flags "please" in instructions                                    |
| `Simply.yml`      | existence       | Flags "simply", "easy", "easily", "just", "quickly" in procedures |
| `Exclamation.yml` | existence (raw) | Flags exclamation marks outside code                              |
| `WeOur.yml`       | existence       | Flags first-person "we", "our", "us" addressing the reader        |
| `Passive.yml`     | existence (raw) | Common passive voice patterns (be + past participle)              |
| `Will.yml`        | existence       | Unnecessary future tense "will"                                   |
| `Slang.yml`       | existence       | Internet slang: "tl;dr", "ymmv", "RTFM"                           |

### Grammar

| File               | Type         | Purpose                                                             |
| ------------------ | ------------ | ------------------------------------------------------------------- |
| `Gender.yml`       | existence    | Gendered pronouns used generically (he/she, him/her, his/hers)      |
| `Contractions.yml` | substitution | Suggests contractions: "do not" → "don't", "cannot" → "can't", etc. |
| `Would.yml`        | existence    | Hypothetical "would"                                                |

### Punctuation

| File              | Type            | Purpose                                               |
| ----------------- | --------------- | ----------------------------------------------------- |
| `OxfordComma.yml` | existence (raw) | Missing serial comma before "and"/"or" in lists       |
| `EnDash.yml`      | existence       | En dash character (–) → use em dash (—) or hyphen (-) |
| `Ellipsis.yml`    | existence       | Ellipsis character (…) → use three periods (...)      |
| `CurlyQuotes.yml` | existence       | Curly quotes (" " ' ') → straight quotes (" ')        |
| `Ampersand.yml`   | existence (raw) | `&` used as "and" in prose (outside code)             |

### Headings

| File                        | Type            | Purpose                                         |
| --------------------------- | --------------- | ----------------------------------------------- |
| `HeadingSentenceCase.yml`   | capitalization  | Enforces sentence case in headings              |
| `HeadingEndPunctuation.yml` | existence (raw) | Flags periods/colons at end of headings         |
| `HeadingGerund.yml`         | existence (raw) | Flags -ing verb forms as first word of headings |

### Accessibility & inclusion

| File              | Type         | Purpose                                                                                        |
| ----------------- | ------------ | ---------------------------------------------------------------------------------------------- |
| `Ableist.yml`     | existence    | "sanity check", "crazy", "cripple", "dumb", "blind to", etc.                                   |
| `Inclusive.yml`   | substitution | "blacklist" → "denylist", "whitelist" → "allowlist", "master" → "primary", "slave" → "replica" |
| `Directional.yml` | existence    | "above", "below", "right-hand side" for positional references                                  |

### Numbers & dates

| File                  | Type            | Purpose                                              |
| --------------------- | --------------- | ---------------------------------------------------- |
| `OrdinalNumerals.yml` | existence       | Flags "1st", "2nd", "3rd", etc. → spell out ordinals |
| `Seasons.yml`         | existence       | Flags season names used as time references           |
| `DateFormat.yml`      | existence (raw) | Flags ambiguous slash-based dates (MM/DD/YYYY)       |

### Readability

| File                 | Type       | Purpose                                |
| -------------------- | ---------- | -------------------------------------- |
| `ReadingLevel.yml`   | metric     | Flesch-Kincaid grade level (flags > 8) |
| `SentenceLength.yml` | occurrence | Flags sentences > 40 words             |
| `Repetition.yml`     | repetition | Repeated consecutive words ("the the") |

## Test infrastructure

### Directory structure

```
testdata/
├── pass/                  # Files that must lint clean (zero errors)
│   ├── clean.md
│   └── suppressed.md     # Demonstrates inline suppression
├── fail/                  # Files that must trigger specific rules
│   ├── word-list.md
│   ├── voice-tone.md
│   ├── grammar.md
│   ├── punctuation.md
│   ├── headings.md
│   ├── accessibility.md
│   ├── numbers-dates.md
│   └── readability.md
└── .vale.ini             # Points to local Ghalactic/ style
```

### Test Vale config

```ini
StylesPath = ..
MinAlertLevel = error

[*]
BasedOnStyles = Ghalactic
```

### Test assertion format

Each `testdata/fail/` file declares expected rules in a comment header:

```markdown
<!-- expect: Ghalactic.WordList, Ghalactic.Abbreviations -->
```

The test runner parses this header, runs Vale with JSON output, and asserts all
expected rule names appear in the results.

### Makefile

Targets:

- `make test` — runs `test-pass` and `test-fail`
- `make test-pass` — `vale testdata/pass/` asserts exit code 0
- `make test-fail` — for each file in `testdata/fail/`, parses expected rules
  from the `<!-- expect: ... -->` comment, runs Vale, asserts expected rule
  names are present in JSON output
- `make lint` — runs Vale on repo documentation (README.md, CHANGELOG.md)

### CI workflow

File: `.github/workflows/test.yml`

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

## Word list filtering

The Google style guide word list contains 597 entries. For the `WordList.yml`
substitution rule, we include only entries where:

1. `recommendation` is `"not recommended"`
2. `use_instead` is not null (provides a concrete alternative)
3. The term is not Google-product-specific

This yields approximately 94 swap entries. Terms marked "use with care" are not
included (they require contextual judgment beyond what Vale can assess).

## Files to create/modify

### New files

- `Ghalactic/*.yml` — 27 rule files (replacing Placeholder.yml)
- `testdata/.vale.ini`
- `testdata/pass/*.md`
- `testdata/fail/*.md`
- `Makefile`
- `.github/workflows/test.yml`
- `.vale.ini` (root, for linting repo docs)

### Modified files

- `Ghalactic/Placeholder.yml` — deleted
- `README.md` — updated with rule documentation
- `CHANGELOG.md` — updated with release notes

## Constraints

- **No external Vale styles as reference.** Do not use any pre-existing Vale
  style packages as a reference for how or what to implement. All rules are
  authored from scratch based on the Google developer style guide skills.
- **No external Vale packages.** Do not install any external Vale packages via
  `vale sync`. The style is entirely self-contained.

## Out of scope

- Rules from `google-developer-style-guide-images-media` (HTML structure checks
  not enforceable in prose linting)
- Rules from `google-developer-style-guide-api-code-reference` (applies to
  source code comments, not Markdown docs)
- Google-product-specific word list entries
