view: corporate_open_reqs {
  sql_table_name: "PEOPLE_ANALYTICS"."LOOKER"."CORPORATE_OPEN_REQS" ;;

  dimension: open_req_ids {
    type: number
    sql: ${TABLE}."OPEN_REQ_IDS" ;;
  }
  dimension: department {
    type: string
    sql: ${TABLE}."DEPARTMENT" ;;
  }
  dimension: sub_department {
    type: string
    sql: ${TABLE}."SUB_DEPARTMENT" ;;
  }
}
