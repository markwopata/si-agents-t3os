view: collectors_customer_flag_list {
  derived_table: {
    # datagroup_trigger: Every_Hour_Update
    sql: with company_list as (
              SELECT name, company_id from ES_WAREHOUSE.PUBLIC.companies
              )
              SELECT
                  c.name,
                  c.company_id,
                  cf.dnc AS customer_flag
              FROM
                company_list c
                LEFT JOIN collector_cust_flags cf ON c.company_id::text = cf.customer_id
              WHERE
                cf.dnc is not null
              UNION
              SELECT
                  c.name,
                  c.company_id,
                  CASE WHEN cf.legal is null then 'Not Legal' ELSE cf.legal END
              FROM
                company_list c
                LEFT JOIN collector_cust_flags cf ON c.company_id::text = cf.customer_id
              UNION
              SELECT
                  c.name,
                  c.company_id,
                  cf.oil
              FROM
                company_list c
                LEFT JOIN collector_cust_flags cf ON c.company_id::text = cf.customer_id
              WHERE
                cf.oil is not null
              UNION
              SELECT
                  c.name,
                  c.company_id,
                  CASE WHEN cf.legal is null and cf.oil is null then 'Not Legal & Oil' END
              FROM
                company_list c
                LEFT JOIN collector_cust_flags cf ON c.company_id::text = cf.customer_id
              UNION
              SELECT
                  c.name,
                  c.company_id,
                  CASE WHEN cf.legal is null and cf.oil is null then 'Not Legal & Not Oil' END
              FROM
                company_list c
                LEFT JOIN collector_cust_flags cf ON c.company_id::text = cf.customer_id
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
