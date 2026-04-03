# The name of this view in Looker is "Work Order Originators"
view: work_order_originators {
  # The sql_table_name parameter indicates the underlying database table
  # to be used for all fields in this view.
  sql_table_name: "WORK_ORDERS"."WORK_ORDER_ORIGINATORS"
    ;;
  drill_fields: [work_order_originator_id]
  # This primary key is the unique key for this table in the underlying database.
  # You need to define a primary key in a view in order to join to other views.

  dimension: work_order_originator_id {
    primary_key: yes
    type: number
    sql: ${TABLE}."WORK_ORDER_ORIGINATOR_ID" ;;
  }

  # Dates and timestamps can be represented in Looker using a dimension group of type: time.
  # Looker converts dates and timestamps to the specified timeframes within the dimension group.

  dimension_group: _es_update_timestamp {
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
    sql: CAST(${TABLE}."_ES_UPDATE_TIMESTAMP" AS TIMESTAMP_NTZ) ;;
  }

  # Here's what a typical dimension looks like in LookML.
  # A dimension is a groupable field that can be used to filter query results.
  # This dimension will be called "Originator ID" in Explore.

  dimension: originator_id {
    type: number
    sql: ${TABLE}."ORIGINATOR_ID" ;;
  }

  dimension: originator_item_id {
    type: number
    sql: ${TABLE}."ORIGINATOR_ITEM_ID" ;;
  }

  dimension: originator_item_uuid {
    type: string
    sql: ${TABLE}."ORIGINATOR_ITEM_UUID" ;;
  }

  dimension: originator_type_id {
    type: number
    # hidden: yes
    sql: ${TABLE}."ORIGINATOR_TYPE_ID" ;;
  }

  dimension: originator_uuid {
    type: string
    sql: ${TABLE}."ORIGINATOR_UUID" ;;
  }

  dimension: work_order_id {
    type: number
    sql: ${TABLE}."WORK_ORDER_ID" ;;
  }

  measure: count {
    type: count
    drill_fields: [work_order_originator_id, originator_types.name, originator_types.originator_type_id]
  }
}
