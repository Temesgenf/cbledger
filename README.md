# cbledger

A small batch ledger written in COBOL. It reads an account master file and a
file of daily transactions, applies them, and writes the new master plus a
list of rejected transactions.

## Building

Needs [GnuCOBOL](https://gnucobol.sourceforge.io/) 2.2 or later.

    make

## Running

    mkdir -p out
    bin/ledger

By default the program reads `data/accounts.dat` and `data/trans.dat` and
writes to `out/`. Set `LEDGER_DATA` and `LEDGER_OUT` to use other directories.

## Monthly interest

    bin/ledger --interest

Credits one month of interest to every savings account instead of processing
transactions. The annual rate depends on the balance: 0.50% under 1,000,
1.00% under 10,000 and 1.50% above that.

The return code is 0 for a clean run, 4 if any transaction was rejected and 12
if the run could not complete.

## Tests

    make test

See `docs/FILE-FORMATS.md` for the record layouts.
