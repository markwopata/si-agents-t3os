view: impact_location_report {
  derived_table: {
    sql: with own_asset_list as (
      select
          alo.asset_id,
          'Owned' as ownership,
          a.custom_name as asset,
          org.group_name,
          a.asset_class,
          cat.name as category,
          m.name as branch,
          a.make,
          a.model,
          concat(upper(substring(ast.name,1,1)),substring(ast.name,2,length(ast.name))) as asset_type
      from
          table(assetlist({{ _user_attributes['user_id'] }}::numeric)) alo
          --from table(assetlist(11408::numeric))
          join assets a on alo.asset_id = a.asset_id
          left join asset_types ast on ast.asset_type_id = a.asset_type_id
          left join (select oax.asset_id, listagg(o.name,', ') as group_name from organization_asset_xref oax join organizations o on oax.organization_id = o.organization_id where {% condition groups_filter %} o.name {% endcondition %} group by oax.asset_id) org on org.asset_id = alo.asset_id
          left join categories cat on cat.category_id = a.category_id
          left join markets m on m.market_id = a.inventory_branch_id
        where
          {% condition custom_name_filter %} a.custom_name {% endcondition %}
          AND {% condition asset_class_filter %} a.asset_class {% endcondition %}
          AND {% condition groups_filter %} org.group_name {% endcondition %}
          AND {% condition ownership_filter %} ('Owned') {% endcondition %}
          AND {% condition category_filter %} cat.name {% endcondition %}
          AND {% condition branch_filter %} m.name {% endcondition %}
          AND {% condition asset_type_filter %} ast.name {% endcondition %}
      )
      , rental_asset_list as (
      select
          alr.asset_id,
          alr.start_date,
          alr.end_date,
          'Rented' as ownership,
          a.custom_name as asset,
          org.group_name,
          a.asset_class,
          cat.name as category,
          m.name as branch,
          a.make,
          a.model,
          concat(upper(substring(ast.name,1,1)),substring(ast.name,2,length(ast.name))) as asset_type
      from
          table(rental_asset_list({{ _user_attributes['user_id'] }}::numeric,
          convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC',{% date_start date_filter %}),
          convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC',{% date_end date_filter %}),
          '{{ _user_attributes['user_timezone'] }}')) alr
          join assets a on alr.asset_id = a.asset_id
          left join asset_types ast on ast.asset_type_id = a.asset_type_id
          left join (select oax.asset_id, listagg(o.name,', ') as group_name from organization_asset_xref oax join organizations o on oax.organization_id = o.organization_id where {% condition groups_filter %} o.name {% endcondition %} group by oax.asset_id) org on org.asset_id = alr.asset_id
          left join categories cat on cat.category_id = a.category_id
          left join markets m on m.market_id = a.inventory_branch_id
      )
      select
          ti.tracking_incident_id,
          al.asset_id,
          al.asset,
          al.group_name,
          al.asset_class,
          al.category,
          al.branch,
          al.make,
          al.model,
          al.asset_type,
          al.ownership,
          convert_timezone('{{ _user_attributes['user_timezone'] }}',ti.report_timestamp) as report_timestamp,
          --convert_timezone('America/Chicago',ti.report_timestamp) as report_timestamp,
          t.trip_id,
          te.location_lon as impact_event_location_lon,
          te.location_lat as impact_event_location_lat,
          concat(start_street,', ',start_city,', ', s.abbreviation) as trip_start_address,
          concat(end_street,', ',end_city,', ', s2.abbreviation) as trip_end_address
      from
          own_asset_list al
          join tracking_incidents ti on al.asset_id = ti.asset_id and tracking_incident_type_id = 16
          join tracking_events te on te.tracking_event_id = ti.tracking_event_id
          join trips t on t.trip_id = ti.trip_id
          join states s on s.state_id = t.start_state_id
          join states s2 on s2.state_id = t.end_state_id
      where
          ti.report_timestamp BETWEEN convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC',{% date_start date_filter %}) and convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC',{% date_end date_filter %})
      union
      select
          ti.tracking_incident_id,
          al.asset_id,
          al.asset,
          al.group_name,
          al.asset_class,
          al.category,
          al.branch,
          al.make,
          al.model,
          al.asset_type,
          al.ownership,
          convert_timezone('{{ _user_attributes['user_timezone'] }}',ti.report_timestamp) as report_timestamp,
          --convert_timezone('America/Chicago',ti.report_timestamp) as report_timestamp,
          t.trip_id,
          te.location_lon as impact_event_location_lon,
          te.location_lat as impact_event_location_lat,
          concat(start_street,', ',start_city,', ', s.abbreviation) as trip_start_address,
          concat(end_street,', ',end_city,', ', s2.abbreviation) as trip_end_address
      from
          rental_asset_list al
          join tracking_incidents ti on al.asset_id = ti.asset_id and tracking_incident_type_id = 16 and ti.report_timestamp >= al.start_date and ti.report_timestamp <= al.end_date
          join tracking_events te on te.tracking_event_id = ti.tracking_event_id
          join trips t on t.trip_id = ti.trip_id
          join states s on s.state_id = t.start_state_id
          join states s2 on s2.state_id = t.end_state_id
      where
          ti.report_timestamp BETWEEN convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC',{% date_start date_filter %}) and convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC',{% date_end date_filter %})
 ;;
  }

  measure: count {
    label: "Total Impact Events"
    type: count
    html: {{rendered_value}}
    <p>Asset
    <br />{{ asset._rendered_value}}
    </p>
    <p>Report Timestamp
    <br />{{ report_timestamp_formatted._rendered_value}}
    </p>
    <p>Trip Start Address
    <br />{{trip_start_address._rendered_value}}
    </p>
    <p>Trip End Address
    <br />{{trip_end_address._rendered_value}}
    </p>
    ;;
  }

  dimension: tracking_incident_id {
    type: number
    sql: ${TABLE}."TRACKING_INCIDENT_ID" ;;
  }

  dimension: asset_id {
    type: number
    sql: ${TABLE}."ASSET_ID" ;;
  }

  dimension: asset {
    type: string
    sql: ${TABLE}."ASSET" ;;
  }

  dimension: group_name {
    type: string
    sql: ${TABLE}."GROUP_NAME" ;;
  }

  dimension: asset_class {
    type: string
    sql: ${TABLE}."ASSET_CLASS" ;;
  }

  dimension: category {
    type: string
    sql: ${TABLE}."CATEGORY" ;;
  }

  dimension: branch {
    type: string
    sql: ${TABLE}."BRANCH" ;;
  }

  dimension: make {
    type: string
    sql: ${TABLE}."MAKE" ;;
  }

  dimension: model {
    type: string
    sql: ${TABLE}."MODEL" ;;
  }

  dimension: asset_type {
    type: string
    sql: ${TABLE}."ASSET_TYPE" ;;
  }

  dimension: ownership {
    type: string
    sql: ${TABLE}."OWNERSHIP" ;;
  }

  dimension_group: report_timestamp {
    type: time
    sql: ${TABLE}."REPORT_TIMESTAMP" ;;
  }

  dimension: trip_id {
    type: number
    sql: ${TABLE}."TRIP_ID" ;;
  }

  dimension: impact_event_location_lon {
    type: number
    sql: ${TABLE}."IMPACT_EVENT_LOCATION_LON" ;;
  }

  dimension: impact_event_location_lat {
    type: number
    sql: ${TABLE}."IMPACT_EVENT_LOCATION_LAT" ;;
  }

  dimension: trip_start_address {
    type: string
    sql: ${TABLE}."TRIP_START_ADDRESS" ;;
  }

  dimension: trip_end_address {
    type: string
    sql: ${TABLE}."TRIP_END_ADDRESS" ;;
  }

  filter: date_filter {
    type: date_time
  }

  dimension: mapping_impact_event {
    label: "Impact Event Location"
    type: location
    sql_latitude:${impact_event_location_lat} ;;
    sql_longitude:${impact_event_location_lon} ;;
  }

  dimension: report_timestamp_formatted {
    group_label: "HTML Passed Date Format" label: "Report Timestamp"
    type: date_time
    sql: ${report_timestamp_raw} ;;
    html: {{ rendered_value | date: "%b %d, %Y %r" }} {{ _user_attributes['user_timezone_label'] }};;
  }

  dimension: asset_impact_id_cross_filter {
    label: "Asset Impact Event ID"
    group_label: "Cross Filter Impact ID"
    type: number
    sql: ${tracking_incident_id} ;;
    html: Click here! ;;
    description: "Click a row below to view a certain idle event on the map"
  }

  filter: custom_name_filter {
    suggest_explore: impact_location_report
    suggest_dimension: impact_location_report.asset
  }

  filter: groups_filter {
    suggest_explore: impact_location_report
    suggest_dimension: impact_location_report.group_name
  }

  filter: ownership_filter {
    suggest_explore: impact_location_report
    suggest_dimension: impact_location_report.ownership
  }

  filter: asset_class_filter {
    suggest_explore: impact_location_report
    suggest_dimension: impact_location_report.asset_class
  }

  filter: branch_filter {
    suggest_explore: impact_location_report
    suggest_dimension: impact_location_report.branch
  }

  filter: category_filter {
    suggest_explore: impact_location_report
    suggest_dimension: impact_location_report.category
  }

  filter: asset_type_filter {
    suggest_explore: impact_location_report
    suggest_dimension: impact_location_report.asset_type
  }

  set: detail {
    fields: [
      tracking_incident_id,
      asset_id,
      report_timestamp_time,
      trip_id,
      impact_event_location_lon,
      impact_event_location_lat,
      trip_start_address,
      trip_end_address
    ]
  }
}
