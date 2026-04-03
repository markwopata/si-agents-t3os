view: asset_class_customer_branch {
  derived_table: {
    sql:
    select  distinct a.asset_id,
            initcap(aty.name) as asset_type,
            coalesce(a.asset_class, 'No Asset Class') as asset_class,
            c.company_id, c.name as asset_owner,
            a.rental_branch_id,
            a.inventory_branch_id,
            m.market_id, m.name as branch,
            a.category_id,
            coalesce(cat.name, 'No Asset Category') as asset_category,
            cat.parent_category_id,
            coalesce(cat2.name, 'No Parent Category') as parent_category,
            m.is_public_rsp,
            m.company_id as rsp_company_id,
            a.make,
            a.model
   from  ES_WAREHOUSE.SCD.scd_asset_company scdc
        left join  ES_WAREHOUSE.PUBLIC.assets a on scdc.asset_id = a.asset_id
        left join ES_WAREHOUSE.PUBLIC.companies c on a.company_id = c.company_id
        left join ES_WAREHOUSE.PUBLIC.markets m on a.rental_branch_id = m.market_id
        left join ES_WAREHOUSE.PUBLIC.equipment_classes ec on a.equipment_class_id = ec.equipment_class_id
        left join ES_WAREHOUSE.PUBLIC.categories cat on ec.category_id = cat.category_id
        left join ES_WAREHOUSE.PUBLIC.categories cat2 on cat.parent_category_id = cat2.category_id
        left join  ES_WAREHOUSE.PUBLIC.asset_types aty on a.asset_type_id = aty.asset_type_id
    where m.company_id = {{ _user_attributes['company_id'] }}
    ;;
  }

  dimension: asset_id {
    primary_key: yes
    type: number
    sql: ${TABLE}."ASSET_ID";;
    value_format_name: id
  }

  dimension: asset_type {
    type: string
    sql: ${TABLE}."ASSET_TYPE";;
  }

  dimension: asset_class {
    type: string
    sql: ${TABLE}."ASSET_CLASS";;
  }

  dimension: company_id {
    type: number
    sql: ${TABLE}."COMPANY_ID";;
    value_format_name: id
  }

  dimension: asset_owner {
    type: string
    sql: ${TABLE}."ASSET_OWNER";;
  }

  dimension: rental_branch_id {
    type: number
    sql: ${TABLE}."RENTAL_BRANCH_ID";;
    value_format_name: id
  }

  dimension: inventory_branch_id {
    type: number
    sql: ${TABLE}."INVENTORY_BRANCH_ID";;
    value_format_name: id
  }

  dimension: market_id {
    label: "Branch ID"
    type: number
    sql: ${TABLE}."MARKET_ID";;
    value_format_name: id
  }

  dimension: branch {
    type: string
    sql: ${TABLE}."BRANCH";;
  }

  dimension: rsp_company_id {
    type: number
    sql: ${TABLE}."RSP_COMPANY_ID";;
  }

  dimension: category_id {
    type: number
    sql: ${TABLE}."CATEGORY_ID";;
    value_format_name: id
  }

  dimension: asset_category {
    type: string
    sql: ${TABLE}."ASSET_CATEGORY";;
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

  dimension: is_public_rsp {
    type: yesno
    sql: ${TABLE}."IS_PUBLIC_RSP";;
  }

  dimension: make {
    type: string
    sql: ${TABLE}."MAKE";;
  }

  dimension: model {
    type: string
    sql: ${TABLE}."MODEL";;
  }

  measure: count {
    type: count
    value_format_name: decimal_0
    drill_fields: [detail*]
  }

  set: detail {
    fields: [asset_id, asset_class, branch, asset_category]
  }

}
