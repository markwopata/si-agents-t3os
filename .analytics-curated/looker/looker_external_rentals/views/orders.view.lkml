view: orders {
 # sql_table_name: "PUBLIC"."ORDERS"
 #   ;;

  derived_table: {
    sql:
    select
    o.*
    , c.contract_id
    from
    es_warehouse.public.orders o
    left join es_warehouse.public.contracts c on o.order_id = c.terms:order_id

    ;;
    }

  drill_fields: [purchase_order_id]

  dimension: purchase_order_id {
    primary_key: yes
    type: number
    sql: ${TABLE}."PURCHASE_ORDER_ID" ;;
  }

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

  dimension: accepted_by {
    type: string
    sql: ${TABLE}."ACCEPTED_BY" ;;
  }

  dimension_group: accepted {
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
    sql: CAST(${TABLE}."ACCEPTED_DATE" AS TIMESTAMP_NTZ) ;;
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

  dimension: deleted {
    type: yesno
    sql: ${TABLE}."DELETED" ;;
  }

  dimension: delivery_instructions {
    type: string
    sql: ${TABLE}."DELIVERY_INSTRUCTIONS" ;;
  }

  dimension: delivery_required {
    type: yesno
    sql: ${TABLE}."DELIVERY_REQUIRED" ;;
  }

  dimension: external_id {
    type: string
    sql: ${TABLE}."EXTERNAL_ID" ;;
  }

  dimension: sub_renter_id {
    type: number
    sql: ${TABLE}."SUB_RENTER_ID" ;;
  }

  dimension: insurance_covers_rental {
    type: yesno
    sql: ${TABLE}."INSURANCE_COVERS_RENTAL" ;;
  }

  dimension: insurance_policy_id {
    type: number
    sql: ${TABLE}."INSURANCE_POLICY_ID" ;;
  }

  dimension: location_id {
    type: number
    sql: ${TABLE}."LOCATION_ID" ;;
  }

  dimension: market_id {
    type: number
    sql: ${TABLE}."MARKET_ID" ;;
  }

  dimension: job_id {
    type: number
    sql: ${TABLE}."JOB_ID" ;;
  }

  dimension: order_id {
    type: number
    # hidden: yes
    sql: ${TABLE}."ORDER_ID" ;;
  }

  dimension: order_id_string {
    label: "Order ID"
    group_label: "Strings"
    type: string
    sql: ${TABLE}."ORDER_ID" ;;
    # html: <font color="#0063f3"><u><a href="https://app.estrack.com/{{contract_id._filterable_value}}" target="_blank">{{order_id_string._rendered_value}}</a></font></u>;;
  }

  dimension: order_status_id {
    type: number
    sql: ${TABLE}."ORDER_STATUS_ID" ;;
  }

  dimension: reference {
    type: string
    sql: ${TABLE}."REFERENCE" ;;
  }

  dimension: salesperson_user_id {
    type: number
    sql: ${TABLE}."SALESPERSON_USER_ID" ;;
  }

  dimension: supplier_company_id {
    type: number
    sql: ${TABLE}."SUPPLIER_COMPANY_ID" ;;
  }

  dimension: user_id {
    type: number
    sql: ${TABLE}."USER_ID" ;;
  }

  dimension: approver_user_id {
    type: number
    sql: ${TABLE}."APPROVER_USER_ID" ;;
  }

  dimension: contract_id {
    type: string
    sql: ${TABLE}."CONTRACT_ID" ;;
  }

  measure: count {
    type: count
    drill_fields: [purchase_order_id, orders.purchase_order_id, invoices.count, orders.count]
  }

# # Dummy data added below

#   dimension: rental_id {
#     type: string
#     sql: '12345' ;;
#   }

#   dimension: asset_description {
#     type: string
#     sql: 'Lift' ;;
#   }

#   dimension: asset_id {
#     type: string
#     sql: '12345' ;;
#   }

#   dimension: next_cycle_inv_date {
#     type: string
#     sql: '12-3-2020' ;;
#   }

#   dimension: start_date {
#     type: string
#     sql: '12-1-2020' ;;
#   }

#   dimension: end_date{
#     type: string
#     sql: '12-2-2020' ;;
#   }

#   dimension: on_rent_off_rent_status {
#     type: string
#     sql: 'On Rent' ;;
#   }

#   dimension: price {
#     type: string
#     sql: '$1.00' ;;
#   }

#   dimension: rental_revenue {
#     type: string
#     sql: '$0.00' ;;
#   }

#   dimension: total_rental_forcast {
#     type: string
#     sql: '$1.00' ;;
#   }
}
