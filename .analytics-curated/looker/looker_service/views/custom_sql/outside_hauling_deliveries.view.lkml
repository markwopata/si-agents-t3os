view: outside_hauling_deliveries {
  derived_table: {
    sql: with detail as (select m.market_id
, d.date_created
, d.scheduled_date
, d.completed_date
, d.order_id
, d.rental_id
, d.delivery_status_id
, ds.name delivery_status
, d.driver_user_id
, d.facilitator_type_id
, d.asset_id
, d.delivery_id
, d.charge customer_charge
, HAVERSINE(org.LATITUDE, org.LONGITUDE, des.LATITUDE, des.LONGITUDE)/1.60934 miles
, po.purchase_order_number
, count(d.delivery_id) over (partition by po.purchase_order_id) deliveries_on_po
, count(d.delivery_id) over (partition by d.location_id, d.origin_location_id, po.purchase_order_id) shared_loads
, iff((miles/shared_loads)<1,1,(miles/shared_loads)) distinct_miles
, po.status po_status
, VENDINT.name vendor
, amount_approved
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
 join "ES_WAREHOUSE"."PUBLIC"."MARKETS" m
 on o.market_id=m.market_id
join ES_WAREHOUSE.PUBLIC.DELIVERY_STATUSES ds
on d.DELIVERY_STATUS_ID=ds.DELIVERY_STATUS_ID
-- left join ANALYTICS.INTACCT_MODELS.AP_detail ap -- may want to use this at some point for the $s but we dont have invoices right away.
-- on to_char(po.purchase_order_number)= ap.document_number
 where --d._ES_UPDATE_TIMESTAMP::date>='2024-12-05' --launch of the PO line, taking this out since im inner joining to POs anyways
 amount_approved>1 --getting rid of mock POs
and m.company_id=1854
and d.DELIVERY_STATUS_ID !=4
 order by deliveries_on_po desc)
 select *
            , ratio_to_report(distinct_miles) over (partition by purchase_order_number) miles_perc_po
            , miles_perc_po*amount_approved amount_weighted_miles
            from detail
 ;;
  }
  dimension: market_id {
    type: string
    sql: ${TABLE}."MARKET_ID" ;;
  }
  dimension: order_id {
    type: string
    sql: ${TABLE}."ORDER_ID" ;;
  }
  dimension: rental_id {
    type: string
    sql: ${TABLE}."RENTAL_ID" ;;
  }
  dimension: driver_user_id {
    type: string
    sql: ${TABLE}."DRIVER_USER_ID" ;;
  }
  dimension: delivery_id {
    type: string
    sql: ${TABLE}."DELIVERY_ID" ;;
  }
  dimension: asset_id {
    type: string
    sql: ${TABLE}."ASSET_ID" ;;
  }
  dimension: purchase_order_number {
    type: string
    sql: ${TABLE}."PURCHASE_ORDER_NUMBER" ;;
  }
  dimension_group: created {
    type: time
    timeframes: [raw,date,week,month,quarter,year]
    sql: ${TABLE}."DATE_CREATED" ;;
  }
  dimension_group: scheduled {
    type: time
    timeframes: [raw,date,week,month,quarter,year]
    sql: ${TABLE}."SCHEDULED_DATE" ;;
  }
  dimension_group: completed {
    type: time
    timeframes: [raw,date,week,month,quarter,year]
    sql: ${TABLE}."COMPLETED_DATE" ;;
  }
  dimension: delivery_status {
    type: string
    sql: ${TABLE}."DELIVERY_STATUS" ;;
  }
  dimension: po_status {
    type: string
    sql: ${TABLE}."PO_STATUS" ;;
  }
  dimension: hauling_vendor {
    type: string
    sql: ${TABLE}."VENDOR" ;;
  }
  dimension: po_amount_approved {# do not agg it will cause dupes, use po_amount agg instead
    type:number
    sql: ${TABLE}."AMOUNT_APPROVED" ;;
    value_format_name: usd_0
    }
  dimension: weighted_po_amount {
    type: number
    sql: ${TABLE}."AMOUNT_WEIGHTED_MILES" ;;
    value_format_name: usd_0
  }
  measure: po_amount {
    type: sum
    sql: ${weighted_po_amount} ;;
    value_format_name: usd_0
  }
  dimension: customer_charge {
    type: number
    sql: ${TABLE}."CUSTOMER_CHARGE" ;;
    value_format_name: usd_0
  }
  measure: total_customer_charge {
    type: sum
    sql: ${customer_charge} ;;
    value_format_name: usd_0
  }
  dimension: miles {
    type: number
    sql: ${TABLE}."MILES" ;;
    value_format_name: decimal_0
  }
  measure: total_miles_recorded { #does not account for shared loads
    type: sum
    sql: ${miles} ;;
    value_format_name: decimal_0
  }
  dimension: deliveries_on_po { #do not agg
    type: number
    sql: ${TABLE}."DELIVERIES_ON_PO" ;;
    value_format_name: decimal_0
  }
  dimension: shared_loads { #do not agg
    type: number
    sql: ${TABLE}."SHARED_LOADS" ;;
    value_format_name: decimal_0
  }
  dimension: distinct_miles {
    type: number
    sql: ${TABLE}."DISTINCT_MILES" ;;
    value_format_name: decimal_0
  }
  measure: total_distinct_miles {#accounts for shared loads
    type: sum
    sql: ${distinct_miles} ;;
    value_format_name: decimal_0
  }

measure: unrecovered_cost {
  type: number
  sql: ${po_amount}-${total_customer_charge} ;;
  value_format_name: usd_0
}

measure: cost_per_mile {
  type: number
  sql: ${po_amount}/${total_distinct_miles} ;;
  value_format_name: usd_0
  drill_fields: [detail*]
}

measure: unrecovered_cost_per_mile {
  type: number
  sql: ${unrecovered_cost}/${total_distinct_miles} ;;
  value_format_name: usd_0
}

set: detail {
  fields: [market_region_xwalk.region_name,
  market_region_xwalk.district,
  market_region_xwalk.market_name,
  order_id,
  rental_id,
  delivery_id,
  asset_id,
  hauling_vendor,
  purchase_order_number,
  po_amount_approved,
  deliveries_on_po,
  shared_loads,
  distinct_miles,
  weighted_po_amount,
  cost_per_mile
  ]
}

}
