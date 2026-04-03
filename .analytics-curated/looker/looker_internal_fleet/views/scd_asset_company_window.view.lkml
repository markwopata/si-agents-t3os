include: "/views/scd_asset_company.view"

view: scd_asset_company_window {

  extends: [scd_asset_company]

  derived_table: {
    sql:
      SELECT
        ASSET_ID,
        COMPANY_ID,
        LEAD(COMPANY_ID, -1) OVER (PARTITION BY ASSET_ID ORDER BY ASSET_SCD_COMPANY_ID) AS previous_company_id,
        DATE_START,
        CURRENT_FLAG
      FROM
        SCD.SCD_ASSET_COMPANY ;;
  }

  dimension: previous_company_id {
    type: number
    sql: ${TABLE}.previous_company_id ;;
  }

}
