
//2015 AHF - Antonio H. Ferreira <disal.antonio.ferreira@gmail.com>

 FUNCTION Main()
 LOCAL cSql :=""

  RddRegister("ADORDD",1)
  RddSetDefault("ADORDD")


    /*                                             NOTES

    SET ADO TABLES INDEX LIST TO = indexes without of any clipper like expression only to be used by SQL

    SET ADODBF TABLES INDEX LIST TO = indexes with the clipper like expressions needed by the app for its evaluations.

    When we use &(indexkey(0)) we cant evaluate a index expression in ADO TABLES "name+dDate+nValue" we will get an error but we can issues a sql select like that.
    Thus we need the ADODBF expression "name+DTOS(dDate)+STR(nValue) to do it.

    The ADO indexes are for queries the ADODBF are for the normal clipper expressions to allow its evaluation.

        ARRAY SPEC FOR BOTH CASES:
        ATTENTION ALL MUST BE UPPERCASE
        { {"TABLE1",{"FIRST","FIRST"} }, {"TABLE2" ,{"CODID","CODID"}} }

    temporary index names
    temporary indexes are not included here they are create on fly and added to temindex list array
    they are only valid through the duration of the application
    the temp index name is auto given by adordd

    SET ADO TEMPORAY NAMES INDEX LIST TO {"TMP","TEMP"}

    each table autoinc field used as recno

    SET ADO FIELDRECNO TABLES LIST TO {{"TABLE1","HBRECNO"},{"TABLE2","HBRECNO"}}

    default table autoinc field used as recno

    SET ADO DEFAULT RECNO FIELD TO "HBRECNO"

    SET AUTOPEN ON //might be OFF if you wish
    SET AUTORDER TO 1 // first index opened can be other

    set default parameters to adordd if you do not USE COMMAND or dont pretend to include this info
    set it here

    SET ADO DEFAULT DATABASE TO "test2.mdb" SERVER TO "ACCESS" ENGINE TO "ACESS" ;
       USER TO "" PASSWORD TO ""

    SET DBF TABLE TCONTROL ALL LOCKING RECORD AND TABLE IN ADORDD

    DEFAULTS TO PATH WHERE APP IS RUNING
    SET ADO LOCK CONTROL SHAREPATH TO  "C:" RDD TO "DBFCDX"
    DISABLE CONTOL LOCK
    SET ADO FORCE LOCK OFF /ON

/*               THE ONLY CHANGES IN YOUR APP CODE END HERE! (SHOULD)              */


