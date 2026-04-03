view: asset_transfer_approval_log {
  derived_table: {
    sql:
     with employee_match as (
    select
      ato.transfer_order_id,
      ato.date_created,
      ato.to_branch_id,
      ato.from_branch_id,
      ato.requester_id,
      m1.market_id requester_market_id,
      e1.employee_title requester_title,
      ato.approver_id,
      m2.market_id approver_market_id,
      e2.employee_title approver_title,
      concat(e1.first_name, ' ', e1.last_name) requester_name,
      concat(e2.first_name, ' ', e2.last_name) approver_name,
      split_part(e1.location, ' ', 2) mgr_requester_region,
      split_part(e2.location, ' ', 2) mgr_approver_region
      from asset_transfer.public.transfer_orders ato
      left join business_intelligence.gold.v_dim_users_bi u1
      on ato.requester_id = u1.user_id
      left join business_intelligence.gold.v_dim_employees e1
      on u1.user_employee_key = e1.employee_key
      left join platform.gold.dim_markets m1
      on e1.market_key = m1.market_key
      left join business_intelligence.gold.v_dim_users_bi u2
      on ato.approver_id = u2.user_id
      left join business_intelligence.gold.v_dim_employees e2
      on u2.user_employee_key = e2.employee_key
      left join platform.gold.dim_markets m2
      on e2.market_key = m2.market_key
  )

  , market_region_check as (
  select
      ato.*,
      em.requester_market_id,
      em.requester_title,
      em.approver_market_id,
      em.approver_title,
      mrx1.market_name to_market,
      mrx2.market_name from_market,
      mrx1.district to_district,
      mrx2.district from_district,
      mrx1.region_name to_region,
      mrx2.region_name from_region,
      mrx3.market_name requester_market,
      mrx3.region_name requester_region,
      mrx4.market_name approver_market,
      mrx4.region_name approver_region,
      mrx5.region_name asset_region,
      em.requester_name,
      em.approver_name,
      a.asset_class,
      a.make,
      a.model,
      case
          when (
              (em.requester_market_id = ato.from_branch_id OR em.requester_market_id = ato.to_branch_id)
              and (em.approver_market_id = ato.from_branch_id OR em.approver_market_id = ato.to_branch_id)
          ) then true
          else false
          end as associated_to_branch,
      case
          when(
              em.mgr_requester_region = mrx5.region_name
              or em.mgr_approver_region = mrx5.region_name
              or em.mgr_requester_region = mrx5.district
              or em.mgr_approver_region = mrx5.district
          ) then true else false
              end as is_region_match
  from asset_transfer.public.transfer_orders ato
  join employee_match em on em.transfer_order_id = ato.transfer_order_id
  left join analytics.public.market_region_xwalk mrx1 on mrx1.market_id = ato.to_branch_id
  left join analytics.public.market_region_xwalk mrx2 on mrx2.market_id = ato.from_branch_id
  left join analytics.public.market_region_xwalk mrx3 on mrx3.market_id = em.requester_market_id
  left join analytics.public.market_region_xwalk mrx4 on mrx4.market_id = em.approver_market_id
  left join es_warehouse.public.assets a on ato.asset_id = a.asset_id
  left join analytics.public.market_region_xwalk mrx5 on mrx5.market_id = a.market_id
  order by ato.date_created desc)


  select
      mrc._es_update_timestamp,
      mrc.transfer_order_id,
      mrc.to_branch_id,
      mrc.requester_note,
      mrc.requester_id,
      mrc.status,
      mrc.date_approved,
      mrc.is_rental_transfer,
      mrc.received_by_id,
      mrc.date_rejected,
      mrc.from_branch_id,
      mrc.date_updated,
      mrc.transfer_type_id,
      mrc.date_transfer_cancelled,
      mrc.cancellation_note,
      mrc.is_closed,
      mrc.company_id,
      mrc.date_request_cancelled,
      mrc.date_received,
      mrc.approver_note,
      mrc.transfer_order_number,
      mrc.date_created,
      mrc.approver_id,
      mrc.asset_id,
      mrc.cancelled_by_id,
      mrc.requester_market_id,
      mrc.requester_title,
      mrc.approver_market_id,
      mrc.approver_title,
      mrc.from_market,
      mrc.to_market,
      mrc.from_district,
      mrc.to_district,
      mrc.from_region,
      mrc.to_region,
      mrc.requester_market,
      mrc.approver_market,
      mrc.asset_region,
      mrc.requester_region,
      mrc.approver_region,
      mrc.requester_name,
      mrc.approver_name,
      mrc.associated_to_branch,
      mrc.is_region_match,
      mrc.asset_class,
      mrc.make,
      mrc.model,
      case
          when mrc.associated_to_branch = true then true
          when mrc.is_region_match = true then true
          else false
          end as branch_check
  from market_region_check mrc
  where transfer_order_number not in (1,2,3) ;;
  }

  dimension: transfer_order_id { type: number sql: ${TABLE}.transfer_order_id ;; }
  dimension: to_branch_id { type: number sql: ${TABLE}.to_branch_id ;; }
  dimension: from_branch_id { type: number sql: ${TABLE}.from_branch_id ;; }
  dimension: requester_id { type: number sql: ${TABLE}.requester_id ;; }
  dimension: approver_id { type: number sql: ${TABLE}.approver_id ;; }
  dimension: asset_id {
    type: number
    sql: ${TABLE}.asset_id ;;
    value_format_name: id
  }
  dimension: transfer_order_number {
    type: number
    sql: ${TABLE}.transfer_order_number ;;
    value_format_name: "id"
  }

  dimension: requester_market_id { type: number sql: ${TABLE}.requester_market_id ;; }
  dimension: approver_market_id { type: number sql: ${TABLE}.approver_market_id ;; }
  dimension: requester_market { type: string sql: ${TABLE}.requester_market ;; }
  dimension: approver_market { type: string sql: ${TABLE}.approver_market ;; }

  dimension: to_market {
    type:string
    sql: ${TABLE}.to_market ;;
  }

  dimension: from_market {
    type:string
    sql: ${TABLE}.from_market ;;
  }

  dimension: to_district {
    type:string
    sql: ${TABLE}.to_district ;;
  }

  dimension: from_district {
    type:string
    sql: ${TABLE}.from_district ;;
  }

  dimension: to_region {
    type:string
    sql: ${TABLE}.to_region ;;
  }

  dimension: from_region {
    type:string
    sql: ${TABLE}.from_region ;;
  }

  dimension: asset_class {
    type: string
    sql: ${TABLE}.asset_class ;;
  }

  dimension: make {
    type: string
    sql: ${TABLE}.make ;;
  }

  dimension: model {
    type: string
    sql: ${TABLE}.model ;;
  }

  dimension: asset_region { type: string sql: ${TABLE}.asset_region ;; }
  dimension: requester_region { type: string sql: ${TABLE}.requester_region ;; }
  dimension: approver_region { type: string sql: ${TABLE}.approver_region ;; }
  dimension: requester_title { type: string sql: ${TABLE}.requester_title ;; }
  dimension: approver_title { type: string sql: ${TABLE}.approver_title ;; }
  dimension: requester_name { type: string sql: ${TABLE}.requester_name ;; }
  dimension: approver_name { type: string sql: ${TABLE}.approver_name ;; }

  dimension: requester_info_html {
    label: "Requester Info"
    type: string
    sql: ${requester_name} ;;  # Required anchor field for rendering
    html:
    <div style='line-height: 1.5;'>
      <b>{{ requester_name._value }}</b><br>
      <span style='color:#666;'>Title:</span> {{ requester_title._value }}<br>
      <span style='color:#666;'>Market:</span> {{ requester_market._value }}
    </div> ;;
  }


  dimension: asset_info {
    label: "Asset Info"
    type: string
    sql: ${asset_id} ;;
    html:
    <div style='line-height: 1.5;'>
      <span style='color:#666:'> {{ asset_class._value }}</span><br>
      <span style='color:#666:'> {{ make._value }} - {{ model._value }}</span><br>
      <a href="https://app.estrack.com/#/assets/all/asset/{{asset_id._value}}/status" style='color: blue;'
      target="_blank"><b>{{asset_id._value}}</b> ➔</a>
    </div>
    ;;
  }

  dimension: approver_info_html {
    label: "Approver Info"
    type: string
    sql: ${approver_name} ;;  # Required anchor field for rendering
    html:
    <div style='line-height: 1.5;'>
      <b> {{ approver_name._value }}</b><br>
      <span style='color:#666;'>Title:</span> {{ approver_title._value }}<br>
      <span style='color:#666;'>Market:</span> {{ approver_market._value }}
    </div> ;;
  }

  dimension: transfer_markets_html {
    label: "Transfer Markets"
    type: string
    sql: ${from_market} ;;  # Required anchor field for rendering
    html:
    <div style='line-height: 1.5;'>
      <span style='color:#666;'>From:</span> {{ from_market._value }}<br>
      <span style='color:#666;'>To:</span> {{ to_market._value }}
    </div> ;;
  }


  dimension: status { type: string sql: ${TABLE}.status ;; }
  dimension: is_closed { type: yesno sql: ${TABLE}.is_closed ;; }
  dimension: is_rental_transfer { type: yesno sql: ${TABLE}.is_rental_transfer ;; }
  dimension: associated_to_branch { type: yesno sql: ${TABLE}.associated_to_branch ;; }
  dimension: is_region_match { type: yesno sql: ${TABLE}.is_region_match ;; }
  dimension: branch_check {
    label: "In Market"
    type: yesno
    sql: ${TABLE}.branch_check ;;
    }
  dimension: requester_note { type: string sql: ${TABLE}.requester_note ;; }
  dimension: approver_note { type: string sql: ${TABLE}.approver_note ;; }
  dimension: cancellation_note { type: string sql: ${TABLE}.cancellation_note ;; }
  dimension: company_id { type: number sql: ${TABLE}.company_id ;; }
  dimension: cancelled_by_id { type: number sql: ${TABLE}.cancelled_by_id ;; }
  dimension: received_by_id { type: number sql: ${TABLE}.received_by_id ;; }
  dimension_group: date_created {
    type: time
    timeframes: [time, date, week, month, quarter, year]
    sql: ${TABLE}.date_created ;;
  }

  dimension: formatted_date {
    group_label: "HTML Formatted Date"
    label: "Created Date"
    type: date
    datatype: date
    sql: ${TABLE}.date_created ;;
    html: {{ value | date: "%b %-d, %Y" }} ;;
  }


  dimension_group: date_updated {
    type: time
    timeframes: [time, date, week, month, quarter, year]
    sql: ${TABLE}.date_updated ;;
  }
  dimension_group: date_approved {
    type: time
    timeframes: [time, date, week, month, quarter, year]
    sql: ${TABLE}.date_approved ;;
  }
  dimension_group: date_received {
    type: time
    timeframes: [time, date, week, month, quarter, year]
    sql: ${TABLE}.date_received ;;
  }
  dimension_group: date_rejected {
    type: time
    timeframes: [time, date, week, month, quarter, year]
    sql: ${TABLE}.date_rejected ;;
  }
  dimension_group: date_transfer_cancelled {
    type: time
    timeframes: [time, date, week, month, quarter, year]
    sql: ${TABLE}.date_transfer_cancelled ;;
  }
  dimension_group: date_request_cancelled {
    type: time
    timeframes: [time, date, week, month, quarter, year]
    sql: ${TABLE}.date_request_cancelled ;;
  }
  dimension: transfer_type_id { type: number sql: ${TABLE}.transfer_type_id ;; }
  dimension_group: _es_update_timestamp {
    type: time
    timeframes: [time, date, week, month, quarter, year]
    sql: ${TABLE}._es_update_timestamp ;;
  }

  # set: detail {
  #   fields: [
  #     transfer_order_id
  #   ]
  # }

  measure: count {
    type: count
    drill_fields: [transfer_order_number]
  }

  measure: in_market_transfers {
    type: count
    filters: [branch_check: "Yes"]
    drill_fields: [transfer_order_number]
  }

  measure: out_of_market_transfers {
    type: count
    filters: [branch_check: "No"]
    drill_fields: [transfer_order_number]
  }


}
