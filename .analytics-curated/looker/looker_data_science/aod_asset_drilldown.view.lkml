view: asset_14_day_avg_metric_values_drilldown {
  derived_table: {
    sql: with aod_dm as (
        select to_number(pk_id_json:asset_id) as asset_id, metric_value
        from data_metrics
        where data_metrics.metric_name = 'probability'
          and data_metrics.data_source ilike {% parameter aod_asset_drilldown.data_metric_group %}
          and end_timestamp::date between (dateadd(day, -14, current_date())) and (current_date())
          and data_metrics.metric_value is not null
          and data_metrics.metric_value != 'NULL'
          and data_metrics.pk_id_json:keys = array_construct('asset_id')
      ) select asset_id, avg(metric_value) as average_metric_value, count(metric_value) as metric_value_count
        from aod_dm
        group by asset_id
      ;;
  }
}



view: top_assets_drilldown {
  # Let Looker write this query for BRAND, DATE, measureing SALES and ORDER for 30 days
  derived_table: {
    sql: with top_bot as (
          select asset_id, average_metric_value, metric_value_count
          from ${asset_14_day_avg_metric_values_drilldown.SQL_TABLE_NAME}
          order by average_metric_value desc
        )
        select data_metrics.pk_id_json:asset_id as asset_id, average_metric_value, metric_value_count, to_varchar(round(to_numeric(data_metrics.metric_value), 2)) as metric_value_str, metric_value, end_timestamp::date as day
        from data_metrics join top_bot on (data_metrics.pk_id_json:asset_id = top_bot.asset_id)
        where data_metrics.metric_name = 'probability'
          and data_metrics.data_source ilike {% parameter aod_asset_drilldown.data_metric_group %}
          and end_timestamp::date between (dateadd(day, -14, current_date())) and (current_date())
        ;;
  }
}

view: last_top_assets_drilldown {
  # Let Looker write this query for BRAND, DATE, measureing SALES and ORDER for 30 days
  derived_table: {
    sql: with top_bot as (
          select asset_id, average_metric_value, metric_value_count
          from ${asset_14_day_avg_metric_values_drilldown.SQL_TABLE_NAME}
          order by average_metric_value desc
        )
        select data_metrics.pk_id_json:asset_id as asset_id, average_metric_value, metric_value_count, to_varchar(round(to_numeric(data_metrics.metric_value), 2)) as metric_value_str, metric_value, end_timestamp::date as day
        from data_metrics join top_bot on (data_metrics.pk_id_json:asset_id = top_bot.asset_id)
        where data_metrics.metric_name = 'probability'
          and data_metrics.data_source ilike {% parameter aod_asset_drilldown.data_metric_group %}
          and end_timestamp::date between (dateadd(day, -14, current_date())) and (current_date())
        ;;
  }
}

view: recent_probability_color {
  derived_table: {
    sql:  select met.asset_id as asset_id,
    case when  met.metric_value is null then 'Gray'
            when met.metric_value >= 0.95 then 'Red'
             when met.metric_value >= 0.85 then 'Yellow'
             else 'Green'
            end
             as recentMetricColor
    from ${last_top_assets_drilldown.SQL_TABLE_NAME} met
    inner join
    (select asset_id, MAX(day) as day
    from ${last_top_assets_drilldown.SQL_TABLE_NAME}
    GROUP BY asset_id) recentDay
    on met.day = recentDay.day
    and met.asset_id = recentDay.asset_id
    ;;
  }
}



view : most_recent_value {
  derived_table: {
    sql:  SELECT scores.ASSET_ID, scores.spn, scores.PGN, scores.REPORT_TIMESTAMP as As_Of, scores.Value
            FROM es_warehouse.public.j1939_data scores
            INNER join
            (SELECT ASSET_ID, spn, PGN, MAX(REPORT_TIMESTAMP) AS Last_DateTime
            FROM es_warehouse.public.j1939_data
            WHERE pgn = {% parameter aod_asset_drilldown.pgn %}
            and spn = {% parameter aod_asset_drilldown.spn %}
            GROUP BY ASSET_ID, spn, PGN) lasts
            ON scores.ASSET_ID = lasts.asset_id
            AND scores.pgn = lasts.pgn
            AND scores.spn = lasts.spn
            AND lasts.Last_DateTime = scores.REPORT_TIMESTAMP;;
  }
}




view: asset_day_possible_values_drilldown {
  # Get all the possible values for dates and brands combinations so we can zero fill.
  derived_table: {
    sql: SELECT day, asset_id
      FROM (
        select dateadd(day, '-' || row_number() over (order by null), current_date()) as day
        from table (generator(rowcount => 14))
      ) as dates CROSS JOIN (
        SELECT DISTINCT asset_id
        FROM ${top_assets_drilldown.SQL_TABLE_NAME}
      ) assets ;;
  }
}

