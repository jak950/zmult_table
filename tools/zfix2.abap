REPORT zfix2.
DATA: ls_pd TYPE tpakpackage,
      lo_p  TYPE REF TO if_package,
      lo    TYPE string_table,
      lv    TYPE string,
      lv_dc TYPE tadir-devclass,
      lv_c  TYPE i.
ls_pd-devclass = '$ZMULT_TABLE'.
ls_pd-parentcl = '$TMP'.
ls_pd-ctext = 'Mult table demo'.
cl_package_factory=>create_new_package(
  EXPORTING
    i_suppress_dialog = abap_true
  IMPORTING
    e_package = lo_p
  CHANGING
    c_package_data = ls_pd ).
IF lo_p IS BOUND.
  APPEND 'create=BOUND' TO lo.
  lo_p->save( i_suppress_dialog = abap_true ).
  lo_p->set_changeable( i_changeable = abap_false
                        i_suppress_dialog = abap_true ).
  COMMIT WORK.
  APPEND 'saved' TO lo.
ELSE.
  APPEND 'create=UNBOUND' TO lo.
ENDIF.
UPDATE tadir SET devclass = '$ZMULT_TABLE'
  WHERE pgmid = 'R3TR' AND object = 'CLAS'
  AND obj_name = 'ZCL_MULT_TABLE'.
COMMIT WORK.
SELECT COUNT(*) FROM tdevc INTO lv_c WHERE devclass = '$ZMULT_TABLE'.
lv = |tdevc_zmult={ lv_c }|.
APPEND lv TO lo.
SELECT SINGLE devclass FROM tadir INTO lv_dc
  WHERE pgmid = 'R3TR' AND object = 'CLAS'
  AND obj_name = 'ZCL_MULT_TABLE'.
lv = |tadir_dc={ lv_dc }|.
APPEND lv TO lo.
OPEN DATASET '/tmp/zfix2.out' FOR OUTPUT IN TEXT MODE ENCODING UTF-8.
LOOP AT lo INTO lv.
  TRANSFER lv TO '/tmp/zfix2.out'.
ENDLOOP.
CLOSE DATASET '/tmp/zfix2.out'.
