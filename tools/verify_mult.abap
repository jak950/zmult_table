REPORT zver_mult.
DATA: lt_tab TYPE string_table,
      lt_out TYPE string_table,
      lv_p   TYPE i,
      lv_n   TYPE i,
      lv_s   TYPE string.
lv_p = zcl_mult_table=>get_product( iv_a = 7 iv_b = 8 ).
lv_s = |get_product_7_8={ lv_p }|.
APPEND lv_s TO lt_out.
lt_tab = zcl_mult_table=>build_table( iv_n = 9 ).
lv_n = lines( lt_tab ).
lv_s = |lines={ lv_n }|.
APPEND lv_s TO lt_out.
READ TABLE lt_tab INTO lv_s INDEX 62.
lv_s = |line62={ lv_s }|.
APPEND lv_s TO lt_out.
READ TABLE lt_tab INTO lv_s INDEX 81.
lv_s = |line81={ lv_s }|.
APPEND lv_s TO lt_out.
OPEN DATASET '/tmp/zver.out' FOR OUTPUT IN TEXT MODE ENCODING UTF-8.
LOOP AT lt_out INTO lv_s.
  TRANSFER lv_s TO '/tmp/zver.out'.
ENDLOOP.
CLOSE DATASET '/tmp/zver.out'.
