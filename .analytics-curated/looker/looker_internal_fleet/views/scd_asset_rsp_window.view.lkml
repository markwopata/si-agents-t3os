include: "scd_asset_rsp.view"

view: scd_asset_rsp_window {

  extends: [scd_asset_rsp]

  derived_table: {
    sql:
      SELECT
        SCD_ASSET_RSP_ID,
        ASSET_ID,
        RENTAL_BRANCH_ID,
        USER_ID,
        LEAD(RENTAL_BRANCH_ID, -1) OVER (PARTITION by ASSET_ID ORDER by SCD_ASSET_RSP_ID) as previous_rsp_id,
        DATE_START,
        DATE_END,
        CURRENT_FLAG
      FROM
        SCD.SCD_ASSET_RSP
      ;;
  }
  dimension: previous_rsp_id {
    type:  number
    sql:  ${TABLE}.previous_rsp_id ;;
  }
}
