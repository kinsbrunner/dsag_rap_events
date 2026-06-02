@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: '##GENERATED Design'
define root view entity ZR_DMO_ProcessBO
  as select from zdmo_procbo as ProcessBO
{
      @EndUserText.label: 'Process-ID'
  key process_id            as ProcessID,
      status                as Status,
      @EndUserText.label: 'Error Description'
      error_description     as errorDescription,
      design_team           as DesignTeam,
      salesorder            as Salesorder,
      material              as Material,
      billofmaterial        as Billofmaterial,
      @Semantics.user.createdBy: true
      created_by            as CreatedBy,
      @Semantics.systemDateTime.createdAt: true
      created_at            as CreatedAt,
      @Semantics.systemDateTime.lastChangedAt: true
      last_changed_at       as LastChangedAt,
      @Semantics.user.lastChangedBy: true
      last_changed_by       as LastChangedBy,
      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      local_last_changed_at as LocalLastChangedAt

}
