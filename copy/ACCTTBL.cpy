      * ACCTTBL - IN-MEMORY COPY OF THE ACCOUNT MASTER.
      * NO VALUE CLAUSES SO IT CAN ALSO BE USED IN A LINKAGE SECTION.
       01  ACCT-TABLE.
           05  AT-COUNT         PIC 9(4) COMP.
           05  AT-ENTRY OCCURS 500 TIMES.
               10  AT-ACCT.
                   15  AT-ID            PIC 9(8).
                   15  AT-NAME          PIC X(20).
                   15  AT-TYPE          PIC X.
                   15  AT-BALANCE       PIC 9(9)V99.
                   15  AT-OPEN-DATE     PIC 9(8).
