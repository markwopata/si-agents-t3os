
view: heap_job_title_export {
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
          u.user_id,
          cd.employee_title,
          cd.location,
          RIGHT(cd.default_cost_centers_full_path, POSITION('/' IN REVERSE(cd.default_cost_centers_full_path)) - 1) as cost_center,
          IFF(da.company_name IS NULL,FALSE,TRUE) is_demo_company,
          IFF(vip.vip_customer = TRUE,TRUE,FALSE) is_vip_company,
          IFF(vip.t3aas_customer = TRUE,TRUE,FALSE) is_t3_company
      from
          es_warehouse.public.users u
          left join analytics.payroll.company_directory cd on lower(cd.work_email) = lower(u.email_address) AND cd.employee_status IN ('Active', 'Leave without Pay', 'Leave with Pay', 'Military Training Program', 'Work Comp Leave', 'External Payroll')
          left join ANALYTICS.T3_ANALYTICS.VW_DEMO_ACCOUNTS da on da.company_id = u.company_id
          left join vip_list vip on TRY_CAST(vip.company_id AS NUMBER) = u.company_id
      where
          u.deleted = false
          AND lower(u.username) not like '%customersupport%' ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: user_id {
    type: number
    sql: ${TABLE}."USER_ID" ;;
  }

  dimension: employee_title {
    type: string
    sql: ${TABLE}."EMPLOYEE_TITLE" ;;
  }

  dimension: location {
    type: string
    sql: ${TABLE}."LOCATION" ;;
  }

  dimension: cost_center {
    type: string
    sql: ${TABLE}."COST_CENTER" ;;
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
      user_id,
      employee_title,
      location,
      cost_center,
      is_demo_company,
      is_vip_company,
      is_t3_company
    ]
  }
}
