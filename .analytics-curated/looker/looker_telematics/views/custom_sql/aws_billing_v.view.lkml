view: aws_billing_v {
derived_table: {
sql: WITH aws_cte as
        (
             SELECT date_trunc('month', USAGESTARTDATE)::date as dte,
                    sum(USAGEQUANTITY)                        as usagequantity,
                    sum(TOTALCOST)                            as totalcost
             FROM aws_billing
             GROUP BY date_trunc('month', USAGESTARTDATE)::date
         ),
  trackers_cte as
      (
          SELECT count(ata.TRACKER_ID) as tracker_count,
                 ds.dte
          FROM ES_WAREHOUSE.PUBLIC.ASSET_TRACKER_ASSIGNMENTS ata
                   JOIN (SELECT distinct date_trunc('month', d.SERIES)::date as dte
                         FROM table (ES_WAREHOUSE.public.generate_series('2015-01-01'::timestamp_tz,
                                                                         current_date::timestamp_tz, '1 week')) d) ds
                        ON ds.dte BETWEEN ata.DATE_INSTALLED AND coalesce(ata.DATE_UNINSTALLED, '2099-12-31')
          GROUP BY ds.dte
      ),
  assets_cte as
         (
             SELECT date_trunc('month', dte)::date                    as dte,
                    count(ASSET_ID) / day(CASE
                                              WHEN date_trunc('month', current_date) = date_trunc('month', dte)
                                                  THEN current_date
                                              ELSE last_day(dte) end) as avg_assets_on_rent
             FROM HISTORICAL_UTILIZATION
             WHERE ON_RENT
             GROUP BY date_trunc('month', dte)::date,
                      day(CASE
                              WHEN date_trunc('month', current_date) = date_trunc('month', dte) THEN current_date
                              ELSE last_day(dte) end)
         )
SELECT row_number() over(ORDER BY aws.dte) as pk,
        aws.dte,
       aws.usagequantity,
      aws.totalcost,
       tc.tracker_count,
       ac.avg_assets_on_rent
FROM aws_cte aws
    LEFT JOIN trackers_cte tc
        ON aws.dte = tc.dte
    LEFT JOIN assets_cte ac
        ON aws.dte = ac.dte
WHERE aws.dte is not null
ORDER BY aws.dte   ;;
  }

  dimension: pk {
    type: number
    primary_key: yes
    sql: ${TABLE}."PK" ;;
  }

  dimension_group: month {
    type: time
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year
    ]
    sql:${TABLE}."DTE" ;;

  }

  measure: usage {
    type: sum
    sql: ${TABLE},"USAGEQUANTITY" ;;
  }

  measure: cost {
    type: sum
    sql: ${TABLE},"TOTALCOST" ;;
  }

  measure: trackers {
    type: sum
    sql: ${TABLE},"TRACKER_COUNT" ;;
  }

  measure: avg_assets_on_rent {
    type: sum
    sql: ${TABLE},"AVG_ASSETS_ON_RENT" ;;
  }

}
