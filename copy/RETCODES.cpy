      * RETCODES - REASON CODES WRITTEN TO THE REJECT FILE.
       01  REJECT-CODES.
           05  RC-NO-ACCOUNT    PIC XX VALUE "01".
           05  RC-NO-FUNDS      PIC XX VALUE "02".
           05  RC-NO-TARGET     PIC XX VALUE "09".
           05  RC-SAME-ACCOUNT  PIC XX VALUE "08".
           05  RC-BAD-DATE      PIC XX VALUE "06".
           05  RC-BAD-TYPE      PIC XX VALUE "05".
           05  RC-ZERO-AMOUNT   PIC XX VALUE "07".
           05  RC-FROZEN        PIC XX VALUE "03".
           05  RC-CLOSED        PIC XX VALUE "04".
           05  RC-OVER-LIMIT    PIC XX VALUE "10".
           05  RC-FUTURE-DATE   PIC XX VALUE "11".
           05  RC-OVERFLOW      PIC XX VALUE "12".
           05  RC-TARGET-FULL   PIC XX VALUE "13".
