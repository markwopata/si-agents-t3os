view: new_parts {
  derived_table: {
    sql: SELECT
          P.PART_ID,
          P.DATE_CREATED,
      --    P.DATE_UPDATED,
          P.PART_NUMBER,
          PT.DESCRIPTION AS "PART_TYPE_DESCRIPTION",
          P.SKU_FIELD,
          P.PROVIDER_ID,
          PRO.NAME AS "PROVIDER_NAME",
          PC.NAME AS "PART_CATEGORY_NAME",
          PC.DESCRIPTION AS "PART_CATEGORY_DESCRIPTION",
          I.CREATED_BY_ID,
          d.title user_dept,
          m.name user_market,
          mx.region_name user_region,
          CONCAT(U.FIRST_NAME,' ',U.LAST_NAME) AS "USER",
          iff(CONCAT(U.FIRST_NAME,' ',U.LAST_NAME)='Global Parts Upload By The System', 'Global Upload','Individual Upload') upload_type
      --   TIMESTAMPDIFF(day, current_timestamp,p.date_created) as "timestampdiff"
      FROM "ES_WAREHOUSE"."INVENTORY"."PARTS" P
      LEFT JOIN "PROCUREMENT"."PUBLIC"."ITEMS" I ON I.ITEM_ID = P.ITEM_ID
      LEFT JOIN "ES_WAREHOUSE"."PUBLIC"."USERS" U ON I.CREATED_BY_ID = U.USER_ID
      left join "ANALYTICS"."PAYROLL"."COMPANY_DIRECTORY" cd
       on u.employee_id=to_char(cd.employee_id)
       left join "ANALYTICS"."INTACCT"."DEPARTMENT" d
        on to_char(cd.market_id)=d.departmentid
      left join "ES_WAREHOUSE"."PUBLIC"."MARKETS" m
      on cd.market_id=m.market_id
      left join "ANALYTICS"."PUBLIC"."MARKET_REGION_XWALK" mx
      on m.market_id=mx.market_id
      LEFT JOIN "ES_WAREHOUSE"."INVENTORY"."PROVIDERS" PRO
      ON P.PROVIDER_ID = PRO.PROVIDER_ID
      LEFT JOIN "ES_WAREHOUSE"."INVENTORY"."PROVIDER_PART_NUMBERS" PPN
      ON P.PROVIDER_PART_NUMBER_ID = PPN.PROVIDER_PART_NUMBER_ID
      LEFT JOIN "ES_WAREHOUSE"."INVENTORY"."PART_TYPES" PT
      ON P.PART_TYPE_ID = PT.PART_TYPE_ID
      LEFT JOIN "ES_WAREHOUSE"."INVENTORY"."PART_CATEGORIES" PC
      ON PT.PART_CATEGORY_ID = PC.PART_CATEGORY_ID
      WHERE P.COMPANY_ID = '1854'
      and CAST(P.DATE_CREATED AS DATE) >= '2021-11-1'
       ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: part_id {
    type: number
    sql: ${TABLE}."PART_ID" ;;
  }

  dimension_group: date_created {
    type: time
    sql: ${TABLE}."DATE_CREATED" ;;
  }

dimension: upload_type {
  type: string
  sql: ${TABLE}."UPLOAD_TYPE" ;;
}
dimension: user_department {
  type: string
  sql: ${TABLE}."USER_DEPT" ;;
}
dimension: user_market {
  type: string
  sql: ${TABLE}."USER_MARKET" ;;
}
dimension: user_region {
  type: string
  sql: ${TABLE}."USER_REGION" ;;
}
  dimension: part_number {
    type: string
    sql: ${TABLE}."PART_NUMBER" ;;
  }

  dimension: part_type_description {
    type: string
    sql: ${TABLE}."PART_TYPE_DESCRIPTION" ;;
  }

  dimension: sku_field {
    type: string
    sql: ${TABLE}."SKU_FIELD" ;;
  }

  dimension: provider_id {
    type: number
    sql: ${TABLE}."PROVIDER_ID" ;;
  }

  dimension: provider_name {
    type: string
    sql: ${TABLE}."PROVIDER_NAME" ;;
  }

  dimension: part_category_name {
    type: string
    sql: ${TABLE}."PART_CATEGORY_NAME" ;;
  }

  dimension: part_category_description {
    type: string
    sql: ${TABLE}."PART_CATEGORY_DESCRIPTION" ;;
  }

  dimension: created_by_id {
    type: number
    sql: ${TABLE}."CREATED_BY_ID" ;;
  }

  dimension: user {
    type: string
    sql: ${TABLE}."USER" ;;
  }

  set: detail {
    fields: [
      part_id,
      date_created_time,
      part_number,
      part_type_description,
      sku_field,
      provider_id,
      provider_name,
      part_category_name,
      part_category_description,
      created_by_id,
      user
    ]
  }
}
