#
# The purpose of this view is to capture on rent metrics.
# Asset count is the distinct number of assets where the inventory status is 'On Rent'.
# OEC Sum is the total of the OEC for the assets on rent (defined above as inventory status is 'On Rent'.
# Active Rental Customers is the distinct number of customers that are tied to an asset on rent (same definition, customer is based on equpment assignements).
#
#Related story:
# [https://app.shortcut.com/businessanalytics/story/278895/salesperson-overview-section-refresh]
#
# Britt Shanklin | Built 2023-08-15 | Modified 2023-08-22
view: on_rent {
  derived_table: {
    sql:

    with current_on_rent as (
    select coalesce(s.user_id, o.salesperson_user_id) as user_id,
           1 as current_flag,
           r.asset_id,
           p.oec,
           r.last_order_company_id,
           r.last_order_company_name
    from analytics.asset_details.asset_rental r
    left join analytics.asset_details.asset_physical p on p.asset_id = r.asset_id
    left join es_warehouse.public.orders o on o.order_id = r.last_order_id
    left join es_warehouse.public.order_salespersons s on o.order_id = s.order_id
    where p.asset_inventory_status = 'On Rent'
          and (s.user_id = try_to_number(split_part({{ _filters['salesperson_on_rent.full_name_with_id'] | sql_quote }}, '-', 2))
               or o.salesperson_user_id = try_to_number(split_part({{ _filters['salesperson_on_rent.full_name_with_id'] | sql_quote }}, '-', 2)))
    group by coalesce(s.user_id, o.salesperson_user_id), current_flag, r.asset_id, p.oec, last_order_company_id, last_order_company_name),
    yesterday_on_rent as (
     select coalesce(s.user_id, o.salesperson_user_id) as user_id,
           0 as current_flag,
           r.asset_id,
           p.oec,
           r.last_order_company_id,
           r.last_order_company_name
    from analytics.asset_details.asset_rental r
    left join analytics.asset_details.asset_physical p on p.asset_id = r.asset_id
    left join es_warehouse.public.orders o on o.order_id = r.last_order_id
    left join es_warehouse.public.order_salespersons s on o.order_id = s.order_id
    where (r.last_off_rent_date >= current_date - INTERVAL '1 Days' or r.last_rental_assignment >= current_date - INTERVAL '1 Days')
          and (s.user_id = try_to_number(split_part({{ _filters['salesperson_on_rent.full_name_with_id'] | sql_quote }}, '-', 2))
               or o.salesperson_user_id = try_to_number(split_part({{ _filters['salesperson_on_rent.full_name_with_id'] | sql_quote }}, '-', 2)))
    group by coalesce(s.user_id, o.salesperson_user_id), current_flag, r.asset_id, p.oec, last_order_company_id, last_order_company_name
    ),
    combine as (
    select * from current_on_rent
    UNION
    select * from yesterday_on_rent)
    select c.*, stl.fleet_login_link
    from combine c
    left join es_warehouse.public.sales_track_logins stl on c.last_order_company_id = stl.company_id;;
  }

  dimension: surrogate_key {
    hidden: yes
    primary_key: yes
    sql: CONCAT(${TABLE}."USER_ID", '_', ${TABLE}."ASSET_ID") ;;
  }

  dimension: salesperson_user_id {
    type: string
    sql: ${TABLE}."USER_ID" ;;
  }

  dimension: asset_id {
    type: string
    sql: ${TABLE}."ASSET_ID" ;;
  }

  dimension: company_id {
    type: string
    sql: ${TABLE}."LAST_ORDER_COMPANY_ID" ;;
  }

  dimension: company_name {
    type: string
    sql: ${TABLE}."LAST_ORDER_COMPANY_NAME" ;;
  }

  dimension: oec {
    type: number
    sql: ${TABLE}."OEC" ;;
    value_format_name: usd_0
  }

  # dimension: asset_count {
  #   hidden: yes
  #   type: number
  #   sql: ${TABLE}."ASSET_COUNT" ;;
  # }
  #
  # dimension: oec_sum {
  #   hidden: yes
  #   type: number
  #   sql: ${TABLE}."OEC_SUM" ;;
  # }

  # dimension: customer_count {
  #   hidden: yes
  #   type: number
  #   sql: ${TABLE}."CUSTOMER_COUNT" ;;
  # }

  dimension: fleet_login_link {
    type: string
    sql: ${TABLE}."FLEET_LOGIN_LINK" ;;
  }

  dimension: company_name_with_links {
    type: string
    sql: ${company_name};;
    link: {
      label: "View as Customer in T3"
      url: "{{fleet_login_link._value}}"
    }
    link: {
      label: "View Customer Information Dashboard"
      url: "https://equipmentshare.looker.com/dashboards/28?Company%20Name={{ company_name._filterable_value | url_encode }}&Company%20ID="
    }
  }

  dimension: current_flag {
    hidden: yes
    type: yesno
    sql: ${TABLE}."CURRENT_FLAG" = 1 ;;
  }

  measure: assets_on_rent {
    type: count_distinct
    filters: [current_flag: "Yes"]
    sql: ${asset_id} ;;
  }

  measure: oec_on_rent {
    type: sum_distinct
    filters: [current_flag: "Yes"]
    sql: ${oec} ;;
    value_format_name: usd_0
  }

  measure: active_rental_customers {
    type: count_distinct
    filters: [current_flag: "Yes"]
    sql: ${company_id} ;;
  }

  measure: yesterday_assets_on_rent {
    type: count_distinct
    filters: [current_flag: "No"]
    sql: ${asset_id} ;;
    value_format: "+0;-0; -"
  }

  measure: yesterday_oec_on_rent {
    type: sum_distinct
    filters: [current_flag: "No"]
    sql: ${oec} ;;
    value_format: "+$#,##0;-$#,##0; -"
  }

  measure: yesterday_active_rental_customers {
    type: count_distinct
    filters: [current_flag: "No"]
    sql: ${company_id} ;;
    value_format: "+0;-0; -"
  }

  measure: change_assets_on_rent {
    type: number
    sql: ${assets_on_rent} - ${yesterday_assets_on_rent} ;;
    value_format: "+0;-0; -"
  }

  measure: change_oec_on_rent {
    type: number
    sql: ${oec_on_rent} - ${yesterday_oec_on_rent} ;;
    value_format: "+$#,##0;-$#,##0; -"
  }

  measure: change_active_rental_customers {
    type: number
    sql: ${active_rental_customers} - ${yesterday_active_rental_customers} ;;
    value_format: "+0;-0; -"
  }

  measure: formatted_change_assets_on_rent {
    type: number
    sql: ${assets_on_rent} - ${yesterday_assets_on_rent} ;;
    value_format: "+0;-0; -"
    html:
    {% if value > 0 %}
    <span style="color:darkgreen;">{{ rendered_value }}</span>
    {% elsif value == 0 %}
    <span style="color:grey;">{{ rendered_value }}</span>
    {% else %}
    <span style="color:darkred;">{{ rendered_value }}</span>
    {% endif %} ;;
  }

  measure: formatted_change_oec_on_rent {
    type: number
    sql: ${oec_on_rent} - ${yesterday_oec_on_rent};;
    value_format: "+$#,##0;-$#,##0; -"
    html:
    {% if value > 0 %}
    <span style="color:darkgreen;">{{ rendered_value }}</span>
    {% elsif value == 0 %}
    <span style="color:grey;">{{ rendered_value }}</span>
    {% else %}
    <span style="color:darkred;">{{ rendered_value }}</span>
    {% endif %} ;;
  }

  measure: formatted_change_active_rental_customers {
    type: number
    sql: ${active_rental_customers} - ${yesterday_active_rental_customers};;
    value_format: "+0;-0; -"
    html:
    {% if value > 0 %}
    <span style="color:darkgreen;">{{ rendered_value }}</span>
    {% elsif value == 0 %}
    <span style="color:grey;">{{ rendered_value }}</span>
    {% else %}
    <span style="color:darkred;">{{ rendered_value }}</span>
    {% endif %} ;;
  }



}
