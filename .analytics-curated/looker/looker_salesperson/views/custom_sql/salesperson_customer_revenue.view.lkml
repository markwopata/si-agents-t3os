
view: salesperson_customer_revenue {
  derived_table: {
    sql: with main_info as (
      select
          concat(use.first_name, ' ', use.last_name) as salesperson,
          use.USER_ID as user_id,
          sum(li.AMOUNT) as all_time_revenue,
          c.NAME as company_name,
          c.COMPANY_ID as company_id,
          date_trunc('day', li.GL_BILLING_APPROVED_DATE) as date
      from ANALYTICS.PUBLIC.V_LINE_ITEMS as li
          left join ES_WAREHOUSE.PUBLIC.INVOICES as inv
          on li.INVOICE_ID = inv.INVOICE_ID
          left join ES_WAREHOUSE.PUBLIC.ORDERS as ord
          on inv.ORDER_ID = ord.ORDER_ID
          left join ES_WAREHOUSE.PUBLIC.ORDER_SALESPERSONS as ors
          on ord.ORDER_ID = ors.ORDER_ID
          left join ES_WAREHOUSE.PUBLIC.USERS as use
          on ors.USER_ID = use.USER_ID
          left join ES_WAREHOUSE.PUBLIC.COMPANIES as c
          on c.COMPANY_ID = inv.COMPANY_ID
      where LINE_ITEM_TYPE_ID in (8,6,108,109)
          and li.amount > 0
          and li.GL_BILLING_APPROVED_DATE >= dateadd(year,-2,current_date)
          and ors.SALESPERSON_TYPE_ID = 1
      group by use.USER_ID,
              concat(use.first_name, ' ', use.last_name),
              c.NAME,
              c.COMPANY_ID,
              li.GL_BILLING_APPROVED_DATE
      ),
      revenue_totals as (
      select salesperson,
             user_id,
             company_name,
             company_id,
          SUM(CASE WHEN date >= date_trunc('month', current_date - interval '12 month') AND date < date_trunc('day', current_date)
              THEN all_time_revenue ELSE 0 END ) AS trailing_12_months,

--         SUM(CASE WHEN date >= dateadd(year, -2, date_trunc('month', current_date)) AND date <= dateadd(year, -1, date_trunc('month', current_date))
--             THEN all_time_revenue ELSE 0 END) AS last_year_trailing_12_months,

          SUM(CASE WHEN date >= dateadd(day,-30,current_date) and date < date_trunc('day', current_date) THEN all_time_revenue ELSE 0 END) AS last_30_days,

--         SUM(CASE WHEN date >= dateadd(days, -30, dateadd(year, -1, current_date)) and date <= dateadd(year, -1, current_date)
--              THEN all_time_revenue ELSE 0 END) AS last_year_last_30_days,

          SUM(CASE WHEN date >= dateadd(day,-60,current_date) and date < date_trunc('day', current_date) THEN all_time_revenue ELSE 0 END) AS last_60_days,

--          SUM(CASE WHEN date >= dateadd(days, -60, dateadd(year, -1, current_date)) and date <= dateadd(year, -1, current_date)
--              THEN all_time_revenue ELSE 0 END) AS last_year_last_60_days,

          SUM(CASE WHEN date >= dateadd(day,-90,current_date) and date < date_trunc('day', current_date) THEN all_time_revenue ELSE 0 END) AS last_90_days

--          SUM(CASE WHEN date >= dateadd(days, -90, dateadd(year, -1, current_date)) and date <= dateadd(year, -1, current_date)
--              THEN all_time_revenue ELSE 0 END) AS last_year_last_90_days
      from main_info
      group by salesperson,
               user_id,
               company_name,
               company_id
      ),
    sum_30 as(
      select
        user_id,
        sum(last_30_days) as total_30_revenue
      from revenue_totals
      group by user_id
  ),
    actively_renting_customers as (
      select concat(u.FIRST_NAME, ' ', u.LAST_NAME) as salesperson,
             u.USER_ID,
             c.COMPANY_ID,
             c.NAME
      from ES_WAREHOUSE.PUBLIC.RENTALS r
          left join ES_WAREHOUSE.PUBLIC.ORDERS o
          on o.ORDER_ID = r.ORDER_ID
          left join ES_WAREHOUSE.PUBLIC.ORDER_SALESPERSONS os
          on os.ORDER_ID = o.ORDER_ID
          left join ES_WAREHOUSE.PUBLIC.USERS u
          on u.USER_ID = os.USER_ID
          left join ES_WAREHOUSE.PUBLIC.USERS as customer
          on o.USER_ID = customer.USER_ID
          left join ES_WAREHOUSE.PUBLIC.COMPANIES c
          on customer.COMPANY_ID = c.COMPANY_ID
      where SALESPERSON_TYPE_ID = 1
          and RENTAL_STATUS_ID = 5
      group by concat(u.FIRST_NAME, ' ', u.LAST_NAME),
             u.USER_ID,
             c.COMPANY_ID,
             c.NAME
      )
      select rt.salesperson,
             rt.user_id,
             rt.company_name,
             rt.company_id,
             rt.trailing_12_months,
            -- rt.last_year_trailing_12_months,
             rt.last_30_days,
            -- rt.last_year_last_30_days,
             rt.last_60_days,
            -- rt.last_year_last_60_days,
             rt.last_90_days,
            -- rt.last_year_last_90_days,
             CASE WHEN arc.COMPANY_ID IS NOT null THEN 'Active' ELSE 'Not Active' END AS active_flag,
             st.total_30_revenue,
             CASE WHEN st.total_30_revenue = 0 THEN null ELSE rt.last_30_days/st.total_30_revenue END AS total_30_day_revenue_percent,
             row_number() over (partition by rt.salesperson order by rt.last_30_days desc) as row_number
      from revenue_totals rt
          left join actively_renting_customers arc
          on rt.user_id = arc.USER_ID and rt.company_id = arc.COMPANY_ID
          left join sum_30 st
          on rt.user_id = st.user_id;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: primary_key {
    primary_key: yes
    type: string
    sql: concat(${salesperson},${company_id},${total_30_revenue}) ;;
  }

  dimension: salesperson {
    type: string
    sql: ${TABLE}."SALESPERSON" ;;
  }

  dimension: user_id {
    type: string
    sql: ${TABLE}."USER_ID" ;;
  }

  dimension: company_name {
    type: string
    sql: ${TABLE}."COMPANY_NAME" ;;
  }

  dimension: company_id {
    type: string
    sql: ${TABLE}."COMPANY_ID" ;;
  }

  dimension: trailing_12_months {
    type: number
    sql: ${TABLE}."TRAILING_12_MONTHS" ;;
    value_format_name: usd_0
  }

  dimension: total_30_revenue {
    type: number
    sql: ${TABLE}."TOTAL_30_REVENUE" ;;
    value_format_name: usd_0
  }

  dimension: total_30_day_revenue_percent {
    type: number
    sql: ${TABLE}."TOTAL_30_DAY_REVENUE_PERCENT" ;;
    value_format_name: percent_1
  }

  dimension: row_number {
    type: string
    sql: ${TABLE}."ROW_NUMBER" ;;
  }

  dimension: test_bucket {
    sql:
    CASE
    WHEN ${row_number} <= 10 THEN ${company_name}
    ELSE 'Other Customers'
    END ;;
  }

  measure: trailing_12_measure {
    type: number
    sql: ${trailing_12_months} ;;
    value_format_name: usd_0
  }

  # dimension: last_year_trailing_12_months {
  #   type: number
  #   sql: ${TABLE}."LAST_YEAR_TRAILING_12_MONTHS" ;;
  #   value_format_name: usd_0
  # }

  dimension: last_30_days {
    type: number
    sql: ${TABLE}."LAST_30_DAYS" ;;
    value_format_name: usd_0
  }

  measure: last_30_measure {
    type: sum
    sql: ${last_30_days} ;;
    value_format_name: usd_0
  }

  # dimension: last_year_last_30_days {
  #   type: number
  #   sql: ${TABLE}."LAST_YEAR_LAST_30_DAYS" ;;
  #   value_format_name: usd_0
  # }

  dimension: last_60_days {
    type: number
    sql: ${TABLE}."LAST_60_DAYS" ;;
    value_format_name: usd_0
  }

  measure: last_60_measure {
    type: number
    sql: ${last_60_days} ;;
    value_format_name: usd_0
  }

  # dimension: last_year_last_60_days {
  #   type: number
  #   sql: ${TABLE}."LAST_YEAR_LAST_60_DAYS" ;;
  #   value_format_name: usd_0
  # }

  dimension: last_90_days {
    type: number
    sql: ${TABLE}."LAST_90_DAYS" ;;
    value_format_name: usd_0
  }

  measure: last_90_measure {
    type: number
    sql: ${last_90_days} ;;
    value_format_name: usd_0
  }

  # dimension: last_year_last_90_days {
  #   type: number
  #   sql: ${TABLE}."LAST_YEAR_LAST_90_DAYS" ;;
  #   value_format_name: usd_0
  # }

  measure: total_30_revenue_measure {
    type: sum
    sql: ${total_30_revenue} ;;
    value_format_name: usd_0
  }

  measure: percent_test {
    type: number
    sql: case when ${total_30_revenue_measure} = 0 then null else ${last_30_measure}/${total_30_revenue_measure} end ;;
    value_format_name: percent_1
  }

  measure: total_30_day_revenue_percent_measure {
    type: number
    sql: ${percent_test} ;;
    value_format_name: percent_1
  }

  dimension: active_flag {
    type: string
    sql: ${TABLE}."ACTIVE_FLAG" ;;
    html:
    {% if active_flag._value == "Active" %}

    {% assign indicator = "green,✔️" | split: ',' %}

    {% elsif active_flag._value == "Not Active" %}

    {% assign indicator = "red,✗" | split: ',' %}

    {% else %}

    {% endif %}

    <font color="{{indicator[0]}}">

    {% if value == "Active" %}✔

    {% elsif value == "Not Active" %}✗

    {% else %}

    {% endif %}

    </font>
    </a>;;
  }

  # measure: change_in_revenue_dollars{
  #   type: number
  #   sql: ${trailing_12_months} - ${last_year_trailing_12_months} ;;
  #   value_format_name: usd_0
  # }


  set: detail {
    fields: [
        salesperson,
  user_id,
  company_name,
  company_id,
  trailing_12_months,
  last_30_days,
  last_60_days,
  last_90_days,
  active_flag
    ]
  }
}
