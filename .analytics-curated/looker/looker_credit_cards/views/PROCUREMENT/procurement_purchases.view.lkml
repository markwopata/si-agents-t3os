view: procurement_purchases {
  sql_table_name: "PROCUREMENT"."PUBLIC"."PURCHASES" ;;

  dimension: purchase_id {
    type: number
    primary_key: yes
    sql: ${TABLE}."PURCHASE_ID" ;;
  }

  dimension: notes {
    type: string
    sql: ${TABLE}."NOTES" ;;
  }

  dimension: grand_total {
    type: number
    sql: ${TABLE}."GRAND_TOTAL" ;;
  }

  dimension: user_id {
    type: number
    sql: ${TABLE}."USER_ID" ;;
  }

  dimension: submitted_by_user_id {
    type: number
    sql: ${TABLE}."SUBMITTED_BY_USER_ID" ;;
  }

  dimension: account_type {
    type: string
    sql: ${TABLE}."ACCOUNT_TYPE" ;;
  }

  dimension: card_type {
    type: string
    sql: CASE WHEN ${account_type} = 'CENTRAL' then 'central_bank'
              WHEN ${account_type} = 'FUEL' then 'fuel_card'
              ELSE LOWER(${account_type})
         END ;;
  }

  dimension: vendor_id {
    type: number
    sql: ${TABLE}."VENDOR_ID" ;;
  }

  dimension_group: submitted_date {
    type: time
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: CAST(${TABLE}."SUBMITTED_AT" AS TIMESTAMP_NTZ) ;;
  }

  dimension_group: purchased_date {
    type: time
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: CAST(${TABLE}."PURCHASED_AT" AS TIMESTAMP_NTZ) ;;
  }

  dimension: business_sub_department_snapshot_id {
    type: string
    sql: ${TABLE}."BUSINESS_SUB_DEPARTMENT_SNAPSHOT_ID" ;;
  }

  dimension: business_department_snapshot_id {
    type: string
    sql: ${TABLE}."BUSINESS_DEPARTMENT_SNAPSHOT_ID" ;;
  }

  dimension: business_expense_line_snapshot_id {
    type: string
    sql: ${TABLE}."BUSINESS_EXPENSE_LINE_SNAPSHOT_ID" ;;
  }

  dimension: market_id {
    type: number
    value_format_name: id
    sql: ${TABLE}."MARKET_ID" ;;
  }

  dimension: image_urls {
    type: string
    sql: REGEXP_REPLACE(${TABLE}."IMAGE_URLS", '[\\[\\]\"]', '');;
    html: {% assign urls = value | split: "," %}
    {% for url in urls %}
    <a href="{{ url | strip }}" target="_blank">{{ url | strip }}</a>{% unless forloop.last %}, {% endunless %}
    {% endfor %} ;;
  }

  measure: purchase_total {
    type: sum
    sql: ${grand_total} ;;
  }
}
