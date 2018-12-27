       IDENTIFICATION DIVISION.
       PROGRAM-ID. RPTWRT.
      *
      * RPTWRT - PRINTS THE ACCOUNT LIST AT THE END OF A RUN.
      *
       ENVIRONMENT DIVISION.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
           SELECT REPORT-FILE ASSIGN TO WS-PATH
               ORGANIZATION IS LINE SEQUENTIAL.
       DATA DIVISION.
       FILE SECTION.
       FD  REPORT-FILE.
       01  REPORT-REC           PIC X(80).
       WORKING-STORAGE SECTION.
       01  WS-PATH              PIC X(100).
       01  WS-IX                PIC 9(4) COMP.
       01  WS-TOT-CHECKING      PIC 9(11)V99 VALUE 0.
       01  WS-TOT-SAVINGS       PIC 9(11)V99 VALUE 0.
       01  WS-LINE-COUNT        PIC 9(3) COMP VALUE 0.
       01  WS-PAGE-NO           PIC 9(3) COMP VALUE 0.
       01  WS-PAGE-SIZE         PIC 9(3) COMP VALUE 10.
       01  HEADING-1.
           05  FILLER           PIC X(46) VALUE "CBLEDGER ACCOUNT LIST".
           05  FILLER           PIC X(5)  VALUE "PAGE ".
           05  HD-PAGE          PIC ZZ9.
       01  HEADING-2.
           05  FILLER           PIC X(10) VALUE "ACCT ID".
           05  FILLER           PIC X(22) VALUE "NAME".
           05  FILLER           PIC X(8)  VALUE "TYPE".
           05  FILLER           PIC X(14) VALUE "       BALANCE".
       01  RULE-LINE            PIC X(54) VALUE ALL "-".
       01  DETAIL-LINE.
           05  DL-ID            PIC 9(8).
           05  FILLER           PIC XX VALUE SPACES.
           05  DL-NAME          PIC X(20).
           05  FILLER           PIC XX VALUE SPACES.
           05  DL-TYPE          PIC X(8).
           05  DL-BALANCE       PIC ZZZ,ZZZ,ZZ9.99.
       01  TOTAL-LINE.
           05  TL-LABEL         PIC X(40).
           05  TL-AMOUNT        PIC ZZZ,ZZZ,ZZ9.99.
       LINKAGE SECTION.
           COPY ACCTTBL.
           COPY STATS.
       01  LK-PATH              PIC X(100).
       PROCEDURE DIVISION USING ACCT-TABLE LEDGER-STATS LK-PATH.
       MAIN-LINE.
           MOVE LK-PATH TO WS-PATH
           OPEN OUTPUT REPORT-FILE
           PERFORM VARYING WS-IX FROM 1 BY 1 UNTIL WS-IX > AT-COUNT
               PERFORM PRINT-DETAIL
           END-PERFORM
           PERFORM PRINT-TOTALS
           CLOSE REPORT-FILE
           GOBACK.

       PRINT-HEADINGS.
           ADD 1 TO WS-PAGE-NO
           MOVE WS-PAGE-NO TO HD-PAGE
           IF WS-PAGE-NO > 1
               MOVE SPACES TO REPORT-REC
               WRITE REPORT-REC
           END-IF
           WRITE REPORT-REC FROM HEADING-1
           WRITE REPORT-REC FROM HEADING-2
           WRITE REPORT-REC FROM RULE-LINE
           MOVE 0 TO WS-LINE-COUNT.

       PRINT-DETAIL.
           IF WS-LINE-COUNT = 0 OR WS-LINE-COUNT >= WS-PAGE-SIZE
               PERFORM PRINT-HEADINGS
           END-IF
           MOVE AT-ID (WS-IX) TO DL-ID
           MOVE AT-NAME (WS-IX) TO DL-NAME
           IF AT-TYPE (WS-IX) = "C"
               MOVE "CHECKING" TO DL-TYPE
               ADD AT-BALANCE (WS-IX) TO WS-TOT-CHECKING
           ELSE
               MOVE "SAVINGS" TO DL-TYPE
               ADD AT-BALANCE (WS-IX) TO WS-TOT-SAVINGS
           END-IF
           MOVE AT-BALANCE (WS-IX) TO DL-BALANCE
           WRITE REPORT-REC FROM DETAIL-LINE
           ADD 1 TO WS-LINE-COUNT.

       PRINT-TOTALS.
           WRITE REPORT-REC FROM RULE-LINE
           MOVE "TOTAL CHECKING" TO TL-LABEL
           MOVE WS-TOT-CHECKING TO TL-AMOUNT
           WRITE REPORT-REC FROM TOTAL-LINE
           MOVE "TOTAL SAVINGS" TO TL-LABEL
           MOVE WS-TOT-SAVINGS TO TL-AMOUNT
           WRITE REPORT-REC FROM TOTAL-LINE.

       END PROGRAM RPTWRT.
