@AccessControl.authorizationCheck: #CHECK

@EndUserText.label: '##GENERATED SalesOrder'

define root view entity ZR_DMO_SALESORDER
  as select from zdmo_salesorder as SalesOrder

{
      @EndUserText.label: 'SalesOrder-ID'
  key salesorder            as Salesorder,

      customer              as Customer,
      material_text         as MaterialText,

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
