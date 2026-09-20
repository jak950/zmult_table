REPORT zfix1.
DATA: lr    TYPE REF TO data,
      lo    TYPE string_table,
      lv    TYPE string,
      lt_   TYPE string,
      lv_v  TYPE string,
      lp    TYPE string,
      lx    TYPE string,
      lv_rc TYPE i,
      lv_c  TYPE i,
      lo_p  TYPE REF TO if_package.
FIELD-SYMBOLS: <tab> TYPE STANDARD TABLE,
               <wa>  TYPE any,
               <f>   TYPE any.
CREATE DATA lr TYPE TABLE OF ('ZABAPGIT').
ASSIGN lr->* TO <tab>.
SELECT * FROM ('ZABAPGIT') INTO TABLE <tab> UP TO 100 ROWS.
lv_c = sy-dbcnt.
lv = |zabapgit_rows={ lv_c }|.
APPEND lv TO lo.
LOOP AT <tab> ASSIGNING <wa>.
  CLEAR: lt_, lv_v, lp.
  ASSIGN COMPONENT 'TYPE' OF STRUCTURE <wa> TO <f>.
  IF sy-subrc = 0.
    lt_ = <f>.
  ENDIF.
  IF lt_ CS 'REPO'.
    ASSIGN COMPONENT 'VALUE' OF STRUCTURE <wa> TO <f>.
    IF sy-subrc = 0.
      lv_v = <f>.
    ENDIF.
    ASSIGN COMPONENT 'DATA_STR' OF STRUCTURE <wa> TO <f>.
    IF sy-subrc = 0.
      lx = <f>.
      FIND REGEX '<PACKAGE>[^<]*' IN lx.
      IF sy-subrc = 0.
        CLEAR lp.
        FIND REGEX '<PACKAGE>([^<]*)' IN lx SUBMATCHES lp.
      ENDIF.
    ENDIF.
    CONCATENATE 'repo_type=' lt_ 'value=' lv_v 'pkg=' lp
      INTO lv SEPARATED BY space.
    APPEND lv TO lo.
  ENDIF.
ENDLOOP.
cl_package_factory=>create_new_package(
  EXPORTING
    i_package_name    = '$ZMULT_TABLE'
    i_suppress_dialog = abap_true
  RECEIVING
    r_package         = lo_p
  EXCEPTIONS
    object_already_existing = 1
    object_invalid         = 2
    OTHERS                 = 3 ).
lv_rc = sy-subrc.
IF lv_rc = 0 AND lo_p IS BOUND.
  lo_p->set_short_text( i_short_text = 'Mult table demo' ).
  lo_p->save( ).
  lo_p->set_changeable( abap_false ).
  COMMIT WORK.
  APPEND 'pkg_create=OK' TO lo.
ELSE.
  lv = |pkg_create_rc={ lv_rc }|.
  APPEND lv TO lo.
ENDIF.
SELECT COUNT(*) FROM tdevc INTO lv_c WHERE devclass = '$ZMULT_TABLE'.
lv = |tdevc_zmult_after={ lv_c }|.
APPEND lv TO lo.
OPEN DATASET '/tmp/zfix.out' FOR OUTPUT IN TEXT MODE ENCODING UTF-8.
LOOP AT lo INTO lv.
  TRANSFER lv TO '/tmp/zfix.out'.
ENDLOOP.
CLOSE DATASET '/tmp/zfix.out'.
