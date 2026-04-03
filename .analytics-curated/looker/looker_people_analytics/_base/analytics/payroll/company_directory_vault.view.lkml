view: company_directory_vault {
  derived_table: {
    sql:
      SELECT
        employee_id,
        first_name,
        last_name,
        pay_calc,
        employee_status,
        _es_update_timestamp,
        CAST(_es_update_timestamp AS DATE) as _es_update_timestamp_date
      FROM analytics.payroll.company_directory_vault
      QUALIFY ROW_NUMBER() OVER (
        PARTITION BY employee_id, CAST(_es_update_timestamp AS DATE)
        ORDER BY _es_update_timestamp ASC
      ) = 1
      ORDER BY employee_id, _es_update_timestamp desc
      ;;
  }

  dimension: employee_id {
    type: number
    sql: ${TABLE}.employee_id ;;
  }

  dimension: first_name {
    type: string
    sql: ${TABLE}.first_name ;;
  }

  dimension: last_name {
    type: string
    sql: ${TABLE}.last_name ;;
  }

  dimension: pay_calc {
    type: string
    sql: ${TABLE}.pay_calc ;;
  }

  dimension: employee_status {
    type: string
    sql: ${TABLE}.employee_status ;;
  }

  dimension: _es_update_timestamp {
    type: date
    sql: ${TABLE}._es_update_timestamp ;;
  }

  dimension: _es_update_timestamp_date {
    type: date
    sql: ${TABLE}._es_update_timestamp_date ;;
  }




}