view: asset_30_day_possible_values_drilldown {
  # Get all the possible values for dates and brands combinations so we can zero fill.
  derived_table: {
    sql: SELECT day, asset_id
      FROM (
        select dateadd(day, '-' || row_number() over (order by null), current_date()) as day
        from table (generator(rowcount => 30))
      ) as dates CROSS JOIN (
        SELECT DISTINCT asset_id
        FROM ${top_assets_drilldown.SQL_TABLE_NAME}
      ) assets ;;
  }
}


view: engine_data_last_30_days_drilldown {
  derived_table: {
    sql: with j1939_daily_medians as (
          SELECT asset_id, report_timestamp::date as day, to_varchar(round(median(to_number(value)))) as median_value
          from es_warehouse.public.j1939_data j
            join es_warehouse.public.assets a using (asset_id)
          where asset_id in (SELECT DISTINCT asset_id FROM ${top_assets_drilldown.SQL_TABLE_NAME})
            and report_timestamp::date between (dateadd(day, -30, current_date())) and (current_date())
            and pgn = {% parameter aod_asset_drilldown.pgn %}
            and spn = {% parameter aod_asset_drilldown.spn %}
            and j1939_data_id < 0
          group by asset_id, report_timestamp::date
        ) select asset_id,
            LISTAGG(COALESCE(median_value,''),',') WITHIN GROUP (ORDER BY day) as median_list,
            MAX(median_value) as max_asset_specific_value,
            MIN(median_value) as min_asset_specific_value
          from j1939_daily_medians jdm
            right join ${asset_30_day_possible_values_drilldown.SQL_TABLE_NAME} using (asset_id, day)
          group by asset_id;;
  }
}






view: engine_data_reference_drilldown {
  derived_table: {
    sql: with j1939_daily_reference as (
          SELECT a.equipment_model_id, report_timestamp::date as day, to_varchar(round(median(to_number(value)))) as median_value
          from es_warehouse.public.j1939_data j
            join es_warehouse.public.assets a using (asset_id)
          where a.equipment_model_id in (
                SELECT DISTINCT equipment_model_id
                FROM es_warehouse.public.assets
                    join (SELECT DISTINCT asset_id FROM ${top_assets_drilldown.SQL_TABLE_NAME}) as relevant_assets using (asset_id)
          )
            and report_timestamp::date between (dateadd(day, -30, current_date())) and (current_date())
            and pgn = {% parameter aod_asset_drilldown.pgn %}
            and spn = {% parameter aod_asset_drilldown.spn %}
            and j1939_data_id < 0
          group by a.equipment_model_id, report_timestamp::date
        ) select equipment_model_id, LISTAGG(COALESCE(median_value,''),',') WITHIN GROUP (ORDER BY day) as ref_median_list,
            MAX(median_value) as max_reference_value,
            MIN(median_value) as min_reference_value
          from j1939_daily_reference jdm
            right join (SELECT DISTINCT day FROM ${asset_30_day_possible_values_drilldown.SQL_TABLE_NAME}) as dates using (day)
          group by equipment_model_id
        ;;
  }
}






view: asset_probabilities_drilldown {
  derived_table: {
    sql: SELECT pv.asset_id,
        LISTAGG(COALESCE(pq.metric_value_str,''),',') WITHIN GROUP (ORDER BY pv.day) as all_probabilities,
        LISTAGG(CASE WHEN pq.metric_value is null THEN '100' ELSE '' END,',') WITHIN GROUP (ORDER BY pv.day) as grey_probabilities,
        LISTAGG(CASE WHEN COALESCE(pq.metric_value,0.0) >= 0.95 THEN '100' ELSE '' END,',') WITHIN GROUP (ORDER BY pv.day) as red_probabilities,
        LISTAGG(CASE WHEN COALESCE(pq.metric_value,0.0) < 0.95 and COALESCE(pq.metric_value,0.0) >= 0.85 THEN '100' ELSE '' END,',') WITHIN GROUP (ORDER BY pv.day) as yellow_probabilities,
        LISTAGG(CASE WHEN pq.metric_value is not null and COALESCE(pq.metric_value,0.0) < 0.85 THEN '100' ELSE '' END,',') WITHIN GROUP (ORDER BY pv.day) as green_probabilities
      FROM  ${top_assets_drilldown.SQL_TABLE_NAME} as pq
      RIGHT JOIN  ${asset_day_possible_values_drilldown.SQL_TABLE_NAME} as pv ON pv.day = pq.day AND pv.asset_id = pq.asset_id
      GROUP BY 1
      ;;
  }
}







