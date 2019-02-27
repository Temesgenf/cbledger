      * ACCTREC - ACCOUNT MASTER RECORD, ONE LINE PER ACCOUNT.
      * THE FILE IS KEPT IN ASCENDING ACCT-ID ORDER.
      * BALANCE HAS TWO IMPLIED DECIMAL PLACES.
       01  ACCT-REC.
           05  ACCT-ID          PIC 9(8).
           05  ACCT-NAME        PIC X(20).
           05  ACCT-TYPE        PIC X.
               88  ACCT-CHECKING VALUE "C".
               88  ACCT-SAVINGS  VALUE "S".
           05  ACCT-STATUS      PIC X.
               88  ACCT-ACTIVE   VALUE "A".
               88  ACCT-FROZEN   VALUE "F".
               88  ACCT-CLOSED   VALUE "C".
           05  ACCT-BALANCE     PIC 9(9)V99.
           05  ACCT-OPEN-DATE   PIC 9(8).
