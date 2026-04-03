
view: overdue_inspections {
  derived_table: {
    sql: select
          mrx.market_name as market,
          mrx.region_name as region,
          mrx.market_id,
          mrx.district,
          mrx.market_type,
          h.asset_id,
          case
          when UPPER(mgi.name) LIKE '%ANSI%' then 'ANSI'
          when UPPER(mgi.name) LIKE '%DOT %' OR UPPER(mgi.name) LIKE '%90 DAY%' then 'DOT'
          when UPPER(mgi.name) LIKE '%ANNUAL%' then 'ANNUAL'
          else 'PM' end as inspection_type,
          askv.inventory_status,
          mgi.name as maintenance_group_interval_name,
          IFF(((ms.until_next_service_time < 0 AND ms.until_next_service_time is not null) OR (ms.until_next_service_usage < 0 AND ms.until_next_service_usage is not null)),TRUE,FALSE) as overdue,
          h.owning_company_name,
          coalesce(total_oec,0) as total_oec
      from
          saasy.public.asset_maintenance_status ms
          join analytics.assets.int_asset_historical h on ms.asset_id = h.asset_id AND h.daily_timestamp BETWEEN current_date AND current_date + interval '1 day'
          join es_warehouse.public.maintenance_group_intervals mgi on mgi.maintenance_group_interval_id = ms.maintenance_group_interval_id
          join (select asset_id, value as inventory_status from es_warehouse.public.asset_status_key_values where name = 'asset_inventory_status') askv on askv.asset_id = h.asset_id
          join analytics.public.market_region_xwalk mrx on mrx.market_id = coalesce(h.rental_branch_id,h.service_branch_id)
      where
        ms.is_deleted = FALSE
          ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: market {
    type: string
    sql: ${TABLE}."MARKET" ;;
  }
  dimension: market_id {
    type: string
    sql: ${TABLE}."MARKET_ID" ;;
  }

  dimension: region {
    type: string
    sql: ${TABLE}."REGION" ;;
  }

  dimension: district {
    type: string
    sql: ${TABLE}."DISTRICT" ;;
  }

  dimension: market_type {
    type: string
    sql: ${TABLE}."MARKET_TYPE" ;;
  }

  dimension: asset_id {
    type: string
    sql: ${TABLE}."ASSET_ID" ;;
    html: <font color="0063f3 "><u><a href="https://equipmentshare.looker.com/dashboards/169?Asset+ID={{asset_id}}" target="_blank">{{ asset_id._value }}</a></font></u> ;;
  }

  dimension: inspection_type {
    type: string
    sql: ${TABLE}."INSPECTION_TYPE" ;;
  }

  dimension: inventory_status {
    type: string
    sql: ${TABLE}."INVENTORY_STATUS" ;;
  }

  dimension: maintenance_group_interval_name {
    label: "Maintenance Group Interval"
    type: string
    sql: ${TABLE}."MAINTENANCE_GROUP_INTERVAL_NAME" ;;
  }

  dimension: owning_company_name {
    type: string
    sql: ${TABLE}."OWNING_COMPANY_NAME" ;;
  }

  dimension: overdue {
    type: yesno
    sql: ${TABLE}."OVERDUE" ;;
  }

  dimension: total_oec {
    label: "OEC"
    type: number
    sql: ${TABLE}."TOTAL_OEC" ;;
    value_format_name: usd_0
  }

  measure: total_overdue_inspections {
    type: count_distinct
    sql: ${asset_id} ;;
    filters: [overdue: "TRUE"]
  }

  measure: total_overdue_on_rent_inspections {
    type: count_distinct
    sql: ${asset_id} ;;
    filters: [overdue: "TRUE", inventory_status: "On Rent"]
    drill_fields: [asset_id, owning_company_name, total_oec, inventory_status, inspection_type, maintenance_group_interval_name]
  }

  measure: total_overdue_excluding_on_rent_inspections {
    type: count_distinct
    sql: ${asset_id} ;;
    filters: [overdue: "TRUE", inventory_status: "-On Rent"]
    drill_fields: [asset_id, owning_company_name, total_oec, inventory_status, inspection_type, maintenance_group_interval_name]
  }

  # measure: total_overdue_excluding_on_rent_inspections { --- The above measure makes it so you can have drill fields - KC
  #   type: number
  #   sql: ${total_overdue_inspections} - ${total_overdue_on_rent_inspections} ;;
  # }

  set: detail {
    fields: [
        market,
  region,
  district,
  market_type,
  asset_id,
  inspection_type,
  inventory_status,
  maintenance_group_interval_name,
  overdue
    ]
  }
}
