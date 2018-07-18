# Changelog

## 0.1.0 - 2018-07-18

- Load the account master into memory.
- Apply deposits and withdrawals; refuse withdrawals that exceed the balance.
- Write rejected transactions with a reason code to `rejects.dat`.
- Write the updated master to `accounts.new`.
- Regression test runner (`make test`).
