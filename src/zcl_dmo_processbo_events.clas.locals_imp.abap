CLASS leh_zr_dmo_process DEFINITION INHERITING FROM cl_abap_behavior_event_handler.

  PRIVATE SECTION.
    METHODS handle_process_started FOR ENTITY EVENT IMPORTING it_param FOR ProcessBo~processStarted.
    METHODS handle_material_created FOR ENTITY EVENT IMPORTING it_param FOR ProcessBo~materialCreated.
    METHODS handle_bom_created FOR ENTITY EVENT IMPORTING it_param FOR ProcessBo~bomCreated.
    METHODS handle_status_update FOR ENTITY EVENT IMPORTING it_param FOR ProcessBO~updateStatus.
    METHODS handle_material_create_error FOR ENTITY EVENT it_param FOR ProcessBO~materialCreateError.

ENDCLASS.


CLASS leh_zr_dmo_process IMPLEMENTATION.
  METHOD handle_process_started.

    IF zif_dmo_control=>c_cloud = abap_true.
      cl_abap_tx=>save( ).
    ENDIF.

    LOOP AT it_param INTO DATA(param).

      zcl_dmo_material=>create_for_process( iv_process_id = param-ProcessID ).

    ENDLOOP.

  ENDMETHOD.

  METHOD handle_bom_created.

    " Image here a happy Unicorn farting rainbows jumping across your screen

  ENDMETHOD.

  METHOD handle_material_created.

    IF zif_dmo_control=>c_cloud = abap_true.
      cl_abap_tx=>save( ).
    ENDIF.

    LOOP AT it_param INTO DATA(param).

      zcl_dmo_billomaterial=>create_for_process( iv_process_id = param-ProcessID ).

    ENDLOOP.

  ENDMETHOD.

  METHOD handle_status_update.

    DATA process_update TYPE TABLE FOR UPDATE ZR_DMO_ProcessBO\\ProcessBO.

    LOOP AT it_param INTO DATA(ls_param).

      APPEND INITIAL LINE TO process_update ASSIGNING FIELD-SYMBOL(<update>).

      IF ls_param-status = 'MAT_ERR'.
        <update> = VALUE #( %key             = VALUE #( ProcessID = ls_param-ProcessID )
                            errorDescription = ls_param-error_description
                            Status           = ls_param-status
                            %control         = VALUE #( errorDescription = if_abap_behv=>mk-on
                                                        status           = if_abap_behv=>mk-on ) ).
      ELSEIF ls_param-status = 'BOM_OK'.
        <update> = VALUE #( %key           = VALUE #( ProcessID = ls_param-ProcessID )
                            Status         = ls_param-status
                            BillOfMaterial = ls_param-billofmaterial
                            %control       = VALUE #( BillOfMaterial = if_abap_behv=>mk-on
                                                      Status         = if_abap_behv=>mk-on ) ).
      ELSEIF ls_param-status = 'MAT_OK'.
        <update> = VALUE #( %key             = VALUE #( ProcessID = ls_param-ProcessID )
                            errorDescription = ls_param-error_description
                            material         = ls_param-material
                            Status           = ls_param-status
                            %control         = VALUE #( material         = if_abap_behv=>mk-on
                                                        errorDescription = if_abap_behv=>mk-on
                                                        status           = if_abap_behv=>mk-on ) ).
      ENDIF.

    ENDLOOP.

    MODIFY ENTITIES OF ZR_DMO_ProcessBO
           ENTITY ProcessBO
           UPDATE FROM process_update.

  ENDMETHOD.

  METHOD handle_material_create_error.

    IF zif_dmo_control=>c_cloud = abap_true.
      cl_abap_tx=>save( ).
    ENDIF.

    LOOP AT it_param INTO DATA(ls_param).

      zcl_dmo_process_notification=>send_notification( iv_process_id = ls_param-ProcessID ).

    ENDLOOP.

  ENDMETHOD.

ENDCLASS.
