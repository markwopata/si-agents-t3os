view: sub_categories {
  derived_table: {
    # datagroup_trigger: 6AM_update
    sql: select
        x.equipment_model_id,
        ec.equipment_class_id,
        c.parent_category_id,
        c.name as sub_category_name,
        c.category_id,
        c.company_division_id
      from ES_WAREHOUSE.PUBLIC.EQUIPMENT_MODELS m
      left join ES_WAREHOUSE.PUBLIC.EQUIPMENT_CLASSES_MODELS_XREF x on x.EQUIPMENT_MODEL_ID = m.EQUIPMENT_MODEL_ID
      left join ES_WAREHOUSE.PUBLIC.EQUIPMENT_CLASSES ec on ec.EQUIPMENT_CLASS_ID = x.EQUIPMENT_CLASS_ID
      left join ES_WAREHOUSE.PUBLIC.categories c on ec.category_id = c.category_id
      where
        c.active = true
        and c.parent_category_id is not null
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

  dimension: sub_category_name {
    type: string
    sql: ${TABLE}."SUB_CATEGORY_NAME" ;;
  }

  dimension: category_id {
    type: number
    sql: ${TABLE}."CATEGORY_ID" ;;
  }

  dimension: company_division_id {
    type: number
    sql: ${TABLE}."COMPANY_DIVISION_ID" ;;
  }

  dimension: equipment_model_id {
    type:number
    sql: ${TABLE}."EQUIPMENT_MODEL_ID" ;;
  }

  dimension: equipment_class_id {
    type: number
    sql: ${TABLE}."EQUIPMENT_CLASS_ID" ;;
  }

  set: detail {
    fields: [parent_category_id, sub_category_name, category_id, company_division_id]
  }
}
