
view: prior_vs_this_year_esmax {
  derived_table: {
    sql: with current_total_amount as (
                SELECT
           i.SALESPERSON_USER_ID as salesperson_id,
           concat(u.FIRST_NAME, ' ', u.LAST_NAME) as salesperson_full_name,
           xw.DISTRICT as district,
           xw.REGION_NAME as region,
           sum(li.AMOUNT) as total_amount,
           count(distinct r.RENTAL_ID) as total_count_of_rentals,
           date_trunc(month, li.GL_BILLING_APPROVED_DATE) as billing_approved_month
                   FROM es_warehouse.public.invoices i
                          LEFT JOIN analytics.public.v_line_items li
                          ON i.invoice_id = li.invoice_id
                          LEFT JOIN es_warehouse.public.approved_invoice_salespersons ais
                          ON i.invoice_id = ais.invoice_id
                          LEFT JOIN es_warehouse.public.orders o
                          ON i.order_id = o.order_id
                          LEFT JOIN es_warehouse.public.rentals r
                          ON i.order_id = r.order_id AND li.asset_id = r.asset_id and li.rental_id = r.rental_id
                          LEFT JOIN analytics.public.rateachievement_points ra
                          ON li.rental_id = ra.rental_id AND i.invoice_id = ra.invoice_id AND li.asset_id = ra.asset_id
                          LEFT JOIN es_warehouse.public.users u
                          on u.user_id = i.salesperson_user_id
                          LEFT JOIN ANALYTICS.PAYROLL.COMPANY_DIRECTORY cd
                          on cd.EMPLOYEE_ID = try_to_number(u.EMPLOYEE_ID)
                          LEFT JOIN ANALYTICS.PUBLIC.MARKET_REGION_XWALK xw
                          on xw.MARKET_ID = cd.MARKET_ID
                   WHERE li.GL_BILLING_APPROVED_DATE BETWEEN '05/01/2022' AND '12/31/2023'
                        AND i.company_id not in (1854,1855,8151,155)
                        AND li.LINE_ITEM_TYPE_ID in (8,6,108,109)
                        and cast(cd.DATE_HIRED as DATE) <= '2022-05-01'
                        and case when cast(cd.DATE_TERMINATED as DATE) <= '2023-12-31' then 1 else 0 end = 0
                        and li.amount > 0
       group by
           i.SALESPERSON_USER_ID,
           concat(u.FIRST_NAME, ' ', u.LAST_NAME),
           cd.MARKET_ID,
           xw.MARKET_NAME,
           xw.DISTRICT,
           xw.REGION_NAME,
           date_trunc(month, li.GL_BILLING_APPROVED_DATE)
            ),
above_online as (
                SELECT
           i.SALESPERSON_USER_ID as salesperson_id,
           sum(li.AMOUNT) as above_online_billing_approved,
           count(distinct r.RENTAL_ID) as total_count_of_rentals_above,
           date_trunc(month, li.GL_BILLING_APPROVED_DATE) as billing_approved_month
                   FROM es_warehouse.public.invoices i
                          LEFT JOIN analytics.public.v_line_items li
                          ON i.invoice_id = li.invoice_id
                          LEFT JOIN es_warehouse.public.approved_invoice_salespersons ais
                          ON i.invoice_id = ais.invoice_id
                          LEFT JOIN es_warehouse.public.orders o
                          ON i.order_id = o.order_id
                          LEFT JOIN es_warehouse.public.rentals r
                          ON i.order_id = r.order_id AND li.asset_id = r.asset_id and li.rental_id = r.rental_id
                          LEFT JOIN analytics.public.rateachievement_points ra
                          ON li.rental_id = ra.rental_id AND i.invoice_id = ra.invoice_id AND li.asset_id = ra.asset_id
                          LEFT JOIN es_warehouse.public.users u
                          on u.user_id = i.salesperson_user_id
                          LEFT JOIN ANALYTICS.PAYROLL.COMPANY_DIRECTORY cd
                          on cd.EMPLOYEE_ID = try_to_number(u.EMPLOYEE_ID)
                          LEFT JOIN ANALYTICS.PUBLIC.MARKET_REGION_XWALK xw
                          on xw.MARKET_ID = cd.MARKET_ID
                   WHERE li.GL_BILLING_APPROVED_DATE BETWEEN '05/01/2022' AND '12/31/2023'
                        AND i.company_id not in (1854,1855,8151,155)
                        AND li.LINE_ITEM_TYPE_ID in (8,6,108,109)
                        and cast(cd.DATE_HIRED as DATE) <= '2022-05-01'
                        and case when cast(cd.DATE_TERMINATED as DATE) <= '2023-12-31' then 1 else 0 end = 0
                        and RATE_TIER = 1
                        and li.amount > 0
       group by
           i.SALESPERSON_USER_ID,
           concat(u.FIRST_NAME, ' ', u.LAST_NAME),
           date_trunc(month, li.GL_BILLING_APPROVED_DATE)
      ),
between_floor as (
                SELECT
           i.SALESPERSON_USER_ID as salesperson_id,
           sum(li.AMOUNT) as between_floor_billing_approved,
           count(distinct r.RENTAL_ID) as total_count_of_rentals_between,
           date_trunc(month, li.GL_BILLING_APPROVED_DATE) as billing_approved_month
                   FROM es_warehouse.public.invoices i
                          LEFT JOIN analytics.public.v_line_items li
                          ON i.invoice_id = li.invoice_id
                          LEFT JOIN es_warehouse.public.approved_invoice_salespersons ais
                          ON i.invoice_id = ais.invoice_id
                          LEFT JOIN es_warehouse.public.orders o
                          ON i.order_id = o.order_id
                          LEFT JOIN es_warehouse.public.rentals r
                          ON i.order_id = r.order_id AND li.asset_id = r.asset_id and li.rental_id = r.rental_id
                          LEFT JOIN analytics.public.rateachievement_points ra
                          ON li.rental_id = ra.rental_id AND i.invoice_id = ra.invoice_id AND li.asset_id = ra.asset_id
                          LEFT JOIN es_warehouse.public.users u
                          on u.user_id = i.salesperson_user_id
                          LEFT JOIN ANALYTICS.PAYROLL.COMPANY_DIRECTORY cd
                          on cd.EMPLOYEE_ID = try_to_number(u.EMPLOYEE_ID)
                          LEFT JOIN ANALYTICS.PUBLIC.MARKET_REGION_XWALK xw
                          on xw.MARKET_ID = cd.MARKET_ID
                   WHERE li.GL_BILLING_APPROVED_DATE BETWEEN '05/01/2022' AND '12/31/2023'
                        AND i.company_id not in (1854,1855,8151,155)
                        AND li.LINE_ITEM_TYPE_ID in (8,6,108,109)
                        and cast(cd.DATE_HIRED as DATE) <= '2022-05-01'
                        and case when cast(cd.DATE_TERMINATED as DATE) <= '2023-12-31' then 1 else 0 end = 0
                        and (RATE_TIER in (0,2) or RATE_TIER is null)
                        and li.amount > 0
       group by
           i.SALESPERSON_USER_ID,
           concat(u.FIRST_NAME, ' ', u.LAST_NAME),
           date_trunc(month, li.GL_BILLING_APPROVED_DATE)
      ),
below_floor as (
                SELECT
           i.SALESPERSON_USER_ID as salesperson_id,
           sum(li.AMOUNT) as below_floor_billing_approved,
           count(distinct r.RENTAL_ID) as total_count_of_rentals_below,
           date_trunc(month, GL_BILLING_APPROVED_DATE) as billing_approved_month
                   FROM es_warehouse.public.invoices i
                          LEFT JOIN analytics.public.v_line_items li
                          ON i.invoice_id = li.invoice_id
                          LEFT JOIN es_warehouse.public.approved_invoice_salespersons ais
                          ON i.invoice_id = ais.invoice_id
                          LEFT JOIN es_warehouse.public.orders o
                          ON i.order_id = o.order_id
                          LEFT JOIN es_warehouse.public.rentals r
                          ON i.order_id = r.order_id AND li.asset_id = r.asset_id and li.rental_id = r.rental_id
                          LEFT JOIN analytics.public.rateachievement_points ra
                          ON li.rental_id = ra.rental_id AND i.invoice_id = ra.invoice_id AND li.asset_id = ra.asset_id
                          LEFT JOIN es_warehouse.public.users u
                          on u.user_id = i.salesperson_user_id
                          LEFT JOIN ANALYTICS.PAYROLL.COMPANY_DIRECTORY cd
                          on cd.EMPLOYEE_ID = try_to_number(u.EMPLOYEE_ID)
                          LEFT JOIN ANALYTICS.PUBLIC.MARKET_REGION_XWALK xw
                          on xw.MARKET_ID = cd.MARKET_ID
                   WHERE li.GL_BILLING_APPROVED_DATE BETWEEN '05/01/2022' AND '12/31/2023'
                        AND i.company_id not in (1854,1855,8151,155)
                        AND li.LINE_ITEM_TYPE_ID in (8,6,108,109)
                        and cast(cd.DATE_HIRED as DATE) <= '2022-05-01'
                        and case when cast(cd.DATE_TERMINATED as DATE) <= '2023-12-31' then 1 else 0 end = 0
                        and RATE_TIER = 3
                        and li.amount > 0
       group by
           i.SALESPERSON_USER_ID,
           concat(u.FIRST_NAME, ' ', u.LAST_NAME),
           date_trunc(month, li.GL_BILLING_APPROVED_DATE)
            ),
first_quote_date_filter as (
    select sales_rep_id,
           min(created_date) as first_quote_date
    from QUOTES.QUOTES.QUOTE
    group by sales_rep_id
)
            select ci.salesperson_id,
             ci.salesperson_full_name,
             ci.billing_approved_month,
             ci.total_amount,
             ci.total_count_of_rentals,
             ao.total_count_of_rentals_above,
             bef.total_count_of_rentals_between,
             bf.total_count_of_rentals_below,
             ci.district,
             ci.region,
             ao.above_online_billing_approved as above_online_billing,
             bef.between_floor_billing_approved as between_floor_billing,
             bf.below_floor_billing_approved as below_floow_billing,
             case when ci.billing_approved_month between '05/01/2022' AND '12/31/2022' THEN 'Prior Year'
                 when ci.billing_approved_month between '05/01/2023' AND '12/31/2023' THEN 'Current Year' end as year_flag
      from current_total_amount ci
          left join above_online ao
          on ao.salesperson_id = ci.salesperson_id and ao.billing_approved_month = ci.billing_approved_month
          left join between_floor bef
          on bef.salesperson_id = ci.salesperson_id and bef.billing_approved_month = ci.billing_approved_month
          left join below_floor bf
          on bf.salesperson_id = ci.salesperson_id and bf.billing_approved_month = ci.billing_approved_month
          left join first_quote_date_filter fqdf
          on fqdf.sales_rep_id = ci.salesperson_id
      where year_flag is not null
      and total_amount > 0
      and region is not null
      and first_quote_date < '06/01/2023'
      ;;
  }

  dimension: salesperson_id {
    type: number
    sql: ${TABLE}."SALESPERSON_ID" ;;
  }

  dimension: salesperson_full_name {
    type: string
    label: "Salesperson"
    sql: ${TABLE}."SALESPERSON_FULL_NAME" ;;
  }

  dimension: billing_approved_month {
    type: date_time
    primary_key: yes
    sql: ${TABLE}."BILLING_APPROVED_MONTH" ;;
  }

  dimension: total_amount {
    type: number
    sql: ${TABLE}."TOTAL_AMOUNT" ;;
  }

  dimension: total_count_of_rentals {
    type: number
    sql: ${TABLE}."TOTAL_COUNT_OF_RENTALS" ;;
  }

  dimension: total_count_of_above_rentals {
    type: number
    sql: ${TABLE}."TOTAL_COUNT_OF_RENTALS_ABOVE" ;;
  }

  dimension: total_count_of_between_rentals {
    type: number
    sql: ${TABLE}."TOTAL_COUNT_OF_RENTALS_BETWEEN" ;;
  }

  dimension: total_count_of_below_rentals {
    type: number
    sql: ${TABLE}."TOTAL_COUNT_OF_RENTALS_BELOW" ;;
  }

  dimension: above_online_billing {
    type: number
    sql: ${TABLE}."ABOVE_ONLINE_BILLING" ;;
  }

  dimension: between_floor_billing {
    type: number
    sql: ${TABLE}."BETWEEN_FLOOR_BILLING" ;;
  }

  dimension: below_floow_billing {
    type: number
    sql: ${TABLE}."BELOW_FLOOW_BILLING" ;;
  }

  dimension: year_flag {
    type: string
    sql: ${TABLE}."YEAR_FLAG" ;;
  }

  dimension: region {
    type: string
    sql: ${TABLE}."REGION" ;;
  }

  dimension: district {
    type: string
    sql: ${TABLE}."DISTRICT" ;;
  }

  measure: above {
    type: sum
    sql: ${above_online_billing} ;;
  }

  measure: between {
    type: sum
    sql: ${between_floor_billing} ;;
  }

  measure: below {
    type: sum
    sql: ${below_floow_billing} ;;
  }

  measure: total_count_of_rentals_above {
    type: sum
    sql: ${total_count_of_above_rentals} ;;
  }

  measure: total_count_of_rentals_between {
    type: sum
    sql: ${total_count_of_between_rentals} ;;
  }

  measure: total_count_of_rentals_below {
    type: sum
    sql: ${total_count_of_below_rentals} ;;
  }

  measure: average_above {
    type: number
    sql: ${above}/${count_months} ;;
    value_format_name: usd
  }

  measure: average_between {
    type: number
    sql: ${between}/${count_months} ;;
    value_format_name: usd
  }

  measure: average_below {
    type: number
    sql: ${below}/${count_months} ;;
    value_format_name: usd
  }

  measure: total_spend {
    type: sum
    sql: ${total_amount} ;;
  }

  measure: total_rental_contracts {
    type: sum
    sql: ${total_count_of_rentals} ;;
  }

  measure: average_rental_spend {
    type: number
    sql: ${total_spend}/${total_rental_contracts} ;;
    value_format_name: usd_0
    drill_fields: [avg_drill*]
  }

  measure: prior_average_rental_spend {
    type: number
    sql: ${prior_total_spend}/case when ${prior_total_rental_contracts} = 0 then null else ${prior_total_rental_contracts} end ;;
    value_format_name: usd_0
    drill_fields: [avg_drill*]

  }

  measure: current_average_rental_spend {
    type: number
    sql: ${current_total_spend}/case when ${current_total_rental_contracts} = 0 then null else ${current_total_rental_contracts} end ;;
    value_format_name: usd_0
    drill_fields: [avg_drill*]
  }

  measure: avg_rental_spend_change {
    type: number
    sql: ${current_average_rental_spend} - ${prior_average_rental_spend} ;;
    value_format_name: usd_0
  }

  measure: prior_total_spend {
    type: sum
    sql: ${total_amount} ;;
    filters: [year_flag: "Prior Year"]
  }

  measure: current_total_spend {
    type: sum
    sql: ${total_amount} ;;
    filters: [year_flag: "Current Year"]
  }

  measure: prior_total_rental_contracts {
    type: sum
    sql: ${total_count_of_rentals} ;;
    filters: [year_flag: "Prior Year"]
  }

  measure: current_total_rental_contracts {
    type: sum
    sql: ${total_count_of_rentals} ;;
    filters: [year_flag: "Current Year"]
  }


  ## These are all needed for the percentage difference
  measure: above_online_prior {
    type: sum
    sql: ${above_online_billing} ;;
    filters: [year_flag: "Prior Year"]
  }

  measure: between_floor_prior {
    type: sum
    sql: ${between_floor_billing} ;;
    filters: [year_flag: "Prior Year"]
  }

  measure: below_floor_prior {
    type: sum
    sql: ${below_floow_billing} ;;
    filters: [year_flag: "Prior Year"]
  }

  measure: above_online_current {
    type: sum
    sql: ${above_online_billing} ;;
    filters: [year_flag: "Current Year"]
  }

  measure: between_floor_current {
    type: sum
    sql: ${between_floor_billing} ;;
    filters: [year_flag: "Current Year"]
  }

  measure: below_floor_current {
    type: sum
    sql: ${below_floow_billing} ;;
    filters: [year_flag: "Current Year"]
  }

  measure: above_rental_count_prior {
    type: sum
    sql: ${total_count_of_above_rentals};;
    filters: [year_flag: "Prior Year"]
  }

  measure: between_rental_count_prior {
    type: sum
    sql: ${total_count_of_between_rentals};;
    filters: [year_flag: "Prior Year"]
  }

  measure: below_rental_count_prior {
    type: sum
    sql: ${total_count_of_below_rentals};;
    filters: [year_flag: "Prior Year"]
  }

  measure: above_rental_count_current {
    type: sum
    sql: ${total_count_of_above_rentals};;
    filters: [year_flag: "Current Year"]
  }

  measure: between_rental_count_current {
    type: sum
    sql: ${total_count_of_between_rentals};;
    filters: [year_flag: "Current Year"]
  }

  measure: below_rental_count_current {
    type: sum
    sql: ${total_count_of_below_rentals};;
    filters: [year_flag: "Current Year"]
  }

  measure: above_percent_diff {
    label: "Change in Above Online Billing"
    type: number
    sql: (${above_online_current}-${above_online_prior})/case when ${above_online_prior} = 0 then null else ${above_online_prior} end ;;
    html:
    {% if above_percent_diff._value > 0 %}

    {% assign indicator = "green,▲" | split: ',' %}

    {% elsif above_percent_diff._value < 0 %}

    {% assign indicator = "red,▼" | split: ',' %}

    {% else %}

    {% endif %}

    <font color="{{indicator[0]}}">

    {% if value == 99999.12345 %} &infin

    {% else %}({{ above_percent_diff._rendered_value }})

    {% endif %} {{indicator[1]}}

    </font>;;
    value_format_name: percent_1
  }

  measure: between_percent_diff {
    label: "Change in Between Floor Billing"
    type: number
    sql: (${between_floor_current}-${between_floor_prior})/case when ${between_floor_prior} = 0 then null else ${between_floor_prior} end ;;
    html:
    {% if between_percent_diff._value > 0 %}

    {% assign indicator = "green,▲" | split: ',' %}

    {% elsif between_percent_diff._value < 0 %}

    {% assign indicator = "red,▼" | split: ',' %}

    {% else %}

    {% endif %}

    <font color="{{indicator[0]}}">

    {% if value == 99999.12345 %} &infin

    {% else %}({{ between_percent_diff._rendered_value }})

    {% endif %} {{indicator[1]}}

    </font>;;
    value_format_name: percent_1
  }

  measure: below_percent_diff {
    label: "Change in Below Floor Billing"
    type: number
    sql: (${below_floor_current}-${below_floor_prior})/case when ${below_floor_prior} = 0 then null else ${below_floor_prior} end ;;
    html:
    {% if below_percent_diff._value > 0 %}

    {% assign indicator = "green,▲" | split: ',' %}

    {% elsif below_percent_diff._value < 0 %}

    {% assign indicator = "red,▼" | split: ',' %}

    {% else %}

    {% endif %}

    <font color="{{indicator[0]}}">

    {% if value == 99999.12345 %} &infin

    {% else %}({{ below_percent_diff._rendered_value }})

    {% endif %} {{indicator[1]}}

    </font>;;
    value_format_name: percent_1
  }

  measure: above_rental_count_percent_diff {
    label: "Change in Above Rental Contracts"
    type: number
    sql: (${above_rental_count_current}-${above_rental_count_prior})/case when ${above_rental_count_prior} = 0 then null else ${above_rental_count_prior} end ;;
    html:
    {% if above_rental_count_percent_diff._value > 0 %}

          {% assign indicator = "green,▲" | split: ',' %}

      {% elsif above_rental_count_percent_diff._value < 0 %}

      {% assign indicator = "red,▼" | split: ',' %}

      {% else %}

      {% endif %}

      <font color="{{indicator[0]}}">

      {% if value == 99999.12345 %} &infin

      {% else %}({{ above_rental_count_percent_diff._rendered_value }})

      {% endif %} {{indicator[1]}}

      </font>;;
    value_format_name: percent_1
  }

  measure: between_rental_count_percent_diff {
    label: "Change in Between Floor Rental Contracts"
    type: number
    sql: (${between_rental_count_current}-${between_rental_count_prior})/case when ${between_rental_count_prior} = 0 then null else ${between_rental_count_prior} end ;;
    html:
    {% if between_rental_count_percent_diff._value > 0 %}

          {% assign indicator = "green,▲" | split: ',' %}

      {% elsif between_rental_count_percent_diff._value < 0 %}

      {% assign indicator = "red,▼" | split: ',' %}

      {% else %}

      {% endif %}

      <font color="{{indicator[0]}}">

      {% if value == 99999.12345 %} &infin

      {% else %}({{ between_rental_count_percent_diff._rendered_value }})

      {% endif %} {{indicator[1]}}

      </font>;;
    value_format_name: percent_1
  }

  measure: below_rental_count_percent_diff {
    label: "Change in Below Floor Rental Contracts"
    type: number
    sql: (${below_rental_count_current}-${below_rental_count_prior})/case when ${below_rental_count_prior} = 0 then null else ${below_rental_count_prior} end ;;
    html:
    {% if below_rental_count_percent_diff._value > 0 %}

          {% assign indicator = "green,▲" | split: ',' %}

      {% elsif below_rental_count_percent_diff._value < 0 %}

      {% assign indicator = "red,▼" | split: ',' %}

      {% else %}

      {% endif %}

      <font color="{{indicator[0]}}">

      {% if value == 99999.12345 %} &infin

      {% else %}({{ below_rental_count_percent_diff._rendered_value }})

      {% endif %} {{indicator[1]}}

      </font>;;
    value_format_name: percent_1
  }

  measure: count_months {
    type: count_distinct
    sql: ${billing_approved_month} ;;
  }

  # measure: case_flag {
  #   type: number
  #   sql: case when ${between_floor_prior} > 0 and ${above_online_prior} > 0 or ${below_floor_prior} > 0 then 1 else 0 end;;
  #   }

  measure: more_than_one_percent_revenue{
    type: number
    sql: case when ${above_percent_diff} is null and ${between_percent_diff} is null or ${below_percent_diff} is null then 0 else 1 end ;;
  }

  measure: more_than_one_percent_rentals{
    type: number
    sql: case when ${above_rental_count_percent_diff} is null and ${between_rental_count_percent_diff} is null or ${below_rental_count_percent_diff} is null then 0 else 1 end ;;
  }

  measure: prior_total_count_of_rentals_above {
    type: sum
    sql: ${total_count_of_above_rentals} ;;
    filters: [year_flag: "Prior Year"]
  }

  measure: prior_total_count_of_rentals_between {
    type: sum
    sql: ${total_count_of_between_rentals} ;;
    filters: [year_flag: "Prior Year"]
  }

  measure: prior_total_count_of_rentals_below {
    type: sum
    sql: ${total_count_of_below_rentals} ;;
    filters: [year_flag: "Prior Year"]
  }

  measure: current_total_count_of_rentals_above {
    type: sum
    sql: ${total_count_of_above_rentals} ;;
    filters: [year_flag: "Current Year"]
  }

  measure: current_total_count_of_rentals_between {
    type: sum
    sql: ${total_count_of_between_rentals} ;;
    filters: [year_flag: "Current Year"]
  }

  measure: current_total_count_of_rentals_below {
    type: sum
    sql: ${total_count_of_below_rentals} ;;
    filters: [year_flag: "Current Year"]
  }


  ############################################################Dynamic Measures############################################################

  parameter: show_revenue_rental_counts {
    type: string
    allowed_value: { value: "Average Revenue"}
    allowed_value: { value: "Rental Count"}
  }

  measure: dynamic_above_totals {
    label_from_parameter: show_revenue_rental_counts
    group_label: "Dynamic KPI"
    sql:{% if show_revenue_rental_counts._parameter_value == "'Average Revenue'" %}
      ${average_above}
    {% elsif show_revenue_rental_counts._parameter_value == "'Rental Count'" %}
      ${total_count_of_rentals_above}
    {% else %}
      NULL
    {% endif %} ;;
    html:
    {% if show_revenue_rental_counts._parameter_value == "'Average Revenue'" %}
    ${{ rendered_value }}
    {% elsif show_revenue_rental_counts._parameter_value == "'Rental Count'" %}
    {{ rendered_value }}
    {% else %}
    {{ rendered_value }}
    {% endif %};;
    value_format_name: decimal_0
  }

  measure: dynamic_between_totals {
    group_label: "Dynamic KPI"
    label_from_parameter: show_revenue_rental_counts
    sql:{% if show_revenue_rental_counts._parameter_value == "'Average Revenue'" %}
      ${average_between}
    {% elsif show_revenue_rental_counts._parameter_value == "'Rental Count'" %}
      ${total_count_of_rentals_between}
    {% else %}
      NULL
    {% endif %} ;;
    html:
    {% if show_revenue_rental_counts._parameter_value == "'Average Revenue'" %}
    ${{ rendered_value }}
    {% elsif show_revenue_rental_counts._parameter_value == "'Rental Count'" %}
    {{ rendered_value }}
    {% else %}
    {{ rendered_value }}
    {% endif %};;
    value_format_name: decimal_0
  }

  measure: dynamic_below_totals {
    group_label: "Dynamic KPI"
    label_from_parameter: show_revenue_rental_counts
    sql:{% if show_revenue_rental_counts._parameter_value == "'Average Revenue'" %}
      ${average_below}
    {% elsif show_revenue_rental_counts._parameter_value == "'Rental Count'" %}
      ${total_count_of_rentals_below}
    {% else %}
      NULL
    {% endif %} ;;
    html:
    {% if show_revenue_rental_counts._parameter_value == "'Average Revenue'" %}
    ${{ rendered_value }}
    {% elsif show_revenue_rental_counts._parameter_value == "'Rental Count'" %}
    {{ rendered_value }}
    {% else %}
    {{ rendered_value }}
    {% endif %};;
    value_format_name: decimal_0
  }

  measure: dynamic_prior_above {
    group_label: "Dynamic Prior"
    label_from_parameter: show_revenue_rental_counts
    type: number
    sql:{% if show_revenue_rental_counts._parameter_value == "'Average Revenue'" %}
      ${above_online_prior}
    {% elsif show_revenue_rental_counts._parameter_value == "'Rental Count'" %}
      ${prior_total_count_of_rentals_above}
    {% else %}
      NULL
    {% endif %} ;;
  }

  measure: dynamic_prior_between {
    group_label: "Dynamic Prior"
    label_from_parameter: show_revenue_rental_counts
    type: number
    sql:{% if show_revenue_rental_counts._parameter_value == "'Average Revenue'" %}
      ${between_floor_prior}
    {% elsif show_revenue_rental_counts._parameter_value == "'Rental Count'" %}
      ${prior_total_count_of_rentals_between}
    {% else %}
      NULL
    {% endif %} ;;
  }

  measure: dynamic_prior_below {
    group_label: "Dynamic Prior"
    label_from_parameter: show_revenue_rental_counts
    type: number
    sql:{% if show_revenue_rental_counts._parameter_value == "'Average Revenue'" %}
      ${below_floor_prior}
    {% elsif show_revenue_rental_counts._parameter_value == "'Rental Count'" %}
      ${prior_total_count_of_rentals_below}
    {% else %}
      NULL
    {% endif %} ;;
  }

  measure: dynamic_current_above {
    group_label: "Dynamic Current"
    label_from_parameter: show_revenue_rental_counts
    type: number
    sql:{% if show_revenue_rental_counts._parameter_value == "'Average Revenue'" %}
      ${above_online_current}
    {% elsif show_revenue_rental_counts._parameter_value == "'Rental Count'" %}
      ${current_total_count_of_rentals_above}
    {% else %}
      NULL
    {% endif %} ;;
  }

  measure: dynamic_current_between {
    group_label: "Dynamic Current"
    label_from_parameter: show_revenue_rental_counts
    type: number
    sql:{% if show_revenue_rental_counts._parameter_value == "'Average Revenue'" %}
      ${between_floor_current}
    {% elsif show_revenue_rental_counts._parameter_value == "'Rental Count'" %}
      ${current_total_count_of_rentals_between}
    {% else %}
      NULL
    {% endif %} ;;
  }

  measure: dynamic_current_below {
    group_label: "Dynamic Current"
    label_from_parameter: show_revenue_rental_counts
    type: number
    sql:{% if show_revenue_rental_counts._parameter_value == "'Average Revenue'" %}
      ${below_floor_current}
    {% elsif show_revenue_rental_counts._parameter_value == "'Rental Count'" %}
      ${current_total_count_of_rentals_below}
    {% else %}
      NULL
    {% endif %} ;;
  }

  measure: dynamic_table_change_above {
    group_label: "Dynamic Table Change"
    label_from_parameter: show_revenue_rental_counts
    label: "Change in Above Online Billing"
    sql:{% if show_revenue_rental_counts._parameter_value == "'Average Revenue'" %}
      ${above_percent_diff}
    {% elsif show_revenue_rental_counts._parameter_value == "'Rental Count'" %}
      ${above_rental_count_percent_diff}
    {% else %}
      NULL
    {% endif %} ;;
    html:
    {% if dynamic_table_change_above._value > 0 %}

    {% assign indicator = "green,▲" | split: ',' %}

    {% elsif dynamic_table_change_above._value < 0 %}

    {% assign indicator = "red,▼" | split: ',' %}

    {% else %}

    {% endif %}

    <font color="{{indicator[0]}}">

    {% if value == 99999.12345 %} &infin

    {% else %}({{ dynamic_table_change_above._rendered_value }})

    {% endif %} {{indicator[1]}}

    </font>;;
    value_format_name: percent_1
  }

  measure: dynamic_table_change_between {
    group_label: "Dynamic Table Change"
    label_from_parameter: show_revenue_rental_counts
    label: "Change in Between Floor Billing"
    sql:{% if show_revenue_rental_counts._parameter_value == "'Average Revenue'" %}
      ${between_percent_diff}
    {% elsif show_revenue_rental_counts._parameter_value == "'Rental Count'" %}
      ${between_rental_count_percent_diff}
    {% else %}
      NULL
    {% endif %} ;;
    html:
    {% if dynamic_table_change_between._value > 0 %}

    {% assign indicator = "green,▲" | split: ',' %}

    {% elsif dynamic_table_change_between._value < 0 %}

    {% assign indicator = "red,▼" | split: ',' %}

    {% else %}

    {% endif %}

    <font color="{{indicator[0]}}">

    {% if value == 99999.12345 %} &infin

    {% else %}({{ dynamic_table_change_between._rendered_value }})

    {% endif %} {{indicator[1]}}

    </font>;;
    value_format_name: percent_1
  }

  measure: dynamic_table_change_below {
    group_label: "Dynamic Table Change"
    label_from_parameter: show_revenue_rental_counts
    label: "Change in Below Floor Billing"
    sql:{% if show_revenue_rental_counts._parameter_value == "'Average Revenue'" %}
      ${below_percent_diff}
    {% elsif show_revenue_rental_counts._parameter_value == "'Rental Count'" %}
      ${below_rental_count_percent_diff}
    {% else %}
      NULL
    {% endif %} ;;
    html:
    {% if dynamic_table_change_below._value > 0 %}

    {% assign indicator = "green,▲" | split: ',' %}

    {% elsif dynamic_table_change_below._value < 0 %}

    {% assign indicator = "red,▼" | split: ',' %}

    {% else %}

    {% endif %}

    <font color="{{indicator[0]}}">

    {% if value == 99999.12345 %} &infin

    {% else %}({{ dynamic_table_change_below._rendered_value }})

    {% endif %} {{indicator[1]}}

    </font>;;
    value_format_name: percent_1
  }

  set: avg_drill {
    fields: [region,district,average_rental_spend]
  }

}
