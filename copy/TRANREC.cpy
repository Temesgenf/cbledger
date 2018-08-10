      * TRANREC - TRANSACTION RECORD, ONE LINE PER TRANSACTION.
      * TRAN-TARGET IS ONLY USED BY TRANSFERS, ZEROS OTHERWISE.
       01  TRAN-REC.
           05  TRAN-SEQ         PIC 9(6).
           05  TRAN-DATE        PIC 9(8).
           05  TRAN-TYPE        PIC X.
               88  TRAN-DEPOSIT    VALUE "D".
               88  TRAN-WITHDRAW   VALUE "W".
               88  TRAN-TRANSFER   VALUE "T".
           05  TRAN-ACCT        PIC 9(8).
           05  TRAN-TARGET      PIC 9(8).
           05  TRAN-AMOUNT      PIC 9(9)V99.
           05  TRAN-MEMO        PIC X(20).
