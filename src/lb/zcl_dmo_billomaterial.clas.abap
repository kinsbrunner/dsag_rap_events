CLASS zcl_dmo_billomaterial DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    CLASS-METHODS create_for_process
      IMPORTING iv_process_id TYPE zr_dmo_processbo-processid.

  PRIVATE SECTION.
    CLASS-METHODS call_bom_bapi_in_level_b
      IMPORTING iv_material              TYPE zr_dmo_processbo-Material
      RETURNING VALUE(rv_billofmaterial) TYPE zr_dmo_processbo-BillOfMaterial.
ENDCLASS.


CLASS zcl_dmo_billomaterial IMPLEMENTATION.
  METHOD create_for_process.

    DATA process_update TYPE TABLE FOR UPDATE ZR_DMO_ProcessBO\\ProcessBO.

    READ ENTITIES OF ZR_DMO_ProcessBO
         ENTITY ProcessBO
         ALL FIELDS WITH VALUE #( ( %key-ProcessID = iv_process_id ) )
         RESULT DATA(process_read_result)
         FAILED FINAL(failed).
    ASSERT failed IS INITIAL.

    LOOP AT process_read_result INTO DATA(process).

      DATA(lv_bom_created) = call_bom_bapi_in_level_b( iv_material = process-Material ).

      APPEND INITIAL LINE TO process_update ASSIGNING FIELD-SYMBOL(<process_update>).
      <process_update> = VALUE #( %tky           = process-%tky
                                  BillOfMaterial = lv_bom_created
                                  Status         = 'BOM_OK'
                                  %control       = VALUE #( BillOfMaterial = if_abap_behv=>mk-on
                                                            Status         = if_abap_behv=>mk-on ) ).

    ENDLOOP.

    IF zif_dmo_control=>c_cloud = abap_false.
      MODIFY ENTITIES OF ZR_DMO_ProcessBO
             ENTITY ProcessBO
             UPDATE FROM process_update.
    ELSEIF zif_dmo_control=>c_optimized = abap_true.
      zbp_r_dmo_processbo=>raise_new_status( it_update = process_update ).
    ELSE.
      zbp_r_dmo_processbo=>raise_update_status( it_update = process_update ).
    ENDIF.

  ENDMETHOD.

  METHOD call_bom_bapi_in_level_b.

    CALL FUNCTION 'Z_DMO_BAPI_BOM'
      EXPORTING  iv_material       = iv_material
                 iv_description    = CONV zdmo_char50( |Bom for { iv_material }| )
      IMPORTING  ev_billofmaterial = rv_billofmaterial
      EXCEPTIONS material_unknown  = 1
                 OTHERS            = 2.

    IF sy-subrc <> 0.
      " TODO: Implement Error-Handling here  :-P
    ENDIF.

  ENDMETHOD.
ENDCLASS.
