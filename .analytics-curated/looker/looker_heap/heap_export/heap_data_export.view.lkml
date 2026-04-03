
view: heap_data_export {
  derived_table: {
    sql: with vip_list as (
      select
          hsc.property_es_admin_id as company_id,
          IFF(hsc.property_t_3_subscriber_status like '%VIP%',TRUE,FALSE) as vip_customer,
          IFF(hsc.property_t_3_subscriber_status like '%T3aaS%',TRUE,FALSE) as t3aas_customer,
          ROW_NUMBER() OVER (PARTITION BY hsc.property_es_admin_id ORDER BY hsc.property_createdate desc) as row_num
      from
          ANALYTICS.HUBSPOT_CUSTOMER_SUCCESS.COMPANY hsc
          join es_warehouse.public.companies c on hsc.property_es_admin_id::text = c.company_id::text
      where
          (hsc.property_es_admin_id is not null or hsc.property_es_admin_id <> '')
          AND hsc.is_deleted = FALSE
          AND hsc.property_t_3_subscriber_status like '%Current T3 Customer%'
      qualify
          row_num = 1
      )
      select
        c.company_id,
        c.name,
        IFF(da.company_name IS NULL,FALSE,TRUE) is_demo_company,
        IFF(vip.vip_customer = TRUE,TRUE,FALSE) is_vip_company,
        IFF(vip.t3aas_customer = TRUE,TRUE,FALSE) is_t3_company
      from
        es_warehouse.public.companies c
        left join ANALYTICS.T3_ANALYTICS.VW_DEMO_ACCOUNTS da on da.company_id = c.company_id
        left join vip_list vip on TRY_CAST(vip.company_id AS NUMBER) = c.company_id ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: company_id {
    label: "Company Id"
    type: number
    sql: ${TABLE}."COMPANY_ID" ;;
  }

  dimension: name {
    type: string
    sql: ${TABLE}."NAME" ;;
  }

  dimension: is_demo_company {
    type: yesno
    sql: ${TABLE}."IS_DEMO_COMPANY" ;;
  }

  dimension: is_vip_company {
    type: yesno
    sql: ${TABLE}."IS_VIP_COMPANY" ;;
  }

  dimension: is_t3_company {
    type: yesno
    sql: ${TABLE}."IS_T3_COMPANY" ;;
  }

  set: detail {
    fields: [
        company_id,
  name,
  is_demo_company,
  is_vip_company,
  is_t3_company
    ]
  }
}
