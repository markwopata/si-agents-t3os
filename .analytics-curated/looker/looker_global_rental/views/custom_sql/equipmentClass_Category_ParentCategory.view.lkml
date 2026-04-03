view: equipmentclass_category_parentcategory {
  derived_table: {
    sql:
      select    distinct a.asset_type_id,
          initcap(aty.name) as asset_type,
          coalesce(ec.equipment_class_id, -1) as equipment_class_id,
          coalesce(ec.name, 'No Class Assigned') as asset_class,
          coalesce(ec.category_id, -1) as category_id,
          coalesce(cat.name, 'No Category Assigned') as category,
          coalesce(cat.parent_category_id, -1) as parent_category,
          coalesce(cat2.name, 'No Parent Assigned') as parent_category
      from ES_WAREHOUSE.PUBLIC.equipment_classes ec
          left join ES_WAREHOUSE.PUBLIC.categories cat on ec.category_id = cat.category_id
          left join ES_WAREHOUSE.PUBLIC.categories cat2 on cat.parent_category_id = cat2.category_id
          left join ES_WAREHOUSE.PUBLIC.assets a on ec.equipment_class_id = a.equipment_class_id
          left join ES_WAREHOUSE.PUBLIC.asset_types aty on a.asset_type_id = aty.asset_type_id
      where a.company_id = {{ _user_attributes['company_id'] }}
    ;;
  }

  dimension: equipment_class_id {
    primary_key: yes
    type: number
    sql: ${TABLE}."EQUIPMENT_CLASS_ID";;
    value_format_name: id
  }

  dimension: asset_class {
    type: string
    sql: ${TABLE}."ASSET_CLASS";;
  }

  dimension: asset_type_id {
    type: number
    sql: ${TABLE}."ASSET_TYPE_ID";;
    value_format_name: id
  }

  dimension: asset_type {
    type: string
    sql: ${TABLE}."ASSET_TYPE";;
  }

  dimension: category_id {
    type: number
    sql: ${TABLE}."CATEGORY_ID";;
    value_format_name: id
  }

  dimension: category {
    type: string
    sql: ${TABLE}."CATEGORY";;
  }

  dimension: parent_category_id {
    type: number
    sql: ${TABLE}."PARENT_CATEGORY_ID";;
    value_format_name: id
  }

  dimension: parent_category {
    type: string
    sql: ${TABLE}."PARENT_CATEGORY";;
  }
  }
