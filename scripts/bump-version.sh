set -euo pipefail

# Reads the latest version from CHANGELOG.md headings and updates the
# package install URL in README.md to reference that specific tag.

version=$(grep -m1 '^## \[' CHANGELOG.md | sed 's/^## \[\([^]]*\)\].*/\1/')

if [[ -z "$version" ]]; then
  echo "error: could not find a version heading in CHANGELOG.md" >&2
  exit 1
fi

echo "Latest version: $version"

# Replace any /releases/.../download/ URL with the versioned one
sed -i '' -E \
  "s|/releases/[^/]+/download/Ghalactic\.zip|/releases/download/${version}/Ghalactic.zip|" \
  README.md

echo "Updated README.md install URL to $version"
