view: category_spend_history {
  derived_table: {
    sql:
    {% if duration_selection._parameter_value == "'Daily'" %}
    with date_series as (
      select
          series::date as date
      from
        table
        (generate_series(
        {% date_start date_filter %}::timestamp_tz,
        {% date_end date_filter %}::timestamp_tz,
        'day')
      )
    ),
    market_open_date as (
      select
          child_market_id as market_id
        , branch_earnings_start_month
        , ifnull(datediff(months, branch_earnings_start_month, {% date_start date_filter %}::timestamp_ntz),0) as month_since_open
        , iff(month_since_open >= 12, true, false) as open_more_than_12_months
        from analytics.public.v_market_t3_analytics
    )

      {% if view_by._parameter_value == "'Date Created'" %}
      select
      ds.date as date_created,
      stg.item_type,
      stg.purchase_order_number,
      stg.purchase_order_reference as reference,
      concat(stg.first_name,' ',stg.last_name) as created_by,
      stg.market_name as cost_center,
      stg.purchase_order_id,
      stg.purchase_order_line_items_quantity * stg.purchase_order_line_items_price_per_unit as total_po_cost,
      stg.item_service,
      stg.market_type,
      stg.purchase_order_receivers_date_received as date_received
      from
      date_series ds
      left join BUSINESS_INTELLIGENCE.TRIAGE.STG_T3__CATEGORY_SPEND_HISTORY stg
      on stg.purchase_order_date_created::date = ds.date
      left join market_open_date mod on mod.market_id = stg.requesting_branch_id
      where
      {% condition cost_center_filter %} stg.market_name {% endcondition %}
      AND {% condition region_filter %} stg.market_region_xwalk_region_name {% endcondition %}
      AND {% condition district_filter %} stg.market_region_xwalk_district_name {% endcondition %}
      AND {% condition market_open_filter %} mod.open_more_than_12_months {% endcondition %}
      AND {% condition status_filter %} stg.purchase_order_status {% endcondition %}
      AND {% condition vendor_filter %} stg.purchase_entity_name {% endcondition %}
      AND {% condition preferred_filter %} coalesce(stg.top_vendor_mapping_preferred,'No') {% endcondition %}
      AND stg.market_company_id = {{ _user_attributes['company_id'] }}

      {% else %}
      select
      ds.date as date_created,
      stg.item_type,
      stg.purchase_order_number,
      stg.purchase_order_reference as reference,
      concat(stg.first_name,' ',stg.last_name) as created_by,
      stg.market_name as cost_center,
      stg.purchase_order_id,
      stg.purchase_order_line_items_quantity * stg.purchase_order_line_items_price_per_unit as total_po_cost,
      stg.item_service,
      stg.market_type,
      stg.purchase_order_receivers_date_received as date_received
      from
      date_series ds
      left join BUSINESS_INTELLIGENCE.TRIAGE.STG_T3__CATEGORY_SPEND_HISTORY stg
      on stg.purchase_order_receivers_date_received::date = ds.date
      left join market_open_date mod on mod.market_id = stg.requesting_branch_id
      where
      {% condition cost_center_filter %} stg.market_name {% endcondition %}
      AND {% condition region_filter %} stg.market_region_xwalk_region_name {% endcondition %}
      AND {% condition district_filter %} stg.market_region_xwalk_district_name {% endcondition %}
      AND {% condition market_open_filter %} mod.open_more_than_12_months {% endcondition %}
      AND {% condition status_filter %} stg.purchase_order_status {% endcondition %}
      AND {% condition vendor_filter %} stg.purchase_entity_name {% endcondition %}
      AND {% condition preferred_filter %} coalesce(stg.top_vendor_mapping_preferred,'No') {% endcondition %}
      AND stg.market_company_id = {{ _user_attributes['company_id'] }}
      {% endif %}

      {% elsif duration_selection._parameter_value == "'Weekly'" %}
      with date_series as (
      select
      series as date
      from
      table
      (generate_series(
      {% date_start date_filter %}::timestamp_tz,
      {% date_end date_filter %}::timestamp_tz,
      'week')
      )
      ),
      market_open_date as (
      select
      child_market_id as market_id
      , branch_earnings_start_month
      , ifnull(datediff(months, branch_earnings_start_month, {% date_start date_filter %}::timestamp_ntz),0) as month_since_open
      , iff(month_since_open >= 12, true, false) as open_more_than_12_months
      from analytics.public.v_market_t3_analytics
      )

      {% if view_by._parameter_value == "'Date Created'" %}
      select
      ds.date as date_created,
      stg.item_type,
      stg.purchase_order_number,
      stg.purchase_order_reference as reference,
      concat(stg.first_name,' ',stg.last_name) as created_by,
      stg.market_name as cost_center,
      stg.purchase_order_id,
      stg.purchase_order_line_items_quantity * stg.purchase_order_line_items_price_per_unit as total_po_cost,
      stg.item_service,
      stg.market_type,
      stg.market_type,
      stg.purchase_order_receivers_date_received as date_received
      from
      date_series ds
      left join BUSINESS_INTELLIGENCE.TRIAGE.STG_T3__CATEGORY_SPEND_HISTORY stg
      on WEEK(stg.purchase_order_date_created) = WEEK(ds.date)
      AND YEAR(stg.purchase_order_date_created) = YEAR(ds.date)
      left join market_open_date mod on mod.market_id = stg.requesting_branch_id
      where
      {% condition cost_center_filter %} stg.market_name {% endcondition %}
      AND {% condition region_filter %} stg.market_region_xwalk_region_name {% endcondition %}
      AND {% condition district_filter %} stg.market_region_xwalk_district_name {% endcondition %}
      AND {% condition market_open_filter %} mod.open_more_than_12_months {% endcondition %}
      AND {% condition status_filter %} stg.purchase_order_status {% endcondition %}
      AND {% condition vendor_filter %} stg.purchase_entity_name {% endcondition %}
      AND {% condition preferred_filter %} coalesce(stg.top_vendor_mapping_preferred,'No') {% endcondition %}
      AND stg.market_company_id = {{ _user_attributes['company_id'] }}

      {% else %}
      select
      ds.date as date_created,
      stg.item_type,
      stg.purchase_order_number,
      stg.purchase_order_reference as reference,
      concat(stg.first_name,' ',stg.last_name) as created_by,
      stg.market_name as cost_center,
      stg.purchase_order_id,
      stg.purchase_order_line_items_quantity * stg.purchase_order_line_items_price_per_unit as total_po_cost,
      stg.item_service,
      stg.market_type,
      stg.purchase_order_receivers_date_received as date_received
      from
      date_series ds
      left join BUSINESS_INTELLIGENCE.TRIAGE.STG_T3__CATEGORY_SPEND_HISTORY stg
      on WEEK(stg.purchase_order_receivers_date_received) = WEEK(ds.date)
      AND YEAR(stg.purchase_order_receivers_date_received) = YEAR(ds.date)
      left join market_open_date mod on mod.market_id = stg.requesting_branch_id
      where
      {% condition cost_center_filter %} stg.market_name {% endcondition %}
      AND {% condition region_filter %} stg.market_region_xwalk_region_name {% endcondition %}
      AND {% condition district_filter %} stg.market_region_xwalk_district_name {% endcondition %}
      AND {% condition market_open_filter %} mod.open_more_than_12_months {% endcondition %}
      AND {% condition status_filter %} stg.purchase_order_status {% endcondition %}
      AND {% condition vendor_filter %} stg.purchase_entity_name {% endcondition %}
      AND {% condition preferred_filter %} coalesce(stg.top_vendor_mapping_preferred,'No') {% endcondition %}
      AND stg.market_company_id = {{ _user_attributes['company_id'] }}
      {% endif %}

      {% elsif duration_selection._parameter_value == "'Monthly'" %}
      with date_series as (
      select
      date_trunc('MONTH',series) as date
      from
      table
      (generate_series(
      {% date_start date_filter %}::timestamp_tz,
      {% date_end date_filter %}::timestamp_tz,
      'month')
      )
      ),
      market_open_date as (
      select
      child_market_id as market_id
      , branch_earnings_start_month
      , ifnull(datediff(months, branch_earnings_start_month, {% date_start date_filter %}::timestamp_ntz),0) as month_since_open
      , iff(month_since_open >= 12, true, false) as open_more_than_12_months
      from analytics.public.v_market_t3_analytics
      )

      {% if view_by._parameter_value == "'Date Created'" %}
      select
      ds.date as date_created,
      stg.item_type,
      stg.purchase_order_number,
      stg.purchase_order_reference as reference,
      concat(stg.first_name,' ',stg.last_name) as created_by,
      stg.market_name as cost_center,
      stg.purchase_order_id,
      stg.purchase_order_line_items_quantity * stg.purchase_order_line_items_price_per_unit as total_po_cost,
      stg.item_service,
      stg.market_type,
      stg.purchase_order_receivers_date_received as date_received
      from
      date_series ds
      left join BUSINESS_INTELLIGENCE.TRIAGE.STG_T3__CATEGORY_SPEND_HISTORY stg
      on date_trunc('MONTH',stg.purchase_order_date_created) = ds.date
      left join market_open_date mod on mod.market_id = stg.requesting_branch_id
      where
      {% condition cost_center_filter %} stg.market_name {% endcondition %}
      AND {% condition region_filter %} stg.market_region_xwalk_region_name {% endcondition %}
      AND {% condition district_filter %} stg.market_region_xwalk_district_name {% endcondition %}
      AND {% condition market_open_filter %} mod.open_more_than_12_months {% endcondition %}
      AND {% condition status_filter %} stg.purchase_order_status {% endcondition %}
      AND {% condition vendor_filter %} stg.purchase_entity_name {% endcondition %}
      AND {% condition preferred_filter %} coalesce(stg.top_vendor_mapping_preferred,'No') {% endcondition %}
      AND stg.market_company_id = {{ _user_attributes['company_id'] }}

      {% else %}
      select
      ds.date as date_created,
      stg.item_type,
      stg.purchase_order_number,
      stg.purchase_order_reference as reference,
      concat(stg.first_name,' ',stg.last_name) as created_by,
      stg.market_name as cost_center,
      stg.purchase_order_id,
      stg.purchase_order_line_items_quantity * stg.purchase_order_line_items_price_per_unit as total_po_cost,
      stg.item_service,
      stg.market_type,
      stg.purchase_order_receivers_date_received as date_received
      from
      date_series ds
      left join BUSINESS_INTELLIGENCE.TRIAGE.STG_T3__CATEGORY_SPEND_HISTORY stg
      on date_trunc('MONTH',stg.purchase_order_receivers_date_received)::date = ds.date
      left join market_open_date mod on mod.market_id = stg.requesting_branch_id
      where
      {% condition cost_center_filter %} stg.market_name {% endcondition %}
      AND {% condition region_filter %} stg.market_region_xwalk_region_name {% endcondition %}
      AND {% condition district_filter %} stg.market_region_xwalk_district_name {% endcondition %}
      AND {% condition market_open_filter %} mod.open_more_than_12_months {% endcondition %}
      AND {% condition status_filter %} stg.purchase_order_status {% endcondition %}
      AND {% condition vendor_filter %} stg.purchase_entity_name {% endcondition %}
      AND {% condition preferred_filter %} coalesce(stg.top_vendor_mapping_preferred,'No') {% endcondition %}
      AND stg.market_company_id = {{ _user_attributes['company_id'] }}
      {% endif %}

      {% else %}
      -- Default to Daily
      with date_series as (
      select
      series::date as date
      from
      table
      (generate_series(
      {% date_start date_filter %}::timestamp_tz,
      {% date_end date_filter %}::timestamp_tz,
      'day')
      )
      ),
      market_open_date as (
      select
      child_market_id as market_id
      , branch_earnings_start_month
      , ifnull(datediff(months, branch_earnings_start_month, {% date_start date_filter %}::timestamp_ntz),0) as month_since_open
      , iff(month_since_open >= 12, true, false) as open_more_than_12_months
      from analytics.public.v_market_t3_analytics
      )

      {% if view_by._parameter_value == "'Date Created'" %}
      select
      ds.date as date_created,
      stg.item_type,
      stg.purchase_order_number,
      stg.purchase_order_reference as reference,
      concat(stg.first_name,' ',stg.last_name) as created_by,
      stg.market_name as cost_center,
      stg.purchase_order_id,
      stg.purchase_order_line_items_quantity * stg.purchase_order_line_items_price_per_unit as total_po_cost,
      stg.item_service,
      stg.market_type,
      stg.purchase_order_receivers_date_received as date_received
      from
      date_series ds
      left join BUSINESS_INTELLIGENCE.TRIAGE.STG_T3__CATEGORY_SPEND_HISTORY stg
      on stg.purchase_order_date_created::date = ds.date
      left join market_open_date mod on mod.market_id = stg.requesting_branch_id
      where
      {% condition cost_center_filter %} stg.market_name {% endcondition %}
      AND {% condition region_filter %} stg.market_region_xwalk_region_name {% endcondition %}
      AND {% condition district_filter %} stg.market_region_xwalk_district_name {% endcondition %}
      AND {% condition market_open_filter %} mod.open_more_than_12_months {% endcondition %}
      AND {% condition status_filter %} stg.purchase_order_status {% endcondition %}
      AND {% condition vendor_filter %} stg.purchase_entity_name {% endcondition %}
      AND {% condition preferred_filter %} coalesce(stg.top_vendor_mapping_preferred,'No') {% endcondition %}
      AND stg.market_company_id = {{ _user_attributes['company_id'] }}

      {% else %}
      select
      ds.date as date_created,
      stg.item_type,
      stg.purchase_order_number,
      stg.purchase_order_reference as reference,
      concat(stg.first_name,' ',stg.last_name) as created_by,
      stg.market_name as cost_center,
      stg.purchase_order_id,
      stg.purchase_order_line_items_quantity * stg.purchase_order_line_items_price_per_unit as total_po_cost,
      stg.item_service,
      stg.market_type,
      stg.purchase_order_receivers_date_received as date_received
      from
      date_series ds
      left join BUSINESS_INTELLIGENCE.TRIAGE.STG_T3__CATEGORY_SPEND_HISTORY stg
      on stg.purchase_order_receivers_date_received::date = ds.date
      left join market_open_date mod on mod.market_id = stg.requesting_branch_id
      where
      {% condition cost_center_filter %} stg.market_name {% endcondition %}
      AND {% condition region_filter %} stg.market_region_xwalk_region_name {% endcondition %}
      AND {% condition district_filter %} stg.market_region_xwalk_district_name {% endcondition %}
      AND {% condition market_open_filter %} mod.open_more_than_12_months {% endcondition %}
      AND {% condition status_filter %} stg.purchase_order_status {% endcondition %}
      AND {% condition vendor_filter %} stg.purchase_entity_name {% endcondition %}
      AND {% condition preferred_filter %} coalesce(stg.top_vendor_mapping_preferred,'No') {% endcondition %}
      AND stg.market_company_id = {{ _user_attributes['company_id'] }}
      {% endif %}
      {%  endif %}
      ;;
  }

  dimension_group: date_created {
    type: time
    sql: ${TABLE}."DATE_CREATED" ;;
  }

  dimension: item_type {
    type: string
    sql: ${TABLE}."ITEM_TYPE" ;;
  }

  dimension: purchase_order_number {
    type: number
    sql: ${TABLE}."PURCHASE_ORDER_NUMBER" ;;
    value_format_name: id
  }

  dimension: reference {
    type: string
    sql: ${TABLE}."REFERENCE" ;;
  }

  dimension: created_by {
    type: string
    sql: ${TABLE}."CREATED_BY" ;;
  }

  dimension: cost_center {
    type: string
    sql: ${TABLE}."COST_CENTER" ;;
  }

  dimension: market_type {
    type: string
    sql: ${TABLE}."MARKET_TYPE" ;;
  }

  dimension: region_name {
    type: string
    sql: ${TABLE}."MARKET_REGION_XWALK_REGION_NAME" ;;
  }

  dimension: district {
    type: string
    sql: ${TABLE}."MARKET_REGION_XWALK_DISTRICT_NAME" ;;
  }

  dimension: total_po_cost {
    type: number
    sql: ${TABLE}."TOTAL_PO_COST" ;;
  }

  dimension: purchase_order_id {
    type: string
    sql: ${TABLE}."PURCHASE_ORDER_ID" ;;
  }

  dimension: item_service {
    label: "Item/Service"
    type: string
    sql: ${TABLE}."ITEM_SERVICE" ;;
  }

  dimension_group: date_received {
    type: time
    sql: ${TABLE}."DATE_RECEIVED" ;;
  }

  filter: date_filter {
    type: date_time
  }

  dimension: date_created_date_html {
    group_label: "HTML Format"
    label: "Date Created"
    type: date
    sql: ${date_created_date} ;;
    html: {{ rendered_value | date: "%b %d, %Y" }};;
  }

  dimension: date_received_date_html {
    group_label: "HTML Format"
    label: "Date Received"
    type: date
    sql: ${date_received_date} ;;
    html: {{ rendered_value | date: "%b %d, %Y" }};;
  }

  parameter: duration_selection {
    type: string
    allowed_value: { value: "Daily"}
    allowed_value: { value: "Weekly"}
    allowed_value: { value: "Monthly"}
  }

  dimension: dynamic_timeframe {
    group_label: "Dynamic Date"
    label: "Date"
    type: string
    sql:
    CASE
    WHEN {% parameter duration_selection %} = 'Daily' AND {% parameter view_by %} = 'Date Created' THEN ${date_created_date}
    WHEN {% parameter duration_selection %} = 'Weekly' AND {% parameter view_by %} = 'Date Created' THEN ${date_created_week}
    WHEN {% parameter duration_selection %} = 'Monthly' AND {% parameter view_by %} = 'Date Created' THEN ${date_created_month}
    WHEN {% parameter duration_selection %} = 'Daily' AND {% parameter view_by %} = 'Date Received' THEN ${date_received_date}
    WHEN {% parameter duration_selection %} = 'Weekly' AND {% parameter view_by %} = 'Date Received' THEN ${date_received_week}
    WHEN {% parameter duration_selection %} = 'Monthly' AND {% parameter view_by %} = 'Date Received' THEN ${date_received_month}
    ELSE ${date_created_date}
    END ;;
    html: {% if duration_selection._parameter_value == "'Daily'" %}
          {{ rendered_value | date: "%b %d, %Y" }}
          {% elsif duration_selection._parameter_value == "'Weekly'"  %}
          {{ rendered_value | date: "%b %d, %Y" }}
          {% elsif duration_selection._parameter_value == "'Monthly'"  %}
          {{ rendered_value | append: "-01" | date: "%b %Y" }}
          {% else %}
          {{ rendered_value | date: "%b %d, %Y" }}
          {% endif %} ;;
  }

  measure: total_purchase_order_cost_inventory {
    label: "Total Inventory Amount"
    type: sum
    sql: ${total_po_cost} ;;
    value_format_name: usd
    drill_fields: [detail_inventory*]
    filters: [item_type: "INVENTORY"]
  }

  measure: total_purchase_order_cost_non_inventory {
    label: "Total Non Inventory Amount"
    type: sum
    sql: ${total_po_cost} ;;
    value_format_name: usd
    drill_fields: [detail_non_inventory*]
    filters: [item_type: "NON_INVENTORY"]
  }

  measure: total_purchase_order_cost_inventory_drill_down {
    group_label: "Drill Down"
    label: "Total Inventory Amount"
    type: sum
    sql: ${total_po_cost} ;;
    value_format_name: usd
    drill_fields: [detail_inventory*]
    filters: [item_type: "INVENTORY"]
  }

  measure: total_purchase_order_cost_non_inventory_drill_down {
    group_label: "Drill Down"
    label: "Total Non-Inventory Amount"
    type: sum
    sql: ${total_po_cost} ;;
    value_format_name: usd
    drill_fields: [detail_non_inventory*]
    filters: [item_type: "NON_INVENTORY"]
  }

  measure: total_purchase_order_cost {
    type: sum
    sql: ${total_po_cost} ;;
    value_format_name: usd
    drill_fields: [detail*]
  }

  filter: cost_center_filter {
    suggest_explore: cost_center
    suggest_dimension: cost_center.cost_center
  }

  filter: region_filter {
    suggest_explore: cost_center
    suggest_dimension: cost_center.region_name
  }

  filter: district_filter {
    suggest_explore: cost_center
    suggest_dimension: cost_center.district_name
  }

  filter: status_filter {
  }

  filter: vendor_filter {
  }

  filter: market_open_filter {
    suggest_explore: cost_center
    suggest_dimension: cost_center.open_more_than_12_months
  }

  filter: preferred_filter {
  }

  dimension: date_in_future {
    type: yesno
    sql: ${date_created_raw} > current_date ;;
  }

  dimension: link_to_purchase_order {
    group_label: "Link To PO"
    label: "Purchase Order Number"
    sql: ${purchase_order_id} ;;
    html: <font color="#0063f3"><u><a href="https://costcapture.estrack.com/purchase-orders/{{rendered_value}}/detail" target="_blank">{{purchase_order_number._rendered_value}}</a></font></u>;;
  }

  parameter: view_by {
    type: string
    allowed_value: { value: "Date Created"}
    allowed_value: { value: "Date Received"}
  }

  set: detail_inventory {
    fields: [
      date_created_date_html,
      date_received_date_html,
      link_to_purchase_order,
      reference,
      created_by,
      cost_center,
      total_purchase_order_cost_inventory_drill_down
    ]
  }

  set: detail_non_inventory {
    fields: [
      date_created_date_html,
      date_received_date_html,
      link_to_purchase_order,
      reference,
      created_by,
      cost_center,
      total_purchase_order_cost_non_inventory_drill_down
    ]
  }

  set: detail {
    fields: [
      date_created_date_html,
      link_to_purchase_order,
      reference,
      created_by,
      cost_center,
      total_purchase_order_cost
    ]
  }
}
