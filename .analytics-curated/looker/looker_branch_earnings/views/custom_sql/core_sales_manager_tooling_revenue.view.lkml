view: core_sales_manager_tooling_revenue {
  derived_table: {
    sql:
    WITH SALESPERSONS AS (
            SELECT user_id,
                employee_id,
                name                                     as salesperson,
                email_address,
                salesperson_jurisdiction_dated           as jurisdiction,
                region_name_dated                        as region,
                district_dated                           as district,
                home_market_id_dated                     as market_id,
                home_market_dated                        as market,
                direct_manager_user_id_present           as direct_manager_user_id,
                record_effective_date,
                record_ineffective_date
            FROM analytics.bi_ops.salesperson_info
            )

        SELECT
            li.GL_BILLING_APPROVED_DATE as rental_approved_date,
            DATE_TRUNC(month, li.GL_BILLING_APPROVED_DATE) as rental_approved_month,
            mrx.REGION_NAME as rental_region,
            mrx.DISTRICT as rental_district,
            o.MARKET_ID  as rental_market_id,
            m.name as rental_market,
            i.company_id as rental_company_id,
            c.name as rental_company,
            li.amount as rental_revenue,
            sp.user_id as sp_user_id,
            sp.email_address as sp_email,
            sp.salesperson,
            sp.jurisdiction as sp_jurisdiction,
            sp.region as sp_region,
            sp.district as sp_district,
            sp.market_id as sp_market_id,
            sp.market as sp_market,
            sp.direct_manager_user_id,
            um.FIRST_NAME||' '||um.LAST_NAME as direct_manager,
            um.EMAIL_ADDRESS                 as direct_manager_email,
            row_number() over (order by sp.user_id) as pk1
        FROM SALESPERSONS sp
         join es_warehouse.public.invoices i on sp.user_id = i.salesperson_user_id
         join analytics.public.v_line_items li on li.invoice_id = i.invoice_id
         join es_warehouse.public.orders o on i.order_id = o.order_id
         join es_warehouse.public.order_salespersons os on o.order_id = os.order_id
         left join es_warehouse.public.companies c on c.company_id = i.company_id
         left join es_warehouse.public.markets m ON o.MARKET_ID = m.MARKET_ID
         left join analytics.public.MARKET_REGION_XWALK mrx on o.MARKET_ID = mrx.MARKET_ID
         left join ES_WAREHOUSE.PUBLIC.USERS usp on sp.USER_ID = usp.USER_ID
         left join ES_WAREHOUSE.PUBLIC.USERS um on sp.direct_manager_user_id = um.USER_ID
         left join ANALYTICS.PAYROLL.COMPANY_DIRECTORY cdm on um.EMPLOYEE_ID::varchar = cdm.EMPLOYEE_ID::varchar
         left join analytics.public.MARKET_REGION_XWALK x on sp.MARKET_ID = x.MARKET_ID -- Joining to SP Market
        WHERE i.company_id not in (1854,1855,8151,155)
          AND li.line_item_type_id in (6,8,108,109)
          AND os.salesperson_type_id = 1
          AND rental_approved_date >= '2023-01-01'::date -- Starting in 2023 - data was filtered to >= 2022-06-01
          AND ((rental_approved_date BETWEEN sp.RECORD_EFFECTIVE_DATE AND dateadd(day, -1, sp.RECORD_INEFFECTIVE_DATE))
               OR (rental_approved_date >= sp.RECORD_EFFECTIVE_DATE AND sp.RECORD_INEFFECTIVE_DATE IS NULL))
          AND mrx.MARKET_TYPE = 'ITL'
          AND rental_approved_month in (select trunc::date from analytics.gs.plexi_periods
                                          where {% condition display %} DISPLAY {% endcondition %})
          AND cdm.employee_title in ('District Sales Manager','Regional Sales Manager','Regional Sales Manager Advanced Solutions','Regional Director of Sales')
          ;;
  }

            # AND (direct_manager in ({% condition managers %} direct_manager {% endcondition %})
          # OR salesperson in ({% condition managers %} direct_manager {% endcondition %}))

  dimension_group: rental_approved_date {
    type: time
    timeframes: [
      raw,
      date,
      week,
      month,
      quarter,
      year
    ]
    convert_tz: no
    datatype: date
    sql: ${TABLE}.rental_approved_date ;;
  }

  dimension: pk1 {
    type: string
    primary_key: yes
    hidden: yes
    sql: ${TABLE}."PK1" ;;
  }

  filter: display {
    type: string
    suggestions: [
      "January 2023","February 2023","March 2023","April 2023","May 2023","June 2023","July 2023","August 2023","September 2023","October 2023","November 2023","December 2023",
      "January 2024","February 2024","March 2024","April 2024","May 2024","June 2024", "July 2024","August 2024","September 2024","October 2024","November 2024","December 2024",
      "January 2025","February 2025","March 2025","April 2025","May 2025","June 2025", "July 2025","August 2025","September 2025","October 2025","November 2025","December 2025",
      "January 2026","February 2026","March 2026","April 2026","May 2026","June 2026", "July 2026","August 2026","September 2026","October 2026","November 2026","December 2026"
    ]
    # suggest_explore: plexi_periods
    # suggest_dimension: plexi_periods.display
  }

  parameter: start_date {
    type: date
  }
  parameter: end_date {
    type: date
  }

  filter: managers {
    type: string
    suggest_dimension: direct_manager
  }

  parameter: sales_managers {
    type: string
    suggest_dimension: direct_manager
  }

  dimension: rental_approved_month {
    label: "Rental Approved Month"
    type: string
    # value_format: "%b %d, %Y"
    sql: TO_CHAR(${TABLE}.rental_approved_month,'Mon YYYY') ;;
    # sql: TO_CHAR(${TABLE}.rental_approved_month,'Mon YYYY') ;;

  }

  dimension: rental_region {
    label: "Rental Region"
    type: string
    sql: ${TABLE}.rental_region ;;
  }

  dimension: rental_district {
    label: "Rental District"
    type: string
    sql: ${TABLE}.rental_district ;;
  }

  dimension: rental_market_id {
    label: "Rental Market ID"
    type: string
    sql: ${TABLE}.rental_market_id ;;
  }

  dimension: rental_market {
    label: "Rental Market"
    type: string
    sql: ${TABLE}.rental_market ;;
  }

  dimension: rental_company_id {
    label: "Rental Company ID"
    type: string
    sql: ${TABLE}.rental_company_id ;;
  }

  dimension: rental_company {
    label: "Rental Company Name"
    hidden: yes
    type: string
    sql: ${TABLE}.rental_company ;;
  }

  dimension: rental_company_id_agg {
    label: "Rental Company"
    type: string
    sql: ${rental_company}||' - '||${rental_company_id} ;;
  }

  dimension: rental_revenue {
    type: number
    sql: ${TABLE}.rental_revenue ;;
    drill_fields: [rep_mkt_company*]
  }

  measure: rental_revenue_sum {
    label: "Rental Revenue Amount"
    type: sum
    value_format: "$#,##0.00"
    sql: ${rental_revenue} ;;
    drill_fields: [rep_mkt_company*]
  }

  measure: manager_individual_revenue {
    label: "Sales Manager Individual Revenue Contribution"
    type: sum
    sql: case when ${salesperson} = {% parameter sales_managers %}
              then ${TABLE}.rental_revenue
              else 0 end;;
    value_format: "$#,##0.00"
  }

  measure: subordinate_revenue {
    label: "Sales Rep Revenue Contribution"
    type: sum
    sql: case when ${direct_manager} = {% parameter sales_managers %}
              then ${TABLE}.rental_revenue
              else 0 end;;
    value_format: "$#,##0.00"
  }

  dimension: sp_user_id {
    label: "Salesperson User ID"
    type: string
    sql: ${TABLE}.sp_user_id ;;
  }

  dimension: sp_email {
    label: "Salesperson Email"
    type: string
    sql: ${TABLE}.sp_email ;;
  }

  dimension: salesperson {
    # label: "Salesperson Name"
    type: string
    sql: ${TABLE}.salesperson ;;
    drill_fields: [rep_mkt_company*]
  }

  dimension: salesperson_id_name {
    label: "Salesperson Name"
    type: string
    sql: ${salesperson}||' - '||${sp_user_id} ;;
  }

  dimension: sp_jurisdiction {
    label: "Salesperson Classification"
    type: string
    sql: ${TABLE}.sp_jurisdiction ;;
  }

  dimension: sp_region {
    label: "Salesperson Assigned Region"
    type: string
    sql: ${TABLE}.sp_region ;;
  }

  dimension: sp_district {
    label: "Salesperson Assigned District"
    type: string
    sql: ${TABLE}.sp_district ;;
  }

  dimension: sp_market_id {
    label: "Salesperson Assigned Market ID"
    type: string
    sql: ${TABLE}.sp_market_id ;;
  }

  dimension: sp_market {
    label: "Salesperson Assigned Market"
    type: string
    sql: ${TABLE}.sp_market ;;
  }

  dimension: direct_manager_user_id {
    label: "Sales Manager User ID"
    type: string
    sql: ${TABLE}.direct_manager_user_id ;;
  }

  dimension: direct_manager {
    label: "Sales Manager Name"
    type: string
    sql: ${TABLE}.direct_manager ;;
    drill_fields: [rep_mkt_company*]
  }

  dimension: direct_manager_email {
    label: "Sales Manager Email"
    type: string
    sql: ${TABLE}.direct_manager_email ;;
  }

  set: rep_mkt_company {
    fields: [
      rental_market,
      rental_company,
      rental_revenue_sum,
      rental_approved_month,
      salesperson
    ]
  }




























}
