FUNCTION z_dmo_bapi_bom.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     VALUE(IV_MATERIAL) TYPE  ZDMO_NUMC10
*"     VALUE(IV_DESCRIPTION) TYPE  ZDMO_CHAR50
*"  EXPORTING
*"     VALUE(EV_BILLOFMATERIAL) TYPE  ZDMO_NUMC10
*"  EXCEPTIONS
*"      MATERIAL_UNKNOWN
*"----------------------------------------------------------------------
  DATA ls_bom TYPE zdmo_bom.

  SELECT SINGLE FROM zdmo_material
    FIELDS 'X'
    WHERE material = @iv_material
    INTO @DATA(lv_material_exists).

  IF sy-subrc NE 0.
    RAISE material_unknown.
  ENDIF.

  SELECT FROM zdmo_bom
    FIELDS MAX( BillOfMaterial ) AS LastBom
    INTO TABLE @DATA(lt_boms).

  ls_bom = VALUE #( BillOfMaterial = VALUE #( lt_boms[ 1 ]-lastbom OPTIONAL ) + 1
                    Description    = iv_description
                    Material       = iv_material ).

  INSERT zdmo_bom FROM ls_bom.

  ev_billofmaterial = ls_bom-BillOfMaterial.

ENDFUNCTION.
