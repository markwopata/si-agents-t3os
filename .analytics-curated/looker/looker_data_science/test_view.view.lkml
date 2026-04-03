view: test_view {
  derived_table: {
    sql: with aod_dm as (
        select to_number(pk_id_json:asset_id) as asset_id, metric_value
        from data_metrics
        where data_metrics.metric_name = 'probability'
          and data_metrics.data_source ilike {% parameter aod_asset_sparklines.data_metric_group %}
          and end_timestamp::date between (dateadd(day, -14, current_date())) and (current_date())
          and data_metrics.metric_value is not null
          and data_metrics.metric_value != 'NULL'
          and data_metrics.pk_id_json:keys = array_construct('asset_id')
      ) select asset_id, avg(metric_value) as average_metric_value, count(metric_value) as metric_value_count
        from aod_dm
        group by asset_id
      ;;
  }
  dimension: asset_id {hidden: no}
  dimension: metric_value {hidden: yes}

}
