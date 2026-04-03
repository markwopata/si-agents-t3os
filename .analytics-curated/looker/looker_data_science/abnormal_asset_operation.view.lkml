view: abnormal_operation_detection {
  derived_table: {
    sql: with week_average_metric_values_by_asset as (
            select asset_id, avg(data_metrics.metric_value) as average_metric_value
            from data_metrics
            where data_metrics.metric_name = 'probability'
              and data_metrics.data_source ilike 'aod%1056%'
              and start_timestamp::date between (dateadd(day, -14, current_date())) and (current_date())
              and data_metrics.metric_value is not null
              and data_metrics.metric_value <> 'NULL'
              --and start_timestamp between (current_date() - interval '7 days') and (current_date())
            group by asset_id
          ), top_asset_ids_by_metric_value as (
            select asset_id--, average_metric_value
            from week_average_metric_values_by_asset
            order by average_metric_value asc
            limit 17
          ), bottom_asset_ids_by_metric_value as (
            select asset_id--, average_metric_value
            from week_average_metric_values_by_asset
            order by average_metric_value desc
            limit 3
          ), top_bot as (
            select * from top_asset_ids_by_metric_value
             UNION
            select * from bottom_asset_ids_by_metric_value
          )
          select data_metrics.asset_id, data_metrics.metric_value, start_timestamp::date as day
          from data_metrics join top_bot using (asset_id)
          where data_metrics.metric_name = 'probability'
            and data_metrics.data_source ilike 'aod%1056%'
            and start_timestamp::date between (dateadd(day, -14, current_date())) and (current_date())
        ;;
  }

  dimension: asset_id {
    type: number
    sql: asset_id ;;
  }

  dimension: day {
    type: date
    sql: day ;;
  }

  measure: metric_value {
    label: "Probability of Typical Operation"
    type: max
    sql: metric_value ;;
  }

  set: detail {
    fields: [asset_id, metric_value, day]
  }
}
