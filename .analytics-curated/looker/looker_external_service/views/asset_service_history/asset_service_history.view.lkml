view: asset_service_history {
  derived_table: {
    sql:
with owned_assets as (
    select
      DISTINCT oa.asset_id
    from
      table(assetlist({{ _user_attributes['user_id'] }}::numeric)) oa
      join assets a on a.asset_id = oa.asset_id
    where
    {% condition custom_name_filter %} a.custom_name {% endcondition %}
)
    select distinct
          a.asset_id,
          a.custom_name as asset,
          a.make,
          a.model,
          a.year,
          a.description as asset_description,
          p.filename as asset_photo,
          o.odometer,
          h.hours,
          coalesce(ccce.complaint,ccc.complaint,'N/A') as complaint,
          coalesce(ccce.cause,ccc.cause,'N/A') as cause,
          coalesce(ccce.correction,ccc.correction,'N/A') as correction,
          wo.work_order_id,
          CAST(wo.work_order_id as text) as work_order_id_display,
          concat(case when wo.work_order_type_id = 1 then 'WO-' else 'INSP-' end,wo.work_order_id) as work_order_with_type,
          cast(wo.date_created as date) as date_created,
          cast(wo.date_completed as date) as date_completed,
          coalesce(wo.description,' ') as wo_description,
          wo.solution,
          ot.name as originator_type
      from
      owned_assets oa
      join assets a on oa.asset_id = a.asset_id
      left join work_orders.work_orders wo on oa.asset_id = wo.asset_id AND wo.date_completed is not null AND wo.archived_date is null
      left join es_warehouse.work_orders.work_order_originators woo on woo.work_order_id = wo.work_order_id
      left join es_warehouse.work_orders.originator_types ot on ot.originator_type_id = woo.originator_type_id
      left join photos p on p.photo_id = a.photo_id
      left join (select asset_id, value as odometer from asset_status_key_values where name = 'odometer') o on o.asset_id = oa.asset_id
      left join (select asset_id, value as hours from asset_status_key_values where name = 'hours') h on h.asset_id = oa.asset_id
      left join work_orders_knowledge_base.complaint_cause_correction ccc on ccc.work_order_id = wo.work_order_id
      left join saasy.public.cccs cccs on cccs.work_order_id = wo.work_order_id
      left join saasy.public.ccc_entries ccce on ccce.ccc_id = cccs.ccc_id
      join es_warehouse.public.markets m on m.market_id = wo.branch_id
      join es_warehouse.public.markets ms on ms.market_id = a.service_branch_id
      where
      {% condition custom_name_filter %} a.custom_name {% endcondition %}
       AND {% condition originator_type_filter %} ot.name {% endcondition %}
UNION
    select distinct
          a.asset_id,
          a.custom_name as asset,
          a.make,
          a.model,
          a.year,
          a.description as asset_description,
          p.filename as asset_photo,
          o.odometer,
          h.hours,
          coalesce(ccce.complaint,ccc.complaint,'N/A') as complaint,
          coalesce(ccce.cause,ccc.cause,'N/A') as cause,
          coalesce(ccce.correction,ccc.correction,'N/A') as correction,
          COALESCE(sr.work_order_id, sr.service_record_id) as work_order_id,
          COALESCE(CAST(sr.work_order_id as text), 'N/A') as work_order_id_display,
          CASE WHEN sr.work_order_id IS NOT NULL THEN CONCAT('WO-', CAST(sr.work_order_id AS TEXT)) ELSE 'N/A' END as work_order_with_type,
          cast(sr.date_created as date) as date_created,
          cast(sr.date_completed as date) as date_completed,
          coalesce(sr.description,' ') as wo_description,
          wo.solution,
          ot.name as originator_type
      from
      owned_assets oa
      join assets a on oa.asset_id = a.asset_id
      join es_warehouse.public.service_records sr on sr.asset_id = oa.asset_id
      left join work_orders.work_orders wo on sr.asset_id = wo.asset_id AND wo.date_completed is not null AND wo.archived_date is null
      left join es_warehouse.work_orders.work_order_originators woo on woo.work_order_id = wo.work_order_id
      left join es_warehouse.work_orders.originator_types ot on ot.originator_type_id = woo.originator_type_id
      left join photos p on p.photo_id = a.photo_id
      left join (select asset_id, value as odometer from asset_status_key_values where name = 'odometer') o on o.asset_id = oa.asset_id
      left join (select asset_id, value as hours from asset_status_key_values where name = 'hours') h on h.asset_id = oa.asset_id
      left join work_orders_knowledge_base.complaint_cause_correction ccc on ccc.work_order_id = sr.work_order_id
      left join saasy.public.cccs cccs on cccs.work_order_id = sr.work_order_id
      left join saasy.public.ccc_entries ccce on ccce.ccc_id = cccs.ccc_id
      join es_warehouse.public.markets m on m.market_id = wo.branch_id
      join es_warehouse.public.markets ms on ms.market_id = a.service_branch_id
      where
      {% condition custom_name_filter %} a.custom_name {% endcondition %}
      AND {% condition originator_type_filter %} ot.name {% endcondition %}
      AND sr.date_completed is not null
      AND sr.service_provider NOT LIKE 'SYSTEM GENERATED%'
       ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: work_order_id {
    type: number
    sql: ${TABLE}."WORK_ORDER_ID" ;;
  }

  dimension: work_order_id_display {
    type: string
    sql:${TABLE}."WORK_ORDER_ID_DISPLAY";;
  }

  dimension: work_order_with_type {
    type: string
    sql: ${TABLE}."WORK_ORDER_WITH_TYPE" ;;
  }

  dimension_group: date_created {
    type: time
    sql: ${TABLE}."DATE_CREATED" ;;
  }

  dimension_group: date_completed {
    type: time
    sql: ${TABLE}."DATE_COMPLETED" ;;
  }

  dimension: wo_description {
    type: string
    sql: ${TABLE}."WO_DESCRIPTION" ;;
  }

  dimension: solution {
    type: string
    sql: ${TABLE}."SOLUTION" ;;
  }

  dimension: originator_type {
    type: string
    sql: ${TABLE}."ORIGINATOR_TYPE" ;;
  }

  dimension: asset_id {
    type: string
    sql: ${TABLE}."ASSET_ID" ;;
  }

  dimension: asset {
    type: string
    sql: ${TABLE}."ASSET" ;;
  }

  dimension: make {
    type: string
    sql: ${TABLE}."MAKE" ;;
  }

  dimension: asset_model {
    type: string
    sql: ${TABLE}."MODEL" ;;
  }

  dimension: year {
    type: number
    sql: ${TABLE}."YEAR" ;;
  }

  dimension: asset_description {
    type: string
    sql: ${TABLE}."ASSET_DESCRIPTION" ;;
  }

  dimension: asset_photo {
    type: string
    sql: ${TABLE}."ASSET_PHOTO" ;;
  }

  dimension: odometer {
    type: string
    sql: ${TABLE}."ODOMETER" ;;
    html: {{rendered_value}} mi. ;;
  }

  dimension: hours {
    type: string
    sql: ${TABLE}."HOURS" ;;
    value_format_name: decimal_2
  }

  dimension: complaint {
    type: string
    sql: ${TABLE}."COMPLAINT" ;;
  }

  dimension: cause {
    type: string
    sql: ${TABLE}."CAUSE" ;;
  }

  dimension: correction {
    type: string
    sql: ${TABLE}."CORRECTION" ;;
  }

  # dimension: wo_picture_url_one {
  #   type: string
  #   sql: ${TABLE}."WO_PICTURE_URL_ONE" ;;
  # }

  # dimension: wo_picture_url_two {
  #   type: string
  #   sql: ${TABLE}."WO_PICTURE_URL_TWO" ;;
  # }

  # dimension: wo_picture_url_three {
  #   type: string
  #   sql: ${TABLE}."WO_PICTURE_URL_THREE" ;;
  # }

  # dimension: wo_picture_url_four {
  #   type: string
  #   sql: ${TABLE}."WO_PICTURE_URL_FOUR" ;;
  # }

  # dimension: wo_picture_url_five {
  #   type: string
  #   sql: ${TABLE}."WO_PICTURE_URL_FIVE" ;;
  # }

  filter: asset_id_filter {
    # suggest_explore: all_asset_ids
    # suggest_dimension: all_asset_ids.asset_id
  }

  filter: originator_type_filter {
    # suggest_explore: all_asset_ids
    # suggest_dimension: all_asset_ids.asset_id
  }

  filter: custom_name_filter {
    suggest_explore: owned_asset_list
    suggest_dimension: owned_asset_list.asset
  }

  dimension: asset_info {
    group_label: "Asset Information"
    label: " "
    type: string
    sql: coalesce(${asset},0) ;;
    # required_fields: [asset_model]
    html:
    <table>
    <tr>
      <td><h3>Asset:</h3></td>
      <td><h3> {{asset._rendered_value}}</h3></td>
    </tr>
    <tr>
      <td><h3>Make:</h3></td>
      <td><h3> {{make._rendered_value}}</h3></td>
    </tr>
    <tr>
      <td><h3>Model:</h3></td>
      <td><h3> {{asset_model._rendered_value}}</h3></td>
    </tr>
    <tr>
      <td><b><h3>Year:</h3></b></td>
      <td><h3> {{year._rendered_value}}</h3></td>
    </tr>
    </table>
      ;;
  }

  dimension: asset_details {
    group_label: "Asset Details"
    label: " "
    type: string
    sql: coalesce(${year},0) ;;
    html:
    <table>
    <tr>
      <td width="15%"><h3>Description:</h3></td>
      <td><h3> {{asset_description._rendered_value}}</h3></td>
    </tr>
    <tr>
      <td><b><h3>Odometer:</h3></b></td>
      <td><h3> {{odometer._rendered_value}} mi.</h3></td>
    </tr>
    <tr>
      <td><b><h3>Hours:</h3></b> </td>
      <td><h3> {{hours._rendered_value}}</h3></td>
    </tr>
    <tr>
      <td></td>
      <td></td>
    </tr>
    </table>
      ;;
  }

  dimension: link_to_asset_photo {
    type: string
    sql: concat('https://appcdn.equipmentshare.com/uploads/',${asset_photo}) ;;
    html: <img src="https://appcdn.equipmentshare.com/uploads/{{asset_photo._value}}" height="250" width="250"> ;;
  }

  dimension: date_created_formatted {
    group_label: "HTML Format" label: "WO Created Date"
    sql: coalesce(${date_created_raw},current_timestamp()) ;;
    html: {{ rendered_value | date: "%b %d, %Y" }};;
  }

  dimension: date_completed_formatted {
    group_label: "HTML Format" label: "WO Completion Date"
    sql: coalesce(${date_completed_raw},current_timestamp()) ;;
    html: {{rendered_value | date: "%b %d, %Y" }};;
  }

  # dimension: wo_pic_one {
  #   group_label: "WO Pic 1"
  #   label: "Top 5 Most Recent Work Order Pictures"
  #   type: string
  #   sql: ${wo_picture_url_one} ;;
  #   html:
  #   <img src="{{value}}" width="150" height="150"/>;;
  # }

  # dimension: wo_pic_two {
  #   group_label: "WO Pic 2"
  #   label: " "
  #   type: string
  #   sql: ${wo_picture_url_two} ;;
  #   html:
  #   <img src="{{value}}" width="150" height="150"/> ;;
  # }

  # dimension: wo_pic_three {
  #   group_label: "WO Pic 3"
  #   label: " "
  #   type: string
  #   sql: ${wo_picture_url_three} ;;
  #   html:
  #   <img src="{{value}}" width="150" height="150"/> ;;
  # }

  # dimension: wo_pic_four {
  #   group_label: "WO Pic 4"
  #   label: " "
  #   type: string
  #   sql: ${wo_picture_url_four} ;;
  #   html:
  #   <img src="{{value}}" width="150" height="150"/> ;;
  # }

  # dimension: wo_pic_five {
  #   group_label: "WO Pic 5"
  #   label: " "
  #   type: string
  #   sql: ${wo_picture_url_five} ;;
  #   html:
  #   <img src="{{value}}" width="150" height="150"/> ;;
  # }

  dimension: wo_notes {
    group_label: "Work Order Notes"
    label: "Work Order Information"
    type: string
    sql: coalesce(${work_order_id},0) ;;
    required_fields: [wo_description,cause,complaint,correction,date_created_formatted,date_completed_formatted,work_order_id,work_order_id_display]
    html:
    {% if work_order_id._value == 0 %}
    <table>
    <tr>
      <th><h3><b>{{ work_order_id_display._rendered_value }}</b></h3></th>
    </tr>
    </table>
    <table>
    <tr>
      <td width="100px"><b>Date Created:</b></td>
      <td width="125px">{{date_created_formatted._rendered_value| date: "%b %d, %Y" }}</td>
    </tr>
    <tr>
      <td width="100px"><b>Date Completed:</b></td>
      <td width="125px">{{date_completed_formatted._rendered_value | date: "%b %d, %Y" }}</td>
    </tr>
    <tr>
      <td width="100px"><b>Description:</b></td>
      <td width="125px">{{wo_description._rendered_value}}</td>
    </tr>
    <tr>
      <td width="100px"><b>Complaint:</b></td>
      <td width="125px">{{complaint._value}}</td>
    </tr>
    <tr>
      <td width="100px"><b>Cause:</b></td>
      <td width="125px">{{cause._value}}</td>
    </tr>
    <tr>
      <td width="100px"><b>Correction:</b></td>
      <td width="125px">{{correction._value}}</td>
    </tr>
    <tr>
      <td></td>
      <td></td>
    </tr>
    </table>
    {% else %}
    <table>
    <tr>
      <th><h3><b>{{ work_order_id_display._rendered_value }}</b></h3></th>
    </tr>
    </table>
    <table>
    <tr>
      <td width="100px"><b>Date Created:</b></td>
      <td width="125px">{{date_created_formatted._rendered_value| date: "%b %d, %Y" }}</td>
    </tr>
    <tr>
      <td width="100px"><b>Date Completed:</b></td>
      <td width="125px">{{date_completed_formatted._rendered_value | date: "%b %d, %Y" }}</td>
    </tr>
    <tr>
      <td width="100px"><b>Description:</b></td>
      <td width="125px">{{wo_description._rendered_value}}</td>
    </tr>
    <tr>
      <td width="100px"><b>Complaint:</b></td>
      <td width="125px">{{complaint._value}}</td>
    </tr>
    <tr>
      <td width="100px"><b>Cause:</b></td>
      <td width="125px">{{cause._value}}</td>
    </tr>
    <tr>
      <td width="100px"><b>Correction:</b></td>
      <td width="125px">{{correction._value}}</td>
    </tr>
    <tr>
      <td width="100px"><b>Originator Type:</b></td>
      <td width="125px">{{originator_type._value}}</td>
    </tr>
    <tr>
      <td></td>
      <td></td>
    </tr>
    </table>
    {% endif %}
      ;;
  }

  set: detail {
    fields: [
      work_order_id,
      work_order_id_display,
      date_created_time,
      date_completed_time,
      wo_description,
      solution,
      asset,
      make,
      asset_model,
      year,
      asset_description,
      asset_photo,
      odometer,
      hours
    ]
  }
}
