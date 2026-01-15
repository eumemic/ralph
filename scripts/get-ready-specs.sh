#!/bin/bash
# get-ready-specs.sh - List spec files with status: READY
#
# Usage: get-ready-specs.sh [specs_dir]
#
# Returns one file path per line for specs that have "status: READY" in frontmatter.
# Specs without a status field or with other statuses (DRAFT, COMPLETE) are excluded.

SPECS_DIR="${1:-.}"

# Find all .md files except _TEMPLATE.md and check for READY status
for file in "$SPECS_DIR"/*.md; do
    [ -f "$file" ] || continue
    [[ "$(basename "$file")" == "_TEMPLATE.md" ]] && continue

    # Check if file has "status: READY" in the first 10 lines (frontmatter)
    if head -10 "$file" | grep -q '^status: READY'; then
        echo "$file"
    fi
done
