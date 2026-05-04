# Ghalactic

A [Vale](https://vale.sh) style enforcing the
[Google developer documentation style guide](https://developers.google.com/style).

## Installation

Add the Ghalactic style to your `.vale.ini` configuration:

```ini
StylesPath = styles
MinAlertLevel = suggestion

Packages = https://github.com/ghalactic/vale-style/releases/latest/download/Ghalactic.zip

[*]
BasedOnStyles = Ghalactic
```

Then run:

```sh
vale sync
```

This downloads and installs the Ghalactic style into your `StylesPath`.

## Rules reference

<!-- vale Ghalactic.Abbreviations = NO -->
<!-- vale Ghalactic.Ampersand = NO -->
<!-- vale Ghalactic.Directional = NO -->
<!-- vale Ghalactic.OrdinalNumerals = NO -->
<!-- vale Ghalactic.Please = NO -->
<!-- vale Ghalactic.Simply = NO -->
<!-- vale Ghalactic.WeOur = NO -->
<!-- vale Ghalactic.Will = NO -->
<!-- vale Ghalactic.Would = NO -->

| Rule                  | Scope          | Description                                   |
| --------------------- | -------------- | --------------------------------------------- |
| Abbreviations         | substitution   | Expands abbreviations like e.g., i.e.         |
| Ableist               | existence      | Flags ableist language                        |
| Ampersand             | existence      | Flags & used as "and"                         |
| Contractions          | substitution   | Suggests contractions for formal phrases      |
| CurlyQuotes           | existence      | Flags curly/smart quotes                      |
| DateFormat            | existence      | Flags ambiguous date formats                  |
| Directional           | existence      | Flags directional language (above/below)      |
| Ellipsis              | existence      | Flags ellipsis character                      |
| EnDash                | existence      | Flags en dash character                       |
| Exclamation           | existence      | Flags exclamation marks                       |
| Gender                | existence      | Flags gendered pronouns                       |
| HeadingEndPunctuation | existence      | Flags punctuation at end of headings          |
| HeadingGerund         | existence      | Flags gerund-starting headings                |
| HeadingSentenceCase   | capitalization | Enforces sentence case in headings            |
| Inclusive             | substitution   | Suggests inclusive alternatives               |
| OrdinalNumerals       | existence      | Flags ordinal numbers (1st, 2nd)              |
| OxfordComma           | existence      | Flags missing serial comma                    |
| Passive               | existence      | Flags passive voice                           |
| Please                | existence      | Flags "please" in instructions                |
| ReadingLevel          | metric         | Enforces eighth-grade reading level           |
| Repetition            | repetition     | Flags repeated words in nearby sentences      |
| Seasons               | existence      | Flags seasonal time references                |
| SentenceLength        | occurrence     | Flags sentences over 40 words                 |
| Simply                | existence      | Flags minimizing words (simply, easily, just) |
| Slang                 | existence      | Flags internet slang                          |
| WeOur                 | existence      | Flags first-person pronouns (we/our/us)       |
| Will                  | existence      | Flags future tense                            |
| WordList              | substitution   | Google word list substitutions                |
| Would                 | existence      | Flags hypothetical language                   |

<!-- vale Ghalactic.Abbreviations = YES -->
<!-- vale Ghalactic.Ampersand = YES -->
<!-- vale Ghalactic.Directional = YES -->
<!-- vale Ghalactic.OrdinalNumerals = YES -->
<!-- vale Ghalactic.Please = YES -->
<!-- vale Ghalactic.Simply = YES -->
<!-- vale Ghalactic.WeOur = YES -->
<!-- vale Ghalactic.Will = YES -->
<!-- vale Ghalactic.Would = YES -->

## Configuration

### Enable the style

Enable Ghalactic for all files in your `.vale.ini`:

```ini
[*]
BasedOnStyles = Ghalactic
```

Or enable it for specific file types:

```ini
[*.md]
BasedOnStyles = Ghalactic

[*.rst]
BasedOnStyles = Ghalactic
```

### Inline suppression

You can suppress individual rules inline using Vale comments:

```markdown
<!-- vale Ghalactic.Exclamation = NO -->

This is amazing!

<!-- vale Ghalactic.Exclamation = YES -->
```

## Contribute

To run the test suite:

```sh
make test
```

<!-- vale Ghalactic.Passive = NO -->

This runs Vale against the test fixtures in `testdata/` and verifies the
expected output.

<!-- vale Ghalactic.Passive = YES -->
