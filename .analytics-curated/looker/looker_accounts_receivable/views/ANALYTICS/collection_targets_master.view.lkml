view: collection_targets_master {
  sql_table_name: "ANALYTICS"."TREASURY"."COLLECTION_TARGETS_MASTER" ;;

  ######## DIMENSIONS ########

  dimension: branch_id {
    type: string
    value_format_name:  id
    sql: ${TABLE}."BRANCH_ID" ;;
  }

  dimension: branch_name {
    type: string
    sql: ${TABLE}."BRANCH_NAME" ;;
  }

  dimension: collector_manager {
    type: string
    sql: ${TABLE}."COLLECTOR_MANAGER" ;;
  }

  dimension: district_sales_manager {
    type: string
    sql: ${TABLE}."DISTRICT_SALES_MANAGER" ;;
  }

  dimension: individual_collector {
    type: string
    sql: ${TABLE}."INDIVIDUAL_COLLECTOR" ;;
  }

  dimension: region {
    type: string
    value_format_name:  id
    sql: ${TABLE}."REGION" ;;
  }

  dimension: region_name {
    type: string
    sql: ${TABLE}."REGION_NAME" ;;
  }

  dimension: region_district {
    type: string
    sql: ${TABLE}."REGION_DISTRICT" ;;
  }

  dimension: regional_sales_manager {
    type: string
    sql: ${TABLE}."REGIONAL_SALES_MANAGER" ;;
  }

  dimension: salesperson_name {
    type: string
    sql: ${TABLE}."SALESPERSON_NAME" ;;
  }

  dimension: salesperson_user_id {
    type: string
    sql: ${TABLE}."SALESPERSON_USER_ID" ;;
  }

  ######## PRIMARY KEY ########
  dimension: key {
    type: string
    primary_key: yes
    sql: ${branch_id}||'-'|| ${salesperson_user_id} ;;
  }

  ######## MEASURES ########

  measure: branch_collection_target {
    type: sum
    value_format_name: usd_0
    sql: ${TABLE}."BRANCH_COLLECTION_TARGET" ;;
  }

  measure: branch_collection_target_average {
    type: average
    value_format_name: usd_0
    sql: ${TABLE}."BRANCH_COLLECTION_TARGET" ;;
  }

  measure: salesperson_collections_target {
    type: sum
    value_format_name: usd_0
    sql: ${TABLE}."SALESPERSON_COLLECTIONS_TARGET" ;;
  }

  measure: amount_to_be_collected {
    type: number
    sql: iff(${salesperson_collections_target} - ${collections_actuals.collections}<=0,0,${salesperson_collections_target} - ${collections_actuals.collections}) ;;
    value_format_name: usd_0
  }


  measure: run_rate_collections {
    label: "Run Rate Collections"
    type: number
    sql: (${collections_actuals.collections} / (datediff(day,'2024-01-01',current_date) +1)) * 91 ;;
    value_format_name: usd_0
  }

  measure: amount_to_be_collected_run_rate {
    label: "Amount to be Collected"
    type: number
    sql: iff(${salesperson_collections_target} - ${run_rate_collections}<=0,0,${salesperson_collections_target} - ${run_rate_collections}) ;;
    value_format_name: usd_0
  }

}
