view: credit_amount_summarized {
  derived_table: {
    # datagroup_trigger: Every_Hour_Update
    sql: select
        c.company_id,
        c.name as company_name,
        sum(cn.remaining_credit_amount) as total_credit_amount_available
      from
        ES_WAREHOUSE.PUBLIC.companies c
        left join ES_WAREHOUSE.PUBLIC.credit_notes cn on c.company_id = cn.company_id
      where
        cn.remaining_credit_amount > 0
        and (datediff(day,date_created::date,current_date())) >= 0
      group by
        c.company_id,
        c.name
 ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: company_id {
    primary_key: yes
    type: number
    sql: ${TABLE}."COMPANY_ID" ;;
  }

  dimension: company_name {
    type: string
    sql: ${TABLE}."COMPANY_NAME" ;;
  }

  dimension: total_credit_amount_available {
    type: number
    sql: ${TABLE}."TOTAL_CREDIT_AMOUNT_AVAILABLE" ;;
  }

  measure: credit_amount_available {
    type: sum
    sql: ${total_credit_amount_available} ;;
    value_format_name: usd_0
  }

  set: detail {
    fields: [company_id, company_name, total_credit_amount_available]
  }
}