/*                                T R I A L S
   PEASE READ THIS CAREFULLY!

   PLEASE REMEMBER THAT ALTHOUGH ADORDD STILL AND MIGHT WORK WITHOUT ANY AUTOINC FIELD AS RECNO
   RESULT WILL BE UNPREDICTABLE IN SOME CIRCUNSTANCES OR ERROR MIGHT OCCOUR.
   THE FINAL RELEASE WIL NOT WORK WITHOUT SUCH A FIELD

   INDEXES WITH DATES IN SOME BROWSE WITHIN A DATE SCOPE RECORD MOVEMENT HAS STILL SOME PROBLEMS

   WHEN YOU DELETE A RECORD YOU CANT ACCESS IT ANYMORE. THUS CODE LIKE THIS IS ILLEGAL:

   DELETE RECORD
   BLANKREC

   THIS MUST BE CHANGED TO

   IF RDDNAME() = "ADORDD"
      BLANKREC
      DELETE RECORD
   ELSE
      DELETE RECORD
      BLANKREC
   ENDIF

   YOU CAN OPEN A TABLE ALSO WITH ANEW CONNECTION
   USE "CTABLE@ CON SRING" ALIAS "TABLE"

   ANY INDEX FUNCTION OR VARIABLES MUST BE EVALUAED BEFORE SENT TO ADO

   BESIDES THESE CHANGES APP SHOULD RUN WITHOUT ANY CODE LOGIC CHANGE


   PLEASE REPORT ANY BUGS! THANKS!   */

    SET ADO TABLES INDEX LIST TO { {"TABLE1",{"FIRST","FIRST"} }, {"TABLE2" ,{"CODID","CODID"}} }
    SET ADODBF TABLES INDEX LIST TO {  {"TABLE1",{"FIRST","FIRST"} }, {"TABLE2" ,{"CODID","CODID"}} }
    SET ADO TEMPORAY NAMES INDEX LIST TO {"TMP","TEMP"}
    SET ADO FIELDRECNO TABLES LIST TO {{"TABLE1","HBRECNO"},{"TABLE2","HBRECNO"}}
    SET ADO DEFAULT RECNO FIELD TO "HBRECNO"
    SET AUTOPEN ON //might be OFF if you wish
    SET AUTORDER TO 1 // first index opened can be other

    //need to include complete path
    SET ADO DEFAULT DATABASE TO "D:\WHATEVER\TEST2.mdb" SERVER TO "CSEVER" ENGINE TO ACCESS USER TO "" PASSWORD TO ""

    //CONTROL LOCKING IN ADORDD FOR BOTH TABLE AND RECORD DONT PUT FINAL "\"
    SET ADO LOCK CONTROL SHAREPATH TO  "D:\WHATEVER" RDD TO "DBFCDX"

   IF !FILE(   "\test2.mdb"   )
      //need to include complete path defaults to SET ADO DEFAULT DATABA
      DbCreate("table1;\test2.mdb", ;
                                { { "CODID",   "C", 10, 0 },;
                                  { "FIRST",   "C", 30, 0 },;
                                  { "LAST",    "C", 30, 0 },;
                                  { "AGE",     "N",  8, 0 },;
                                  { "HBRECNO", "+", 10, 0  } }, "ADORDD" )
      //need to include complete path defaults to SET ADO DEFAULT DATABA
      DbCreate( "table2;\test2.mdb", ;
                                { { "CODID",    "C", 10, 0 },;
                                  { "ADDRESS",  "C", 30, 0 },;
                                  { "PHONE",    "C", 30, 0 },;
                                  { "EMAIL",    "C", 100,0 },;
                                  { "HBRECNO",  "+", 10,0  } }, "ADORDD" )

     SELE 0
     USE table1 ALIAS "TEST1"

     APPEND BLANK
     test1->First   := "HOMER si no Homer"
     test1->Last    := "Simpson"
     test1->Age     := 45
     test1->codid   := "0001"

     APPEND BLANK
     test1->First   := "Lara"
     test1->Last    := "Croft si no"
     test1->Age     := 32
     test1->codid   := "0002"
     test1->(dbcommit())

     SELE 0
     USE table2 ALIAS "TEST2"

     APPEND BLANK
     test2->address := "742 Evergreen Terrace"
     test2->phone   := "01 2920002"
     test2->email   := "homer@homersimpson.com"
     test2->codid   := "0001"

     APPEND BLANK
     test2->address := "Raymond Street"
     test2->phone   := "0039 29933003"
     test2->email   := "lara@laracroft.com"
     test2->codid   := "0002"
     test2->(dbcommit())

     CLOSE ALL
   ENDIF

   SELE 0
   USE table1 ALIAS "TEST1"
   SELE 0
   USE table2 ALIAS "TEST2"

   //LOCKING TRIAL
   GOTO 1

   IF DBRLOCK(1)
      MSGINFO("TABLE 2 RECORD 1 LOCKED! START ANOTHER "+;
              "INSTANCE OF APP BEFORE CLOSING THIS MESSAGE"+;
              " CHECK LOCK!")
      UNLOCK

   ELSE
      MSGINFO("TABLE 2 COULD NOT LOCK RECORD 1")

   ENDIF

   GO TOP

   SELE TEST1
   GO TOP
   MSGINFO("BROWSE DEFAULT ORDER TABLE1")
   Browse()

   SELE TEST 2
   GO TOP
   MSGINFO("BROWSE DEFAULT ORDER TABLE2")
   Browse()

   SELE TEST1
   SET RELATION TO CODID INTO TEST2
   MSGINFO("SET RELATION TO CODID FROM TABLE1 TO TABLE2")
   GO TOP
   DO WHILE !EOF()
      MSGINFO("Name "+TEST1->FIRST+" Address "+TEST2->ADDRESS)
      DBSKIP()
   ENDDO

   MSGINFO("BROWSE TABLE1")
   BROWSE()

   MSGINFO("CHANGE ORDER CREATE INDEX ON LAST TABLE1")
   INDEX ON LAST TO TMP
   SET INDEX TO TMP

   BROWSE()

   cSql := "CREATE VIEW CONTACTS AS SELECT TABLE1.FIRST, TABLE1.LAST,"+;
            "TABLE1.AGE, TABLE2.ADDRESS, TABLE2.EMAIL "+;
            "FROM TABLE1 LEFT OUTER JOIN TABLE2 ON TABLE1.CODID = TABLE2.CODID"
   MSGINFO("RUNING SQL "+cSql)

   TRY
      hb_GetAdoConnection()():EXECUTE(cSql)
   CATCH
      ADOSHOWERROR( hb_GetAdoConnection()())
   END

   SELE 0
   USE CONTACTS
   MSGINFO("BROWSING VIEW CONTACTS")
   BROWSE()
   INDEX ON ADDRESS TO TMP2
   SET INDEX TO TMP2
   MSGINFO("INDEXED BY ADRESS")
   BROWSE()

   //WORKING DIRECTLY WITH RECORDSET IN ANOTHER AREA
   MSGINFO("GET RECORDSET FOR TABLE TEST1 "+STR(SELECT("TEST1")) )

   oRs := hb_adoRddGetRecordSet(SELECT("TEST1"))

   oRs:close()
   aa := "SELECT * FROM "+hb_adoRddGetTableName( SELECT("TEST1") )+ " WHERE FIRST = 'Lara'"

   MSGINFO("NEW SELECT FOR RECORDSET TEST1 "+AA)
   oRs:open(aa,hb_adoRddGetConnection(SELECT("TEST1")))

   MSGINFO("CURRENT WORKAREA "+ALIAS())

   MSGINFO("BROWSE RECORDSET ALIAS TEST1")
   TEST1->(BROWSE())

   MSGINFO("DOES TABLE1 EXISTS ON DB ?"+CVALTOCHAR(hb_adoRddExistsTable( "Table1") ))
   MSGINFO("DOES TABLE3 EXISTS ON DB ?"+CVALTOCHAR(hb_adoRddExistsTable( "Table3") ))
   DbCloseAll()

RETURN nil

