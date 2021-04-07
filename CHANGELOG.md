# Changelog

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
