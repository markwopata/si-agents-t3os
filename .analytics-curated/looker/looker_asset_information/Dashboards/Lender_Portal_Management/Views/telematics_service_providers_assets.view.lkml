#
# The purpose of this view is tie assets to companies.
# This is for T3 validation. (https://app.shortcut.com/businessanalytics/story/143565)
#
# Britt Shanklin | Built 2022-08-12

view: telematics_service_providers_assets {
  sql_table_name: "ES_WAREHOUSE"."PUBLIC"."TELEMATICS_SERVICE_PROVIDERS_ASSETS" ;;

  dimension: asset_id {
    type: number
    sql: ${TABLE}."ASSET_ID" ;;
  }

  dimension: company_id {
    type: string
    sql: ${TABLE}."COMPANY_ID" ;;
  }

}
