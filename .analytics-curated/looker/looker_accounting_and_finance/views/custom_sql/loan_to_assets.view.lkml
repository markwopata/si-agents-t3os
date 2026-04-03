view: loan_to_assets {
  # Or, you could make this view a derived table, like this:
  derived_table: {
    sql: --this code ties all loans to the assets on the loan
     with scheduleID_to_assets as (
      select distinct asset_id, financial_schedule_id
      from ES_WAREHOUSE.PUBLIC.ASSET_PURCHASE_HISTORY aph
      where financial_schedule_id is not null
      order by
      financial_schedule_id)
      , add_schedule_nm as
      (select b.schedule, b.phoenix_id, b.sage_loan_id, a.*
      from
        scheduleID_to_assets a
        left join
        ANALYTICS.DEBT.PHOENIX_ID_TYPES b
        on
        a.financial_schedule_id = b.financial_schedule_id)
      --select * from add_schedule_nm
      ,add_asset_info as (
      select a.*, b.DESCRIPTION , b.year, b.MAKE, b.MODEL
      from
        add_schedule_nm a
        left join
        ES_WAREHOUSE.PUBLIC.ASSETS b
        on
        a.asset_id = b.asset_id)
      select * from add_asset_info
            ;;
  }
  dimension: schedule {
    type: string
    sql: ${TABLE}.schedule ;;
  }
  dimension: phoenix_id {
    type: number
    sql: ${TABLE}.phoenix_id ;;
  }
  dimension: sage_loan_id {
    type: string
    sql: ${TABLE}.sage_loan_id ;;
  }
  dimension: asset_id {
    type: number
    sql: ${TABLE}.asset_id ;;
  }
  dimension: financial_schedule_id {
    type: number
    sql: ${TABLE}.financial_schedule_id ;;
  }
  dimension: description {
    type: string
    sql: ${TABLE}.description ;;
  }
  dimension: year {
    type: number
    sql: ${TABLE}.year ;;
  }
  dimension: make {
    type: string
    sql: ${TABLE}.make ;;
  }
  dimension: model {
    type: string
    sql: ${TABLE}.model ;;
  }
}
