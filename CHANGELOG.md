# Changelog

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
