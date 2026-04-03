include: "/_standard/analytics/commission/commission_details.layer.lkml"
include: "/_standard/es_warehouse/public/users.layer.lkml"
include: "/dashboards/commission_statement/commission_statement_access.view.lkml"
include: "/dashboards/commission_statement/tam_overrides.view.lkml"
include: "/dashboards/commission_statement/salesperson_type_invoice.view.lkml"
include: "/_standard/analytics/commission/employee_commission_info.layer.lkml"
include: "/dashboards/guarantees_to_revenue/date_scaffold.view.lkml"
include: "/_standard/custom_sql/date_start_month.view.lkml"


view: +commission_details {

  dimension: revenue_split_group {
    group_label: "Revenue Crosswalk"
    type: string
    sql: case when ${transaction_type} in ('commission','credit') and ${line_item_type_id} in (6,8,108,109)
         and ${salesperson_type_id} = 1 and ${split} = 1 then 'Rental'
         when ${transaction_type} in ('commission','credit') and ${line_item_type_id} in (6,8,108,109)
         and ${salesperson_type_id} = 1 and ${split} = .5 then 'Rental'
         when ${transaction_type} in ('commission','credit') and ${line_item_type_id} in (5,44)
         and ${salesperson_type_id} = 1 and ${split} = 1 then 'Ancillary'
         when ${transaction_type} in ('commission','credit') and ${line_item_type_id} in (5,44)
         and ${salesperson_type_id} = 1 and ${split} = .5 then 'Ancillary'
         when ${transaction_type} in ('commission','credit') and ${line_item_type_id} in (6,8,108,109)
         and ${salesperson_type_id} = 2 and ${split} <= .5 then 'Rental'
         when ${transaction_type} in ('commission','credit') and ${line_item_type_id} in (5,44)
         and ${salesperson_type_id} = 2 and ${split} <= .5 then 'Ancillary'
         else null end;;
  }
  dimension: revenue_split_desc {
    group_label: "Revenue Crosswalk"
    label: "Revenue Type/Description"
    type: string
    sql: case when ${transaction_type} in ('commission','credit') and ${line_item_type_id} in (6,8,108,109)
              and ${salesperson_type_id} = 1 and ${split} = 1 then 'Rental - Primary Rep, no Secondary Rep'
              when ${transaction_type} in ('commission','credit') and ${line_item_type_id} in (6,8,108,109)
              and ${salesperson_type_id} = 1 and ${split} = .5 then 'Rental - Primary Rep, with Secondary Rep'
              when ${transaction_type} in ('commission','credit') and ${line_item_type_id} in (5,44)
              and ${salesperson_type_id} = 1 and ${split} = 1 then 'Ancillary - Primary Rep, no Secondary Rep'
              when ${transaction_type} in ('commission','credit') and ${line_item_type_id} in (5,44)
              and ${salesperson_type_id} = 1 and ${split} = .5 then 'Ancillary - Primary Rep, with Secondary Rep'
              when ${transaction_type} in ('commission','credit') and ${line_item_type_id} in (6,8,108,109)
              and ${salesperson_type_id} = 2 and ${split} <= .5 then 'Rental - Secondary Rep'
              when ${transaction_type} in ('commission','credit') and ${line_item_type_id} in (5,44)
              and ${salesperson_type_id} = 2 and ${split} <= .5 then 'Ancillary - Secondary Rep (not currently on Salesperson DB)'
              else null end;;
    order_by_field: custom_order
  }
  dimension: commission_split {
    group_label: "Revenue Crosswalk"
    label: "Expected Commission Split (B)"
    type: string
    sql: case when ${transaction_type} in ('commission','credit') and ${line_item_type_id} in (6,8,108,109)
              and ${salesperson_type_id} = 1 and ${split} = 1 then '100%'
              when ${transaction_type} in ('commission','credit') and ${line_item_type_id} in (6,8,108,109)
              and ${salesperson_type_id} = 1 and ${split} = .5 then '50%'
              when ${transaction_type} in ('commission','credit') and ${line_item_type_id} in (5,44)
              and ${salesperson_type_id} = 1 and ${split} = 1 then '100%'
              when ${transaction_type} in ('commission','credit') and ${line_item_type_id} in (5,44)
              and ${salesperson_type_id} = 1 and ${split} = .5 then '50%'
              when ${transaction_type} in ('commission','credit') and ${line_item_type_id} in (6,8,108,109)
              and ${salesperson_type_id} = 2 and ${split} <= .5 then '50% (or less if multiple secondary reps)'
              when ${transaction_type} in ('commission','credit') and ${line_item_type_id} in (5,44)
              and ${salesperson_type_id} = 2 and ${split} <= .5 then '50% (or less if multiple secondary reps)'
              else null end;;
  }
  dimension: custom_order {
    type: number
    sql: case
          when ${revenue_split_desc} = 'Rental - Primary Rep, no Secondary Rep' then 1
          when ${revenue_split_desc} = 'Rental - Primary Rep, with Secondary Rep' then 2
          when ${revenue_split_desc} = 'Ancillary - Primary Rep, no Secondary Rep' then 3
          when ${revenue_split_desc} = 'Ancillary - Primary Rep, with Secondary Rep' then 4
          when ${revenue_split_desc} = 'Rental - Secondary Rep' then 5
          else 6
          end;;
    hidden: yes
    description: "This dimension is used to force sort on the dashboard."
  }
  measure: sales_db_revenue {
    label: "Line Item Total Amount (A)"
    type: sum
    sql: ${line_item_amount} ;;
    value_format_name: usd_0
  }

  dimension: company_name {
    html: <font style="color: #000000; text-align: right;">{{company_name._rendered_value}} </font>
          <br />
          <font style="color: #8C8C8C; text-align: right;">ID: {{company_id._rendered_value}} </font>
          ;;
  }

  dimension: invoice_no {
    label: "Invoice Details"
    html: <font style="color: #000000; text-align: right;">{{invoice_no._rendered_value}} </font>
          <br />
          <font style="color: #8C8C8C; text-align: right;">Invoice ID: {{invoice_id._rendered_value}} </font>
          <br />
          <font style="color: #8C8C8C; text-align: right;">Salesperson Type: {{salesperson_type_varchar._rendered_value}} </font>
          <br />
        <font style="color: #8C8C8C; text-align: right;">List of Salesreps: {{salesperson_type_invoice.salesrep_names._rendered_value}}</font>

      ;;
  }

  dimension: invoice_no_filter {
    sql: ${invoice_no} ;;
  }

  dimension: has_rental {
    type: yesno
    sql: ${rental_id} is not null ;;
  }

  dimension: order_id {
    label: "Order Details"
    html:
        {% if has_rental._rendered_value == 'Yes' %}
        <font style="color: #000000; text-align: left;">Order ID: {{order_id._rendered_value}} </font>
        <br />
        <font style="color: #8C8C8C; text-align: left;">Order Date Created: {{order_date._rendered_value}} </font>
        <br />
        <font style="color: #000000; text-align: left;">Rental ID: {{rental_id._value}} </font>
        <br />
        <font style="color: #8C8C8C; text-align: left;">Rental Date Created: {{rental_date._rendered_value}} </font>
        {% else %}
        <font style="color: #000000; text-align: left;">Order ID: {{order_id._rendered_value}} </font>
        <br />
        <font style="color: #8C8C8C; text-align: left;">Order Date Created: {{order_date._rendered_value}} </font>
        {% endif %}
    ;;
  }

  dimension: substitution {
    type: yesno
    sql: ${invoice_class_id} != ${rental_class_id_from_rental};;
  }

  dimension: asset_id {
    label: "Asset Details"
    html:
        {% if substitution._rendered_value == 'Yes' %}
        <font style="color: #000000; text-align: left;">Asset ID: {{asset_id._rendered_value}} (Substitution) </font>
        {% else %}
        <font style="color: #000000; text-align: left;">Asset ID: {{asset_id._rendered_value}} </font>
        {% endif %}
        <br />
        <font style="color: #8C8C8C; text-align: left;">Class: {{equipment_class_id._rendered_value}} - {{rental_class_from_line_item._rendered_value}} </font>
        <br />
        <font style="color: #8C8C8C; text-align: left;">Quoted Rates: {{quoted_rates._rendered_value}} </font>

      ;;
  }


  dimension: line_item_type {
    label: "Line Item Details"
    html:
        <font style="color: #000000; text-align: left;">{{line_item_type._rendered_value}} </font>
        <br />
        <font style="color: #8C8C8C; text-align: left;">Line Item ID: {{line_item_id._rendered_value}} </font>
        <br />
        {% if line_item_type_id._value == 49 %}
        <p style="color: #8C8C8C; text-align: left;">Margin: ${{amount._rendered_value}} </p>
        {% else %}
        <font style="color: #8C8C8C; text-align: left;">Line Item Amount: ${{amount._rendered_value}} </font>
        {% endif %}
    ;;
  }

  dimension: line_item_type_filter {
    sql: ${line_item_type} ;;
  }

  dimension: commission_percentage {
    html:
        {% if is_override._rendered_value == 'Yes' %}
        <font style="color: #000000; text-align: right;">{{override_rate._rendered_value}} </font>
        <br />
        <p style="color: #8C8C8C; text-align: right;">Override Rate </p>
        {% else %}
        <font style="color: #000000; text-align: right;">{{commission_percentage._rendered_value}} </font>
        {% endif %}
    ;;
  }

  dimension: transaction_description_stmt {
    label: "Transaction Details"
    html:
        <font style="color: #000000; text-align: left;">{{transaction_description_stmt._rendered_value}} </font>
        <br />
        <font style="color: #8C8C8C; text-align: left;">Split: {{split._rendered_value}} </font>
    ;;
  }



}

