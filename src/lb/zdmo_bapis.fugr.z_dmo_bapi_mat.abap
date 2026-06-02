FUNCTION z_dmo_bapi_mat.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     VALUE(IV_TEXT) TYPE  ZDMO_CHAR50
*"     VALUE(IV_BASEUNIT) TYPE  ZDMO_CHAR10
*"  EXPORTING
*"     VALUE(EV_MATERIAL) TYPE  ZDMO_NUMC10
*"----------------------------------------------------------------------

  DATA ls_material TYPE zdmo_material.

  SELECT FROM zdmo_material
    FIELDS MAX( material ) AS LastMaterial
    INTO TABLE @DATA(lt_materials).

  ls_material = VALUE #( material = VALUE #( lt_materials[ 1 ]-LastMaterial OPTIONAL ) + 1
                         text     = iv_text
                         baseunit = iv_baseunit ).

  INSERT zdmo_material FROM ls_material.

  ev_material = ls_material-material.

ENDFUNCTION.
