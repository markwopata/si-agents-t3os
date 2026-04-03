view: collectors_customer_flag_list {
  derived_table: {
    # datagroup_trigger: Every_Hour_Update
    sql: with company_list as (SELECT name, company_id
                      from ES_WAREHOUSE.PUBLIC.companies),
     legal_customers as (select C.COMPANY_ID, 'Legal' is_legal
                         from es_warehouse.public.billing_company_preferences as legal
                                  inner join ES_WAREHOUSE.PUBLIC.COMPANIES as c
                                             on c.company_id = legal.COMPANY_ID
                         where legal.prefs:legal_audit = true)
SELECT c.name,
       c.company_id,
       lc.is_legal AS customer_flag
FROM company_list c
         LEFT JOIN legal_customers lc
                   ON c.company_id::text = lc.COMPANY_ID
WHERE lc.is_legal is not null
UNION
SELECT c.name,
       c.company_id,
       'Not Legal'
FROM company_list c
         LEFT JOIN collector_cust_flags cf
                   ON c.company_id::text = cf.customer_id
         LEFT JOIN legal_customers lc
                   on lc.COMPANY_ID = c.COMPANY_ID
WHERE lc.is_legal is null
 ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: name {
    type: string
    sql: ${TABLE}."NAME" ;;
  }

  dimension: legal_flag {
    type: string
    sql: IFF(${customer_flag} = 'Legal', 'LEGAL', '') ;;
  }

  dimension: company_id {
    type: number
    sql: ${TABLE}."COMPANY_ID" ;;
  }

  dimension: customer_flag {
    type: string
    sql: ${TABLE}."CUSTOMER_FLAG" ;;
  }

  set: detail {
    fields: [name, company_id, customer_flag]
  }
}
