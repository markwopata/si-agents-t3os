view: asset_finance_type {
  derived_table: {
    sql:
  select
      a.asset_id
      ,d.financing_facility_type
      from ES_WAREHOUSE.public.assets a
      left join ES_WAREHOUSE.public.asset_purchase_history aph
        on a.asset_id = aph.asset_id
      left join analytics.debt.phoenix_id_types pit
        on aph.financial_schedule_id  = pit.financial_schedule_id
      left join (select  distinct phoenix_id, financing_facility_type
            from analytics.debt.tv6_xml_debt_table_current
            where current_version = 'Yes') d
         on pit.phoenix_id  = d.phoenix_id
       ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: asset_id {
    type: number
    sql: ${TABLE}."ASSET_ID" ;;
  }

  dimension: financing_facility_type {
    type: string
    sql: ${TABLE}."FINANCING_FACILITY_TYPE" ;;
  }

  set: detail {
    fields: [asset_id, financing_facility_type]
  }
}
