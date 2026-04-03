include: "/_standard/analytics/commission/commission_details.layer.lkml"
include: "/_standard/es_warehouse/public/users.layer.lkml"
include: "/dashboards/commission_statement/commission_statement_access.view.lkml"
include: "/dashboards/commission_statement/commissions_time_series.view.lkml"
include: "/dashboards/commission_statement/tam_overrides.view.lkml"
include: "/dashboards/commission_statement/salesperson_type_invoice.view.lkml"

include: "/dashboards/commission_investigation/branch_rental_rates_historical.view.lkml"

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
    html:
          <a href='https://app.estrack.com/#/billing/{{ invoice_id | url_encode }}' target='_blank' style='color: blue; text-decoration: underline;'>{{ invoice_no._rendered_value }}</a>
          <br />

          <span style='color: #8C8C8C;'>Invoice ID: {{ invoice_id._rendered_value }}</span>
          <br />
          <span style='color: #8C8C8C;'>Salesperson Type: {{ salesperson_type_varchar._rendered_value }}</span>
          <br />
          <span style='color: #8C8C8C;'>List of Salesreps: {{ salesperson_type_invoice.salesrep_names._rendered_value }}</span>

          ;;
  }


  dimension: invoice_no_filter {
    sql: ${invoice_no} ;;
  }

  dimension: has_rental {
    type: yesno
    sql: ${rental_id} is not null ;;
  }

  dimension: lineitemid_w_link {
    label: "Line Item ID w Link"
    type: string

    sql: ${line_item_id} ;;

    link: {
      label: "Quote Rate Comparison Looker"
      url: "https://equipmentshare.looker.com/dashboards/2464?Line+Item+ID={{ line_item_id._value }}"
    }

  }



  dimension: order_id {
    type: number
    sql: ${order_id}  ;;
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

  dimension: floor_rate_link {
    label: "Floor Rate w Link"
    type: number
    sql: ${TABLE}.FLOOR_RATE ;;
    value_format_name: usd

    required_fields: [rental_class_id_from_rental, market_id]

    link: {
      label: "Historical Branch Rate Looker"
      url: "https://equipmentshare.looker.com/dashboards/2462?Equipment+Class+ID={{ rental_class_id_from_rental._value }}&Branch+ID={{ market_id._value }}&Rate+Type=Floor"
    }

  }

  dimension: benchmark_rate_link {
    label: "Benchmark Rate w Link"
    type: number
    sql: ${TABLE}.BENCHMARK_RATE ;;
    value_format_name: usd

    required_fields: [rental_class_id_from_rental, market_id]

    link: {
      label: "Historical Branch Rate Looker"
      url: "https://equipmentshare.looker.com/dashboards/2462?Equipment+Class+ID={{ rental_class_id_from_rental._value }}&Branch+ID={{ market_id._value }}&Rate+Type=Bench"

    }
  }

  dimension: book_rate_link {
    label: "Book Rate w Link"
    type: number
    sql: ${TABLE}.BOOK_RATE ;;
    value_format_name: usd

    required_fields: [rental_class_id_from_rental, market_id]

    link: {
      label: "Historical Branch Rate Looker"
      url: "https://equipmentshare.looker.com/dashboards/2462?Equipment+Class+ID={{ rental_class_id_from_rental._value }}&Branch+ID={{ market_id._value }}&Rate+Type=Book"

    }}


  dimension: floor_rate {
    label: "Floor Rate"
    type: number
    sql: ${TABLE}.FLOOR_RATE ;;
    value_format_name: usd

  }

  dimension: benchmark_rate {
      label: "Benchmark Rate"
      type: number
      sql: ${TABLE}.BENCHMARK_RATE ;;
      value_format_name: usd
    }

  dimension: book_rate {
      label: "Book Rate"
      type: number
      sql: ${TABLE}.BOOK_RATE ;;
      value_format_name: usd
    }


  dimension: commission_percentage {
    sql:
      case
        when ${is_override} then ${override_rate}
        else ${commission_rate}
      end ;;
    value_format_name: percent_0
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

explore: commission_statement {
  always_join: [commission_details,commission_statement_access]
  from: users
  view_label: "Users"
  case_sensitive: no
  sql_always_where: ${commission_details.hidden} = false and
  ('developer' = {{ _user_attributes['department'] }}
  OR TRIM('{{ _user_attributes['email'] | replace: "'", "\\'"}}')  = 'kelsey.mosley@equipmentshare.com'
  OR TRIM('{{ _user_attributes['email'] | replace: "'", "\\'"}}')  = 'beth.marlay@equipmentshare.com'
  OR (

  lower(TRIM('{{ _user_attributes['email'] | replace: "'", "\\'" }}')) IN (
    SELECT lower(cd.work_email)
    FROM analytics.payroll.pa_employee_access ca
    JOIN analytics.payroll.company_directory cd
      ON ca.employee_id = cd.employee_id
    WHERE manager_access_emails ilike 'william.woodruff@equipmentshare.com%'
      AND cd.employee_status NOT IN ('Inactive', 'Never Started', 'Not In Payroll', 'Terminated')
  )
  AND array_contains(
    'william.woodruff@equipmentshare.com'::VARIANT,
    ${commission_statement_access.manager_array}
  )
  )

  OR (
  lower(TRIM('{{ _user_attributes['email'] | replace: "'", "\\'" }}')) IN (
    SELECT lower(cd.work_email)
    FROM analytics.payroll.pa_employee_access ca
    JOIN analytics.payroll.company_directory cd
      ON ca.employee_id = cd.employee_id
    WHERE ca.manager_access_emails ilike 'daniel.weinshenker@equipmentshare.com%'
      AND cd.employee_status NOT IN ('Inactive', 'Never Started', 'Not In Payroll', 'Terminated')
  )
  AND array_contains(
    'daniel.weinshenker@equipmentshare.com'::VARIANT,
    ${commission_statement_access.manager_array}
  )
  )
  OR TRIM('{{ _user_attributes['email'] | replace: "'", "\\'"}}')  = 'dawn.pavlick@equipmentshare.com'
  OR TRIM('{{ _user_attributes['email'] | replace: "'", "\\'"}}')  = 'mark.wopata@equipmentshare.com'
  OR (${commission_details.email_address} =  LOWER('{{ _user_attributes['email'] }}') )
  OR array_contains (TRIM('{{ _user_attributes['email'] | replace: "'", "\\'"}}')::VARIANT, ${commission_statement_access.manager_array}))
  and ${company_id} = 1854 and ${deleted} = 'No' and ${employee_id} is not null;;

  join: commission_details {
    relationship: one_to_many
    type: left_outer
    sql_on: ${commission_statement.user_id} = ${commission_details.user_id} ;;
  }

  join: commission_statement_access {
    relationship: many_to_one
    type: left_outer
    sql_on: ${commission_details.user_id} = ${commission_statement_access.user_id};;
  }

  join: salesperson_type_invoice {
    relationship: many_to_many
    type: left_outer
    sql_on: ${commission_details.invoice_id} = ${salesperson_type_invoice.invoice_id} ;;
  }

  join: commissions_time_series {
    relationship:  many_to_one
    type: left_outer
    sql_on: ${commission_details.commission_month} = ${commissions_time_series.month_start} ;;
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
