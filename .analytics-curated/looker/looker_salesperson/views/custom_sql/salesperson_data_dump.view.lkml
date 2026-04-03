
view: salesperson_data_dump {
  derived_table: {
    sql:

    with salesperson_title as (select u.USER_ID,
                                        cd.EMPLOYEE_TITLE,
                                        cd.FIRST_NAME,
                                        cd.LAST_NAME,
                                        COALESCE(m.REGION_NAME,si.region_name_dated) as region_name,
                                        COALESCE(m.DISTRICT, si.district_dated) as district,
                                        COALESCE(m.MARKET_NAME, si.home_market_dated) as market_name,
                                        COALESCE(m.MARKET_ID, si.home_market_id_dated) as market_id,
                                        cd.DATE_HIRED

                                 from ANALYTICS.PAYROLL.COMPANY_DIRECTORY cd
                                          left join ES_WAREHOUSE.PUBLIC.USERS u
                                                    on lower(cd.WORK_EMAIL) = lower(u.EMAIL_ADDRESS)
                                          left join ANALYTICS.PUBLIC.MARKET_REGION_XWALK m
                                                    on m.MARKET_ID = cd.MARKET_ID
                                          left join analytics.bi_ops.salesperson_info si ON si.user_id = u.user_id AND record_ineffective_date IS NULL
                                 where COMPANY_ID = 1854 and cd.EMPLOYEE_STATUS in ('Active','Leave with Pay')
),
first_order_date as (
select  MARKET_ID,
        date_trunc(month,min(DATE_CREATED))::date as min_order_date
from ES_WAREHOUSE.PUBLIC.ORDERS
where ORDER_STATUS_ID <> 8
group by MARKET_ID
),
market_created_date as (
select xw.MARKET_ID,
       date_trunc(month, m.DATE_CREATED)::date as date_created
from ES_WAREHOUSE.PUBLIC.MARKETS m
left join ANALYTICS.PUBLIC.MARKET_REGION_XWALK xw on m.MARKET_ID = xw.MARKET_ID
where xw.MARKET_ID is not null
),
market_start_final as (
select MARKET_NAME,
       mr.MARKET_ID,
       MARKET_START_MONTH,
       BRANCH_EARNINGS_START_MONTH,
       coalesce(BRANCH_EARNINGS_START_MONTH, MARKET_START_MONTH, min_order_date, mcd.date_created) as market_opened,
       case when market_opened < date_trunc(month,dateadd(month, -12, current_date)) then 'No' else 'Yes' end as market_opened_12_months_ago
from ANALYTICS.GS.REVMODEL_MARKET_ROLLOUT_CONSERVATIVE mr
left join first_order_date fod on mr.MARKET_ID = fod.MARKET_ID
left join market_created_date mcd on mr.MARKET_ID = mcd.MARKET_ID
),
new_customers AS (
select *
from ANALYTICS.PUBLIC.NEW_CUSTOMERS
),
      mtd_revenue as (
          select
              use.USER_ID,
              sum(AMOUNT) as mtd_revenue

      from ANALYTICS.PUBLIC.V_LINE_ITEMS as li
          left join ES_WAREHOUSE.PUBLIC.INVOICES as inv
          on li.INVOICE_ID = inv.INVOICE_ID
          left join ES_WAREHOUSE.PUBLIC.ORDERS as ord
          on inv.ORDER_ID = ord.ORDER_ID
          left join ES_WAREHOUSE.PUBLIC.ORDER_SALESPERSONS as ors
          on ord.ORDER_ID = ors.ORDER_ID
          left join ES_WAREHOUSE.PUBLIC.USERS as use
          on ors.USER_ID = use.USER_ID


      where LINE_ITEM_TYPE_ID in (8,6,108,109)
        and inv.company_id not in (1854,1855,8151,155)
        and GL_BILLING_APPROVED_DATE >= date_trunc('month', current_date)
      group by  use.USER_ID, date_trunc('month', GL_BILLING_APPROVED_DATE)
      ),
last_month_revenue as (
select
    concat(use.first_name, ' ', use.last_name) as sales_person,
    use.USER_ID as salesperson_id,
    sum(li.AMOUNT) as total_revenue_last_month
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
  and inv.company_id not in (1854,1855,8151,155)
  --and ors.salesperson_type_id = 1               ----- Commenting out since Bobbi wants to see secondary revenue as well
  and GL_BILLING_APPROVED_DATE >= date_trunc('month', current_date - interval '1 month') AND GL_BILLING_APPROVED_DATE < date_trunc('month', current_date)
group by use.USER_ID,
        concat(use.first_name, ' ', use.last_name)
),
      active_renting as (
          select
          ors.USER_ID,
          count(rent.ASSET_ID) AS assets_on_rent,
          count(distinct c.COMPANY_ID) AS actively_renting_companies,
          sum(OEC) AS total_oec_on_rent

      from ES_WAREHOUSE.PUBLIC.RENTALS as rent
          left join ES_WAREHOUSE.PUBLIC.ORDER_SALESPERSONS as ors
          on ors.ORDER_ID = rent.ORDER_ID
          left join ES_WAREHOUSE.PUBLIC.ORDERS o
          on o.ORDER_ID = rent.ORDER_ID
          left join ES_WAREHOUSE.PUBLIC.USERS u
          on o.USER_ID = u.USER_ID
          left join ES_WAREHOUSE.PUBLIC.COMPANIES c
          on c.COMPANY_ID = u.COMPANY_ID
          left join ANALYTICS.ASSET_DETAILS.ASSET_PHYSICAL ap
          on ap.ASSET_ID = rent.ASSET_ID
      where RENTAL_STATUS_ID = 5
      group by ors.USER_ID
      ),
      discount_percent as (
          select
          SALESPERSON_USER_ID,
          case when sum(PERCENT_DISCOUNT) is not null and sum(ONLINE_RATE) != 0
                     then (sum(PERCENT_DISCOUNT*ONLINE_RATE)/sum(online_rate))
                 end as discount_percentage
      from ANALYTICS.PUBLIC.RATEACHIEVEMENT_POINTS
      where INVOICE_DATE_CREATED >= dateadd('day', -30, current_date)
      group by SALESPERSON_USER_ID
      ),


      in_out_market_revenue as (
      select slic.SALESPERSON,
             slic.SP_USER_ID,
             sum(slic.RENTAL_REVENUE) as market_revenue_type_total,
             mr.total_market_revenue,
             case when slic.SP_MARKET_ID = slic.RENTAL_MARKET_ID then 'In Market' else 'Out of Market' end as market_revenue_type,
             market_revenue_type_total/nullifzero(total_market_revenue) as market_type_percentage
      from ANALYTICS.BI_OPS.SALESPERSON_LINE_ITEMS_CURRENT slic
      left join (select SALESPERSON,
                        SP_USER_ID,
                        sum(RENTAL_REVENUE) as total_market_revenue
                from ANALYTICS.BI_OPS.SALESPERSON_LINE_ITEMS_CURRENT
                group by SALESPERSON,
                         SP_USER_ID) as mr on slic.SP_USER_ID = mr.SP_USER_ID
      group by slic.SALESPERSON,
               slic.SP_USER_ID,
               mr.total_market_revenue,
               case when slic.SP_MARKET_ID = slic.RENTAL_MARKET_ID then 'In Market' else 'Out of Market' end
      ),


rehire_updates AS (
  SELECT
    name,
    user_id,
    COALESCE(record_ineffective_date, current_date)::DATE AS inef,
    record_effective_date,
    employee_title_dated,
    date_rehired_present,
    date_hired_initial,
    date_terminated_present
FROM
    analytics.bi_ops.salesperson_info si
WHERE
    date_rehired_present IS NULL

  UNION

  SELECT
    name,
    user_id,
    COALESCE(record_ineffective_date, current_date)::DATE AS inef,
    CASE WHEN date_rehired_present >= record_effective_date AND date_rehired_present < inef THEN date_rehired_present
        ELSE record_effective_date END AS record_starts,
    employee_title_dated,
    date_rehired_present,
    date_hired_initial,
    date_terminated_present
FROM
    analytics.bi_ops.salesperson_info si
WHERE
    date_rehired_present IS NOT NULL
    AND record_starts >= date_rehired_present

),
first_TAM_date AS (
     select
          name,
          user_id,
          first_date_as_TAM
      FROM
            (
                SELECT *,
                MIN(record_effective_date) OVER (PARTITION BY si.user_id, si.name) as first_date_as_TAM
                FROM rehire_updates si
                WHERE si.employee_title_dated IN ('Territory Account Manager', 'Strategic Account Manager')

            ) subq
      WHERE record_effective_date = first_date_as_TAM
    ),
    final_tam_hired_date as (
    SELECT
          si.user_id,
          ftd.first_date_as_TAM,
          IFF(date_rehired_present is not null, DATE_REHIRED_PRESENT, DATE_HIRED_INITIAL) as es_start_date
    FROM
          analytics.bi_ops.salesperson_info si
    LEFT JOIN
          first_TAM_date ftd on ftd.user_id = si.user_id AND ftd.name = si.name
    WHERE record_ineffective_date IS NULL AND employee_status_present = 'Active'
)

      select

    concat(trim((salesperson_title.FIRST_NAME)),' ',trim((salesperson_title.LAST_NAME)),' - ',(salesperson_title.USER_ID))  AS full_name_with_id,
    salesperson_title.EMPLOYEE_TITLE,
    salesperson_title.REGION_NAME,
    salesperson_title.DISTRICT,
    COUNT(CASE WHEN ( date_trunc(month,current_date()) =  date_trunc(month,(new_customers."DATE_CREATED")::DATE) ) THEN 1 ELSE NULL END) AS new_customers_count_current_month,
    COUNT(CASE WHEN ( (date_trunc(month,current_date()) - interval '1 month') = date_trunc(month,(new_customers."DATE_CREATED")::DATE) ) THEN 1 ELSE NULL END) AS new_customers_count_last_month,
    last_month_revenue.total_revenue_last_month,
    mtd_revenue.mtd_revenue,
    active_renting.actively_renting_companies,
    active_renting.assets_on_rent,
    active_renting.total_oec_on_rent,
    discount_percent.discount_percentage,
    salesperson_title.DATE_HIRED,
    coalesce(salesperson_title.MARKET_NAME,'No Market Specified') as market_name,
    msf.market_opened,
    msf.market_opened_12_months_ago,
    iomr.market_revenue_type_total,
    iomr.market_revenue_type,
    iomr.market_type_percentage,
    fthd.first_date_as_tam,
    fthd.es_start_date
from salesperson_title
    left join new_customers
    on new_customers.salesperson_user_id = salesperson_title.USER_ID
    left join mtd_revenue
    on salesperson_title.USER_ID = mtd_revenue.USER_ID
    left join active_renting
    on salesperson_title.USER_ID = active_renting.USER_ID
    left join discount_percent
    on salesperson_title.USER_ID = discount_percent.SALESPERSON_USER_ID
    left join last_month_revenue
    on salesperson_title.USER_ID = last_month_revenue.salesperson_id
    left join market_start_final msf
    on salesperson_title.market_id = msf.market_id
    left join in_out_market_revenue iomr
    on salesperson_title.USER_ID = iomr.SP_USER_ID
    left join final_tam_hired_date fthd
    on salesperson_title.user_id = fthd.user_id
 where EMPLOYEE_TITLE like '%Advanced%'
   or EMPLOYEE_TITLE like 'Territory Account Manager'
    or EMPLOYEE_TITLE like 'Rental Coordinator'
     or EMPLOYEE_TITLE like 'General Manager'
group by 1,2,3,4,7,8,9,10,11,12,13,14,15,16,17,18,19,20, 21 ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: full_name_with_id {
    label: "Employee Full Name With ID"
    view_label: ""
    type: string
    sql: ${TABLE}."FULL_NAME_WITH_ID" ;;
  }

  dimension: employee_title {
    type: string
    sql: ${TABLE}."EMPLOYEE_TITLE" ;;
  }

  dimension: region_name {
    label: "Region"
    view_label: ""
    type: string
    sql: ${TABLE}."REGION_NAME" ;;
  }

  dimension: district {
    type: string
    view_label: ""
    sql: ${TABLE}."DISTRICT" ;;
  }

  dimension: market {
    type: string
    view_label: ""
    sql: ${TABLE}."MARKET_NAME" ;;
  }

  dimension_group: market_opened {
    type: time
    sql: ${TABLE}."MARKET_OPENED" ;;
    html: {{ rendered_value | date: "%m/%d/%y" }};;
  }

  dimension: market_opened_in_the_last_12_months {
    type: string
    view_label: ""
    sql: ${TABLE}."MARKET_OPENED_12_MONTHS_AGO" ;;
  }

  dimension: new_customers_count_current_month {
    type: number
    sql: ${TABLE}."NEW_CUSTOMERS_COUNT_CURRENT_MONTH" ;;
  }

  dimension: new_customers_count_last_month {
    type: number
    sql: ${TABLE}."NEW_CUSTOMERS_COUNT_LAST_MONTH" ;;
  }

  dimension: mtd_revenue {
    label: "MTD Revenue"
    type: number
    sql: ${TABLE}."MTD_REVENUE" ;;
    value_format_name: usd_0
  }

  dimension: total_revenue_last_month {
    type: number
    sql: ${TABLE}. "TOTAL_REVENUE_LAST_MONTH" ;;
    value_format_name: usd_0
  }

  dimension: actively_renting_companies {
    type: number
    sql: ${TABLE}."ACTIVELY_RENTING_COMPANIES" ;;
  }

  dimension: assets_on_rent {
    type: number
    sql: ${TABLE}."ASSETS_ON_RENT" ;;
  }

  dimension: total_oec_on_rent {
    type: number
    sql: ${TABLE}."TOTAL_OEC_ON_RENT" ;;
    value_format_name: usd_0
  }

  dimension: discount_percentage {
    type: number
    sql: ${TABLE}."DISCOUNT_PERCENTAGE" ;;
  }

  dimension_group: date_hired {
    label: "Hired"
    type: time
    sql: ${TABLE}."DATE_HIRED";;
    html: {{ rendered_value | date: "%m/%d/%y" }};;
  }

  dimension: market_revenue_type {
    type: string
    sql: ${TABLE}."MARKET_REVENUE_TYPE" ;;
  }

  dimension: market_revenue_type_total {
    type: number
    sql: ${TABLE}."MARKET_REVENUE_TYPE_TOTAL" ;;
    value_format_name: usd_0
  }

  dimension: market_revenue_percentage {
    type: number
    sql: ${TABLE}."MARKET_TYPE_PERCENTAGE" ;;
  }

  measure: in_market_revenue_percent {
    label: "Percent of In Market Revenue (Current Month)"
    type: sum
    sql: ${market_revenue_percentage} ;;
    filters: [market_revenue_type: "In Market"]
    value_format_name: percent_1
  }

  measure: out_market_revenue_percent {
    label: "Percent of Out of Market Revenue (Current Month)"
    type: sum
    sql: ${market_revenue_percentage} ;;
    filters: [market_revenue_type: "Out of Market"]
    value_format_name: percent_1
  }

  measure: in_market_revenue {
    label: "In Market Revenue (Current Month)"
    type: sum
    sql: ${market_revenue_type_total} ;;
    filters: [market_revenue_type: "In Market"]
    value_format_name: usd_0
  }

  measure: out_market_revenue {
    label: "Out of Market Revenue (Current Month)"
    type: sum
    sql: ${market_revenue_type_total} ;;
    filters: [market_revenue_type: "Out of Market"]
    value_format_name: usd_0
  }

  dimension_group: first_date_as_tam {
    label: "First Date as TAM"
    type: time
    sql: ${TABLE}."FIRST_DATE_AS_TAM";;
    html: {{ rendered_value | date: "%m/%d/%y" }};;
  }

  dimension_group: es_start_date {
    label: "ES Start"
    type: time
    sql: ${TABLE}."ES_START_DATE";;
    html: {{ rendered_value | date: "%m/%d/%y" }};;
  }

  set: detail {
    fields: [
        full_name_with_id,
  employee_title,
  region_name,
  district,
  new_customers_count_current_month,
  new_customers_count_last_month,
  mtd_revenue,
  actively_renting_companies,
  assets_on_rent,
  total_oec_on_rent,
  discount_percentage,
  date_hired_date
    ]
  }
}
