CLASS zcl_mult_table DEFINITION PUBLIC CREATE PUBLIC.
  PUBLIC SECTION.
    CLASS-METHODS:
      get_product
        IMPORTING iv_a TYPE i
                  iv_b TYPE i
        RETURNING VALUE(rv_product) TYPE i,
      build_table
        IMPORTING iv_n TYPE i DEFAULT 10
        RETURNING VALUE(rt_table) TYPE string_table.
ENDCLASS.

CLASS zcl_mult_table IMPLEMENTATION.

  METHOD get_product.
    rv_product = iv_a * iv_b.
  ENDMETHOD.

  METHOD build_table.
    DATA: lv_a TYPE i,
          lv_b TYPE i,
          lv_p TYPE i.
    DO iv_n TIMES.
      lv_a = sy-index.
      DO iv_n TIMES.
        lv_b = sy-index.
        lv_p = lv_a * lv_b.
        APPEND |{ lv_a } x { lv_b } = { lv_p }| TO rt_table.
      ENDDO.
    ENDDO.
  ENDMETHOD.

ENDCLASS.
