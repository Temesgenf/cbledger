# File formats

All files are LINE SEQUENTIAL text with fixed-width fields and no delimiters.
Amounts have two implied decimal places and no decimal point, so `00000012550`
is 125.50.

## accounts.dat

One line per account, strictly ascending by account id (the run stops
with RC 12 otherwise, lookups are a binary search). Layout is in `copy/ACCTREC.cpy`.

| Cols  | Field        | Notes                            |
|-------|--------------|----------------------------------|
| 1-8   | account id   | numeric                          |
| 9-28  | name         | left justified                   |
| 29    | type         | `C` checking, `S` savings        |
| 30    | status       | `A` active, `F` frozen, `C` closed |
| 31-42 | balance      | sign (`+`/`-`) then 9(9)V99      |
| 43-51 | overdraft    | 9(7)V99, zeros for no overdraft  |
| 52-59 | open date    | YYYYMMDD                         |

## trans.dat

One line per transaction, processed in file order. Layout is in
`copy/TRANREC.cpy`.

| Cols  | Field        | Notes                                        |
|-------|--------------|----------------------------------------------|
| 1-6   | sequence     | assigned by the upstream feed                |
| 7-14  | date         | YYYYMMDD                                     |
| 15    | type         | `D` deposit, `W` withdrawal, `T` transfer, `F` fee |
| 16-23 | account id   |                                              |
| 24-31 | target       | zeros unless a transfer                      |
| 32-42 | amount       | 9(9)V99                                      |
| 43-62 | memo         | free text                                    |

## rejects.dat

The rejected transaction followed by a two character reason code
(see `copy/RETCODES.cpy`).

| Code | Meaning                         |
|------|---------------------------------|
| 01   | unknown account                 |
| 02   | insufficient funds              |
| 03   | account is frozen               |
| 04   | account is closed               |
| 05   | unknown transaction type        |
| 06   | invalid date                    |
| 07   | zero amount                     |
| 08   | transfer to the same account    |
| 09   | transfer target does not exist  |

## audit.log

One line per transaction: date, sequence, type, account, amount and either
`OK` or `REJECT nn`.

## accounts.csv

The final account table for spreadsheets, with a header row. Names that
contain a comma are wrapped in double quotes. Balances use a decimal point.
