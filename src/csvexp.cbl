       IDENTIFICATION DIVISION.
       PROGRAM-ID. CSVEXP.
      *
      * CSVEXP - WRITES THE ACCOUNT TABLE AS A CSV FILE.
      *
       ENVIRONMENT DIVISION.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
           SELECT CSV-FILE ASSIGN TO WS-PATH
               ORGANIZATION IS LINE SEQUENTIAL.
       DATA DIVISION.
       FILE SECTION.
       FD  CSV-FILE.
       01  CSV-REC              PIC X(120).
       WORKING-STORAGE SECTION.
       01  WS-PATH              PIC X(100).
       01  WS-IX                PIC 9(4) COMP.
       01  WS-LINE              PIC X(120).
       01  WS-NAME-OUT          PIC X(24).
       01  WS-COMMAS            PIC 9(2) COMP.
       01  WS-BAL-EDIT          PIC -(9)9.99.
       01  WS-OD-EDIT           PIC Z(6)9.99.
       LINKAGE SECTION.
           COPY ACCTTBL.
       01  LK-PATH              PIC X(100).
       PROCEDURE DIVISION USING ACCT-TABLE LK-PATH.
       MAIN-LINE.
           MOVE LK-PATH TO WS-PATH
           OPEN OUTPUT CSV-FILE
           MOVE "id,name,type,status,balance,od_limit" TO CSV-REC
           WRITE CSV-REC
           PERFORM VARYING WS-IX FROM 1 BY 1 UNTIL WS-IX > AT-COUNT
               PERFORM BUILD-ROW
           END-PERFORM
           CLOSE CSV-FILE
           GOBACK.

       BUILD-ROW.
           MOVE AT-BALANCE (WS-IX) TO WS-BAL-EDIT
           MOVE AT-OD-LIMIT (WS-IX) TO WS-OD-EDIT
           MOVE 0 TO WS-COMMAS
           INSPECT AT-NAME (WS-IX) TALLYING WS-COMMAS FOR ALL ","
           MOVE SPACES TO WS-NAME-OUT
           IF WS-COMMAS > 0
               STRING QUOTE FUNCTION TRIM(AT-NAME (WS-IX)) QUOTE
                   DELIMITED BY SIZE INTO WS-NAME-OUT
           ELSE
               MOVE FUNCTION TRIM(AT-NAME (WS-IX)) TO WS-NAME-OUT
           END-IF
           MOVE SPACES TO WS-LINE
           STRING AT-ID (WS-IX) "," FUNCTION TRIM(WS-NAME-OUT) ","
               AT-TYPE (WS-IX) "," AT-STATUS (WS-IX) ","
               FUNCTION TRIM(WS-BAL-EDIT) "," FUNCTION TRIM(WS-OD-EDIT)
               DELIMITED BY SIZE INTO WS-LINE
           WRITE CSV-REC FROM WS-LINE.

       END PROGRAM CSVEXP.
