#!/bin/sh
# Regression tests: run the ledger over every case in tests/cases and compare
# everything it writes with the case's expected/ directory.
#
#   tests/run_tests.sh            compare
#   tests/run_tests.sh --update   regenerate expected/ (review the diff!)

cd "$(dirname "$0")/.." || exit 1

BIN=
for b in bin/ledger.exe bin/ledger; do
    if [ -f "$b" ]; then BIN=$b; break; fi
done
if [ -z "$BIN" ]; then
    echo "bin/ledger not built, run make first" >&2
    exit 1
fi

pass=0
fail=0
for dir in tests/cases/*/; do
    dir=${dir%/}
    name=$(basename "$dir")
    out="out/test/$name"
    rm -rf "$out"
    mkdir -p "$out"
    args=
    if [ -f "$dir/args" ]; then args=$(cat "$dir/args"); fi
    run_date=20180831
    if [ -f "$dir/run_date" ]; then run_date=$(cat "$dir/run_date"); fi
    LEDGER_DATA="$dir" LEDGER_OUT="$out" LEDGER_RUN_DATE="$run_date" \
        "./$BIN" $args > "$out/console.txt" 2>&1
    echo $? > "$out/rc.txt"
    for f in "$out"/*; do
        tr -d '\r' < "$f" > "$f.tmp" && mv "$f.tmp" "$f"
    done
    if [ "$1" = "--update" ]; then
        rm -rf "$dir/expected"
        mkdir "$dir/expected"
        cp "$out"/* "$dir/expected/"
        echo "updated $name"
        continue
    fi
    if diff -r "$dir/expected" "$out" > "$out.diff"; then
        pass=$((pass + 1))
    else
        fail=$((fail + 1))
        echo "FAIL $name"
        cat "$out.diff"
    fi
done

echo "$pass passed, $fail failed"
[ "$fail" -eq 0 ]