view: aod_asset_drilldown {
  derived_table: {
    sql: SELECT p.asset_id,
        average_metric_value as average_abnormal_probability,
        metric_value_count as abnormal_probability_count,
        all_probabilities,
        15 - least(position('1',reverse(all_probabilities)),position('0',reverse(all_probabilities))) as last_data_day,
        grey_probabilities,
        red_probabilities,
        yellow_probabilities,
        green_probabilities,
        median_list,
        ref_median_list,
        concat(Year,' ',Make,' ',Model) AS year_make_model,
        LEAST(min_reference_value, coalesce(min_asset_specific_value,10000000)) as lower_bound,
        GREATEST(max_reference_value, coalesce(max_asset_specific_value,-10000000)) as upper_bound,
        coalesce(wo.open_work_orders,0) as open_work_orders,
        round(up.Usage_Percentage_Remaining * 100, 0) as usage_percentage_remaining,
        up.Service_Interval_Name as service_interval_name,
        case when up.Usage_Percentage_Remaining <=0 then 'Red'
             when up.Usage_Percentage_Remaining <.8 then 'Orange'
             else 'Green'
            end as Usage_Percentage_Remaining_Color,
        round(recent.value, 0) as recentValue,
        As_Of,
        recentColor.recentMetricColor as recent_Metric_Color
      from ${asset_probabilities_drilldown.SQL_TABLE_NAME} p
        join ${asset_14_day_avg_metric_values_drilldown.SQL_TABLE_NAME} as amv using (asset_id)
        join es_warehouse.public.assets as assets using (asset_id)
        join ${engine_data_last_30_days_drilldown.SQL_TABLE_NAME} as ed using (asset_id)
        left join ${most_recent_value.SQL_TABLE_NAME} as recent using (asset_id)
        left join ${recent_probability_color.SQL_TABLE_NAME} as recentColor using (asset_id)
        left join ${engine_data_reference_drilldown.SQL_TABLE_NAME} as er using (equipment_model_id)
        left join (SELECT asset_id, count(ASSET_ID) as open_work_orders  FROM ES_WAREHOUSE.WORK_ORDERS.WORK_ORDERS
          WHERE WORK_ORDER_STATUS_ID = 1 GROUP BY ASSET_ID) as wo using (asset_id)
        left join (SELECT ASSET_ID ,USAGE_PERCENTAGE_REMAINING , SERVICE_INTERVAL_NAME FROM (
          SELECT asset_ID, USAGE_PERCENTAGE_REMAINING, SERVICE_INTERVAL_NAME,
          row_number() OVER (PARTITION BY ASSET_ID ORDER BY USAGE_PERCENTAGE_REMAINING ASC) AS row_number
          from ES_WAREHOUSE."PUBLIC".ASSET_SERVICE_INTERVALS) WHERE ROW_NUMBER = 1
          ) as up using (asset_id)

      order by average_abnormal_probability desc
    ;;
  }




  dimension: asset_ymm {
    type:  string
    sql: ${TABLE}.asset_id;;
    #html: <a href="https://app.estrack.com/#/home/assets/all/asset/{{rendered_value}}" target="_blank"><button type="button">{{rendered_value}} — {{year_make_model._value}}</button></a>;;
    html: <p style ="color:#0000FF"><u><a href="https://app.estrack.com/#/home/assets/all/asset/{{rendered_value}}" target="_blank">{{rendered_value}} — {{year_make_model._value}}</a></u></p>;;
  }
  dimension: asset_id {hidden: no}
  dimension: year_make_model {hidden: no}
  dimension: average_abnormal_probability {hidden: no}
  dimension: abnormal_probability_count {hidden: yes}
  dimension: lower_bound {hidden: yes}
  dimension: upper_bound {hidden: yes}
  dimension: all_probabilities {hidden: no}
  dimension: last_data_day {hidden: no}
  dimension: grey_probabilities {hidden: no}
  dimension: red_probabilities {hidden: no}
  dimension: yellow_probabilities {hidden: no}
  dimension: green_probabilities {hidden: no}
  dimension: median_list {hidden: no}
  dimension: ref_median_list {hidden: no}
  dimension: open_work_orders {hidden:no}
  dimension: service_interval_name {hidden:no}
  dimension: Usage_Percentage_Remaining_Color {hidden: yes}
  dimension: usage_percentage_remaining  {hidden:no type:number}
  dimension: recentValue{hidden: yes}
  dimension: as_of {hidden: yes}
  dimension: last_data {
    sql: ${as_of} ;;
    html: {{ rendered_value | date: "%m/%d/%Y %I:%Mpm" }} ;;
  }
  dimension: recent_Metric_Color {hidden: no}
  dimension: most_recent_value {
    sql: '1';;
    html:   <div height=60><div style="width: 45px;
    height: 45px;
    line-height: 45px;
    border-radius: 50%;
    font-size: 12px;
    color: #000000;
    text-align: center;
    background: {{recent_Metric_Color}}"  ><b>{{recentValue}}</b></div></div> ;;

  }
  dimension: abnormal_probabilities_last_14_days{
    sql: '1';;
    # html: <img src="https://image-charts.com/chart?chs=200x50&cht=ls&chd=t:{{probabilities._value}}">;;
    # html: <img src="https://quickchart.io/chart?chs=200x50&cht=ls&chd=t:{{probabilities._value}}&chls=1">;;
    html: <img height="30" width="200" src="https://quickchart.io/chart?chs=200x30&cht=bvs&chd=a:{{grey_probabilities._value}}|{{red_probabilities._value}}|{{yellow_probabilities._value}}|{{green_probabilities._value}}&chco=aaaaaa,aa2222,aaaa22,22aa22">;;
    # html: <img src="https://quickchart.io/chart?bkg=white&c={type:%27sparkline%27,data:{datasets:[{data:[{{probabilities._value}}],fill:false}]}}">;;
  }
  dimension: engine_data_last_30_days{
    sql: '1';;
    #html: <img src="https://quickchart.io/chart?chs=400x50&cht=ls&chd=a:{{median_list._value}}|{{ref_median_list._value}}&chco=882222,22228877&chxt=y&chxr=0,{{lower_bound._value}},{{upper_bound._value}}">;;
    html: <img height="200" width="1000" src="https://quickchart.io/chart?w=1000&h=200&c={type:%27line%27,options:{scales:{yAxes:[{ticks:{min:{{lower_bound._value}},max:{{upper_bound._value}},maxTicksLimit:2},gridLines:{display:false}}],xAxes:[{gridLines:{display:false}}]},plugins:{legend:false}},data:{labels:[%27%27,%27%27,%27%27,%27%27,%27%27,%27%27,%27%27,%27%27,%27%27,%27%27,%27%27,%27%27,%27%27,%27%27,%27%27,%27%27,%27%27,%27%27,%27%27,%27%27,%27%27,%27%27,%27%27,%27%27,%27%27,%27%27,%27%27,%27%27,%27%27,%27%27],datasets:[{data:[{{median_list._value}}],fill:false,backgroundColor:%27%2322228877%27,borderColor:%27%2322228877%27},{data:[{{ref_median_list._value}}],fill:false,backgroundColor:%27%2388222277%27,borderColor:%27%2388222277%27}]}}">;;
  }

  dimension: service_percent_remaining {type: number sql: 1.0*(${usage_percentage_remaining});;

    html: <p style="text-align:left;color:{{Usage_Percentage_Remaining_Color}}">{{value}}% - {{service_interval_name}} ({{open_work_orders}} open work orders)</p>
              <div style="float: left

                ; width:{{value}}%

                ; background-color: {{Usage_Percentage_Remaining_Color}}

                ; text-align:left

                ; color: #FFFFFF

                ; border-radius: 5px"> <p style="margin-bottom: 0; margin-left: 4px;">&nbsp;</p>

                </div>


            ;;

    }
    dimension: drilldown_top {
      sql: '1';;
    html:   <div height=80><div style="width: 80px;
    height: 80px;
    line-height: 80px;
    border-radius: 50%;
    font-size: 20px;
    color: #000000;
    text-align: center;
    background: {{recent_Metric_Color}}"  ><b>{{recentValue}}</b></div></div>
    <img height="30" width="80" src="https://quickchart.io/chart?chs=80x30&cht=bvs&chd=a:{{grey_probabilities._value}}|{{red_probabilities._value}}|{{yellow_probabilities._value}}|{{green_probabilities._value}}&chco=aaaaaa,aa2222,aaaa22,22aa22">
    ;;

    }
    dimension: header {
      sql: ${as_of} ;;
      html: <H1>{{year_make_model}}</H1><br><h3>Data as of {{ rendered_value | date: "%m/%d/%Y %I:%M pm" }}</h3>  ;;
    }


    parameter: pgn {
      type: string
      allowed_value: {
        label: "Coolant Temperature"
        value: "65262"
      }
      allowed_value: {
        label: "Oil Pressure"
        value: "65263"
      }
      allowed_value: {
        label: "Oil Temperature"
        value: "65262"
      }
      suggestions: ["Engine Coolant"]
    }

    parameter: spn {
      type: string
      allowed_value: {
        label: "Coolant Temperature"
        value: "110"
      }
      allowed_value: {
        label: "Oil Pressure"
        value: "100"
      }
      allowed_value: {
        label: "Oil Temperature"
        value: "175"
      }
      suggestions: ["Engine Coolant"]
    }

    parameter: data_metric_group {
      type: string
      allowed_value: {
        label: "Coolant Temperature"
        value: "aod%1056%110"
      }
      allowed_value: {
        label: "Oil Pressure"
        value: "aod%1056%100"
      }
      allowed_value: {
        label: "Engine Oil Temperature"
        value: "aod%1056%175"
      }
      suggestions: ["Engine Coolant"]
    }
  }
