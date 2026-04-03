view: telematics_asset_info {

  derived_table: {
    sql:
     select a.ASSET_ID, coalesce(a.SERIAL_NUMBER,a.vin) as asset_serial_vin,
a.make, a.model, aa.CLASS, a.COMPANY_ID, c.name as company_name, a.INVENTORY_BRANCH_ID, m.name as inventory_branch,
a.TRACKER_ID, t.DEVICE_SERIAL as tracker_serial, tt.name as tracker_type, pd.HARDWARE_NAME,
pd.SERIAL_NUMBER as peripheral_serial, pd.APP_VERSION as peripheral_firmware, askv.value as rental_status
from ES_WAREHOUSE.PUBLIC.assets as a
left join ES_WAREHOUSE.PUBLIC.TRACKERS_MAPPING as tm
on a.TRACKER_ID = tm.ESDB_TRACKER_ID
left join ES_WAREHOUSE.PUBLIC.TRACKERS as t
on a.TRACKER_ID = t.TRACKER_ID
left join ES_WAREHOUSE.PUBLIC.TRACKER_TYPES as tt
on t.TRACKER_TYPE_ID = tt.TRACKER_TYPE_ID
left join ES_WAREHOUSE.TRACKERS.PERIPHERAL_DEVICES as pd
on tm.TRACKER_TRACKER_ID = pd.TRACKER_ID
left join ES_WAREHOUSE.PUBLIC.COMPANIES as c
on a.COMPANY_ID = c.COMPANY_ID
left join ES_WAREHOUSE.PUBLIC.MARKETS as m
on a.INVENTORY_BRANCH_ID = m.MARKET_ID
left join ES_WAREHOUSE.PUBLIC.ASSETS_AGGREGATE as aa
on a.ASSET_ID = aa.ASSET_ID
left join ES_WAREHOUSE.PUBLIC.ASSET_STATUS_KEY_VALUES as askv
on a.ASSET_ID = askv.ASSET_ID
where a.COMPANY_ID in (1854,1855,8151)
and lower(askv.NAME) = 'asset_rental_status'
                         ;;
  }


  dimension: asset_id {
    type: number
    sql: ${TABLE}.ASSET_ID ;;
  }

  dimension: asset_serial_vin {
    type: string
    sql: ${TABLE}.ASSET_SERIAL_VIN ;;
  }

  dimension: make {
    type: string
    sql: ${TABLE}.MAKE ;;
  }

  dimension: model {
    type: string
    sql: ${TABLE}.MODEL ;;
  }

  dimension: equipment_class {
    type: string
    sql: ${TABLE}.CLASS ;;
  }

  dimension: company_id {
    type: number
    sql: ${TABLE}.COMPANY_ID ;;
  }

  dimension: company_name {
    type: string
    sql: ${TABLE}.COMPANY_NAME ;;
  }

  dimension: inventory_branch_id {
    type: number
    sql: ${TABLE}.INVENTORY_BRANCH_ID ;;
  }

  dimension: inventory_branch {
    type: string
    sql: ${TABLE}.INVENTORY_BRANCH ;;
  }

  dimension: tracker_id {
    type: number
    sql: ${TABLE}.TRACKER_ID ;;
  }



  dimension: tracker_serial {
    type: string
    sql: ${TABLE}.TRACKER_SERIAL ;;
  }

  dimension: tracker_type {
    type: string
    sql: ${TABLE}.TRACKER_TYPE ;;
  }

  dimension: hardware_name {
    type: string
    sql: ${TABLE}.HARDWARE_NAME ;;
  }

  dimension: peripheral_serial {
    type: string
    sql: ${TABLE}.PERIPHERAL_SERIAL ;;
  }

  dimension: peripheral_firmware {
    type: string
    sql: ${TABLE}.PERIPHERAL_FIRMWARE ;;
  }
  dimension: rental_status {
    type: string
    sql: ${TABLE}.RENTAL_STATUS ;;
  }



  }
