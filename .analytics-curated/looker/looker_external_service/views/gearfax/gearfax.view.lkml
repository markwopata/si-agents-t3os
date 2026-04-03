view: gearfax {
  derived_table: {
    sql:
    select
          concat(case when wo.work_order_type_name = 'General' then 'WO-' else 'INSP-' end,wo.work_order_id) as work_order_id,
          wo.date_created,
          wo.date_completed,
          coalesce(wo.description,' ') as wo_description,
          wo.solution,
          a.asset_id,
          a.custom_name as asset,
          a.make,
          a.model,
          a.year,
          a.description as asset_description,
          p.filename as asset_photo,
          o.odometer,
          h.hours,
          case when len(complaint) = 0 then 'N/A' else coalesce(ccc.complaint,'N/A') end as complaint,
          case when len(cause) = 0 then 'N/A' else coalesce(ccc.cause,'N/A') end as cause,
          case when len(correction) = 0 then 'N/A' else coalesce(ccc.correction,'N/A') end as correction,
          wp.wo_picture_url_one,
          wp.wo_picture_url_two,
          wp.wo_picture_url_three,
          wp.wo_picture_url_four,
          wp.wo_picture_url_five
      from
          assets a
          left join work_orders.work_orders wo on a.asset_id = wo.asset_id AND wo.date_completed is not null AND wo.archived_date is null
          left join photos p on p.photo_id = a.photo_id
          left join (select asset_id, value as odometer from asset_status_key_values where name = 'odometer') o on o.asset_id = a.asset_id
          left join (select asset_id, value as hours from asset_status_key_values where name = 'hours') h on h.asset_id = a.asset_id
          left join work_orders_knowledge_base.complaint_cause_correction ccc on ccc.work_order_id = wo.work_order_id
          left join
          (
          with wo_pic_ranking as (
          select
              wof.work_order_id,
              ROW_NUMBER() OVER(partition by wof.work_order_id ORDER BY wof.date_created desc) wo_picture_ranking,
              case
                  when substr(url, 0, 16) = 'work_order_files' then concat('https://appcdn.equipmentshare.com/uploads/',url)
                  else url
                  end as wo_picture_url
          from
             work_orders.work_order_files wof
          where
            date_deleted is null
          --  and wof.work_order_id = 570565
           )
           , rank_one as (
           select
                work_order_id,
                wo_picture_url as wo_picture_url_one
           from
                wo_pic_ranking
           where
               wo_picture_ranking = 1
           )
           , rank_two as (
           select
                work_order_id,
                wo_picture_url as wo_picture_url_two
           from
                wo_pic_ranking
           where
                wo_picture_ranking = 2
           )
          , rank_three as (
           select
                work_order_id,
                wo_picture_url as wo_picture_url_three
           from
                wo_pic_ranking
           where
                wo_picture_ranking = 3
           )
          , rank_four as (
           select
                work_order_id,
                wo_picture_url as wo_picture_url_four
           from
                wo_pic_ranking
           where
                wo_picture_ranking = 4
           )
          , rank_five as (
           select
                work_order_id,
                wo_picture_url as wo_picture_url_five
           from
                wo_pic_ranking
           where
                wo_picture_ranking = 5
           )
           select
                ro.work_order_id,
                ro.wo_picture_url_one,
                rt.wo_picture_url_two,
                rth.wo_picture_url_three,
                rf.wo_picture_url_four,
                rfive.wo_picture_url_five
          from
                rank_one ro
                left join rank_two rt on ro.work_order_id = rt.work_order_id
                left join rank_three rth on ro.work_order_id = rth.work_order_id
                left join rank_four rf on ro.work_order_id = rf.work_order_id
                left join rank_five rfive on ro.work_order_id = rfive.work_order_id
          ) wp on wp.work_order_id = wo.work_order_id
      where
          {% condition asset_id_filter %} a.asset_id {% endcondition %}
       ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: work_order_id {
    type: string
    sql: ${TABLE}."WORK_ORDER_ID" ;;
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

  dimension: wo_picture_url_one {
    type: string
    sql: ${TABLE}."WO_PICTURE_URL_ONE" ;;
  }

  dimension: wo_picture_url_two {
    type: string
    sql: ${TABLE}."WO_PICTURE_URL_TWO" ;;
  }

  dimension: wo_picture_url_three {
    type: string
    sql: ${TABLE}."WO_PICTURE_URL_THREE" ;;
  }

  dimension: wo_picture_url_four {
    type: string
    sql: ${TABLE}."WO_PICTURE_URL_FOUR" ;;
  }

  dimension: wo_picture_url_five {
    type: string
    sql: ${TABLE}."WO_PICTURE_URL_FIVE" ;;
  }

  filter: asset_id_filter {
    suggest_explore: selection_of_all_assets
    suggest_dimension: selection_of_all_assets.asset_id_string
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
    sql: coalesce(${date_created_raw},current_timestamp) ;;
    html: {{ rendered_value | date: "%b %d, %Y" }};;
  }

  dimension: date_completed_formatted {
    group_label: "HTML Format" label: "WO Completion Date"
    sql: coalesce(${date_completed_raw},current_timestamp) ;;
    html: {{rendered_value | date: "%b %d, %Y" }};;
  }

  dimension: wo_pic_one {
    group_label: "WO Pic 1"
    label: "Top 5 Most Recent Work Order Pictures"
    type: string
    sql: ${wo_picture_url_one} ;;
    html:
    <img src="{{value}}" width="150" height="150"/>;;
  }

  dimension: wo_pic_two {
    group_label: "WO Pic 2"
    label: " "
    type: string
    sql: ${wo_picture_url_two} ;;
    html:
    <img src="{{value}}" width="150" height="150"/> ;;
  }

  dimension: wo_pic_three {
    group_label: "WO Pic 3"
    label: " "
    type: string
    sql: ${wo_picture_url_three} ;;
    html:
    <img src="{{value}}" width="150" height="150"/> ;;
  }

  dimension: wo_pic_four {
    group_label: "WO Pic 4"
    label: " "
    type: string
    sql: ${wo_picture_url_four} ;;
    html:
    <img src="{{value}}" width="150" height="150"/> ;;
  }

  dimension: wo_pic_five {
    group_label: "WO Pic 5"
    label: " "
    type: string
    sql: ${wo_picture_url_five} ;;
    html:
    <img src="{{value}}" width="150" height="150"/> ;;
  }

  dimension: wo_notes {
    group_label: "Work Order Notes"
    label: "Work Order Information"
    type: string
    sql: ${year} ;;
    required_fields: [wo_description,cause,complaint,correction,date_created_formatted,date_completed_formatted,work_order_id]
    html:
    <table>
    <tr>
      <th><h3><b>{{ work_order_id._rendered_value }}</b></h3></th>
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
          ;;
  }

  set: detail {
    fields: [
      work_order_id,
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
