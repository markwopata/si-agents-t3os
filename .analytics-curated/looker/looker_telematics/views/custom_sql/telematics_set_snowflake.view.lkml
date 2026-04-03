view: telematics_set_snowflake {
  derived_table: {
    sql:
    select a.asset_id as asset_id,
coalesce(a.serial_number,a.vin) as serial_vin,
a.year as asset_year, a.make as asset_make,
a.model as asset_model,
a.tracker_id as tracker_id,
m.NAME as market_name,
a.company_id as company_id, c.name as company_name,
t.device_serial as device_serial, t.vendor_id as tracker_vendor_id,
t.phone_number as tracker_phone_number,
t.tracker_type_id as tracker_type_id,
t.created as tracker_created, t.updated as tracker_updated,
tt.description as tracker_type_desc, tt.image as tracker_type_image,
tt.name as tracker_type_name, tt.tracker_vendor_id as tracker_type_vendor_id,
tt.is_ble_node as is_ble_node, tv.name as tracker_vendor_name
from ES_WAREHOUSE."PUBLIC".assets as a
left join ES_WAREHOUSE."PUBLIC".trackers as t
on a.tracker_id = t.tracker_id
left join ES_WAREHOUSE."PUBLIC".markets as m
on a.market_id = m.market_id
left join ES_WAREHOUSE."PUBLIC".companies as c
on a.company_id = c.company_id
left join ES_WAREHOUSE."PUBLIC".tracker_types as tt
on t.tracker_type_id = tt.tracker_type_id
left join ES_WAREHOUSE."PUBLIC".tracker_vendors as tv
on tt.tracker_vendor_id = tv.tracker_vendor_id
where a.tracker_id is not null
                                   ;;
  }


  dimension: asset_id {
    type: number
    sql: ${TABLE}.asset_id ;;
  }

  dimension: serial_vin {
    type: string
    sql: ${TABLE}.serial_vin ;;
  }


  dimension: asset_year {
    type: number
    sql: ${TABLE}.asset_year ;;
  }

  dimension: asset_make {
    type: string
    sql: ${TABLE}.asset_make ;;
  }

  dimension: asset_model {
    type: string
    sql: ${TABLE}.asset_model ;;
  }

  dimension: tracker_id {
    type: number
    sql: ${TABLE}.tracker_id ;;
  }

  dimension: market_name {
    type: string
    sql: ${TABLE}.market_name ;;
  }

  dimension: company_id {
    type: number
    sql: ${TABLE}.company_id ;;
  }

  dimension: company_name {
    type: string
    sql: ${TABLE}.company_name ;;
  }

  dimension: company_name_with_link_to_customer_dashboard {
    type: string
    sql: ${company_name} ;;

    link: {
      label: "View Customer Information Dashboard"
      url: "https://equipmentshare.looker.com/dashboards/28?Company%20Name={{ company_name._filterable_value | url_encode }}&Company%20ID="
    }

  }

  dimension: device_serial {
    type: string
    sql: ${TABLE}.device_serial ;;
  }

  dimension: tracker_vendor_id {
    type: number
    sql: ${TABLE}.tracker_vendor_id ;;
  }

  dimension: tracker_phone_number {
    type: string
    sql: ${TABLE}.tracker_phone_number ;;
  }

  dimension: tracker_type_id {
    type: number
    sql: ${TABLE}.tracker_type_id ;;
  }

  dimension: tracker_date_created {
    type: date_time
    sql: ${TABLE}.tracker_created ;;
  }

  dimension: tracker_date_updated {
    type: date_time
    sql: ${TABLE}.tracker_updated ;;
  }

  dimension: tracker_type_desc {
    type: string
    sql: ${TABLE}.tracker_type_desc ;;
  }

  dimension: tracker_type_image {
    type: string
    sql: ${TABLE}.tracker_type_image ;;
  }

  dimension: tracker_type_name {
    type: string
    sql: ${TABLE}.tracker_type_name ;;
  }

  dimension: tracker_type_vendor_id {
    type: number
    sql: ${TABLE}.tracker_type_vendor_id ;;
  }

  dimension: is_ble_node {
    type: yesno
    sql: ${TABLE}.is_ble_node ;;
  }

  dimension: tracker_vendor_name {
    type: string
    sql: ${TABLE}.tracker_vendor_name ;;
  }
}
