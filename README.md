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

Return codes:

| RC | Meaning                                              |
|----|------------------------------------------------------|
| 0  | clean run                                            |
| 4  | at least one transaction was rejected                |
| 8  | closing balances do not reconcile with the movements |
| 12 | a file is missing or the master is unsorted          |

Every run writes `rejects.dat`, `accounts.new`, `audit.log` and `ledger.rpt`
to the output directory.

## Overdrafts

A withdrawal or fee is refused (reason 02) when it is larger than the balance
plus the account's overdraft limit. Balances are signed, so an overdrawn
account shows a negative balance on the report.

## Tests

    make test    # regression cases in tests/cases
    make check   # 72 column limit
    make demo    # run on data/ and print the report

See `docs/FILE-FORMATS.md` for the record layouts.
