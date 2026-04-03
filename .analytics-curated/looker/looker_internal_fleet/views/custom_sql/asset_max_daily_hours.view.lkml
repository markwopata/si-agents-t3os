
view: asset_max_daily_hours {
  derived_table: {
    sql: with invoice_info as (
select coalesce(li.ASSET_ID, regexp_substr(li.DESCRIPTION, 'Asset: (\\d{1,})', 1, 1, 'e')::integer) as asset_id,
       date_trunc(day,i.INVOICE_DATE)::date as invoice_date
from ES_WAREHOUSE.PUBLIC.LINE_ITEMS li
left join ES_WAREHOUSE.PUBLIC.INVOICES i on li.INVOICE_ID = i.INVOICE_ID
where line_item_type_id in (24, 50, 80, 81, 110, 111, 118, 120, 123, 125, 126, 127, 141)
--and ASSET_ID = 178720
),
asset_hours as (
select ASSET_ID,
       date_trunc(day,DATE_START)::date as date,
       case when lag(date_trunc(day,DATE_START),1) over (partition by ASSET_ID order by date_trunc(day,DATE_START) desc) is null
            then '9999-12-31 00:00:00.000000000 +00:00'
            else lag(date_trunc(day,DATE_START),1) over (partition by ASSET_ID order by date_trunc(day,DATE_START) desc)
            END as date_needed_to_get_previous_hours,
       -- This case statement is needed for assets that have only had one entry in the SCD table, meaning there is no previous date available.
       max(HOURS) as max_hours,
       lag(max(HOURS),-1) over (partition by ASSET_ID order by date_trunc(day,DATE_START) desc) as previous_max_hours
from ES_WAREHOUSE.SCD.SCD_ASSET_HOURS
--where ASSET_ID = 178720
group by ASSET_ID,
         date_trunc(day,DATE_START)
order by date_trunc(day,DATE_START) desc
),
official_asset_hours as (
select ii.invoice_date,
       ah.*,
       case when ii.invoice_date = ah.date then 1
            when ii.invoice_date <> ah.date
                 AND ii.invoice_date between ah.date and ah.date_needed_to_get_previous_hours
                 then 2 else 0 end as invoice_date_flag,
       case when invoice_date_flag = 2 and previous_max_hours is null then max_hours else null end as max_hours_if_no_previous_scd_entry
from invoice_info ii
left join asset_hours ah on ii.ASSET_ID = ah.ASSET_ID
--where ii.ASSET_ID in (104376)
),
final_asset_max_hours as (
select distinct oah.ASSET_ID,
       max_hours,
       invoice_date
from official_asset_hours oah
where invoice_date_flag = 1
  --and ASSET_ID = 104376
),
final_previous_asset_max_hours as (
select distinct oah.ASSET_ID,
       previous_max_hours,
       max_hours_if_no_previous_scd_entry,
       invoice_date
from official_asset_hours oah
where invoice_date_flag = 2
  --and ASSET_ID = 104376
)
select distinct coalesce(famh.ASSET_ID, fpamh.ASSET_ID) as asset_id,
                coalesce(famh.max_hours, fpamh.previous_max_hours, fpamh.max_hours_if_no_previous_scd_entry) as max_hours,
                coalesce(famh.invoice_date, fpamh.invoice_date) as invoice_date
from invoice_info iif
left join final_asset_max_hours famh on iif.ASSET_ID = famh.ASSET_ID
left join final_previous_asset_max_hours fpamh on iif.ASSET_ID = fpamh.ASSET_ID;;
##where coalesce(famh.ASSET_ID, fpamh.ASSET_ID) = 178720;
  }

  measure: count {
    type: count
  }

  dimension: asset_id {
    type: number
    sql: ${TABLE}."ASSET_ID" ;;
  }

  dimension: max_hours {
    label: "Asset Hours at Invoice"
    type: number
    sql: ${TABLE}."MAX_HOURS" ;;
  }

  dimension_group: invoice {
    type: time
    sql: ${TABLE}."INVOICE_DATE" ;;
  }

}
