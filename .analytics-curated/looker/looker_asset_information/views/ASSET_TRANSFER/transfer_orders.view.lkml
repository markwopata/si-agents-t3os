view: transfer_orders {
  sql_table_name: "ASSET_TRANSFER"."PUBLIC"."TRANSFER_ORDERS" ;;
  drill_fields: [transfer_order_id]

  dimension: transfer_order_id {
    primary_key: yes
    type: string
    sql: ${TABLE}."TRANSFER_ORDER_ID" ;;
    value_format_name: "id"
  }
  dimension_group: _es_load_timestamp {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."_ES_LOAD_TIMESTAMP" AS TIMESTAMP_NTZ) ;;
  }
  dimension_group: _es_update_timestamp {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."_ES_UPDATE_TIMESTAMP" AS TIMESTAMP_NTZ) ;;
  }
  dimension: formatted_date {
    group_label: "HTML Formatted Date"
    label: "Created Date"
    type: date
    datatype: date
    sql: ${TABLE}.date_created ;;
    html: {{ value | date: "%b %-d, %Y" }} ;;
  }
  dimension: approver_id {
    type: number
    sql: ${TABLE}."APPROVER_ID" ;;
  }
  dimension: approver_note {
    type: string
    sql: ${TABLE}."APPROVER_NOTE" ;;
  }
  dimension: asset_id {
    type: number
    value_format_name: id
    sql: ${TABLE}."ASSET_ID" ;;
  }
  dimension: cancellation_note {
    type: string
    sql: ${TABLE}."CANCELLATION_NOTE" ;;
  }
  dimension: cancelled_by_id {
    type: number
    sql: ${TABLE}."CANCELLED_BY_ID" ;;
  }
  dimension: company_id {
    type: number
    sql: ${TABLE}."COMPANY_ID" ;;
  }
  dimension_group: date_approved {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."DATE_APPROVED" AS TIMESTAMP_NTZ) ;;
  }
  dimension_group: date_created {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."DATE_CREATED" AS TIMESTAMP_NTZ) ;;
  }
  dimension_group: date_received {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."DATE_RECEIVED" AS TIMESTAMP_NTZ) ;;
  }
  dimension_group: date_rejected {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."DATE_REJECTED" AS TIMESTAMP_NTZ) ;;
  }
  dimension_group: date_request_cancelled {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."DATE_REQUEST_CANCELLED" AS TIMESTAMP_NTZ) ;;
  }
  dimension_group: date_transfer_cancelled {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."DATE_TRANSFER_CANCELLED" AS TIMESTAMP_NTZ) ;;
  }
  dimension_group: date_updated {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."DATE_UPDATED" AS TIMESTAMP_NTZ) ;;
  }
  dimension: from_branch_id {
    type: number
    sql: ${TABLE}."FROM_BRANCH_ID" ;;
  }
  dimension: is_closed {
    type: yesno
    sql: ${TABLE}."IS_CLOSED" ;;
  }
  dimension: is_rental_transfer {
    type: yesno
    sql: ${TABLE}."IS_RENTAL_TRANSFER" ;;
  }
  dimension: received_by_id {
    type: number
    sql: ${TABLE}."RECEIVED_BY_ID" ;;
  }
  dimension: requester_id {
    type: number
    sql: ${TABLE}."REQUESTER_ID" ;;
  }
  dimension: requester_note {
    type: string
    sql: ${TABLE}."REQUESTER_NOTE" ;;
  }
  dimension: status {
    type: string
    sql: ${TABLE}."STATUS" ;;
  }
  dimension: to_branch_id {
    type: number
    sql: ${TABLE}."TO_BRANCH_ID" ;;
  }
  dimension: transfer_order_number {
    type: number
    sql: ${TABLE}."TRANSFER_ORDER_NUMBER" ;;
    value_format_name: "id"
  }

  dimension: transfer_order_number_html {
    label: "Transfer Order Number"
    type: string
    sql: ${transfer_order_number} ;;
    html:
    <div style='line-height: 1.5;'>
      <a href="https://equipmentshare.looker.com/dashboards/2168?From+Market=&In+Market+%28Yes+%2F+No%29=&From+Region=&From+District=&Asset+ID=&To+District=&Created+Date=90+day&To+Market=&To+Region=&Transfer+Order+Number={{transfer_order_number._value}}" style='color: blue;'
      target="_blank"><b>{{transfer_order_number._value}}</b> ➔</a><br>
      <span style='color:#666:'> View Details</span>
    </div>
    ;;
  }
  dimension: transfer_type_id {
    type: number
    sql: ${TABLE}."TRANSFER_TYPE_ID" ;;
  }

  dimension: requester_name {
    type: string
    sql: ${v_dim_employees_requester.first_name} || ' ' || ${v_dim_employees_requester.last_name};;
  }

  dimension: requester_title {
    type: string
    sql: ${v_dim_employees_requester.employee_title};;
  }

  dimension: requester_market {
    type: string
    sql: ${v_markets_requestor.market_name} ;;
  }

  dimension: requester_market_id {
    type: string
    sql: ${v_markets_requestor.market_id} ;;
  }

  dimension: requester_region {
    type: string
    sql: coalesce(try_to_number(REGEXP_SUBSTR(${v_dim_employees_requester.location}, 'R([0-9]+)', 1, 1, 'e', 1)),0);;
  }

  dimension: requester_district {
    type: string
    sql: split_part(${v_dim_employees_requester.location}, ' ', 2) ;;
  }

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

  dimension: approver_name {
    type: string
    sql: ${v_dim_employees_approver.first_name} || ' ' || ${v_dim_employees_approver.last_name};;
  }

  dimension: approver_title {
    type: string
    sql: ${v_dim_employees_approver.employee_title};;
  }

  dimension: approver_market {
    type: string
    sql: ${v_markets_approver.market_name} ;;
  }

  dimension: approver_market_id {
    type: string
    sql: ${v_markets_approver.market_id} ;;
  }

  dimension: approver_region {
    type: string
    sql: coalesce(try_to_number(REGEXP_SUBSTR(${v_dim_employees_approver.location}, 'R([0-9]+)', 1, 1, 'e', 1)),0);;
  }

  dimension: approver_district {
    type: string
    sql: split_part(${v_dim_employees_approver.location}, ' ', 2) ;;
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

  dimension: associated_to_branch {
    type: yesno
    sql: case
          when (
            (${requester_market_id} = ${to_branch_id} OR ${requester_market_id} = ${from_branch_id})
            and (${approver_market_id} = ${to_branch_id} OR ${approver_market_id} = ${from_branch_id})
          ) then true
          else false
          end;;
  }

  dimension: v_asset_region {
    group_label: "v_asset_fields"
    label: "asset region"
    type: string
    sql: ${v_assets_markets.market_region} ;;
  }

  dimension: v_asset_district {
    group_label: "v_asset_fields"
    label: "asset district"
    type: string
    sql: ${v_assets_markets.market_district} ;;
  }

  dimension: v_asset_id {
    group_label: "v_asset_fields"
    label: "asset id"
    type: string
    sql: ${v_assets.asset_id} ;;
  }

  dimension: asset_class {
    group_label: "v_asset_fields"
    type: string
    sql: ${v_assets.asset_equipment_class_name} ;;
  }

  dimension: make {
    group_label: "v_asset_fields"
    type: string
    sql: ${v_assets.asset_equipment_make} ;;
  }

  dimension: model {
    group_label: "v_asset_fields"
    type: string
    sql: ${v_assets.asset_equipment_model_name} ;;
  }

  dimension: asset_info {
    label: "Asset Info"
    type: string
    sql: ${asset_id} ;;
    html:
    <div style='line-height: 1.5;'>
      <span style='color:#666:'> {{ asset_class._value }}</span><br>
      <span style='color:#666:'> {{ make._value }} - {{ model._value }}</span><br>
      <a href="https://equipmentshare.looker.com/dashboards/169?Asset+ID={{asset_id._value}}" style='color: blue;'
      target="_blank"><b>{{asset_id._value}}</b> ➔</a>
    </div>
    ;;
  }

  dimension: asset_id_html {
    group_label: "Asset ID HTML"
    label: "Asset ID"
    sql: ${asset_id} ;;
    html:
    <a href="https://equipmentshare.looker.com/dashboards/169?Asset+ID={{asset_id._value}}" style='color: blue;'
    target="_blank"><b>{{asset_id._value}}</b> ➔</a>
    ;;
  }


  dimension: is_region_district_match {
    type: string
    sql: case
          when (
            ${requester_district} = ${v_asset_district}
            or ${approver_district} = ${v_asset_district}
            or ${requester_region} = ${v_asset_region}
            or ${approver_region} = ${v_asset_region}
          ) then true
          else false
          end ;;
  }

  dimension: in_market {
    type: yesno
    sql: case
          when ${associated_to_branch} = 'yes' then true
          when ${is_region_district_match} = 'yes' then true
          else false
          end ;;
  }

  dimension: from_market {
    type: string
    sql: ${v_markets_from_branch.market_name} ;;
  }

  dimension: to_market {
    type: string
    sql: ${v_markets_to_branch.market_name} ;;
  }

  filter: market_name {
    type: string
    suggest_explore: transfer_orders
    suggest_dimension: v_markets_to_branch.market_name
  }

  filter: district {
    type: string
    suggest_explore: transfer_orders
    suggest_dimension: v_markets_to_branch.market_district
  }

  filter: region_name {
    type: string
    suggest_explore: transfer_orders
    suggest_dimension: v_markets_to_branch.market_region_name
  }

  parameter: scope_level {
    allowed_value: { value: "Region" }
    allowed_value: { value: "District" }
    allowed_value: { value: "Market" }
  }

# Filter-only field that dashboard filters will bind to
  filter: location {
    type: string
    suggest_explore: transfer_orders
    suggest_dimension: to_location   # points to your dynamic dimension
  }

  dimension: from_location {
    type: string
    sql:
    CASE
      WHEN {% parameter scope_level %} = 'Region'   THEN ${v_markets_from_branch.market_region_name}
      WHEN {% parameter scope_level %} = 'District' THEN ${v_markets_from_branch.market_district}
      WHEN {% parameter scope_level %} = 'Market'   THEN ${v_markets_from_branch.market_name}
    END ;;
  }

  dimension: to_location {
    type: string
    sql:
    CASE
      WHEN {% parameter scope_level %} = 'Region'   THEN ${v_markets_to_branch.market_region_name}
      WHEN {% parameter scope_level %} = 'District' THEN ${v_markets_to_branch.market_district}
      WHEN {% parameter scope_level %} = 'Market'   THEN ${v_markets_to_branch.market_name}
    END ;;
  }

  measure: in_location_oec {
    type: sum
    value_format_name: usd_0
    sql:
    CASE
      -- Inbound = matches filter on TO side
      WHEN {% condition location %} ${to_location} {% endcondition %}
       AND ${from_location} = ${to_location}   -- exclude internal moves
        THEN ${v_assets.asset_current_oec}
      ELSE null
    END ;;
    drill_fields: [detail*]
  }

  dimension: transfer_row_flag {
    type: number
    sql:
    CASE
      WHEN {% condition location %} ${to_location} {% endcondition %}
       OR {% condition location %} ${from_location} {% endcondition %}
        THEN 1
      ELSE 0
    END ;;
  }

  measure: transfers_per_asset {
    type: sum
    sql: ${transfer_row_flag} ;;
    value_format_name: decimal_0
    drill_fields: [detail*]
  }

  measure: total_asset_transfers {
    type: number
    sql:  ${total_assets_in} + ${total_assets_out};;
    drill_fields: [detail*]
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }


  measure: in_market_transfers {
    type: count
    filters: [in_market: "Yes"]
    drill_fields: [detail*]
  }

  measure: out_of_market_transfers {
    type: count
    filters: [in_market: "No"]
    drill_fields: [detail*]
  }

  dimension: is_net_inbound {
    type: yesno
    sql:
    CASE
      WHEN {% condition location %} ${to_location} {% endcondition %}
       AND ${from_location} <> ${to_location}
      THEN TRUE
      ELSE FALSE
    END ;;
  }

  dimension: is_net_outbound {
    type: yesno
    sql:
    CASE
      WHEN {% condition location %} ${from_location} {% endcondition %}
       AND ${from_location} <> ${to_location}
      THEN TRUE
      ELSE FALSE
    END ;;
  }

  dimension: is_net {
    type: number
    sql: case
          when ${is_net_inbound} then 1
          when ${is_net_outbound} then 1
          else 0
          end;;
  }

  measure: net_assets_in {
    type: count_distinct
    sql: CASE WHEN ${is_net_inbound} THEN ${transfer_order_number} END ;;
    filters: [is_net_inbound: "Yes"]
    drill_fields: [detail*]
  }

  measure: net_assets_out {
    type: count_distinct
    sql: CASE WHEN ${is_net_outbound} THEN ${transfer_order_number} END ;;
    filters: [is_net_outbound: "Yes"]
    drill_fields: [detail*]
  }

  measure: net_assets {
    type: sum
    sql: case
          when ${is_net_inbound} then 1
          when ${is_net_outbound} then -1
          else 0
          end;;
    value_format_name: decimal_0
    filters: [is_net: "1"]
    drill_fields: [detail*]
  }

  measure: net_oec_in {
    type: sum
    sql: CASE WHEN ${is_net_inbound} THEN ${v_assets.asset_current_oec} END ;;
    value_format_name: usd_0
    filters: [is_inbound: "Yes"]
    drill_fields: [detail*]
  }

  measure: net_oec_out {
    type: sum
    sql: CASE WHEN ${is_net_outbound} THEN ${v_assets.asset_current_oec} END ;;
    value_format_name: usd_0
    filters: [is_outbound: "Yes"]
    drill_fields: [detail*]
  }

  measure: net_oec {
    type: sum
    sql: case
          when ${is_net_inbound} then ${v_assets.asset_current_oec}
          when ${is_net_outbound} then -${v_assets.asset_current_oec}
          else 0
          end;;
    value_format_name: usd_0
    filters: [is_net: "1"]
    drill_fields: [detail*]
  }

  dimension: is_inbound {
    type: yesno
    sql:
    CASE
      WHEN {% condition location %} ${to_location} {% endcondition %}
      THEN TRUE
      ELSE FALSE
    END ;;
  }

  dimension: is_outbound {
    type: yesno
    sql:
    CASE
      WHEN {% condition location %} ${from_location} {% endcondition %}
      THEN TRUE
      ELSE FALSE
    END ;;
  }

  measure: total_assets_in {
    type: count_distinct
    sql: CASE WHEN ${is_inbound} THEN ${transfer_order_number} END ;;
    filters: [is_inbound: "Yes"]
    drill_fields: [detail*]
  }

  measure: total_assets_out {
    type: count_distinct
    sql: CASE WHEN ${is_outbound} THEN ${transfer_order_number} END ;;
    filters: [is_outbound: "Yes"]
    drill_fields: [detail*]
  }

  measure: total_assets_transferred {
    type: count_distinct
    sql: case
          when ${is_inbound} or ${is_outbound} then ${transfer_order_number}
          else null
          end;;
    value_format_name: decimal_0
    filters: [transfer_row_flag: "1"]
    drill_fields: [detail*]
  }

  measure: total_oec_in {
    type: sum
    sql: CASE WHEN ${is_inbound} THEN ${v_assets.asset_current_oec} END ;;
    value_format_name: usd_0
    filters: [is_inbound: "Yes"]
    drill_fields: [detail*]
  }

  measure: total_oec_out {
    type: sum
    sql: CASE WHEN ${is_outbound} THEN ${v_assets.asset_current_oec} END ;;
    value_format_name: usd_0
    filters: [is_outbound: "Yes"]
    drill_fields: [detail*]
  }

  measure: total_oec_transferred {
    type: sum
    sql: case
          when ${is_inbound} or ${is_outbound} then ${v_assets.asset_current_oec}
          end;;
    value_format_name: usd_0
    filters: [transfer_row_flag: "1"]
    drill_fields: [detail*]
  }

  measure: asset_count {
    type: count_distinct
    sql: ${v_assets.asset_id} ;;
    drill_fields: [detail*]
  }

  set: detail {
    fields: [
      from_location,
      to_location,
      v_assets.asset_equipment_class_name,
      v_assets.asset_current_oec,
      asset_id_html,
      transfer_order_number,
      status,
      date_created_date]
  }
}
