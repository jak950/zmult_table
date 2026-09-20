REPORT zmult_pow_ui.

DATA: gv_i TYPE i,
      gv_r TYPE i.

PARAMETERS: rb_mul RADIOBUTTON GROUP op DEFAULT 'X',
            rb_pow RADIOBUTTON GROUP op.

SELECT-OPTIONS: s_a FOR gv_i,
                s_b FOR gv_i.

START-OF-SELECTION.
  LOOP AT s_a.
    LOOP AT s_b.
      IF rb_mul = 'X'.
        gv_r = zcl_power=>get_product( iv_a = s_a-low
                                       iv_b = s_b-low ).
        WRITE: / s_a-low, 'x', s_b-low, '=', gv_r.
      ELSE.
        gv_r = zcl_power=>power( iv_base = s_a-low
                                 iv_exp  = s_b-low ).
        WRITE: / s_a-low, '^', s_b-low, '=', gv_r.
      ENDIF.
    ENDLOOP.
  ENDLOOP.
