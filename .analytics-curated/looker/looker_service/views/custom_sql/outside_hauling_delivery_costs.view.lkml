view: outside_hauling_delivery_costs {
  derived_table: {
    sql:with detail as (select o.market_id
, d.date_created
, d.scheduled_date
, d.order_id
, d.rental_id
, d.delivery_status_id
, d.driver_user_id
, d.facilitator_type_id
, d.asset_id
, d.delivery_id
, d.charge customer_charge
, HAVERSINE(org.LATITUDE, org.LONGITUDE, des.LATITUDE, des.LONGITUDE)/1.60934 miles
, po.purchase_order_number
, count(d.delivery_id) over (partition by po.purchase_order_id) deliveries_on_po
, count(d.delivery_id) over (partition by d.location_id, d.origin_location_id, po.purchase_order_id) shared_loads
, miles/shared_loads distinct_miles
, po.status, VENDINT.name vendor, amount_approved
                , amount_approved/deliveries_on_po amount_even_dist
from "ES_WAREHOUSE"."PUBLIC"."DELIVERIES" d
join "ES_WAREHOUSE"."PUBLIC"."LOCATIONS" des
on d.location_id=des.location_id
join "ES_WAREHOUSE"."PUBLIC"."LOCATIONS" org
on d.origin_location_id=org.location_id
 join "PROCUREMENT"."PUBLIC"."PURCHASE_ORDERS" po
 on d.purchase_order_id = po.purchase_order_id
 LEFT JOIN "ES_WAREHOUSE"."PURCHASES"."ENTITY_VENDOR_SETTINGS" VEND
        ON PO.VENDOR_ID = VEND.ENTITY_ID
    LEFT JOIN "ANALYTICS"."INTACCT"."VENDOR" VENDINT
        ON VEND.EXTERNAL_ERP_VENDOR_REF = VENDINT.VENDORID
 join "ES_WAREHOUSE"."PUBLIC"."ORDERS" o
 on d.order_id=o.order_id
// left join ANALYTICS.INTACCT_MODELS.AP_detail ap -- may want to use this at some point for the $s but we dont have invoices right away.
// on to_char(po.purchase_order_number)= ap.document_number
 where d._ES_UPDATE_TIMESTAMP::date>='2024-12-05' --launch of the PO line
 and amount_approved>1 --getting rid of mock POs
 )
select *
            , ratio_to_report(distinct_miles) over (partition by purchase_order_number) miles_perc_po
            , miles_perc_po*amount_approved amount_weighted_miles
            from detail
;;
}
dimension: delivery_id {
  primary_key: yes
  type: number
  value_format_name: id
  sql: ${TABLE}."DELIVERY_ID" ;;
}
dimension: market_id {
  type: number
  value_format_name: id
  sql: ${TABLE}."MARKET_ID" ;;
}

  dimension: order_id {
    type: number
    value_format_name: id
    sql: ${TABLE}."ORDER_ID" ;;
  }
  dimension: rental_id {
    type: number
    value_format_name: id
    sql: ${TABLE}."RENTAL_ID" ;;
  }

  dimension_group: delivery_created{
    type: time
    timeframes: [date,week,month,year]
    sql: ${TABLE}."DATE_CREATED" ;;
  }
  dimension_group: delivery_scheduled{
    type: time
    timeframes: [date,week,month,year]
    sql: ${TABLE}."SCHEDULED_DATE" ;;
  }
  dimension: delivery_status_id {
    type: number
    value_format_name: id
    sql: ${TABLE}."DELIVERY_STATUS_ID" ;;
  }

  dimension: driver_user_id {
    type: number
    value_format_name: id
    sql: ${TABLE}."DRIVER_USER_ID" ;;
  }
  dimension: asset_id {
    type: number
    value_format_name: id
    sql: ${TABLE}."ASSET_ID" ;;
  }
  dimension: hauling_po_number {
    type: number
    value_format_name: id
    sql: ${TABLE}."PURCHASE_ORDER_NUMBER" ;;
  }
  dimension: po_status {
    type: string
    sql: ${TABLE}."STATUS" ;;
  }
  dimension: po_vendor {
    type: string
    sql: ${TABLE}."vendor" ;;
  }
  dimension: amount_approved {#do not sum, this will cause dupes at the PO level
    type: number
    value_format_name: usd_0
    sql: ${TABLE}."AMOUNT_APPROVED" ;;
    }
  dimension: deliveries_on_po { #do not sum, this will cause dupes at the PO level
    type: number
    sql: ${TABLE}."DELIVERIES_ON_PO" ;;
  }
  dimension: shared_loads { #do not sum, this will cause dupes at the PO level
    type: number
    sql: ${TABLE}."SHARED_LOADS" ;;
  }
  measure: delivery_miles {
    type: sum
    sql: ${TABLE}."DISTINCT_MILES" ;;
  }
  dimension: miles_perc_po {
    type: number
    value_format_name: percent_2
    sql: ${TABLE}."MILES_PERC_PO" ;;
  }

  measure: amount_weighted_miles {
    type: sum
    value_format_name: usd_0
    sql: ${TABLE}."AMOUNT_WEIGHTED_MILES" ;;
  }
  # dimension: customer_charge {
  #   type: number
  #   value_format_name: usd_0
  #   sql: ${TABLE}."CUSTOMER_CHARGE" ;;
  # }
  measure: customer_charge {
    type: sum
    value_format_name: usd_0
    sql: ${TABLE}."CUSTOMER_CHARGE" ;;
  }
}
