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
       01  WS-JX                PIC 9(4) COMP.
       01  WS-FIND-ID           PIC 9(8).
       01  WS-FOUND-IX          PIC 9(4) COMP.
       01  WS-TX                PIC 9(4) COMP.
       01  WS-DATE-OK           PIC X.
           88  DATE-IS-VALID    VALUE "Y".
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
           PERFORM PROCESS-TRANSACTIONS
           PERFORM WRITE-ACCOUNTS
           PERFORM FINISH
           STOP RUN.

       START-UP.
           MOVE 0 TO AT-COUNT
           INITIALIZE LEDGER-STATS
           PERFORM GET-DIRECTORIES
           PERFORM GET-OUT-DIR
           PERFORM BUILD-PATHS.

       GET-DIRECTORIES.
           MOVE SPACES TO WS-DATA-DIR
           ACCEPT WS-DATA-DIR FROM ENVIRONMENT "LEDGER_DATA"
           IF WS-DATA-DIR = SPACES
               MOVE "data" TO WS-DATA-DIR
           END-IF.

       GET-OUT-DIR.
           MOVE SPACES TO WS-OUT-DIR
           ACCEPT WS-OUT-DIR FROM ENVIRONMENT "LEDGER_OUT"
           IF WS-OUT-DIR = SPACES
               MOVE "out" TO WS-OUT-DIR
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
               DELIMITED BY SIZE INTO WS-NEW-PATH.

       LOAD-ACCOUNTS.
           OPEN INPUT ACCOUNT-FILE
           PERFORM UNTIL WS-ACCT-EOF
               READ ACCOUNT-FILE
                   AT END
                       SET WS-ACCT-EOF TO TRUE
                   NOT AT END
                       IF AT-COUNT >= 500
                           DISPLAY "ACCOUNT TABLE FULL AT " AT-COUNT
                           MOVE 12 TO RETURN-CODE
                           STOP RUN
                       END-IF
                       ADD 1 TO AT-COUNT
                       MOVE ACCT-REC TO AT-ACCT (AT-COUNT)
               END-READ
           END-PERFORM
           CLOSE ACCOUNT-FILE.

       PROCESS-TRANSACTIONS.
           OPEN INPUT TRANS-FILE
           OPEN OUTPUT REJECT-FILE
           PERFORM UNTIL WS-TRAN-EOF
               READ TRANS-FILE
                   AT END
                       SET WS-TRAN-EOF TO TRUE
                   NOT AT END
                       PERFORM APPLY-TRANSACTION
               END-READ
           END-PERFORM
           CLOSE TRANS-FILE REJECT-FILE.

       APPLY-TRANSACTION.
           ADD 1 TO ST-READ
           MOVE SPACES TO WS-REJECT-CODE
           PERFORM VALIDATE-TRANSACTION
           IF WS-REJECT-CODE = SPACES
               PERFORM POST-TRANSACTION
           END-IF
           IF WS-REJECT-CODE = SPACES
               ADD 1 TO ST-APPLIED
           ELSE
               PERFORM REJECT-TRANSACTION
           END-IF.

       FIND-ACCOUNT.
           MOVE 0 TO WS-FOUND-IX
           PERFORM VARYING WS-JX FROM 1 BY 1
                   UNTIL WS-JX > AT-COUNT OR WS-FOUND-IX > 0
               IF AT-ID (WS-JX) = WS-FIND-ID
                   MOVE WS-JX TO WS-FOUND-IX
               END-IF
           END-PERFORM.

       VALIDATE-TRANSACTION.
           MOVE TRAN-ACCT TO WS-FIND-ID
           PERFORM FIND-ACCOUNT
           MOVE WS-FOUND-IX TO WS-IX
           CALL "DATEUTIL" USING TRAN-DATE WS-DATE-OK
           EVALUATE TRUE
               WHEN WS-IX = 0
                   MOVE RC-NO-ACCOUNT TO WS-REJECT-CODE
               WHEN TRAN-TRANSFER AND TRAN-TARGET = TRAN-ACCT
                   MOVE RC-SAME-ACCOUNT TO WS-REJECT-CODE
               WHEN NOT DATE-IS-VALID
                   MOVE RC-BAD-DATE TO WS-REJECT-CODE
               WHEN OTHER
                   CONTINUE
           END-EVALUATE.

       POST-TRANSACTION.
           EVALUATE TRUE
               WHEN TRAN-DEPOSIT
                   ADD TRAN-AMOUNT TO AT-BALANCE (WS-IX)
               WHEN TRAN-WITHDRAW
                   PERFORM DEBIT-ACCOUNT
               WHEN TRAN-TRANSFER
                   PERFORM TRANSFER-FUNDS
           END-EVALUATE.

       DEBIT-ACCOUNT.
           IF TRAN-AMOUNT > AT-BALANCE (WS-IX)
               MOVE RC-NO-FUNDS TO WS-REJECT-CODE
           ELSE
               SUBTRACT TRAN-AMOUNT FROM AT-BALANCE (WS-IX)
           END-IF.

       REJECT-TRANSACTION.
           ADD 1 TO ST-REJECTED
           MOVE TRAN-REC TO REJ-TRAN
           MOVE WS-REJECT-CODE TO REJ-CODE
           WRITE REJECT-REC.

       WRITE-ACCOUNTS.
           OPEN OUTPUT NEWACCT-FILE
           PERFORM VARYING WS-IX FROM 1 BY 1 UNTIL WS-IX > AT-COUNT
               WRITE NEWACCT-REC FROM AT-ACCT (WS-IX)
           END-PERFORM
           CLOSE NEWACCT-FILE.

       FINISH.
           DISPLAY "LEDGER RUN COMPLETE"
           DISPLAY "  ACCOUNTS LOADED   " AT-COUNT
           DISPLAY "  TRANSACTIONS READ " ST-READ
           DISPLAY "  APPLIED           " ST-APPLIED
           DISPLAY "  REJECTED          " ST-REJECTED
           IF ST-REJECTED > 0
               MOVE 4 TO RETURN-CODE
           END-IF.

       TRANSFER-FUNDS.
           MOVE TRAN-TARGET TO WS-FIND-ID
           PERFORM FIND-ACCOUNT
           MOVE WS-FOUND-IX TO WS-TX
           IF WS-TX = 0
               MOVE RC-NO-TARGET TO WS-REJECT-CODE
           ELSE
               PERFORM DEBIT-ACCOUNT
               IF WS-REJECT-CODE = SPACES
                   ADD TRAN-AMOUNT TO AT-BALANCE (WS-TX)
               END-IF
           END-IF.

       END PROGRAM LEDGER.
