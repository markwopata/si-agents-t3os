view: costentory__stores {
  sql_table_name: "COSTENTORY_GOLD"."COSTENTORY__STORES" ;;

  dimension: pk_store_id {
    primary_key: yes
    type: string
    sql: ${TABLE}."PK_STORE_ID" ;;
  }

  dimension: name_store {
    type: string
    sql: ${TABLE}."NAME_STORE" ;;
  }

  dimension: name_store_type {
    type: string
    sql: ${TABLE}."NAME_STORE_TYPE" ;;
  }

  dimension: name_branch {
    type: string
    sql: ${TABLE}."NAME_BRANCH" ;;
  }

  dimension: name_parent_store_branch {
    type: string
    sql: ${TABLE}."NAME_PARENT_STORE_BRANCH" ;;
  }

  dimension: name_effective_branch {
    type: string
    sql: ${TABLE}."NAME_EFFECTIVE_BRANCH" ;;
  }

  dimension: fk_company_id {
    type: string
    sql: ${TABLE}."FK_COMPANY_ID" ;;
  }

  dimension: fk_store_type_id {
    type: string
    sql: ${TABLE}."FK_STORE_TYPE_ID" ;;
  }

  dimension: fk_parent_store_id {
    type: string
    sql: ${TABLE}."FK_PARENT_STORE_ID" ;;
  }

  dimension: fk_branch_id {
    type: string
    sql: ${TABLE}."FK_BRANCH_ID" ;;
  }

  dimension: fk_parent_store_branch_id {
    type: string
    sql: ${TABLE}."FK_PARENT_STORE_BRANCH_ID" ;;
  }

  dimension: fk_effective_branch_id {
    type: string
    sql: ${TABLE}."FK_EFFECTIVE_BRANCH_ID" ;;
  }

  dimension: fk_inventory_type_id {
    type: string
    sql: ${TABLE}."FK_INVENTORY_TYPE_ID" ;;
  }

  dimension_group: timestamp_created {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}."TIMESTAMP_CREATED" ;;
  }

  dimension_group: timestamp_modified {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}."TIMESTAMP_MODIFIED" ;;
  }

  dimension_group: timestamp_archived {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}."TIMESTAMP_ARCHIVED" ;;
  }

  dimension_group: timestamp_loaded {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}."TIMESTAMP_LOADED" ;;
  }

  measure: count {
    type: count
  }
}
