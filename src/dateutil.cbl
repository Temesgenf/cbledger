       IDENTIFICATION DIVISION.
       PROGRAM-ID. DATEUTIL.
      *
      * DATEUTIL - CHECKS A YYYYMMDD DATE. LK-VALID IS "Y" OR "N".
      *
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       01  WS-DAYS-VALUES       PIC X(24)
               VALUE "312831303130313130313031".
       01  WS-DAYS-TABLE REDEFINES WS-DAYS-VALUES.
           05  WS-DAYS-IN-MONTH PIC 99 OCCURS 12 TIMES.
       01  WS-MAX-DAY           PIC 99.
       LINKAGE SECTION.
       01  LK-DATE.
           05  LK-YEAR          PIC 9(4).
           05  LK-MONTH         PIC 99.
           05  LK-DAY           PIC 99.
       01  LK-VALID             PIC X.
       PROCEDURE DIVISION USING LK-DATE LK-VALID.
       MAIN-LINE.
           MOVE "N" TO LK-VALID
           IF LK-YEAR >= 1900 AND LK-MONTH >= 1 AND LK-MONTH <= 12
               MOVE WS-DAYS-IN-MONTH (LK-MONTH) TO WS-MAX-DAY
               IF LK-MONTH = 2 AND FUNCTION MOD (LK-YEAR, 4) = 0
                  AND (FUNCTION MOD (LK-YEAR, 100) NOT = 0
                       OR FUNCTION MOD (LK-YEAR, 400) = 0)
                   MOVE 29 TO WS-MAX-DAY
               END-IF
               IF LK-DAY >= 1 AND LK-DAY <= WS-MAX-DAY
                   MOVE "Y" TO LK-VALID
               END-IF
           END-IF
           GOBACK.

       END PROGRAM DATEUTIL.
