      * ACCTTBL - IN-MEMORY COPY OF THE ACCOUNT MASTER.
      * NO VALUE CLAUSES SO IT CAN ALSO BE USED IN A LINKAGE SECTION.
       01  ACCT-TABLE.
           05  AT-COUNT         PIC 9(4) COMP.
           05  AT-ENTRY OCCURS 1 TO 1000 TIMES DEPENDING ON AT-COUNT
                   ASCENDING KEY IS AT-ID INDEXED BY AX.
               10  AT-ACCT.
                   15  AT-ID            PIC 9(8).
                   15  AT-NAME          PIC X(20).
                   15  AT-TYPE          PIC X.
                   15  AT-STATUS        PIC X.
                       88  AT-ACTIVE    VALUE "A".
                       88  AT-FROZEN    VALUE "F".
                       88  AT-CLOSED    VALUE "C".
                   15  AT-BALANCE       PIC S9(9)V99
                                        SIGN IS LEADING SEPARATE.
                   15  AT-OD-LIMIT      PIC 9(7)V99.
                   15  AT-OPEN-DATE     PIC 9(8).
               10  AT-TXN-COUNT     PIC 9(4) COMP.
