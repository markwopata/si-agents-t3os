view: asset_geo_fence_miles_driven_detail {
    derived_table: {
      sql: with owned_assets as (
          select asset_id
          from table(assetlist({{ _user_attributes['user_id'] }}::numeric))
          )
          , rented_assets as (
          select rl.asset_id, start_date::date as start_date, end_date::date as end_date
          from table(rental_asset_list({{ _user_attributes['user_id'] }}::numeric,
          convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC',{% date_start asset_geofence_time_utilization.date_filter %}),
          convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC',{% date_end asset_geofence_time_utilization.date_filter %}),
          ('{{ _user_attributes['user_timezone'] }}'))) rl
          join assets a on a.asset_id = rl.asset_id
          where
          a.company_id <> {{ _user_attributes['company_id'] }}
         )
        , geo_duration as (
        select
          distinct
          ge.asset_id,
          g.geofence_id,
          ge.encounter_start_timestamp as entry,
          convert_timezone('{{ _user_attributes['user_timezone'] }}',ge.encounter_end_timestamp) as exit,

           case
              when ge.start_odometer <= IFNULL(ge.end_odometer,ge.start_odometer) then ge.start_odometer
              when ge.start_odometer > IFNULL(ge.end_odometer,ge.start_odometer) then ge.end_odometer
              end as start_odometer,
          case
              when IFNULL(ge.end_odometer,ge.start_odometer) >= ge.start_odometer then IFNULL(ge.end_odometer,ge.start_odometer)
              when IFNULL(ge.end_odometer,ge.start_odometer) < ge.start_odometer then ge.start_odometer
              end as end_odometer,

          case when ge.encounter_start_timestamp  < convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC',{% date_start asset_geofence_time_utilization.date_filter %}) and (ge.encounter_end_timestamp is null or convert_timezone('{{ _user_attributes['user_timezone'] }}',ge.encounter_end_timestamp) > convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC',{% date_end asset_geofence_time_utilization.date_filter %})) then TIMESTAMPDIFF(seconds,{% date_start asset_geofence_time_utilization.date_filter %}, {% date_end asset_geofence_time_utilization.date_filter %})
               when ge.encounter_start_timestamp  < convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC',{% date_start asset_geofence_time_utilization.date_filter %}) and convert_timezone('{{ _user_attributes['user_timezone'] }}',ge.encounter_end_timestamp) between convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC',{% date_start asset_geofence_time_utilization.date_filter %}) and convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC',{% date_end asset_geofence_time_utilization.date_filter %}) then TIMESTAMPDIFF(seconds, {% date_start asset_geofence_time_utilization.date_filter %}, ge.encounter_end_timestamp)
               when ge.encounter_start_timestamp >= convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC',{% date_start asset_geofence_time_utilization.date_filter %}) and convert_timezone('{{ _user_attributes['user_timezone'] }}',ge.encounter_end_timestamp) <=  convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC',{% date_end asset_geofence_time_utilization.date_filter %}) then TIMESTAMPDIFF(seconds, ge.encounter_start_timestamp, ge.encounter_end_timestamp)
               when ge.encounter_start_timestamp between convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC',{% date_start asset_geofence_time_utilization.date_filter %}) and convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC',{% date_end asset_geofence_time_utilization.date_filter %}) then
                  case when ge.encounter_end_timestamp is null then TIMESTAMPDIFF(seconds, ge.encounter_start_timestamp, {% date_end asset_geofence_time_utilization.date_filter %})
                     when convert_timezone('{{ _user_attributes['user_timezone'] }}',ge.encounter_end_timestamp) >  {% date_end asset_geofence_time_utilization.date_filter %} then TIMESTAMPDIFF(seconds, ge.encounter_start_timestamp, {% date_end asset_geofence_time_utilization.date_filter %})
                   end
                   else TIMESTAMPDIFF(seconds, ge.encounter_start_timestamp, ge.encounter_end_timestamp)
              end as geo_seconds
        from
          owned_assets o
          left join asset_geofence_encounters ge on o.asset_id = ge.asset_id
          join geofences g on ge.geofence_id = g.geofence_id
          --asset_geofence_encounters ge
          --join geofences g on ge.geofence_id = g.geofence_id
          --join owned_rented_assets o on o.asset_id = ge.asset_id
        where
          g.company_id = {{ _user_attributes['company_id'] }}::numeric
          and  overlaps(
              ge.encounter_start_timestamp,
              coalesce(ge.encounter_end_timestamp, current_timestamp),
              convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC',{% date_start asset_geofence_time_utilization.date_filter %}),
              convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC',{% date_end asset_geofence_time_utilization.date_filter %})
              )
        union
        select
          distinct
          ge.asset_id,
          g.geofence_id,
          ge.encounter_start_timestamp as entry,
          convert_timezone('{{ _user_attributes['user_timezone'] }}',ge.encounter_end_timestamp) as exit,

          case
              when ge.start_odometer <= IFNULL(ge.end_odometer,ge.start_odometer) then ge.start_odometer
              when ge.start_odometer > IFNULL(ge.end_odometer,ge.start_odometer) then ge.end_odometer
              end as start_odometer,
          case
              when IFNULL(ge.end_odometer,ge.start_odometer) >= ge.start_odometer then IFNULL(ge.end_odometer,ge.start_odometer)
              when IFNULL(ge.end_odometer,ge.start_odometer) < ge.start_odometer then ge.start_odometer
              end as end_odometer,

          case when ge.encounter_start_timestamp  < convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC',{% date_start asset_geofence_time_utilization.date_filter %}) and (ge.encounter_end_timestamp is null or convert_timezone('{{ _user_attributes['user_timezone'] }}',ge.encounter_end_timestamp) > convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC',{% date_end asset_geofence_time_utilization.date_filter %})) then TIMESTAMPDIFF(seconds,{% date_start asset_geofence_time_utilization.date_filter %}, {% date_end asset_geofence_time_utilization.date_filter %})
               when ge.encounter_start_timestamp  < convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC',{% date_start asset_geofence_time_utilization.date_filter %}) and convert_timezone('{{ _user_attributes['user_timezone'] }}',ge.encounter_end_timestamp) between convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC',{% date_start asset_geofence_time_utilization.date_filter %}) and convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC',{% date_end asset_geofence_time_utilization.date_filter %}) then TIMESTAMPDIFF(seconds, {% date_start asset_geofence_time_utilization.date_filter %}, ge.encounter_end_timestamp)
               when ge.encounter_start_timestamp >= convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC',{% date_start asset_geofence_time_utilization.date_filter %}) and convert_timezone('{{ _user_attributes['user_timezone'] }}',ge.encounter_end_timestamp) <=  convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC',{% date_end asset_geofence_time_utilization.date_filter %}) then TIMESTAMPDIFF(seconds, ge.encounter_start_timestamp, ge.encounter_end_timestamp)
               when ge.encounter_start_timestamp between convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC',{% date_start asset_geofence_time_utilization.date_filter %}) and convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC',{% date_end asset_geofence_time_utilization.date_filter %}) then
                  case when ge.encounter_end_timestamp is null then TIMESTAMPDIFF(seconds, ge.encounter_start_timestamp, {% date_end asset_geofence_time_utilization.date_filter %})
                     when convert_timezone('{{ _user_attributes['user_timezone'] }}',ge.encounter_end_timestamp) >  {% date_end asset_geofence_time_utilization.date_filter %} then TIMESTAMPDIFF(seconds, ge.encounter_start_timestamp, {% date_end asset_geofence_time_utilization.date_filter %})
                   end
                   else TIMESTAMPDIFF(seconds, ge.encounter_start_timestamp, ge.encounter_end_timestamp)
              end as geo_seconds
        from
          rented_assets o
          left join asset_geofence_encounters ge on o.asset_id = ge.asset_id
          AND ge.encounter_end_timestamp
          between convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC',{% date_start asset_geofence_time_utilization.date_filter %})
          AND coalesce(convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC',{% date_end asset_geofence_time_utilization.date_filter %}),current_timestamp)

          join geofences g on ge.geofence_id = g.geofence_id
          --asset_geofence_encounters ge
          --join geofences g on ge.geofence_id = g.geofence_id
          --join owned_rented_assets o on o.asset_id = ge.asset_id
        where
          g.company_id = {{ _user_attributes['company_id'] }}::numeric
          and  overlaps(
              ge.encounter_start_timestamp,
              coalesce(ge.encounter_end_timestamp, current_timestamp),
              convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC',{% date_start asset_geofence_time_utilization.date_filter %}),
              convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC',{% date_end asset_geofence_time_utilization.date_filter %})
              )
        )
        select
        gd.asset_id,
        gd.geofence_id,
        gd.entry as geofence_entry,
        gd.exit as geofence_exit,
        gd.start_odometer,
        gd.end_odometer,
        gd.end_odometer - gd.start_odometer as miles_driven_detail
        from geo_duration gd ;;
    }

    measure: count {
      type: count
      drill_fields: [detail*]
    }

    dimension: asset_id {
      type: number
      sql: ${TABLE}."ASSET_ID" ;;
    }

    dimension: geofence_id {
      type: number
      sql: ${TABLE}."GEOFENCE_ID" ;;
    }

    dimension_group: geofence_entry {
      type: time
      sql: ${TABLE}."GEOFENCE_ENTRY" ;;
      html: {{ rendered_value | date: "%b %d, %Y %r  "  }} {{ _user_attributes['user_timezone_label'] }};;
    }

    dimension_group: geofence_exit {
      type: time
      sql: ${TABLE}."GEOFENCE_EXIT" ;;
      html: {{ rendered_value | date: "%b %d, %Y %r  "  }} {{ _user_attributes['user_timezone_label'] }};;
    }

    dimension: start_odometer {
      type: number
      sql: ${TABLE}."START_ODOMETER" ;;
      value_format_name: decimal_2
      html: {{rendered_value}} miles ;;
    }

    dimension: end_odometer {
      type: number
      sql: ${TABLE}."END_ODOMETER" ;;
      value_format_name: decimal_2
      html: {{rendered_value}} miles ;;
    }

    dimension: miles_driven_detail {
      type: number
      sql: ${TABLE}."MILES_DRIVEN_DETAIL" ;;
      value_format_name: decimal_2
      html: {{rendered_value}} miles ;;
    }

    set: detail {
      fields: [
        asset_id,
        geofence_id,
        start_odometer,
        end_odometer,
        miles_driven_detail
      ]
    }
  }