view: +employee_commission_info {
  measure: unique_userid {
    type: count_distinct
    sql: ${user_id};;
  }


  }

explore: employee_commission_info {

  label: "guarantees to revenue"


  join: commission_details {
    relationship: many_to_many
    type: left_outer
    sql_on: ${commission_details.user_id} = ${employee_commission_info.user_id}  ;;
  }


  join: salesperson_type_invoice {
    relationship: many_to_many
    type: left_outer
    sql_on: ${commission_details.invoice_id} = ${salesperson_type_invoice.invoice_id} ;;
  }

  join: date_scaffold {
    type: cross
    sql_on: 1=1 ;;
    relationship: many_to_many
  }
}

explore: date_start_month{


  join: employee_commission_info {
    relationship: many_to_many
    type: left_outer
    sql_on:  ${employee_commission_info.guarantee_start_month} <= ${date_start_month.date_record_date}
          AND ${employee_commission_info.guarantee_end_month} >= ${date_start_month.date_record_date}
            ;;
  }

  join: commission_details {
    relationship: many_to_many
    type: left_outer
    sql_on: ${commission_details.commission_month_month} = ${date_start_month.date_record_month} ;;
  }


}

explore: tam_override_details {
  always_join: [commission_statement_access]
  from: users
  view_label: "Users"
  case_sensitive: no
  sql_always_where: ('developer' = {{ _user_attributes['department'] }}
      OR TRIM('{{ _user_attributes['email'] | replace: "'", "\\'"}}')  = 'kelsey.mosley@equipmentshare.com'
      OR TRIM('{{ _user_attributes['email'] | replace: "'", "\\'"}}')  = 'beth.marlay@equipmentshare.com'
      OR TRIM('{{ _user_attributes['email'] | replace: "'", "\\'"}}')  = 'dawn.pavlick@equipmentshare.com'
      OR (${tam_overrides.requestor_email} =  LOWER('{{ _user_attributes['email'] }}') )
      OR array_contains (TRIM('{{ _user_attributes['email'] | replace: "'", "\\'"}}')::VARIANT, ${commission_statement_access.manager_array}))
      and ${company_id} = 1854 and ${deleted} = 'No' and ${employee_id} is not null;;

  join: tam_overrides {
    relationship: one_to_many
    type: left_outer
    sql_on: ${tam_override_details.user_id} = ${tam_overrides.requestor_user_id} ;;
  }

  join: commission_statement_access {
    relationship: many_to_one
    type: left_outer
    sql_on: ${tam_overrides.requestor_user_id} = ${commission_statement_access.user_id} ;;
  }

}
