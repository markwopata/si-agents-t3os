view: payout_programs {
sql_table_name: "ES_WAREHOUSE"."PUBLIC"."PAYOUT_PROGRAMS" ;;

dimension: payout_program_id {
  type: number
  value_format_name: id
  sql: ${TABLE}.payout_program_id ;;
}

  dimension: payout_program {
    type: string
    sql: ${TABLE}.name;;
  }
}
