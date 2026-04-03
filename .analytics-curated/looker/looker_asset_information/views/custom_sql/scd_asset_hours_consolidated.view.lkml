view: scd_asset_hours_consolidated {
  derived_table: {
    # datagroup_trigger: 6AM_update
    sql:

with asset_hours as(
select
ash.asset_id
,ash.hours
,ROW_NUMBER() OVER (PARTITION BY ash.asset_id ORDER BY ash.date_start DESC) AS rn
from ES_WAREHOUSE.SCD.SCD_ASSET_HOURS ash
order by ash.asset_id ,ash.date_start
)
,consolidate_hours as(
select
ah.asset_id
,hours
from asset_hours ah
where rn=1
) select * from consolidate_hours;;

}

  dimension: asset_id {
    type: number
    sql: ${TABLE}.asset_id ;;
  }

  dimension: hours {
    type: number
    sql: ${TABLE}.hours ;;
  }

}
