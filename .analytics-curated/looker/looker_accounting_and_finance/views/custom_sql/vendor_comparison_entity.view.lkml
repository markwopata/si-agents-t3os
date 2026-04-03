view: vendor_comparison_entity {
  derived_table: {
    sql:
SELECT T3.*
FROM ES_WAREHOUSE.PURCHASES.ENTITIES T3
WHERE T3.ENTITY_ID NOT IN (SELECT T3MAP.ENTITY_ID FROM ES_WAREHOUSE.PURCHASES.ENTITY_VENDOR_SETTINGS T3MAP)
    AND COMPANY_ID = '1854';;
  }

  dimension: entity_id {
    type: string
    sql: ${TABLE}.entity_id;;
  }

  dimension: entity_name {
    type: string
    sql: ${TABLE}.name;;
  }

  dimension: is_active {
    type: string
    sql: ${TABLE}.active;;
  }

  dimension: is_vendor {
    type: string
    sql: ${TABLE}.is_vendor;;
  }

  dimension: is_customer {
    type: string
    sql: ${TABLE}.is_customer;;
  }
}
