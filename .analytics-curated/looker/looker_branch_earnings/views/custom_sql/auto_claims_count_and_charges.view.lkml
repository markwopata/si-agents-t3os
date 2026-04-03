view: auto_claims_count_and_charges {
  derived_table: {
    sql:
with monthly_loss_counts as
         (select date_trunc(month, hm.date)                   as date_month,
                 MARKET_ID,
                 sum(LOSS_COUNT)                                 monthly_loss_count,
                 sum(case when rn = 1 then VEHICLE_COUNT end) as monthly_avg_vehicle_count
          from (select *,
                       row_number() over (partition by date_trunc(month, date), MARKET_ID order by date desc) as rn --selecting number of vehicles by the last day of month
                from ANALYTICS.CLAIMS.HISTORIC_MARKET_VEHICLE_LOSS_COUNT) hm
          group by date_month, MARKET_ID)
select mlc.date_month,
       mlc.MARKET_ID,
       m.NAME as MARKET_NAME,
       xw.REGION,
       xw.DISTRICT,
       monthly_loss_count,        --loss count sums for the month
       monthly_avg_vehicle_count, --vehicle count at the end of the month
       ma.AVG_VEHICLE_COUNT,      --12 month average vehicle count running average
       ma.TOTAL_LOSS_COUNT,       -- 12 month total loss count running average
       ma.COST_PER_VEHICLE,
       ma.MONTHLY_CHARGE
from monthly_loss_counts mlc
         left join ANALYTICS.CLAIMS.MARKET_AUTO_PREMIUM_RECOVERY ma
                   on mlc.MARKET_ID = ma.MARKET_ID and mlc.date_month = ma.BRANCH_EARNING_DATE::DATE
         join ES_WAREHOUSE.PUBLIC.MARKETS m
              on mlc.MARKET_ID = m.MARKET_ID
         left join ANALYTICS.PUBLIC.MARKET_REGION_XWALK xw
                   on m.MARKET_ID = xw.MARKET_ID
         LEFT JOIN analytics.gs.plexi_periods plexi_periods
                   ON mlc.date_month = plexi_periods.TRUNC
where m.COMPANY_ID = 1854       --branch is an es company
  and m.DISTRICT_ID is not null --they have a district/region assigned to them
  and date_trunc(month,date_month) between dateadd(month, -11, (select trunc::date from analytics.gs.plexi_periods where {% condition period_name %} display {% endcondition %}))
      and (select trunc::date from analytics.gs.plexi_periods where {% condition period_name %} display {% endcondition %});;

  }


  filter: period_name {
    type: string
    suggest_explore: plexi_periods_to_date
    suggest_dimension: plexi_periods_to_date.display
  }

  dimension: date_month {
    type: date_month
    convert_tz: no
    sql: ${TABLE}."DATE_MONTH" ;;
  }

  dimension: market_id {
    type: string
    sql:  ${TABLE}."MARKET_ID";;
  }

  dimension: market_name {
    type: string
    sql:  ${TABLE}."MARKET_NAME";;
  }

  dimension: region {
    type: string
    sql:  ${TABLE}."REGION";;
  }

  dimension: district {
    type: string
    sql:  ${TABLE}."DISTRICT";;
  }

  measure: monthly_loss_count {
    type: sum
    sql:  ${TABLE}."MONTHLY_LOSS_COUNT";;
  }

  measure: monthly_avg_vehicle_count {
    type: sum
    sql:  ${TABLE}."MONTHLY_AVG_VEHICLE_COUNT";;
  }

  measure: avg_vehicle_count {
    type: sum
    sql:  ${TABLE}."AVG_VEHICLE_COUNT";;
  }

  measure: total_loss_count {
    type: sum
    sql:  ${TABLE}."TOTAL_LOSS_COUNT";;
  }

  measure: cost_per_vehicle {
    type: sum
    sql:  ${TABLE}."COST_PER_VEHICLE";;
  }

  measure: monthly_charge {
    type: sum
    sql:  ${TABLE}."MONTHLY_CHARGE";;
  }
}
