       IDENTIFICATION DIVISION.
       PROGRAM-ID. LEDGER.
      *
      * LEDGER - APPLY A BATCH OF TRANSACTIONS TO THE ACCOUNT MASTER.
      *
       ENVIRONMENT DIVISION.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
           SELECT ACCOUNT-FILE ASSIGN TO WS-ACCT-PATH
               ORGANIZATION IS LINE SEQUENTIAL
               FILE STATUS IS WS-ACCT-STATUS.
           SELECT TRANS-FILE ASSIGN TO WS-TRAN-PATH
               ORGANIZATION IS LINE SEQUENTIAL
               FILE STATUS IS WS-TRAN-STATUS.
           SELECT REJECT-FILE ASSIGN TO WS-REJ-PATH
               ORGANIZATION IS LINE SEQUENTIAL.
           SELECT NEWACCT-FILE ASSIGN TO WS-NEW-PATH
               ORGANIZATION IS LINE SEQUENTIAL.
       DATA DIVISION.
       FILE SECTION.
       FD  ACCOUNT-FILE.
           COPY ACCTREC.
       FD  TRANS-FILE.
           COPY TRANREC.
       FD  REJECT-FILE.
       01  REJECT-REC.
           05  REJ-TRAN         PIC X(62).
           05  REJ-CODE         PIC XX.
       FD  NEWACCT-FILE.
       01  NEWACCT-REC          PIC X(80).
       WORKING-STORAGE SECTION.
           COPY RETCODES.
           COPY STATS.
           COPY ACCTTBL.
       01  WS-DATA-DIR          PIC X(60).
       01  WS-OUT-DIR           PIC X(60).
       01  WS-ACCT-PATH         PIC X(100).
       01  WS-TRAN-PATH         PIC X(100).
       01  WS-REJ-PATH          PIC X(100).
       01  WS-NEW-PATH          PIC X(100).
       01  WS-REJECT-CODE       PIC XX.
       01  WS-ACCT-STATUS       PIC XX.
       01  WS-TRAN-STATUS       PIC XX.
       01  WS-FIND-ID           PIC 9(8).
       01  WS-FOUND-IX          PIC 9(4) COMP.
       01  WS-TX                PIC 9(4) COMP.
       01  WS-DATE-OK           PIC X.
           88  DATE-IS-VALID    VALUE "Y".
       01  WS-AUDIT-PATH        PIC X(100).
       01  WS-AUDIT-LINE        PIC X(100).
       01  WS-AUDIT-RESULT      PIC X(10).
       01  WS-AMT-EDIT          PIC Z(8)9.99.
       01  WS-RPT-PATH          PIC X(100).
       01  WS-RUN-DATE          PIC X(8).
       01  WS-RUN-DATE-N REDEFINES WS-RUN-DATE PIC 9(8).
       01  WS-CMDLINE           PIC X(40).
       01  WS-MODE-SW           PIC X VALUE "T".
           88  RUN-INTEREST     VALUE "I".
       01  WS-INTEREST          PIC 9(9)V99.
       01  WS-EXPECTED          PIC S9(11)V99.
       01  WS-AVAILABLE         PIC S9(10)V99.
       01  WS-CSV-PATH          PIC X(100).
       01  WS-WITHDRAW-LIMIT    PIC 9(9)V99 VALUE 10000.00.
       01  WS-MAX-BALANCE       PIC 9(9)V99 VALUE 999999999.99.
       01  WS-PREV-ID           PIC 9(8) VALUE 0.
       01  WS-LAST-SEQ          PIC 9(6) VALUE 0.
       01  WS-REASON-IX         PIC 99.
       01  WS-VERSION           PIC X(8) VALUE "1.5.0".
       01  WS-IX                PIC 9(4) COMP.
       01  WS-SWITCHES.
           05  WS-ACCT-EOF-SW   PIC X VALUE "N".
               88  WS-ACCT-EOF  VALUE "Y".
           05  WS-TRAN-EOF-SW   PIC X VALUE "N".
               88  WS-TRAN-EOF  VALUE "Y".
       PROCEDURE DIVISION.
       MAIN-LINE.
           PERFORM START-UP
           PERFORM LOAD-ACCOUNTS
           IF RUN-INTEREST
               PERFORM POST-INTEREST
           ELSE
               PERFORM PROCESS-TRANSACTIONS
           END-IF
           PERFORM WRITE-ACCOUNTS
           PERFORM FINISH
           STOP RUN.

       START-UP.
           MOVE 0 TO AT-COUNT
           INITIALIZE LEDGER-STATS
           PERFORM GET-DIRECTORIES
           PERFORM GET-OUT-DIR
           PERFORM GET-RUN-DATE
           PERFORM CHECK-RUN-DATE
           PERFORM GET-MODE
           PERFORM BUILD-PATHS
           CALL "AUDITLOG" USING "O" WS-AUDIT-PATH.

       GET-DIRECTORIES.
           MOVE SPACES TO WS-DATA-DIR
           ACCEPT WS-DATA-DIR FROM ENVIRONMENT "LEDGER_DATA"
           IF WS-DATA-DIR = SPACES
               MOVE "data" TO WS-DATA-DIR
           END-IF.

       GET-MODE.
           MOVE SPACES TO WS-CMDLINE
           ACCEPT WS-CMDLINE FROM COMMAND-LINE
           IF WS-CMDLINE (1:9) = "--version"
               DISPLAY "cbledger " FUNCTION TRIM(WS-VERSION)
               STOP RUN
           END-IF
           IF WS-CMDLINE (1:10) = "--interest"
               SET RUN-INTEREST TO TRUE
           END-IF.

       GET-OUT-DIR.
           MOVE SPACES TO WS-OUT-DIR
           ACCEPT WS-OUT-DIR FROM ENVIRONMENT "LEDGER_OUT"
           IF WS-OUT-DIR = SPACES
               MOVE "out" TO WS-OUT-DIR
           END-IF.

       GET-RUN-DATE.
           MOVE SPACES TO WS-RUN-DATE
           ACCEPT WS-RUN-DATE FROM ENVIRONMENT "LEDGER_RUN_DATE"
           IF WS-RUN-DATE = SPACES
               MOVE FUNCTION CURRENT-DATE (1:8) TO WS-RUN-DATE
           END-IF.

       CHECK-RUN-DATE.
           IF WS-RUN-DATE IS NOT NUMERIC
               MOVE "N" TO WS-DATE-OK
           ELSE
               CALL "DATEUTIL" USING WS-RUN-DATE WS-DATE-OK
           END-IF
           IF NOT DATE-IS-VALID
               DISPLAY "INVALID RUN DATE " WS-RUN-DATE
               MOVE 12 TO RETURN-CODE
               STOP RUN
           END-IF.

       BUILD-PATHS.
           MOVE SPACES TO WS-ACCT-PATH
           STRING FUNCTION TRIM(WS-DATA-DIR) "/accounts.dat"
               DELIMITED BY SIZE INTO WS-ACCT-PATH
           MOVE SPACES TO WS-TRAN-PATH
           STRING FUNCTION TRIM(WS-DATA-DIR) "/trans.dat"
               DELIMITED BY SIZE INTO WS-TRAN-PATH
           MOVE SPACES TO WS-REJ-PATH
           STRING FUNCTION TRIM(WS-OUT-DIR) "/rejects.dat"
               DELIMITED BY SIZE INTO WS-REJ-PATH
           MOVE SPACES TO WS-NEW-PATH
           STRING FUNCTION TRIM(WS-OUT-DIR) "/accounts.new"
               DELIMITED BY SIZE INTO WS-NEW-PATH
           MOVE SPACES TO WS-AUDIT-PATH
           STRING FUNCTION TRIM(WS-OUT-DIR) "/audit.log"
               DELIMITED BY SIZE INTO WS-AUDIT-PATH
           MOVE SPACES TO WS-RPT-PATH
           STRING FUNCTION TRIM(WS-OUT-DIR) "/ledger.rpt"
               DELIMITED BY SIZE INTO WS-RPT-PATH
           MOVE SPACES TO WS-CSV-PATH
           STRING FUNCTION TRIM(WS-OUT-DIR) "/accounts.csv"
               DELIMITED BY SIZE INTO WS-CSV-PATH.

       LOAD-ACCOUNTS.
           OPEN INPUT ACCOUNT-FILE
           IF WS-ACCT-STATUS NOT = "00"
               DISPLAY "CANNOT OPEN ACCOUNT FILE "
                   FUNCTION TRIM(WS-ACCT-PATH)
                   " (STATUS " WS-ACCT-STATUS ")"
               PERFORM ABORT-RUN
           END-IF
           PERFORM UNTIL WS-ACCT-EOF
               READ ACCOUNT-FILE
                   AT END
                       SET WS-ACCT-EOF TO TRUE
                   NOT AT END
                       IF ACCT-ID <= WS-PREV-ID
                           DISPLAY "ACCOUNT FILE OUT OF ORDER AT "
                               ACCT-ID
                           PERFORM ABORT-RUN
                       END-IF
                       MOVE ACCT-ID TO WS-PREV-ID
                       IF AT-COUNT >= 1000
                           DISPLAY "ACCOUNT TABLE FULL AT " AT-COUNT
                           PERFORM ABORT-RUN
                       END-IF
                       ADD 1 TO AT-COUNT
                       MOVE ACCT-REC TO AT-ACCT (AT-COUNT)
                       ADD ACCT-BALANCE TO ST-OPENING-TOTAL
               END-READ
           END-PERFORM
           CLOSE ACCOUNT-FILE.

       PROCESS-TRANSACTIONS.
           OPEN INPUT TRANS-FILE
           IF WS-TRAN-STATUS NOT = "00"
               DISPLAY "CANNOT OPEN TRANSACTION FILE "
                   FUNCTION TRIM(WS-TRAN-PATH)
                   " (STATUS " WS-TRAN-STATUS ")"
               PERFORM ABORT-RUN
           END-IF
           OPEN OUTPUT REJECT-FILE
           PERFORM UNTIL WS-TRAN-EOF
               READ TRANS-FILE
                   AT END
                       SET WS-TRAN-EOF TO TRUE
                   NOT AT END
                       IF TRAN-REC NOT = SPACES
                           PERFORM APPLY-TRANSACTION
                       END-IF
               END-READ
           END-PERFORM
           CLOSE TRANS-FILE REJECT-FILE.

       APPLY-TRANSACTION.
           ADD 1 TO ST-READ
           MOVE SPACES TO WS-REJECT-CODE
           PERFORM VALIDATE-TRANSACTION
           IF TRAN-SEQ > WS-LAST-SEQ
               MOVE TRAN-SEQ TO WS-LAST-SEQ
           END-IF
           IF WS-REJECT-CODE = SPACES
               PERFORM POST-TRANSACTION
           END-IF
           IF WS-REJECT-CODE = SPACES
               ADD 1 TO ST-APPLIED
               ADD 1 TO AT-TXN-COUNT (WS-IX)
               MOVE "OK" TO WS-AUDIT-RESULT
               PERFORM WRITE-AUDIT
           ELSE
               PERFORM REJECT-TRANSACTION
           END-IF.

       FIND-ACCOUNT.
           MOVE 0 TO WS-FOUND-IX
           SEARCH ALL AT-ENTRY
               AT END
                   CONTINUE
               WHEN AT-ID (AX) = WS-FIND-ID
                   SET WS-FOUND-IX TO AX
           END-SEARCH.

       VALIDATE-TRANSACTION.
           MOVE TRAN-ACCT TO WS-FIND-ID
           PERFORM FIND-ACCOUNT
           MOVE WS-FOUND-IX TO WS-IX
           CALL "DATEUTIL" USING TRAN-DATE WS-DATE-OK
           EVALUATE TRUE
               WHEN TRAN-SEQ <= WS-LAST-SEQ
                   MOVE RC-BAD-SEQ TO WS-REJECT-CODE
               WHEN WS-IX = 0
                   MOVE RC-NO-ACCOUNT TO WS-REJECT-CODE
               WHEN TRAN-TRANSFER AND TRAN-TARGET = TRAN-ACCT
                   MOVE RC-SAME-ACCOUNT TO WS-REJECT-CODE
               WHEN NOT DATE-IS-VALID
                   MOVE RC-BAD-DATE TO WS-REJECT-CODE
               WHEN NOT TRAN-KNOWN-TYPE
                   MOVE RC-BAD-TYPE TO WS-REJECT-CODE
               WHEN TRAN-AMOUNT = ZERO
                   MOVE RC-ZERO-AMOUNT TO WS-REJECT-CODE
               WHEN AT-FROZEN (WS-IX)
                   MOVE RC-FROZEN TO WS-REJECT-CODE
               WHEN AT-CLOSED (WS-IX)
                   MOVE RC-CLOSED TO WS-REJECT-CODE
               WHEN TRAN-WITHDRAW AND TRAN-AMOUNT > WS-WITHDRAW-LIMIT
                   MOVE RC-OVER-LIMIT TO WS-REJECT-CODE
               WHEN TRAN-DATE < AT-OPEN-DATE (WS-IX)
                   MOVE RC-BEFORE-OPEN TO WS-REJECT-CODE
               WHEN TRAN-DATE > WS-RUN-DATE-N
                   MOVE RC-FUTURE-DATE TO WS-REJECT-CODE
               WHEN OTHER
                   CONTINUE
           END-EVALUATE.

       POST-TRANSACTION.
           EVALUATE TRUE
               WHEN TRAN-DEPOSIT
                   ADD TRAN-AMOUNT TO AT-BALANCE (WS-IX)
                       ON SIZE ERROR
                           MOVE RC-OVERFLOW TO WS-REJECT-CODE
                       NOT ON SIZE ERROR
                           ADD TRAN-AMOUNT TO ST-DEPOSIT-TOTAL
                   END-ADD
               WHEN TRAN-WITHDRAW OR TRAN-FEE
                   PERFORM DEBIT-ACCOUNT
                   IF WS-REJECT-CODE = SPACES
                       ADD TRAN-AMOUNT TO ST-DEBIT-TOTAL
                   END-IF
               WHEN TRAN-TRANSFER
                   PERFORM TRANSFER-FUNDS
           END-EVALUATE.

       DEBIT-ACCOUNT.
           COMPUTE WS-AVAILABLE =
               AT-BALANCE (WS-IX) + AT-OD-LIMIT (WS-IX)
           IF TRAN-AMOUNT > WS-AVAILABLE
               MOVE RC-NO-FUNDS TO WS-REJECT-CODE
           ELSE
               SUBTRACT TRAN-AMOUNT FROM AT-BALANCE (WS-IX)
           END-IF.

       REJECT-TRANSACTION.
           ADD 1 TO ST-REJECTED
           MOVE WS-REJECT-CODE TO WS-REASON-IX
           ADD 1 TO ST-REASON-COUNT (WS-REASON-IX)
           MOVE TRAN-REC TO REJ-TRAN
           MOVE WS-REJECT-CODE TO REJ-CODE
           WRITE REJECT-REC
           MOVE SPACES TO WS-AUDIT-RESULT
           STRING "REJECT " WS-REJECT-CODE DELIMITED BY SIZE
               INTO WS-AUDIT-RESULT
           PERFORM WRITE-AUDIT.

       POST-INTEREST.
           PERFORM VARYING WS-IX FROM 1 BY 1 UNTIL WS-IX > AT-COUNT
               IF AT-TYPE (WS-IX) = "S" AND AT-ACTIVE (WS-IX)
                   CALL "INTCALC" USING AT-BALANCE (WS-IX) WS-INTEREST
                   IF WS-INTEREST > 0
                       ADD WS-INTEREST TO AT-BALANCE (WS-IX)
                       ADD WS-INTEREST TO ST-INTEREST-TOTAL
                       ADD 1 TO ST-APPLIED
                       PERFORM AUDIT-INTEREST
                   END-IF
               END-IF
           END-PERFORM.

       AUDIT-INTEREST.
           MOVE WS-INTEREST TO WS-AMT-EDIT
           MOVE SPACES TO WS-AUDIT-LINE
           STRING WS-RUN-DATE " ------ I " AT-ID (WS-IX) " " WS-AMT-EDIT
               " OK" DELIMITED BY SIZE INTO WS-AUDIT-LINE
           CALL "AUDITLOG" USING "W" WS-AUDIT-LINE.

       WRITE-ACCOUNTS.
           OPEN OUTPUT NEWACCT-FILE
           PERFORM VARYING WS-IX FROM 1 BY 1 UNTIL WS-IX > AT-COUNT
               WRITE NEWACCT-REC FROM AT-ACCT (WS-IX)
           END-PERFORM
           CLOSE NEWACCT-FILE.

       FINISH.
           PERFORM RECONCILE
           CALL "AUDITLOG" USING "C" WS-AUDIT-LINE
           CALL "RPTWRT" USING ACCT-TABLE LEDGER-STATS WS-RPT-PATH
               WS-RUN-DATE
           CALL "CSVEXP" USING ACCT-TABLE WS-CSV-PATH
           DISPLAY "LEDGER RUN COMPLETE"
           DISPLAY "  ACCOUNTS LOADED   " AT-COUNT
           DISPLAY "  TRANSACTIONS READ " ST-READ
           DISPLAY "  APPLIED           " ST-APPLIED
           DISPLAY "  REJECTED          " ST-REJECTED
           IF ST-REJECTED > 0 AND RETURN-CODE = 0
               MOVE 4 TO RETURN-CODE
           END-IF.

       TRANSFER-FUNDS.
           MOVE TRAN-TARGET TO WS-FIND-ID
           PERFORM FIND-ACCOUNT
           MOVE WS-FOUND-IX TO WS-TX
           EVALUATE TRUE
               WHEN WS-TX = 0
                   MOVE RC-NO-TARGET TO WS-REJECT-CODE
               WHEN AT-FROZEN (WS-TX)
                   MOVE RC-FROZEN TO WS-REJECT-CODE
               WHEN AT-CLOSED (WS-TX)
                   MOVE RC-CLOSED TO WS-REJECT-CODE
               WHEN AT-BALANCE (WS-TX) + TRAN-AMOUNT
                       > WS-MAX-BALANCE
                   MOVE RC-TARGET-FULL TO WS-REJECT-CODE
               WHEN OTHER
                   PERFORM DEBIT-ACCOUNT
                   IF WS-REJECT-CODE = SPACES
                       ADD TRAN-AMOUNT TO AT-BALANCE (WS-TX)
                       ADD 1 TO AT-TXN-COUNT (WS-TX)
                   END-IF
           END-EVALUATE.

       WRITE-AUDIT.
           MOVE TRAN-AMOUNT TO WS-AMT-EDIT
           MOVE SPACES TO WS-AUDIT-LINE
           STRING TRAN-DATE " " TRAN-SEQ " " TRAN-TYPE " "
               TRAN-ACCT " " WS-AMT-EDIT " " WS-AUDIT-RESULT
               DELIMITED BY SIZE INTO WS-AUDIT-LINE
           CALL "AUDITLOG" USING "W" WS-AUDIT-LINE.

       RECONCILE.
           MOVE 0 TO ST-CLOSING-TOTAL
           PERFORM VARYING WS-IX FROM 1 BY 1 UNTIL WS-IX > AT-COUNT
               ADD AT-BALANCE (WS-IX) TO ST-CLOSING-TOTAL
           END-PERFORM
           COMPUTE WS-EXPECTED = ST-OPENING-TOTAL + ST-DEPOSIT-TOTAL
               + ST-INTEREST-TOTAL - ST-DEBIT-TOTAL
           IF WS-EXPECTED NOT = ST-CLOSING-TOTAL
               DISPLAY "OUT OF BALANCE: EXPECTED " WS-EXPECTED
                   " FOUND " ST-CLOSING-TOTAL
               MOVE 8 TO RETURN-CODE
           END-IF.

       ABORT-RUN.
           CLOSE ACCOUNT-FILE
           CLOSE TRANS-FILE
           CALL "AUDITLOG" USING "C" WS-AUDIT-LINE
           MOVE 12 TO RETURN-CODE
           STOP RUN.

       END PROGRAM LEDGER.
