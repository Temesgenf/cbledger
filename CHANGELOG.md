# Changelog

## 1.5.0 - 2026-10-20

- Deposits and transfers that would overflow a balance are rejected (reasons
  12 and 13) instead of wrapping around.
- Transactions dated before the account was opened are rejected (14).
- Repeated or out-of-order sequence numbers are rejected (15).
- An invalid `LEDGER_RUN_DATE` stops the run with RC 12.
- The report no longer cuts off balances of 100 million and over, and shows
  how many accounts are frozen or closed.
- The program is rebuilt when the Makefile changes.

## 1.4.0 - 2026-06-19

- `--version`.
- Transactions dated after the run date are rejected (reason 11).

## 1.3.0 - 2026-02-20

- Clear error and RC 12 when the account or transaction file is missing, or
  when the master is not in ascending order.
- Blank lines in the transaction file are ignored.
- Transfers into frozen or closed accounts are rejected.
- Interest is no longer credited to frozen or closed accounts.
- Account lookup is a binary search (`SEARCH ALL`).
- The report lists rejects by reason.
- `make check`, a Dockerfile and `docs/DESIGN.md`.

## 1.2.0 - 2021-07-06

- `accounts.csv` is written next to the other outputs.

## 1.1.0 - 2021-04-07

- Balances are signed and accounts carry an overdraft limit.
  **The account master layout changed**, see `docs/FILE-FORMATS.md`.
- `make run`, GitHub Actions build and an `.editorconfig`.
- Account table raised from 500 to 1000 entries.

## 1.0.0 - 2019-10-08

- Account status (active, frozen, closed) with matching reject codes.
- `--interest` run mode with tiered monthly interest on savings accounts.
- Control totals: opening balance plus deposits and interest minus debits must
  equal the closing balance, otherwise the run ends with RC 8.
- Report shows status, interest posted and the control totals.

## 0.2.0 - 2019-02-15

- Transfers between accounts (`T`) and monthly fees (`F`).
- Date validation, including leap years.
- Audit log of every applied and rejected transaction.
- Account list report with totals per account type.
- Reject unknown transaction types and zero amounts.

## 0.1.0 - 2018-07-18

- Load the account master into memory.
- Apply deposits and withdrawals; refuse withdrawals that exceed the balance.
- Write rejected transactions with a reason code to `rejects.dat`.
- Write the updated master to `accounts.new`.
- Regression test runner (`make test`).
