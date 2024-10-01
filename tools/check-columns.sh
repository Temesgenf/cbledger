#!/bin/sh
# Fixed-format COBOL ignores everything past column 72, so a longer line is
# silently truncated by the compiler. Fail if any source line is too long.

cd "$(dirname "$0")/.." || exit 1

status=0
for f in src/*.cbl copy/*.cpy; do
    awk -v max=72 'length($0) > max {
        printf "%s:%d: %d columns\n", FILENAME, FNR, length($0)
        bad = 1
    }
    END { exit bad }' "$f" || status=1
done
exit $status
