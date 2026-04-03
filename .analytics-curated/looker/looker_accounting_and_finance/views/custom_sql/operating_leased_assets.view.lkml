view: operating_leased_assets {
  parameter: as_of_date {
    type: date
  }
  # Or, you could make this view a derived table, like this:
  derived_table: {
    sql: select afs.ASSET_ID, fs.CURRENT_SCHEDULE_NUMBER,  afs.financial_schedule_id,
    last_day({% parameter as_of_date %}::date) as as_of_date
from ANALYTICS.PUBLIC.ASSET_FINANCING_SNAPSHOTS afs
left join ES_WAREHOUSE.PUBLIC.FINANCIAL_SCHEDULES fs
on afs.FINANCIAL_SCHEDULE_ID = fs.FINANCIAL_SCHEDULE_ID
where afs.FINANCIAL_SCHEDULE_ID in
      (
          select FINANCIAL_SCHEDULE_ID
          from ANALYTICS.DEBT.LOAN_ATTRIBUTES
          where FINANCING_FACILITY_TYPE = 'Operating'
            and GAAP = false
            and PENDING = false
            and RECORD_STOP_DATE like '9999%'
      )
and afs.DATE = last_day({% parameter as_of_date %}::date)
order by afs.FINANCIAL_SCHEDULE_ID
      ;;
  }

  # Define your dimensions and measures here, like this:
  dimension: asset_id {
    description: "Unique ID for each asset"
    type: number
    sql: ${TABLE}.asset_id ;;
  }
  dimension: CURRENT_SCHEDULE_NUMBER {
    type: string
    sql: ${TABLE}.CURRENT_SCHEDULE_NUMBER ;;
  }
  dimension: financial_schedule_id {
    type: number
    sql: ${TABLE}.financial_schedule_id ;;
  }
  dimension: as_of_eom {
    type: date
    sql: ${TABLE}.as_of_date ;;
  }
}
