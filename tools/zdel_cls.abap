REPORT zdel_cls.
DATA: lt_n TYPE TABLE OF char40,
      lv_n TYPE char40,
      lo   TYPE string_table,
      lv   TYPE string,
      rc   TYPE i,
      cnt  TYPE i.
SELECT progname FROM reposrc INTO TABLE lt_n
  WHERE progname LIKE 'ZCL_MULT_TABLE%'.
SORT lt_n.
DELETE ADJACENT DUPLICATES FROM lt_n.
LOOP AT lt_n INTO lv_n.
  DELETE REPORT lv_n.
  rc = sy-subrc.
  lv = |del={ lv_n } rc={ rc }|.
  APPEND lv TO lo.
ENDLOOP.
DELETE FROM vseoclass WHERE clsname = 'ZCL_MULT_TABLE'.
rc = sy-subrc.
lv = |del_vseoclass_rc={ rc }|.
APPEND lv TO lo.
DELETE FROM tadir WHERE pgmid = 'R3TR' AND object = 'CLAS'
  AND obj_name = 'ZCL_MULT_TABLE'.
rc = sy-subrc.
lv = |del_tadir_rc={ rc }|.
APPEND lv TO lo.
COMMIT WORK.
SELECT COUNT(*) FROM reposrc INTO cnt
  WHERE progname LIKE 'ZCL_MULT_TABLE%'.
lv = |reposrc_left={ cnt }|.
APPEND lv TO lo.
SELECT COUNT(*) FROM vseoclass INTO cnt
  WHERE clsname = 'ZCL_MULT_TABLE'.
lv = |vseoclass_left={ cnt }|.
APPEND lv TO lo.
OPEN DATASET '/tmp/zdel.out' FOR OUTPUT IN TEXT MODE ENCODING UTF-8.
LOOP AT lo INTO lv.
  TRANSFER lv TO '/tmp/zdel.out'.
ENDLOOP.
CLOSE DATASET '/tmp/zdel.out'.
