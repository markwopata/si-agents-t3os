view: v_dim_monday_transportation_audit {
  sql_table_name: "FLEET_OPTIMIZATION"."GOLD"."V_DIM_MONDAY_TRANSPORTATION_AUDIT" ;;

  dimension: pk_audit_id {
    type: string
    sql: ${TABLE}."PK_AUDIT_ID" ;;
  }
  dimension: transportation_audit_name {
    type: string
    sql: ${TABLE}."TRANSPORTATION_AUDIT_NAME" ;;
  }

  dimension: transportation_audit_process_score {
    type: number
    value_format_name: decimal_1
    sql: ${TABLE}."TRANSPORTATION_AUDIT_PROCESS_SCORE" ;;
  }
  dimension: transportation_audit_score {
    type: number
    value_format_name: percent_0
    sql: ${TABLE}."TRANSPORTATION_AUDIT_SCORE" / 100;;
  }
  dimension: transportation_audit_work_score {
    type: number
    value_format_name: decimal_1
    sql: ${TABLE}."TRANSPORTATION_AUDIT_WORK_SCORE" ;;
  }

  dimension: transportation_audit_status {
    type: string
    sql: ${TABLE}."TRANSPORTATION_AUDIT_STATUS" ;;
  }

  dimension: transportation_auditor {
    type: string
    sql: ${TABLE}."TRANSPORTATION_AUDITOR" ;;
  }

  measure: avg_transportation_audit_score {
    type: average
    value_format_name: percent_0
    sql: ${transportation_audit_score} ;;
    drill_fields: [market_details*]
  }
  measure: avg_transportation_audit_work_score {
    type: average
    value_format_name: decimal_1
    sql: ${transportation_audit_work_score} ;;
  }
  measure: avg_transportation_audit_process_score {
    type: average
    value_format_name: decimal_1
    sql: ${transportation_audit_process_score} ;;
  }
  measure: count_completed_audit {
    type: count
    filters: [transportation_audit_score: "not null", dim_dates_fleet_opt.dt_year: "this year"]
  }
  measure: count_total_pending {
    type: count
    filters: [transportation_audit_status: "Pending Schedule"]
  }
  measure: count_markets {
    type: count
    drill_fields: [transportation_audit_name]
  }
  measure: all_markets_rate {
    label:  "All Markets Completion or Pending Rates"
    type: number
    value_format_name: percent_1
    sql: (${count_completed_audit}+${count_total_pending}) / nullifzero(${count_markets}) ;;
  }
  measure: pending_schedule_rate {
    type: number
    value_format_name: percent_1
    sql: ${count_total_pending} / nullifzero(${count_markets}) ;;
  }
  measure: completed_scheduled_rate {
    type: number
    value_format_name: percent_1
    sql: ${count_completed_audit} / nullifzero(${count_completed_audit}+${count_total_pending});;
  }
  set: market_details {
    fields: [dim_markets_fleet_opt.market_name,
             dim_dates_fleet_opt.dt_date,
             transportation_audit_work_score,
             transportation_audit_process_score,
             transportation_audit_score,
             transportation_audit_status,
             transportation_auditor]
  }

}
view: branch_audit_rank {
  derived_table: {
    sql:
      select vdmta.pk_audit_id
           , ddfo.dt_date
           , dmfo.market_id
           , count(distinct vdmta.pk_audit_id) over (partition by dmfo.market_id) as market_audit_count
           , rank() over (partition by dmfo.market_id order by ddfo.dt_date asc) as audit_rank
      from fleet_optimization.gold.fact_monday_transportation_audit fmta -- magic happy link with all the linking keys
      join fleet_optimization.gold.v_dim_monday_transportation_audit vdmta -- monday board data
          on fmta.pk_audit_id = vdmta.PK_AUDIT_ID
      join fleet_optimization.gold.dim_dates_fleet_opt ddfo -- dates details
          on fmta.fk_date_key = ddfo.dt_key
      join fleet_optimization.gold.dim_markets_fleet_opt dmfo -- markets details
          on fmta.fk_market_key = dmfo.market_key
      group by vdmta.pk_audit_id, dmfo.market_id, ddfo.dt_date
    ;;
  }

  dimension: pk_audit_id {
    type: string
    sql: ${TABLE}.pk_audit_id ;;
    primary_key: yes
  }

  dimension: dt_date {
    type: date
    sql: ${TABLE}.dt_date ;;
  }

  dimension: market_id {
    type: string
    sql: ${TABLE}.market_id ;;
  }

  dimension: market_audit_count {
    type: number
    sql: ${TABLE}.market_audit_count ;;
  }

  dimension: audit_rank {
    type: number
    sql: ${TABLE}.audit_rank ;;
  }


}
