REPORT zfix3.
DATA: lr1 TYPE REF TO data,
      lr2 TYPE REF TO data,
      lo  TYPE string_table,
      lv  TYPE string,
      rc  TYPE i,
      lv_dc TYPE tadir-devclass,
      lv_c TYPE i.
FIELD-SYMBOLS: <w1> TYPE any,
               <w2> TYPE any,
               <f>  TYPE any.
CREATE DATA lr1 TYPE ('TDEVC').
ASSIGN lr1->* TO <w1>.
CREATE DATA lr2 TYPE ('TDEVC').
ASSIGN lr2->* TO <w2>.
SELECT SINGLE * FROM tdevc INTO <w1> WHERE devclass = '$TMP'.
IF sy-subrc <> 0.
  APPEND 'NO_TMP_ROW' TO lo.
ELSE.
  <w2> = <w1>.
  ASSIGN COMPONENT 'DEVCLASS' OF STRUCTURE <w2> TO <f>.
  <f> = '$ZMULT_TABLE'.
  ASSIGN COMPONENT 'PARENTCL' OF STRUCTURE <w2> TO <f>.
  <f> = '$TMP'.
  INSERT tdevc FROM <w2>.
  rc = sy-subrc.
  lv = |ins_tdevc_rc={ rc }|.
  APPEND lv TO lo.
  IF rc = 0.
    CREATE DATA lr1 TYPE ('TDEVCT').
    ASSIGN lr1->* TO <w1>.
    CREATE DATA lr2 TYPE ('TDEVCT').
    ASSIGN lr2->* TO <w2>.
    SELECT SINGLE * FROM tdevct INTO <w1>
      WHERE devclass = '$TMP'.
    IF sy-subrc = 0.
      <w2> = <w1>.
      ASSIGN COMPONENT 'DEVCLASS' OF STRUCTURE <w2> TO <f>.
      <f> = '$ZMULT_TABLE'.
      ASSIGN COMPONENT 'CTEXT' OF STRUCTURE <w2> TO <f>.
      <f> = 'Mult table demo'.
      INSERT tdevct FROM <w2>.
      rc = sy-subrc.
      lv = |ins_tdevct_rc={ rc }|.
      APPEND lv TO lo.
    ELSE.
      APPEND 'NO_TMP_TEXT' TO lo.
    ENDIF.
    COMMIT WORK.
    UPDATE tadir SET devclass = '$ZMULT_TABLE'
      WHERE pgmid = 'R3TR' AND object = 'CLAS'
      AND obj_name = 'ZCL_MULT_TABLE'.
    rc = sy-subrc.
    lv = |upd_tadir_rc={ rc }|.
    APPEND lv TO lo.
    COMMIT WORK.
  ENDIF.
ENDIF.
SELECT COUNT(*) FROM tdevc INTO lv_c WHERE devclass = '$ZMULT_TABLE'.
lv = |tdevc_zmult={ lv_c }|.
APPEND lv TO lo.
SELECT SINGLE devclass FROM tadir INTO lv_dc
  WHERE pgmid = 'R3TR' AND object = 'CLAS'
  AND obj_name = 'ZCL_MULT_TABLE'.
lv = |tadir_dc={ lv_dc }|.
APPEND lv TO lo.
OPEN DATASET '/tmp/zfix3.out' FOR OUTPUT IN TEXT MODE ENCODING UTF-8.
LOOP AT lo INTO lv.
  TRANSFER lv TO '/tmp/zfix3.out'.
ENDLOOP.
CLOSE DATASET '/tmp/zfix3.out'.
