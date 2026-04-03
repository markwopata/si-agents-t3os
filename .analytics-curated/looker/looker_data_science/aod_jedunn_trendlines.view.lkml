view: aod_previous_probabilities {
    derived_table: {
      sql: with company_asset_id as (
        select distinct
          asset_id
        from es_warehouse.public.assets
        -- This line could likely be parameterized here
        where company_id in (8935)
        and deleted = False
      )
      , aod_dm as (
        select
          to_number(pk_id_json:asset_id) as asset_id,
          metric_value
        from data_metrics
        where data_metrics.metric_name = 'probability'
          and data_metrics.data_source ilike '%aod%'
          --and data_metrics.data_source ilike {% parameter aod_jedunn_trendlines.data_metric_group %} escape '^'
          --and end_timestamp::date between (dateadd(day, -14, current_date())) and (current_date())
          and data_metrics.metric_value is not null
          and asset_id in (select asset_id from company_asset_id)
          and data_metrics.metric_value != 'NULL'
          and data_metrics.pk_id_json:keys = array_construct('asset_id')
      ) select
          asset_id,
          avg(metric_value) as average_metric_value,
          count(metric_value) as metric_value_count
        from aod_dm
        group by asset_id
      ;;
    }
  }



  view: top_assets_by_company {
    derived_table: {
      sql: with top_bot as (
          select
            asset_id,
            average_metric_value,
            metric_value_count
          from ${aod_previous_probabilities.SQL_TABLE_NAME}
          order by average_metric_value desc
          limit 20
        )
        select
          data_metrics.pk_id_json:asset_id as asset_id,
          average_metric_value,
          metric_value_count,
          to_varchar(round(to_numeric(data_metrics.metric_value), 2)) as metric_value_str,
          metric_value,
          end_timestamp::date as day
        from data_metrics
        join top_bot on (data_metrics.pk_id_json:asset_id = top_bot.asset_id)
        where data_metrics.metric_name = 'probability'
          and data_metrics.data_source ilike '%aod%'
          --and data_metrics.data_source ilike {% parameter aod_jedunn_trendlines.data_metric_group %}  escape '^'
          --and end_timestamp::date between (dateadd(day, -14, current_date())) and (current_date())
        ;;
    }
  }

  view: asset_time_window_possible_values {
    # Get all the possible values for dates and brands combinations so we can zero fill.
    derived_table: {
      sql: SELECT day, asset_id
              FROM (
                select dateadd(day, '-' || row_number() over (order by null), current_date()) as day
                from table (generator(rowcount => 14))
              ) as dates CROSS JOIN (
                SELECT DISTINCT asset_id
                FROM ${top_assets_by_company.SQL_TABLE_NAME}
              ) assets ;;
    }
  }

  view: engine_data_last_two_weeks_company {
    derived_table: {
      sql: with j1939_daily_medians as (
          SELECT
            asset_id,
            report_timestamp::date as day,
            to_varchar(round(median(to_number(value)))) as median_value
          from es_warehouse.public.j1939_data
          join es_warehouse.public.assets using (asset_id)
          where asset_id in (SELECT DISTINCT asset_id FROM ${top_assets_by_company.SQL_TABLE_NAME})
            --and report_timestamp::date between (dateadd(day, -14, current_date())) and (current_date())
            and pgn = {% parameter aod_jedunn_trendlines.pgn %}
            and spn = {% parameter aod_jedunn_trendlines.spn %}
            and j1939_data_id < 0
          group by asset_id, report_timestamp::date
        ) select
            asset_id,
            LISTAGG(COALESCE(median_value,''),',') WITHIN GROUP (ORDER BY day) as median_list,
            -- Force median_value to first unit precision (default for to_number with no arguments)
            MAX(to_number(median_value)) as max_asset_specific_value,
            MIN(to_number(median_value)) as min_asset_specific_value
          from j1939_daily_medians jdm
          right join ${asset_time_window_possible_values.SQL_TABLE_NAME} using (asset_id, day)
          group by asset_id;;
    }
  }

  view: engine_data_reference_total {
    derived_table: {
      sql: with j1939_daily_reference as (
          SELECT
            a.equipment_model_id,
            report_timestamp::date as day,
            to_varchar(round(median(to_number(value)))) as median_value
          from es_warehouse.public.j1939_data j
            join es_warehouse.public.assets a using (asset_id)
          where a.equipment_model_id in (
              SELECT DISTINCT equipment_model_id
              FROM es_warehouse.public.assets
              join (SELECT DISTINCT asset_id  FROM ${top_assets_by_company.SQL_TABLE_NAME}) as relevant_assets using (asset_id)
            )
            --and report_timestamp::date between (dateadd(day, -14, current_date())) and (current_date())
            and pgn = {% parameter aod_jedunn_trendlines.pgn %}
            and spn = {% parameter aod_jedunn_trendlines.spn %}
            and j1939_data_id < 0
          group by a.equipment_model_id, report_timestamp::date
        )
        select
          equipment_model_id,
          LISTAGG(COALESCE(median_value,''),',') WITHIN GROUP (ORDER BY day) as ref_median_list,
          -- Force median_value to first unit precision (default for to_number with no arguments)
          MAX(to_number(median_value)) as max_reference_value,
          MIN(to_number(median_value)) as min_reference_value
        from j1939_daily_reference jdm
        right join (SELECT DISTINCT day FROM ${asset_time_window_possible_values.SQL_TABLE_NAME}) as dates using (day)
          group by equipment_model_id
        ;;
    }
  }

  view: asset_probabilities_company {
    derived_table: {
      sql: SELECT
          pv.asset_id,
          LISTAGG(COALESCE(pq.metric_value_str,''),',') WITHIN GROUP (ORDER BY pv.day) as all_probabilities,
          LISTAGG(CASE WHEN pq.metric_value is null THEN '100' ELSE '' END,',') WITHIN GROUP (ORDER BY pv.day) as grey_probabilities,
          LISTAGG(CASE WHEN COALESCE(pq.metric_value,0.0) >= 0.95 THEN '100' ELSE '' END,',') WITHIN GROUP (ORDER BY pv.day) as red_probabilities,
          LISTAGG(CASE WHEN COALESCE(pq.metric_value,0.0) < 0.95 and COALESCE(pq.metric_value,0.0) >= 0.85 THEN '100' ELSE '' END,',') WITHIN GROUP (ORDER BY pv.day) as yellow_probabilities,
          LISTAGG(CASE WHEN pq.metric_value is not null and COALESCE(pq.metric_value,0.0) < 0.85 THEN '100' ELSE '' END,',') WITHIN GROUP (ORDER BY pv.day) as green_probabilities
      FROM  ${top_assets_by_company.SQL_TABLE_NAME} as pq
      RIGHT JOIN  ${asset_time_window_possible_values.SQL_TABLE_NAME} as pv ON pv.day = pq.day AND pv.asset_id = pq.asset_id
      GROUP BY 1
      ;;
    }
  }


  view: aod_jedunn_trendlines {
    derived_table: {
      sql: SELECT
        p.asset_id,
        average_metric_value as average_abnormal_probability,
        metric_value_count as abnormal_probability_count,
        all_probabilities,
        grey_probabilities,
        red_probabilities,
        yellow_probabilities,
        green_probabilities,
        median_list,
        ref_median_list,
        concat(Year,' ',Make,' ',Model) AS year_make_model,
        -- This is prone to errors on the edge case where both asset_specific and reference are null
        least(coalesce(min_reference_value, 9999), coalesce(min_asset_specific_value, 9999)) as lower_bound,
        greatest(coalesce(max_reference_value, -9999), coalesce(max_asset_specific_value, -9999)) as upper_bound,
        -- This is prone to casting as null if there is no reference value suggest the above instead
        LEAST(min_reference_value, coalesce(min_asset_specific_value,10000000)) as lower_bound_old,
        GREATEST(max_reference_value, coalesce(max_asset_specific_value,-10000000)) as upper_bound_old,
        coalesce(wo.open_work_orders,0) as open_work_orders,
        round(up.Usage_Percentage_Remaining * 100, 0) as usage_percentage_remaining,
        up.Service_Interval_Name as service_interval_name,
        case when up.Usage_Percentage_Remaining <=0 then 'Red'
             when up.Usage_Percentage_Remaining <.8 then 'Orange'
             else 'Green'
        end as Usage_Percentage_Remaining_Color,
        WORK_ORDER_ID
      from ${asset_probabilities_company.SQL_TABLE_NAME} p
        join ${aod_previous_probabilities.SQL_TABLE_NAME} as amv using (asset_id)
        join es_warehouse.public.assets as assets using (asset_id)
        join ${engine_data_last_two_weeks_company.SQL_TABLE_NAME} as ed using (asset_id)
        left join ${engine_data_reference_total.SQL_TABLE_NAME} as er using (equipment_model_id)
        left join (SELECT asset_id, count(ASSET_ID) as open_work_orders  FROM ES_WAREHOUSE.WORK_ORDERS.WORK_ORDERS
          WHERE WORK_ORDER_STATUS_ID = 1 GROUP BY ASSET_ID) as wo using (asset_id)
        left join (SELECT
                    ASSET_ID ,
                    USAGE_PERCENTAGE_REMAINING,
                    SERVICE_INTERVAL_NAME
                    FROM (
                      SELECT
                        asset_ID,
                        USAGE_PERCENTAGE_REMAINING,
                        SERVICE_INTERVAL_NAME,
                        row_number() OVER (PARTITION BY ASSET_ID ORDER BY USAGE_PERCENTAGE_REMAINING ASC) AS row_number
                      from ES_WAREHOUSE."PUBLIC".ASSET_SERVICE_INTERVALS) WHERE ROW_NUMBER = 1
                  ) as up using (asset_id)
        left join (SELECT
                    asset_id,
                    WORK_ORDER_ID
                    FROM ES_WAREHOUSE.WORK_ORDERS.WORK_ORDERS
                    WHERE DESCRIPTION LIKE '%work order generated by data science%'
                  ) as wo_id using (asset_id)

      order by average_abnormal_probability desc
    ;;
    }




    dimension: asset_id {
      type:  string
      sql: ${TABLE}.asset_id;;
      #html: <a href="https://app.estrack.com/#/home/assets/all/asset/{{rendered_value}}" target="_blank"><button type="button">{{rendered_value}} — {{year_make_model._value}}</button></a>;;
      html: <p style ="color:#0000FF"><u><a href="https://app.estrack.com/#/home/assets/all/asset/{{rendered_value}}" target="_blank">{{rendered_value}} — {{year_make_model._value}}</a></u></p>;;
    }
    dimension: year_make_model {hidden: no}
    dimension: average_abnormal_probability {hidden: no}
    dimension: abnormal_probability_count {hidden: yes}
    dimension: lower_bound {hidden: yes}
    dimension: upper_bound {hidden: yes}
    dimension: all_probabilities {hidden: yes}
    dimension: grey_probabilities {hidden: yes}
    dimension: red_probabilities {hidden: yes}
    dimension: yellow_probabilities {hidden: yes}
    dimension: green_probabilities {hidden: yes}
    dimension: median_list {hidden: yes}
    dimension: ref_median_list {hidden: yes}
    dimension: open_work_orders {hidden:no}
    dimension: service_interval_name {hidden:no}
    dimension: Usage_Percentage_Remaining_Color {hidden: yes}
    dimension: usage_percentage_remaining  {hidden:no type:number}
    dimension: WORK_ORDER_ID {hidden: no}
    dimension: abnormal_probabilities_last_14_days{
      sql: ${TABLE}.asset_id;;
      # html: <img src="https://image-charts.com/chart?chs=200x50&cht=ls&chd=t:{{probabilities._value}}">;;
      # html: <img src="https://quickchart.io/chart?chs=200x50&cht=ls&chd=t:{{probabilities._value}}&chls=1">;;
      html: <a href="https://equipmentshare.looker.com/dashboards-next/284?Asset+ID={{rendered_value}}" target="_blank"><img height="30" width="200" src="https://quickchart.io/chart?chs=200x30&cht=bvs&chd=a:{{grey_probabilities._value}}|{{red_probabilities._value}}|{{yellow_probabilities._value}}|{{green_probabilities._value}}&chco=aaaaaa,aa2222,aaaa22,22aa22"></a>;;
      # html: <img src="https://quickchart.io/chart?bkg=white&c={type:%27sparkline%27,data:{datasets:[{data:[{{probabilities._value}}],fill:false}]}}">;;
    }
    dimension: engine_data_last_14_days{
      sql: ${TABLE}.asset_id;;
      #html: <img src="https://quickchart.io/chart?chs=400x50&cht=ls&chd=a:{{median_list._value}}|{{ref_median_list._value}}&chco=882222,22228877&chxt=y&chxr=0,{{lower_bound._value}},{{upper_bound._value}}">;;
      html: <a href="https://equipmentshare.looker.com/dashboards-next/284?Asset+ID={{rendered_value}}" target="_blank"><img height="50" width="400" src="https://quickchart.io/chart?w=400&h=50&c={type:%27line%27,options:{scales:{yAxes:[{ticks:{min:{{lower_bound._value}},max:{{upper_bound._value}},maxTicksLimit:2},gridLines:{display:false}}],xAxes:[{gridLines:{display:false}}]},plugins:{legend:false}},data:{labels:[%27%27,%27%27,%27%27,%27%27,%27%27,%27%27,%27%27,%27%27,%27%27,%27%27,%27%27,%27%27],datasets:[{data:[{{median_list._value}}],fill:false,backgroundColor:%27%2388222277%27,borderColor:%27%2388222277%27},{data:[{{ref_median_list._value}}],fill:false,backgroundColor:%27%2322228877%27,borderColor:%27%2322228877%27}]}}"></a>;;
    }

    dimension: service_percent_remaining {type: number sql: 1.0*(${usage_percentage_remaining});;

      html: <p style="text-align:left;color:{{Usage_Percentage_Remaining_Color}}">{{value}}% - {{service_interval_name}} ({{open_work_orders}} open work orders)
                <a href = "https://app.estrack.com/#/home/service/work-orders/{{WORK_ORDER_ID}}">{{WORK_ORDER_ID}}</a></p>
              <div style="float: left

                ; width:{{value}}%

                ; background-color: {{Usage_Percentage_Remaining_Color}}

                ; text-align:left

                ; color: #FFFFFF

                ; border-radius: 5px"> <p style="margin-bottom: 0; margin-left: 4px;">&nbsp;</p>

                </div>


            ;;

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
          value: "aod^_%^_110"
        }
        allowed_value: {
          label: "Oil Pressure"
          value: "aod^_%^_100"
        }
        allowed_value: {
          label: "Engine Oil Temperature"
          value: "aod^_%^_175"
        }
        suggestions: ["Engine Coolant"]
      }
}
