CLASS zcl_dmo_process_notification DEFINITION
  PUBLIC
  INHERITING FROM /iwngw/cl_notif_provider_abs FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    CLASS-METHODS send_notification IMPORTING iv_process_id TYPE ZR_DMO_ProcessBO-ProcessID.

    METHODS /iwngw/if_notif_provider_ext~get_notification_type       REDEFINITION.
    METHODS /iwngw/if_notif_provider_ext~get_notification_type_text  REDEFINITION.
    METHODS /iwngw/if_notif_provider_ext~get_notification_parameters REDEFINITION.
    METHODS /iwngw/if_notif_provider_ext~handle_action               REDEFINITION.

  PROTECTED SECTION.

  PRIVATE SECTION.
ENDCLASS.


CLASS zcl_dmo_process_notification IMPLEMENTATION.
  METHOD /iwngw/if_notif_provider_ext~get_notification_type.
    es_notification_type-is_groupable = abap_true.
    es_notification_type-type_key     = iv_type_key.
    es_notification_type-version      = iv_type_version.
    et_notification_action = VALUE #( ( action_key = 'retry'
                                        nature     = /iwngw/if_notif_provider=>gcs_action_natures-neutral  )
                                      ( action_key = 'create_template'
                                        nature     = /iwngw/if_notif_provider=>gcs_action_natures-positive ) ).
  ENDMETHOD.

  METHOD /iwngw/if_notif_provider_ext~get_notification_type_text.
    DATA lv_text      TYPE string.
    DATA lv_subtitle  TYPE string.
    DATA ls_Type_text TYPE /iwngw/if_notif_provider_ext=>ty_s_notification_type_text.

    CLEAR et_type_text.
    lv_text = 'Error automated Material creation for SalesOrder {sales_order}'.
    lv_subtitle = 'We tried to automatically trigger the creation of Material, but the required template was not found.'.

    ls_type_text-name  = /iwngw/if_notif_provider_ext=>gc_template_names-template_public.
    ls_type_text-value = lv_text.
    APPEND ls_type_text TO et_type_text.

    ls_type_text-name  = /iwngw/if_notif_provider_ext=>gc_template_names-template_sensitive.
    ls_type_text-value = lv_text.
    APPEND ls_type_text TO et_type_text.

    ls_type_text-name  = /iwngw/if_notif_provider_ext=>gc_template_names-template_grouped.
    ls_type_text-value = 'Automated Material Creation'.
    APPEND ls_type_text TO et_type_text.

    ls_type_text-name  = /iwngw/if_notif_provider_ext=>gc_template_names-subtitle.
    ls_type_text-value = lv_subtitle.
    APPEND ls_type_text TO et_type_text.

    APPEND INITIAL LINE TO et_action_text ASSIGNING FIELD-SYMBOL(<fs_action>).
    <fs_action> = VALUE #( action_key           = 'retry'
                           display_text         = 'Retry'
                           display_text_grouped = 'Retry all' ).
    APPEND INITIAL LINE TO et_action_text ASSIGNING <fs_action>.
    <fs_action> = VALUE #( action_key           = 'create_template'
                           display_text         = 'Create Template'
                           display_text_grouped = 'Create Template All' ).
  ENDMETHOD.

  METHOD send_notification.
    DATA lt_nf TYPE /iwngw/if_notif_provider=>ty_t_notification.
    DATA ls_nf LIKE LINE OF lt_nf.

    ls_nf = VALUE #( id           = iv_process_id
                     type_key     = 'ZCL_DMO_PROCESS_NOTIFICATION'
                     type_version = 1
                     recipients   = VALUE #( ( id = sy-uname ) ) ).
    APPEND ls_nf TO lt_nf.

    TRY.
        /iwngw/cl_notification_api=>create_notifications( iv_provider_id  = 'ZCL_DMO_PROCESS_NOTIFICATION'
                                                          it_notification = lt_nf ).

      CATCH /iwngw/cx_notification_api INTO DATA(lrx_api). " TODO: variable is assigned but never used (ABAP cleaner)
        RETURN.
    ENDTRY.
  ENDMETHOD.

  METHOD /iwngw/if_notif_provider_ext~get_notification_parameters.
    CLEAR et_parameter.

    READ ENTITIES OF ZR_DMO_ProcessBO
         ENTITY ProcessBO
         ALL FIELDS
         WITH VALUE #( FOR row IN it_notif
                       ( %key-ProcessID = row-id ) )
         RESULT FINAL(lt_processes).

    LOOP AT it_notif ASSIGNING FIELD-SYMBOL(<ls_notif>).
      APPEND INITIAL LINE TO et_parameter ASSIGNING FIELD-SYMBOL(<fs_parameter>).
      <fs_parameter>-id           = <ls_notif>-id.
      <fs_parameter>-type_key     = <ls_notif>-type_key.
      <fs_parameter>-type_version = <ls_notif>-type_version.
      <fs_parameter>-name         = 'sales_order'.
      <fs_parameter>-type         = /iwngw/if_notif_provider=>gcs_parameter_types-type_string.
      <fs_parameter>-value        = lt_processes[ KEY entity
                                                  ProcessID = <ls_notif>-id ]-Salesorder.
      <fs_parameter>-is_sensitive = abap_false.
      <fs_parameter>-language     = sy-langu.
    ENDLOOP.
  ENDMETHOD.

  METHOD /iwngw/if_notif_provider_ext~handle_action.

    zcl_dmo_material=>create_for_process( iv_process_id = CONV #( iv_notification_id ) ).
    es_result = VALUE #( success          = abap_true
                         delete_on_return = abap_true
                         action_msg_txt   = 'Retry successful!' ).

  ENDMETHOD.
ENDCLASS.
