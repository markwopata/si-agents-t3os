view: chargetypeadditions {
  derived_table: {
    sql:
      SELECT
        _ES_UPDATE_TIMESTAMP AS es_update_ts,
        LINE_ITEM_TYPE_ID     AS line_item_type_id,
        NAME                  AS name,
        STACKABLE             AS stackable,
        TAX_CODE_ID           AS tax_code_id,
        INVOICE_DISPLAY_NAME  AS invoice_display_name,
        ACTIVE                AS active,
        FIXED_AMOUNT          AS fixed_amount,
        LINE_ITEM_PRODUCT_TYPE_ID AS line_item_product_type_id
      FROM "ES_WAREHOUSE"."PUBLIC"."LINE_ITEM_TYPES"
      ;;
    }


  dimension_group: es_update_ts {
    type: time
    timeframes: [time, hour, date, week, month, quarter, year]
    sql: ${TABLE}.es_update_ts ;;
  }

  dimension: line_item_type_id { primary_key: yes  type: number }
  dimension: name {}
  dimension: invoice_display_name {}
  dimension: stackable { type: yesno }
  dimension: active { type: yesno }
  dimension: tax_code_id { type: number }
  dimension: fixed_amount { type: number }
  dimension: line_item_product_type_id { type: number }

  measure: count { type: count }

  measure: new_types_last_1h  {
    type: count
    filters: [es_update_ts_time: "1 hours"]
  }

  measure: new_types_last_24h {
    type: count
    filters: [es_update_ts_time: "24 hours"]
  }

  measure: distinct_types {
    type: count_distinct
    sql: ${line_item_type_id} ;;
  }
}
