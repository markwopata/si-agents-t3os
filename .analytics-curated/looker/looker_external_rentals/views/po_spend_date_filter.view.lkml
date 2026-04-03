view: po_spend_date_filter {
  derived_table: {
    sql: with po_info as (
      select
        purchase_order_id,
        name as po_name,
        coalesce(sum(budget_amount),0) as budget_amount
      from
        ES_WAREHOUSE.PUBLIC.PURCHASE_ORDERS
      where
        company_id = {{ _user_attributes['company_id'] }}
        and active = TRUE
      group by
        purchase_order_id,
        name
      )
      ,budget_invoice_combine as (
      SELECT
        i.BILLING_APPROVED_DATE,
        pi.po_name,
        i.invoice_id as invoice_id,
        i.invoice_no,
        --i.billed_amount,
        sum(coalesce(vli.amount,0) + coalesce(vli.tax_amount,0)) as billed_amount,
        pi.budget_amount,
        'ES' as rental_type
      FROM
        po_info pi
        --join es_warehouse_stage.public.global_invoices i on i.purchase_order_id = pi.purchase_order_id
        JOIN ES_WAREHOUSE.PUBLIC.GLOBAL_INVOICES i on i.purchase_order_id = pi.purchase_order_id
        JOIN ES_WAREHOUSE.PUBLIC.PURCHASE_ORDERS po ON i.purchase_order_id = po.purchase_order_id
        LEFT JOIN ANALYTICS.PUBLIC.V_LINE_ITEMS vli on i.invoice_id = vli.invoice_id
        left join users u on i.ordered_by_user_id = u.user_id
        --join ES_WAREHOUSE.PUBLIC.ORDERS o on o.purchase_order_id = pi.purchase_order_id
        --join users u on o.user_id = u.user_id
        --JOIN ES_WAREHOUSE.PUBLIC.PURCHASE_ORDERS po ON o.PURCHASE_ORDER_ID =  po.PURCHASE_ORDER_ID
        --JOIN ES_WAREHOUSE.PUBLIC.INVOICES i ON o.ORDER_ID = i.ORDER_ID
      WHERE
          u.company_id = {{ _user_attributes['company_id'] }}::integer
          --and o.deleted = FALSE
          --and i.billing_approved_date >= po.start_date
          and i.billing_approved_date between
            convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC', {% date_start date_filter %}) AND
            convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC', {% date_end date_filter %})
          and po.active = TRUE
      GROUP BY
          i.BILLING_APPROVED_DATE,
          pi.po_name,
          --i.billed_amount,
          pi.budget_amount,
          i.invoice_id,
          i.invoice_no
      )
      ,budget_by_po as (
      SELECT
        po_name,
        budget_amount,
        sum(billed_amount) as cumulative_amount,
        budget_amount - cumulative_amount as remaining_budget
      FROM
        budget_invoice_combine
      GROUP BY
        po_name,
        budget_amount
      )
      select
          po_name,
          coalesce(budget_amount,0) as budget_amount,
          coalesce(remaining_budget,0) as budget_remaining,
          coalesce(cumulative_amount,0) as selected_date_range_spend,
          case when budget_amount > 0 then ((coalesce(budget_amount,0) - coalesce(sum(cumulative_amount),0)) / coalesce(budget_amount,0)) else 0 end as pcnt_budget_remaining
      from
          budget_by_po
      group by
          po_name,
          budget_amount,
          remaining_budget,
          cumulative_amount
 ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: primary_key {
    primary_key: yes
    type: string
    sql: concat(${po_name},${budget_remaining}) ;;
  }

  dimension: po_name {
    type: string
    sql: ${TABLE}."PO_NAME" ;;
  }

  dimension: budget_amount {
    type: number
    sql: ${TABLE}."BUDGET_AMOUNT" ;;
    value_format_name: usd
  }

  dimension: budget_remaining {
    type: number
    sql: ${TABLE}."BUDGET_REMAINING" ;;
    value_format_name: usd
    skip_drill_filter: yes
  }

  dimension: selected_date_range_spend {
    type: number
    sql: ${TABLE}."SELECTED_DATE_RANGE_SPEND" ;;
    value_format_name: usd
    # drill_fields: [invoice_drill*]
    link: {
      label: "View Invoices for Selected Date Range Spend"
      url: "{% assign vis= '{\"show_view_names\":false,
            \"show_row_numbers\":true,
            \"transpose\":false,
            \"truncate_text\":true,
            \"hide_totals\":false,
            \"hide_row_totals\":false,
            \"size_to_fit\":true,
            \"table_theme\":\"gray\",
            \"limit_displayed_rows\":false,
            \"enable_conditional_formatting\":false,
            \"header_text_alignment\":\"left\",
            \"header_font_size\":\"13\",
            \"rows_font_size\":\"12\",
            \"conditional_formatting_include_totals\":false,
            \"conditional_formatting_include_nulls\":false,
            \"show_sql_query_menu_options\":false,
            \"show_totals\":true,
            \"show_row_totals\":true,
            \"series_labels\":{\"po_spend_by_invoice_date_filter.po_name\":\"PO\",
            \"po_spend_by_invoice_date_filter.invoice_no\":\"Invoice Number\",
            \"po_spend_by_invoice_date_filter.billing_approved_date_date\":\"Billing Approved Date\",
            \"po_spend_by_invoice_date_filter.budget_amount\":\"Overall Budget Amount\",
            \"po_spend_by_invoice_date_filter.budget_remaining\":\"Budget Remaining\",
            \"po_spend_by_invoice_date_filter.pcnt_budget_remaining\":\"% of Budget Remaining\"},
            \"series_cell_visualizations\":{\"po_spend_by_invoice_date_filter.budget_remaining\":{\"is_active\":true}},
            \"header_font_color\":\"#000000\",
            \"header_background_color\":\"#E1E2E6\",
            \"type\":\"looker_grid\",
            \"x_axis_gridlines\":false,
            \"y_axis_gridlines\":true,
            \"show_y_axis_labels\":true,
            \"show_y_axis_ticks\":true,
            \"y_axis_tick_density\":\"default\",
            \"y_axis_tick_density_custom\":5,
            \"show_x_axis_label\":true,
            \"show_x_axis_ticks\":true,
            \"y_axis_scale_mode\":\"linear\",
            \"x_axis_reversed\":false,
            \"y_axis_reversed\":false,
            \"plot_size_by_field\":false,
            \"trellis\":\"\",
            \"stacking\":\"\",
            \"legend_position\":\"center\",
            \"point_style\":\"none\",
            \"show_value_labels\":false,
            \"label_density\":25,
            \"x_axis_scale\":\"auto\",
            \"y_axis_combined\":true,
            \"show_null_points\":true,
            \"interpolation\":\"linear\",
            \"defaults_version\":1,
            \"series_types\":{}}' %}

            {% assign dynamic_fields= '[]' %}

            {{dummy._link}}&f[po_spend_date_filter.date_filter]={{_filters['po_spend_date_filter.date_filter'] | url_encode }}&f[po_spend_by_invoice_date_filter.po_name]={{_filters['po_spend_date_filter.po_name'] | url_encode }}&vis={{vis | encode_uri}}&dynamic_fields={{dynamic_fields | encode_uri}}&sorts=po_spend_by_invoice_date_filter.budget_remaining+desc&vis={{vis | encode_uri}}"

    }
  }

  dimension: pcnt_budget_remaining {
    type: number
    sql: ${TABLE}."PCNT_BUDGET_REMAINING" ;;
    value_format_name: percent_1
  }

  filter: date_filter {
    type: date_time
  }

  measure: dummy {
    hidden: yes
    type: number
    sql: 0 ;;
    drill_fields: [invoice_drill*]
  }

  parameter: only_show_active_pos {
    type: string
    allowed_value: { value: "Yes"}
    allowed_value: { value: "No"}
    allowed_value: { value: "Both"}
  }

  set: detail {
    fields: [po_name, budget_amount, budget_remaining, selected_date_range_spend, pcnt_budget_remaining]
  }

  set: invoice_drill {
    fields: [
      po_spend_by_invoice_date_filter.po_name,
      po_spend_by_invoice_date_filter.invoice_no,
      po_spend_by_invoice_date_filter.billing_approved_date_date,
      po_spend_by_invoice_date_filter.billed_amount,
      po_spend_by_invoice_date_filter.budget_amount,
      po_spend_by_invoice_date_filter.budget_remaining,
      po_spend_by_invoice_date_filter.pcnt_budget_remaining]
  }
}
