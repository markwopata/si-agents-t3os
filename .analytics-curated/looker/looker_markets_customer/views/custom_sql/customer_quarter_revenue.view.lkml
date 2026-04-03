
view: customer_quarter_revenue {
  derived_table: {
    sql: with main_q_info as (
      select
                trim(c.NAME) as company_name,
                c.COMPANY_ID as company_id,
                sum(li.AMOUNT) as quarter_revenue,
                xw.REGION_NAME as region,
                xw.DISTRICT as district,
                concat(use.FIRST_NAME, ' ', use.LAST_NAME) as full_name,
                date_trunc(quarter, li.GL_BILLING_APPROVED_DATE) as quarter,
                case when lag(quarter_revenue,1) over(partition by c.NAME, xw.REGION_NAME, xw.DISTRICT, full_name order by quarter) is null then quarter_revenue else lag(quarter_revenue,1) over(partition by c.NAME, xw.REGION_NAME, xw.DISTRICT, full_name order by quarter) end as last_q_revenue,
                (quarter_revenue-last_q_revenue)/case when last_q_revenue = 0 then null else last_q_revenue end as percentage_change
            from ANALYTICS.PUBLIC.V_LINE_ITEMS as li
                left join ES_WAREHOUSE.PUBLIC.INVOICES as inv
                on li.INVOICE_ID = inv.INVOICE_ID
                left join ES_WAREHOUSE.PUBLIC.ORDERS as ord
                on inv.ORDER_ID = ord.ORDER_ID
                left join ES_WAREHOUSE.PUBLIC.ORDER_SALESPERSONS as ors
                on ord.ORDER_ID = ors.ORDER_ID
                left join ANALYTICS.PUBLIC.MARKET_REGION_XWALK xw
                on ord.MARKET_ID = xw.MARKET_ID
                left join ES_WAREHOUSE.PUBLIC.USERS as use
                on ors.USER_ID = use.USER_ID
                left join ES_WAREHOUSE.PUBLIC.COMPANIES as c
                on c.COMPANY_ID = inv.COMPANY_ID
            where LINE_ITEM_TYPE_ID in (8,6,108,109)
                and li.amount > 0
                and li.GL_BILLING_APPROVED_DATE between '01/01/2022' and current_date
                and concat(year(li.GL_BILLING_APPROVED_DATE),quarter(li.GL_BILLING_APPROVED_DATE)) <> concat(year(current_date),quarter(current_date)) --- This makes it so the current quarter is being excluded
                and date_trunc(quarter, li.GL_BILLING_APPROVED_DATE) BETWEEN {% date_start date_filter%} AND {% date_end date_filter%}
                and {% condition region_filter_mapping %} xw.REGION_NAME {% endcondition %}
                and {% condition district_filter_mapping %} xw.DISTRICT {% endcondition %}
                and {% condition employee_filter_mapping %} concat(use.FIRST_NAME, ' ', use.LAST_NAME) {% endcondition %}
                and {% condition company_filter_mapping %} c.NAME {% endcondition %}
            group by c.NAME,
                    c.COMPANY_ID,
                    date_trunc(quarter, li.GL_BILLING_APPROVED_DATE),
                    xw.REGION_NAME,
                    xw.DISTRICT,
                    concat(use.FIRST_NAME, ' ', use.LAST_NAME)
      ),
      total_rev as (
          ---- This will be used to get the total sum of the date range selected (will need to have the liquid lookml)
          select  main_q_info.company_name,
                  main_q_info.company_id,
                  main_q_info.region,
                  main_q_info.district,
                  main_q_info.full_name,
                  sum(quarter_revenue) as total_revenue
          from main_q_info
          where main_q_info.quarter BETWEEN {% date_start date_filter%} AND {% date_end date_filter%}
                and {% condition region_filter_mapping %} main_q_info.region {% endcondition %}
                and {% condition district_filter_mapping %} main_q_info.district {% endcondition %}
                and {% condition employee_filter_mapping %} main_q_info.full_name {% endcondition %}
                and {% condition company_filter_mapping %} main_q_info.company_name {% endcondition %}
          group by main_q_info.company_name,
                   main_q_info.company_id,
                   main_q_info.region,
                   main_q_info.district,
                   main_q_info.full_name
      )
      select mqi.company_name,
             mqi.company_id,
             mqi.quarter_revenue,
             mqi.region,
             mqi.district,
             mqi.full_name,
             mqi.quarter,
             mqi.last_q_revenue,
             mqi.percentage_change,
             tr.total_revenue
      from main_q_info mqi
          join total_rev tr
          on mqi.company_id = tr.company_id and mqi.region = tr.region and mqi.district = tr.district and mqi.full_name = tr.full_name;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: key {
    type: string
    primary_key: yes
    sql: concat(${company_name},${company_id},${region}) ;;
  }

  dimension: company_name {
    type: string
    sql: ${TABLE}."COMPANY_NAME" ;;
  }

  dimension: company_id {
    type: string
    sql: ${TABLE}."COMPANY_ID" ;;
  }

  dimension: quarter_revenue {
    type: number
    sql: ${TABLE}."QUARTER_REVENUE" ;;
  }

  dimension: region {
    type: string
    sql: ${TABLE}."REGION" ;;
  }

  dimension: district {
    type: string
    sql: ${TABLE}."DISTRICT" ;;
  }

  dimension: full_name {
    label: "Employee"
    type: string
    sql: ${TABLE}."FULL_NAME" ;;
  }

  dimension_group: quarter {
    type: time
    sql: ${TABLE}."QUARTER" ;;
  }

  dimension: last_q_revenue {
    type: number
    sql: ${TABLE}."LAST_Q_REVENUE" ;;
  }

  dimension: total_revenue {
    type: number
    sql: ${TABLE}."TOTAL_REVENUE" ;;
    value_format_name: usd_0
  }

  dimension: percentage_change {
    type: number
    sql: ${TABLE}."PERCENTAGE_CHANGE" ;;
    value_format_name: percent_1
  }

  measure: total_quarter_revenue {
    type: sum
    sql: ${quarter_revenue} ;;
  }

  measure: percentage_change_from_previous_quarter {
    type: sum
    sql: ${percentage_change} ;;
    value_format_name: percent_1
  }

  filter: date_filter {
    type: date_time
  }

  filter: region_filter_mapping {
    type: string
  }

  filter: district_filter_mapping {
    type: string
  }

  filter: employee_filter_mapping {
    type: string
  }

  filter: company_filter_mapping {
    type: string
  }

  set: detail {
    fields: [
        company_name,
  company_id,
  quarter_revenue,
  region,
  quarter_time,
  last_q_revenue,
  total_revenue
    ]
  }
}
