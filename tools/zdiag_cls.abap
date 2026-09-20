REPORT zdiag_cls.
DATA: lt_m   TYPE TABLE OF vseomethod,
      lt_n   TYPE TABLE OF char40,
      lt_src TYPE TABLE OF string,
      ls_m   TYPE vseomethod,
      lv_n   TYPE char40,
      lv     TYPE string,
      rc     TYPE i,
      cnt    TYPE i.
DATA: lo TYPE string_table.
SELECT * FROM vseomethod INTO TABLE lt_m
  WHERE clsname = 'ZCL_MULT_TABLE'.
cnt = lines( lt_m ).
lv = |vseomethod_rows={ cnt }|.
APPEND lv TO lo.
LOOP AT lt_m INTO ls_m.
  CONCATENATE 'M=' ls_m-cmpname 'EXP=' ls_m-exposure
    INTO lv SEPARATED BY space.
  APPEND lv TO lo.
ENDLOOP.
SELECT progname FROM reposrc INTO TABLE lt_n
  WHERE progname LIKE 'ZCL_MULT_TABLE%'.
cnt = lines( lt_n ).
lv = |reposrc_rows={ cnt }|.
APPEND lv TO lo.
LOOP AT lt_n INTO lv_n.
  CONCATENATE 'INC=' lv_n INTO lv.
  APPEND lv TO lo.
ENDLOOP.
READ REPORT 'ZCL_MULT_TABLE================CP' INTO lt_src.
rc = sy-subrc.
cnt = lines( lt_src ).
lv = |cp_rc={ rc } cp_lines={ cnt }|.
APPEND lv TO lo.
cnt = 0.
LOOP AT lt_src INTO lv.
  cnt = cnt + 1.
  IF cnt <= 50.
    CONCATENATE 'CP:' lv INTO lv SEPARATED BY space.
    APPEND lv TO lo.
  ENDIF.
ENDLOOP.
OPEN DATASET '/tmp/zdcls.out' FOR OUTPUT IN TEXT MODE ENCODING UTF-8.
LOOP AT lo INTO lv.
  TRANSFER lv TO '/tmp/zdcls.out'.
ENDLOOP.
CLOSE DATASET '/tmp/zdcls.out'.
