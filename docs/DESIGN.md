# Design

`LEDGER` is a single batch step. It reads the whole account master into a
table (`copy/ACCTTBL.cpy`), applies the day's transactions to the table, and
writes everything out again. Nothing is updated in place, the inputs are never
touched.

## Programs

| Program    | Called for                                           |
|------------|------------------------------------------------------|
| `LEDGER`   | main program, file handling, validation and posting  |
| `DATEUTIL` | is this YYYYMMDD a real date                         |
| `INTCALC`  | one month of tiered interest for a balance           |
| `AUDITLOG` | opens, writes and closes `audit.log`                 |
| `RPTWRT`   | `ledger.rpt`                                         |
| `CSVEXP`   | `accounts.csv`                                       |

All of them are linked into one executable, see the `Makefile`.

## Flow of a transaction

1. `VALIDATE-TRANSACTION` looks up the account and picks the first reason to
   refuse it. The order of the `WHEN` clauses is the order of precedence.
2. `POST-TRANSACTION` moves the money. Transfers look up the target before
   touching the source, otherwise a rejected transfer would still debit.
3. Applied transactions are counted and audited, rejected ones go to
   `rejects.dat` with the reason code and to the audit log.

## Control totals

Opening balances plus deposits plus interest minus debits must equal the
closing balances. Transfers net to zero and do not appear. A mismatch is a bug
in the posting code and ends the run with RC 8.

## Why tables and not an indexed file

The branch masters are a few hundred accounts. Reading everything into memory
keeps the code simple and makes the run repeatable: run it twice on the same
inputs and you get the same outputs.
