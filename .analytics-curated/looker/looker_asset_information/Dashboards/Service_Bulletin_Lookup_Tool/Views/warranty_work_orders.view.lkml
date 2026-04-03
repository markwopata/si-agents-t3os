#
# The purpose of this view is to add work order information to service assets so we can incorporate warranty work order
# statuses into the service bulletin lookup tool. This dashboard is intended to be a place to lookup assets with service or
# recall alerts.
#
# Britt Shanklin | Built 2022-07-08 | Last Modified 2022-07-11
view: warranty_work_orders {
   derived_table: {
     sql: select w.*, s.*, q.service_bulletin from ES_WAREHOUSE.WORK_ORDERS.WORK_ORDERS w
          inner join (select o.ASSET_ID, MAX(o.DATE_CREATED) as MAX_DATE
                      from ES_WAREHOUSE.WORK_ORDERS.WORK_ORDERS o
                      left join ES_WAREHOUSE.WORK_ORDERS.WORK_ORDER_COMPANY_TAGS t on t.WORK_ORDER_ID = o.WORK_ORDER_ID
                      left join ES_WAREHOUSE.WORK_ORDERS.COMPANY_TAGS c on c.COMPANY_TAG_ID = t.COMPANY_TAG_ID
                      where UPPER(c.NAME) like 'WARRANTY' OR c.company_tag_id = 130
                      -- updated 2023/01/26 due to c.name change for this ID went from "Service Campaign/Bulletinn" to "Service Bulletin"
                      group by o.ASSET_ID) m
                      on w.ASSET_ID = m.ASSET_ID and w.DATE_CREATED = m.MAX_DATE
          left join ES_WAREHOUSE.WORK_ORDERS.WORK_ORDER_STATUSES s on w.WORK_ORDER_STATUS_ID = s.WORK_ORDER_STATUS_ID
          left join (SELECT Work_Order_ID
             , 1 as Service_bulletin
              FROM ES_Warehouse.WORK_ORDERS.WORK_ORDER_COMPANY_TAGS
              WHERE company_tag_id = 130) q
                  on q.work_order_ID = w.work_order_ID
       ;;
   }

  dimension: work_order_id {
    type: number
    primary_key: yes
    sql: ${TABLE}."WORK_ORDER_ID" ;;
  }

  dimension: urgency_level_id {
    type: number
    value_format_name: id
    sql: ${TABLE}.urgency_level_id ;;
  }

  dimension: work_order_id_str {
    type: string
    sql: CONCAT('WO-', TO_VARCHAR(${work_order_id})) ;;
  }

  dimension: asset_id {
    type: number
    value_format_name: id
    sql: ${TABLE}."ASSET_ID" ;;
  }

  dimension: status {
    type: string
    sql: ${TABLE}."WORK_ORDER_STATUS_NAME" ;;
  }

  dimension: description {
    type: string
    sql: ${TABLE}."DESCRIPTION" ;;
  }

  dimension_group: date_billed {
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
    sql: CAST(${TABLE}."DATE_BILLED" AS TIMESTAMP_NTZ) ;;
  }

  dimension_group: date_completed {
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
    sql: CAST(${TABLE}."DATE_COMPLETED" AS TIMESTAMP_NTZ) ;;
  }

  dimension_group: date_created {
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
    sql: CAST(${TABLE}."DATE_CREATED" AS TIMESTAMP_NTZ) ;;
  }

  dimension: company_tag {
    type: string
    sql: ${TABLE}."NAME" ;;
  }

  dimension: billing_type_id {
    type: number
    sql: ${TABLE}."BILLING_TYPE_ID" ;;
  }

  dimension: invoice_number {
    type: string
    sql: ${TABLE}."INVOICE_NUMBER" ;;
  }

  dimension: work_order_id_with_link_to_work_order {
    type: string
    sql: ${work_order_id_str} ;;
    html: <font color="blue "><u><a href="https://app.estrack.com/#/service/work-orders/{{ work_order_id._value }}" target="_blank">{{ work_order_id_str._value }}</a></font></u> ;;
  }

  dimension_group: archived {
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
    sql: CAST(${TABLE}."ARCHIVED_DATE" AS TIMESTAMP_NTZ) ;;
  }

  dimension: service_bulletin {
    type: number
    sql: ${TABLE}."SERVICE_BULLETIN" ;;
  }

  measure: count {
    type: count
    filters: [
      scd_asset_inventory_status.current_flag: "1",
      warranty_work_orders.service_bulletin: "1"
    ]
    drill_fields: [
      warranty_work_orders.date_created_date,
      warranty_work_orders.date_completed_date,
      warranty_work_orders.work_order_id_with_link_to_work_order,
      warranty_work_orders.status,
      warranty_work_orders.asset_id,
      scd_asset_inventory_status.asset_inventory_status,
      scd_asset_inventory_status.current_flag,
      assets.make,
      assets.model,
      market_region_xwalk.market_name
      ]}

 }
