view: vendor_history {
  derived_table: {
    sql: SELECT
            VEND_HIST.VENDOR_ID,
            VEND_HIST.NAME,
            VEND_HIST.STATUS,
            VEND_HIST.TYPE,
            VEND_HIST.CATEGORY,
            VEND_HIST.PAY_METHOD,
            VEND_HIST.ALT_PAY_METHOD,
            VEND_HIST.TERMNAME,
            VEND_HIST.REPORTING_CATEGORY,
            VEND_HIST.WHEN_CREATED,
            VEND_HIST.WHEN_MODIFIED,
            VEND_HIST.AS_OF_DATE
        FROM
          ANALYTICS.FINANCIAL_SYSTEMS.VENDOR_HISTORY VEND_HIST
      ;;
  }

  measure: count {type: count drill_fields: [detail*]}
  dimension: vendor_id {type: string primary_key: yes sql: ${TABLE}."VENDOR_ID" ;;}
  dimension: name {type: string sql: ${TABLE}."NAME" ;;}
  dimension: status {type: string sql: ${TABLE}."STATUS" ;;}
  dimension: type {type: string sql: ${TABLE}."TYPE" ;;}
  dimension: category {type: string sql: ${TABLE}."CATEGORY" ;;}
  dimension: pay_method {type: string sql: ${TABLE}."PAY_METHOD" ;;}
  dimension: alt_pay_method {type: string sql: ${TABLE}."ALT_PAY_METHOD" ;;}
  dimension: termname {type: string sql: ${TABLE}."TERMNAME" ;;}
  dimension: reporting_category {type: string sql: ${TABLE}."REPORTING_CATEGORY" ;;}
  dimension: when_created {type: date_time sql: ${TABLE}."WHEN_CREATED" ;;}
  dimension: when_modified {type: date_time sql: ${TABLE}."WHEN_MODIFIED" ;;}
  dimension: as_of_date {convert_tz: no type: date sql: ${TABLE}."AS_OF_DATE" ;;}
  dimension: as_of {type: string sql: ${TABLE}."AS_OF_DATE" ;;}

  set: detail {
    fields: [
        vendor_id,
        name,
        status,
        type,
        category,
        pay_method,
        alt_pay_method,
        termname,
        reporting_category,
        when_created,
        when_modified,
        as_of_date,
        as_of
    ]
  }
}
