view: lost_or_stolen_assets {

  derived_table: {
    sql:
    SELECT l.ASSET_ID AS asset_id, l.COMPANY_ID AS company_id, l.COMPANY_NAME AS company_name,
l.FOLDER_NAME AS folder_name, l.folder_url AS folder_url, l.timestamp AS timestamp,
aph.FINANCE_STATUS AS finance_status,
aph.FINANCIAL_SCHEDULE_ID AS financial_schedule_id,
fs.CURRENT_SCHEDULE_NUMBER AS schedule,
fl."NAME" AS lender, a.year as year , a.make as make, a.model as model, a.serial_number as serial_number, a.vin as vin,
COALESCE(aph.oec,aph.PURCHASE_PRICE) AS oec
FROM ANALYTICS.LOST_ASSETS.LOST_OR_STOLEN_ASSETS AS l
LEFT JOIN ES_WAREHOUSE."PUBLIC".asset_purchase_history AS aph
ON l.asset_id = aph.ASSET_ID
LEFT JOIN ES_WAREHOUSE."PUBLIC".assets AS a
ON a.asset_id = aph.ASSET_ID
LEFT JOIN ES_WAREHOUSE."PUBLIC".financial_schedules AS fs
ON aph.FINANCIAL_SCHEDULE_ID = fs.FINANCIAL_SCHEDULE_ID
LEFT JOIN ES_WAREHOUSE."PUBLIC".financial_lenders AS fl
ON fs.ORIGINATING_LENDER_ID = fl.FINANCIAL_LENDER_ID
                         ;;
  }

  dimension: asset_id {
    type: number
    sql: ${TABLE}.ASSET_ID ;;
    html: <font color="blue "><u><a href = "https://equipmentshare.looker.com/looks/79?f[asset_nbv_all_owners.asset_id]={{ asset_id._filterable_value | url_encode }}" target="_blank">{{ asset_id._value }}</a></font></u> ;;
  }

  dimension: year {
    type: number
    sql: ${TABLE}.YEAR ;;
  }

  dimension: make {
    type: string
    sql: ${TABLE}.MAKE ;;
  }

  dimension: serial_number {
    type: string
    sql: ${TABLE}.SERIAL_NUMBER ;;
  }

  dimension: vin {
    type: string
    sql: ${TABLE}.VIN ;;
  }

  dimension: model {
    type: string
    sql: ${TABLE}.MODEL ;;
  }

  dimension: company_id {
    type: number
    sql: ${TABLE}.COMPANY_ID ;;
  }


  dimension: company_name {
    type: string
    sql: ${TABLE}.COMPANY_NAME ;;
    html: <font color="blue "><u><a href = "https://equipmentshare.looker.com/dashboards/28?Company%20Name={{ company_name._filterable_value | url_encode }}" target="_blank">{{ company_name._value }}</a></font></u>;;
  }


  dimension: folder_name {
    type: string
    sql: ${TABLE}.FOLDER_NAME;;
  }



  dimension: folder_url {
    type: string
    sql: ${TABLE}.FOLDER_URL ;;
    html:<font color="blue "><u><a href="{{ folder_url._value }}" target="_blank">Link to Drive Folder</a></font></u> ;;
  }

  dimension: timestamp {
    type: date_time
    sql: ${TABLE}.TIMESTAMP ;;
  }

  dimension: financial_schedule_id {
    type: number
    sql: ${TABLE}.FINANCIAL_SCHEDULE_ID ;;
  }

  dimension: finance_status {
    type: string
    sql: ${TABLE}.FINANCE_STATUS ;;
  }

  dimension: schedule {
    type: string
    sql: ${TABLE}.SCHEDULE ;;
  }
  dimension: lender {
    type: string
    sql: ${TABLE}.LENDER ;;
  }

  measure: oec {
    type: sum
    sql: ${TABLE}.OEC ;;
  }

}
