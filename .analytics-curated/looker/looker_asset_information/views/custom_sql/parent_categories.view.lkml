view: parent_categories {
  derived_table: {
    # datagroup_trigger: 6AM_update
    sql: select
        parent_category_id,
        name as parent_category_name,
        category_id,
        company_division_id
      from
        ES_WAREHOUSE.PUBLIC.categories c
      where
        -- active = true
        -- Commented out where active = true per Ryan Bernhard request Help Looker 02/24/25
        parent_category_id is null
 ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: parent_category_id {
    type: number
    sql: ${TABLE}."PARENT_CATEGORY_ID" ;;
  }

  dimension: parent_category_name {
    type: string
    sql: ${TABLE}."PARENT_CATEGORY_NAME" ;;
  }

  dimension: category_id {
    type: number
    sql: ${TABLE}."CATEGORY_ID" ;;
  }

  dimension: company_division_id {
    type: number
    sql: ${TABLE}."COMPANY_DIVISION_ID" ;;
  }

  set: detail {
    fields: [parent_category_id, parent_category_name, category_id, company_division_id]
  }
}
