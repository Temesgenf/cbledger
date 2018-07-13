# File formats

All files are LINE SEQUENTIAL text with fixed-width fields and no delimiters.
Amounts have two implied decimal places and no decimal point, so `00000012550`
is 125.50.

## accounts.dat

One line per account, ascending by account id. Layout is in `copy/ACCTREC.cpy`.

| Cols  | Field        | Notes                      |
|-------|--------------|----------------------------|
| 1-8   | account id   | numeric                    |
| 9-28  | name         | left justified             |
| 29    | type         | `C` checking, `S` savings  |
| 30-40 | balance      | 9(9)V99                    |
| 41-48 | open date    | YYYYMMDD                   |

## trans.dat

One line per transaction, processed in file order. Layout is in
`copy/TRANREC.cpy`.

| Cols  | Field        | Notes                          |
|-------|--------------|--------------------------------|
| 1-6   | sequence     | assigned by the upstream feed  |
| 7-14  | date         | YYYYMMDD                       |
| 15    | type         | `D` deposit, `W` withdrawal    |
| 16-23 | account id   |                                |
| 24-31 | target       | zeros unless a transfer        |
| 32-42 | amount       | 9(9)V99                        |
| 43-62 | memo         | free text                      |

## rejects.dat

The rejected transaction followed by a two character reason code
(see `copy/RETCODES.cpy`).

| Code | Meaning              |
|------|----------------------|
| 01   | unknown account      |
| 02   | insufficient funds   |
