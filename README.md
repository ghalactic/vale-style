# Ghalactic Vale style

[Vale] style configuration for Ghalactic.

[vale]: https://vale.sh

## Installation

Add the package to your `.vale.ini`:

```ini
Packages = https://github.com/ghalactic/vale-style/releases/download/<version>/Ghalactic.zip
```

Then run:

```sh
vale sync
```

## Usage

Enable the style in your `.vale.ini`:

```ini
[*]
BasedOnStyles = Ghalactic
```
