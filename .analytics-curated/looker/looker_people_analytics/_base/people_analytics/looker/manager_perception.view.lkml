view: manager_perception {
  sql_table_name: "LOOKER"."MANAGER_PERCEPTION" ;;

  dimension: avg_great_job_managing_the_work {
    type: number
    sql: ${TABLE}."AVG_GREAT_JOB_MANAGING_THE_WORK" ;;
  }
  dimension: avg_great_job_people_management {
    type: number
    sql: ${TABLE}."AVG_GREAT_JOB_PEOPLE_MANAGEMENT" ;;
  }
  dimension: avg_manager_available_to_address_needs {
    type: number
    sql: ${TABLE}."AVG_MANAGER_AVAILABLE_TO_ADDRESS_NEEDS" ;;
  }
  dimension: avg_trust_manager {
    type: number
    sql: ${TABLE}."AVG_TRUST_MANAGER" ;;
  }
  dimension: fav_great_job_managing_the_work {
    type: number
    sql: ${TABLE}."FAV_GREAT_JOB_MANAGING_THE_WORK" ;;
  }
  dimension: fav_great_job_people_management {
    type: number
    sql: ${TABLE}."FAV_GREAT_JOB_PEOPLE_MANAGEMENT" ;;
  }
  dimension: fav_manager_available_to_address_needs {
    type: number
    sql: ${TABLE}."FAV_MANAGER_AVAILABLE_TO_ADDRESS_NEEDS" ;;
  }
  dimension: fav_trust_manager {
    type: number
    sql: ${TABLE}."FAV_TRUST_MANAGER" ;;
  }
  dimension: manager_eid {
    type: string
    sql: ${TABLE}."MANAGER_EID" ;;
  }
  dimension: resp_great_job_managing_the_work {
    type: number
    sql: ${TABLE}."RESP_GREAT_JOB_MANAGING_THE_WORK" ;;
  }
  dimension: resp_great_job_people_management {
    type: number
    sql: ${TABLE}."RESP_GREAT_JOB_PEOPLE_MANAGEMENT" ;;
  }
  dimension: resp_manager_available_to_address_needs {
    type: number
    sql: ${TABLE}."RESP_MANAGER_AVAILABLE_TO_ADDRESS_NEEDS" ;;
  }
  dimension: resp_trust_manager {
    type: number
    sql: ${TABLE}."RESP_TRUST_MANAGER" ;;
  }
  measure: count {
    type: count
  }
}
