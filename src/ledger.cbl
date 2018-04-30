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
       DATA DIVISION.
       FILE SECTION.
       FD  ACCOUNT-FILE.
           COPY ACCTREC.
       FD  TRANS-FILE.
           COPY TRANREC.
       WORKING-STORAGE SECTION.
           COPY STATS.
           COPY ACCTTBL.
       01  WS-DATA-DIR          PIC X(60).
       01  WS-ACCT-PATH         PIC X(100).
       01  WS-TRAN-PATH         PIC X(100).
       01  WS-ACCT-STATUS       PIC XX.
       01  WS-TRAN-STATUS       PIC XX.
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
           DISPLAY "ACCOUNTS LOADED: " AT-COUNT
           PERFORM PROCESS-TRANSACTIONS
           DISPLAY "TRANSACTIONS READ: " ST-READ
           DISPLAY "REJECTED: " ST-REJECTED
           STOP RUN.

       START-UP.
           MOVE 0 TO AT-COUNT
           INITIALIZE LEDGER-STATS
           PERFORM GET-DIRECTORIES
           PERFORM BUILD-PATHS.

       GET-DIRECTORIES.
           MOVE SPACES TO WS-DATA-DIR
           ACCEPT WS-DATA-DIR FROM ENVIRONMENT "LEDGER_DATA"
           IF WS-DATA-DIR = SPACES
               MOVE "data" TO WS-DATA-DIR
           END-IF.

       BUILD-PATHS.
           MOVE SPACES TO WS-ACCT-PATH
           STRING FUNCTION TRIM(WS-DATA-DIR) "/accounts.dat"
               DELIMITED BY SIZE INTO WS-ACCT-PATH
           MOVE SPACES TO WS-TRAN-PATH
           STRING FUNCTION TRIM(WS-DATA-DIR) "/trans.dat"
               DELIMITED BY SIZE INTO WS-TRAN-PATH.

       LOAD-ACCOUNTS.
           OPEN INPUT ACCOUNT-FILE
           PERFORM UNTIL WS-ACCT-EOF
               READ ACCOUNT-FILE
                   AT END
                       SET WS-ACCT-EOF TO TRUE
                   NOT AT END
                       ADD 1 TO AT-COUNT
                       MOVE ACCT-REC TO AT-ACCT (AT-COUNT)
               END-READ
           END-PERFORM
           CLOSE ACCOUNT-FILE.

       PROCESS-TRANSACTIONS.
           OPEN INPUT TRANS-FILE
           PERFORM UNTIL WS-TRAN-EOF
               READ TRANS-FILE
                   AT END
                       SET WS-TRAN-EOF TO TRUE
                   NOT AT END
                       PERFORM APPLY-TRANSACTION
               END-READ
           END-PERFORM
           CLOSE TRANS-FILE.

       APPLY-TRANSACTION.
           ADD 1 TO ST-READ
           PERFORM VARYING WS-IX FROM 1 BY 1
                   UNTIL WS-IX > AT-COUNT OR AT-ID (WS-IX) = TRAN-ACCT
               CONTINUE
           END-PERFORM
           IF WS-IX > AT-COUNT
               ADD 1 TO ST-REJECTED
           ELSE
               EVALUATE TRUE
                   WHEN TRAN-DEPOSIT
                       ADD TRAN-AMOUNT TO AT-BALANCE (WS-IX)
                   WHEN TRAN-WITHDRAW
                       IF TRAN-AMOUNT > AT-BALANCE (WS-IX)
                           ADD 1 TO ST-REJECTED
                       ELSE
                           SUBTRACT TRAN-AMOUNT FROM AT-BALANCE (WS-IX)
                       END-IF
               END-EVALUATE
           END-IF.

       END PROGRAM LEDGER.
