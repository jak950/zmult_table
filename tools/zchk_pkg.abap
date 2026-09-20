REPORT zchk_d2.
DATA: lv_dc  TYPE tadir-devclass,
      lv_cnt TYPE i,
      lv_st  TYPE vseoclass-state,
      lo     TYPE string_table,
      lv     TYPE string.
SELECT SINGLE devclass FROM tadir INTO lv_dc
  WHERE pgmid = 'R3TR' AND object = 'CLAS'
  AND obj_name = 'ZCL_MULT_TABLE'.
lv = |tadir_devclass={ lv_dc }|.
APPEND lv TO lo.
SELECT COUNT(*) FROM tdevc INTO lv_cnt WHERE devclass = '$TMP'.
lv = |tdevc_tmp={ lv_cnt }|.
APPEND lv TO lo.
SELECT COUNT(*) FROM tdevc INTO lv_cnt WHERE devclass = '$ZMULT_TABLE'.
lv = |tdevc_zmult={ lv_cnt }|.
APPEND lv TO lo.
SELECT SINGLE state FROM vseoclass INTO lv_st
  WHERE clsname = 'ZCL_MULT_TABLE'.
lv = |vseo_state={ lv_st }|.
APPEND lv TO lo.
OPEN DATASET '/tmp/zchk.out' FOR OUTPUT IN TEXT MODE ENCODING UTF-8.
LOOP AT lo INTO lv.
  TRANSFER lv TO '/tmp/zchk.out'.
ENDLOOP.
CLOSE DATASET '/tmp/zchk.out'.
