view: rebate_amount_per_customer {
  sql_table_name: "ANALYTICS"."RATE_ACHIEVEMENT"."COMPANY_REBATES" ;;
#   derived_table: {
#   sql:
#   --Customer Rebates process to get the total rebate amount to show customer rebates per market for customers with multiple tiers
# with company_rental_rates as (
#                     SELECT *,
#                           IFF(DATE_CREATED<END_DATE AND DATE_VOIDED>END_DATE, END_DATE,
#                               IFF(DATE_CREATED>END_DATE,IFNULL(DATE_VOIDED,'9999-12-31'),IFNULL(DATE_VOIDED,IFNULL(END_DATE,'9999-12-31')))) AS RATE_END_DATE
#                     FROM ES_WAREHOUSE.PUBLIC.COMPANY_RENTAL_RATES
# --                     WHERE
# --                     (EQUIPMENT_CLASS_ID = 195 AND COMPANY_ID = 48614) --rate voided right after it was made
# --                     OR (EQUIPMENT_CLASS_ID = 66 AND COMPANY_ID = 420) --rate voided 6 months after it was made so line item 1 technically will have the wrong dates (also it's a discount. Do we have to take that into account?)
# --                     order by COMPANY_ID, EQUIPMENT_CLASS_ID, DATE_CREATED
#                     ),

# t1 as (select      i.COMPANY_ID,
#                   i.INVOICE_ID,
#                   li.RENTAL_ID,
#                   li.branch_ID,
#                   i.PAID_DATE,
#                   datediff(day,BILLING_APPROVED_DATE, PAID_DATE)                                                 as paid_date_diff,
#                   i.INVOICE_DATE,
#                   i.BILLING_APPROVED_DATE,
#                   crr.DATE_CREATED,
#                   crr.DATE_VOIDED,
#                   crr.end_date,
#                   crr.RATE_END_DATE,
#                   m.name                                                                                           as branch,
#                   r.EQUIPMENT_CLASS_ID                                                                             as rental_class,
#                   aa.EQUIPMENT_CLASS_ID                                                                            as invoiced_class,
#                   case when rental_class <> invoiced_class then True else FALSE end                                as is_sub,
#                   CASE WHEN i.PAID_DATE::Date <= DATEADD(day, 45, i.BILLING_APPROVED_DATE::Date) THEN TRUE ELSE FALSE END as Paid_in_time,
#                   case
#                       when r.PRICE_PER_WEEK is null and r.PRICE_PER_MONTH is null and r.PRICE_PER_DAY is not null
#                           then true
#                       else false end                                                                               as daily_billing_flag,
#                   li.AMOUNT                                                                                        as actual_total,
#                   datediff(day, i.START_DATE, i.END_DATE)                            as cycle_length,
#                   case
#           when li.EXTENDED_DATA:rental:price_per_four_weeks::number is not null then 'four_week'
#           when li.EXTENDED_DATA:rental:price_per_month::number is not null then 'monthly'
#           else null end                                                  as BILLING_TYPE,
#         case
#               when daily_billing_flag = true then (crr.PRICE_PER_MONTH / 28) * cycle_length
#               when BILLING_TYPE = 'four_week' then
#                     (li.EXTENDED_DATA:rental:cheapest_period_hour_count::number * crr.PRICE_PER_HOUR) +
#                     (li.EXTENDED_DATA:rental:cheapest_period_day_count::number * crr.PRICE_PER_DAY) +
#                     (li.EXTENDED_DATA:rental:cheapest_period_week_count::number * crr.PRICE_PER_WEEK) +
#                     (li.EXTENDED_DATA:rental:cheapest_period_four_week_count::number * crr.PRICE_PER_MONTH)
#               when BILLING_TYPE = 'monthly' then iff(cycle_length > 28,
#                     (crr.PRICE_PER_MONTH / 28) * cycle_length,
#                     (li.EXTENDED_DATA:rental:cheapest_period_hour_count::number * crr.PRICE_PER_HOUR) +
#                     (li.EXTENDED_DATA:rental:cheapest_period_day_count::number * crr.PRICE_PER_DAY) +
#                     (li.EXTENDED_DATA:rental:cheapest_period_week_count::number * crr.PRICE_PER_WEEK) +
#                     (li.EXTENDED_DATA:rental:cheapest_period_month_count::number * crr.PRICE_PER_MONTH)) end as expected_total,
#                   abs(actual_total) - expected_total                                                                    as revenue_difference,
#         case
#             when BILLING_TYPE = 'four_week' then li.EXTENDED_DATA:rental:price_per_four_weeks::number
#             when BILLING_TYPE = 'monthly' then li.EXTENDED_DATA:rental:price_per_month::number end as month_rental_rate,
#         case
#             when BILLING_TYPE = 'four_week' then crr.PRICE_PER_MONTH
#             when BILLING_TYPE = 'monthly' then iff(cycle_length > 28, (crr.PRICE_PER_MONTH / 28) * cycle_length, crr.PRICE_PER_MONTH) end as month_company_rate,
#                   month_rental_rate - month_company_rate                                                           as month_rate_difference,
#                   case
#                       when revenue_difference >= 0 then True
#                       when expected_total is null then True
#                       else False end                                                                               as is_valid_rate
#             from ES_WAREHOUSE.PUBLIC.INVOICES i
#                     join analytics.public.v_LINE_ITEMS li on i.INVOICE_ID = li.INVOICE_ID
#                     join ES_WAREHOUSE.PUBLIC.RENTALS r on li.RENTAL_ID = r.RENTAL_ID
#                     join ES_WAREHOUSE.PUBLIC.ASSETS_AGGREGATE aa on li.ASSET_ID = aa.ASSET_ID
#                     join es_warehouse.PUBLIC.MARKETS m on li.branch_ID = m.MARKET_ID
#                     left join company_rental_rates crr
#                               on i.COMPANY_ID = crr.COMPANY_ID and r.EQUIPMENT_CLASS_ID = crr.EQUIPMENT_CLASS_ID and
#                                   i.BILLING_APPROVED_DATE between crr.DATE_CREATED and crr.RATE_END_DATE
#             where --i.COMPANY_ID = 48614 --Kent company
# --             where i.COMPANY_ID = 5652 --Performance Contractors INC
# --             where i.COMPANY_ID = 29659 --BP Works
# --             where i.COMPANY_ID = 70430 --phillips & Jordan
#               li.LINE_ITEM_TYPE_ID = 8
# --               and year(i.BILLING_APPROVED_DATE) = 2023
#     and i.PAID = true
#     and BILLING_APPROVED = 'Yes'
#     --and i.PAID_DATE::Date <= DATEADD(day, 45, i.BILLING_APPROVED_DATE::Date)
#     ),
#     customer_rebates_sworks as (
#     SELECT
#           c.COMPANY_ID as customer_id,
#           co.NAME as customer_name,
#           CAST(a.REBATE_PERIOD_BEGIN AS DATE) as rebate_start_period,
#           CAST(a.REBATE_PERIOD_END AS DATE) as rebate_end_period,
#           t.GROSS_RENT_PAYMENTS_MIN as revenue_lower_bound,
#           t.GROSS_RENT_PAYMENTS_MAX as revenue_upper_bound,
#           t.REBATE_PERCENTAGE as rebate_percent,
#           (a.PAYMENT_TERMS + 3) as paid_in_days,
#           'no' as rebate_paid,
#           0 as rebate_paid_amount,
#           case when a.CUSTOM_RENTAL_RATES = TRUE then 'yes'
#               else 'no' end as customer_specific_rates
#       FROM SWORKS.CUSTOMER_REBATES.REBATE_AGREEMENT_COMPANIES c
#       LEFT JOIN ES_WAREHOUSE.PUBLIC.COMPANIES co on co.COMPANY_ID = c.COMPANY_ID
#       LEFT JOIN SWORKS.CUSTOMER_REBATES.REBATE_AGREEMENTS a on a.REBATE_AGREEMENT_ID = c.REBATE_AGREEMENT_ID
#       LEFT JOIN SWORKS.CUSTOMER_REBATES.REBATE_TIERS t on t.REBATE_AGREEMENT_ID = c.REBATE_AGREEMENT_ID
#       and c.ACTIVE = TRUE
#       and a.ACTIVE = TRUE
#   ),

#     customer_rebate_list as (SELECT cr.CUSTOMER_ID,
#                                     cr.CUSTOMER_NAME,
#                                     cr.rebate_start_period as rebate_start_for_financials,
#                                     CASE
#                                     WHEN cr.CUSTOMER_ID = '39017' and cr.REBATE_END_PERIOD = '12/31/2024' then '1/1/2024'
#                                     WHEN cr.CUSTOMER_ID = '120962' and cr.rebate_end_period = '12/31/2024' then '4/1/2024'
#                                     else cr.REBATE_START_PERIOD end as REBATE_START_PERIOD,
#                                     cr.REBATE_END_PERIOD,
#                                     cr.REVENUE_LOWER_BOUND,
#                                     cr.REVENUE_UPPER_BOUND,
#                                     cr.REBATE_PERCENT,
#                                     cr.PAID_IN_DAYS,
#                                     cr.REBATE_PAID,
#                                     cr.REBATE_PAID_AMOUNT,
#                                     cr.CUSTOMER_SPECIFIC_RATES,
#                                     CAST(COALESCE(cg.CUSTOMER_GROUP_ID ,cr.CUSTOMER_ID) as NUMBER) as group_id,
#                                     CAST(COALESCE(cg.CUSTOMER_GROUP_NAME ,cr.CUSTOMER_NAME) as string) as group_name,
#                                     ROW_NUMBER() OVER (PARTITION BY cr.CUSTOMER_ID, REBATE_END_PERIOD ORDER BY REVENUE_LOWER_BOUND) AS TIER_NUMBER
#                             FROM customer_rebates_sworks cr
#                             LEFT JOIN ANALYTICS.GS.AR_BB_CUSTOMER_GROUPING cg on TRY_CAST(cg.CUSTOMER_ID as number) = cr.CUSTOMER_ID),


#     customer_rebates_v as (SELECT --CUSTOMER_ID, REBATE_START_PERIOD, REBATE_END_PERIOD,
#                                 crl.*,
#                                 case when crl.CUSTOMER_SPECIFIC_RATES = 'yes' then t1.is_valid_rate else 'yes' end as is_rebate_eligible,
#                         t1.actual_total as rebate_eligible_amount
#                         FROM customer_rebate_list crl
#                                   left join t1 on t1.company_id = crl.CUSTOMER_ID
#                             WHERE t1.PAID_DATE::Date <= DATEADD(day, crl.PAID_IN_DAYS, t1.BILLING_APPROVED_DATE::Date)
#                             AND t1.BILLING_APPROVED_DATE::DATE >= crl.rebate_start_for_financials::DATE
#                             AND t1.BILLING_APPROVED_DATE::DATE <= crl.REBATE_END_PERIOD::DATE
#                             AND is_rebate_eligible = 'yes'
#                             and TIER_NUMBER = 1
#                         ),

# rental_charges_eligible_for_rebate as (select group_id,
#                                               group_name,
#                                               REBATE_START_PERIOD,
#                                               REBATE_END_PERIOD,
#                                               min(REVENUE_LOWER_BOUND) as minimum_spend,
#                                               sum(rebate_eligible_amount) as total_rebate_eligible_amount,
#                                               CASE WHEN sum(rebate_eligible_amount) > minimum_spend THEN TRUE ELSE FALSE END AS CUSTOMER_REBATE_ELIGIBLE
# --                                               iff(Total_rebate_eligible_amount > minimum_spend, Total_rebate_eligible_amount-minimum_spend,0) as total_rebate_eligible_after_min_spend
#                                       from customer_rebates_v
# --                                         WHERE CUSTOMER_ID in (5652,48614,29659) --performance contractors
# --                                          and REBATE_END_PERIOD = '12/31/2023'
#                                       group by 1,2,3,4
#                                       ),


# rental_charges_eligible_for_rebate_per_customer as (select CUSTOMER_ID,
#                                               CUSTOMER_NAME,
#                                               REBATE_START_PERIOD,
#                                               REBATE_END_PERIOD,
#                                               sum(rebate_eligible_amount) as total_rebate_eligible_amount_per_customer
# --                                               iff(Total_rebate_eligible_amount > minimum_spend, Total_rebate_eligible_amount-minimum_spend,0) as total_rebate_eligible_after_min_spend
#                                       from customer_rebates_v
# --                                         WHERE CUSTOMER_ID in (5652,48614,29659) --performance contractors
# --                                          and REBATE_END_PERIOD = '12/31/2023'
#                                       group by 1,2,3,4
#                                       ),



# rental_charges_eligible_with_rebate_percent as (SELECT DISTINCT r.*,
#                                                       zeroifnull(crl.REBATE_PERCENT) as rebate_percent_achieved
#                                                       --crl.*
#                                                 FROM rental_charges_eligible_for_rebate r
#                                                 left join customer_rebate_list crl on crl.group_id = r.group_id and crl.group_name = r.group_name
#                                                         and crl.REBATE_START_PERIOD = r.REBATE_START_PERIOD
#                                                         and crl.REBATE_END_PERIOD = r.REBATE_END_PERIOD
#                                                         and r.total_rebate_eligible_amount > crl.REVENUE_LOWER_BOUND AND r.total_rebate_eligible_amount <= crl.REVENUE_UPPER_BOUND),


# rebate_eligibility_and_percent as (select
#     r.CUSTOMER_ID,
#     r.CUSTOMER_NAME,
#     r.rebate_start_for_financials as REBATE_START_PERIOD,
#     r.REBATE_END_PERIOD,
#     r.REVENUE_LOWER_BOUND,
#     r.REVENUE_UPPER_BOUND,
#     r.REBATE_PERCENT,
#     r.group_id,
#     r.group_name,
#     COALESCE(rp.CUSTOMER_REBATE_ELIGIBLE, false) as CUSTOMER_REBATE_ELIGIBLE,
#     COALESCE(rp.rebate_percent_achieved, 0) as rebate_percent_achieved,
#     COALESCE(rp.total_rebate_eligible_amount, 0) as total_rebate_eligible_amount,
#     COALESCE(c.total_rebate_eligible_amount_per_customer, 0) as total_rebate_eligible_amount_per_customer,
#     COALESCE(rp.rebate_percent_achieved * c.total_rebate_eligible_amount_per_customer, 0) as total_rebate_amount,
#     ROW_NUMBER() OVER (PARTITION BY r.CUSTOMER_ID, r.REBATE_END_PERIOD ORDER BY REVENUE_LOWER_BOUND) as tier,
#     concat(r.CUSTOMER_ID, ROW_NUMBER() OVER (PARTITION BY r.CUSTOMER_ID, r.REBATE_END_PERIOD ORDER BY REVENUE_LOWER_BOUND)) AS key
# from customer_rebate_list r
# left join rental_charges_eligible_with_rebate_percent rp on rp.group_id = r.group_id
#     and rp.group_name = r.group_name
#     and rp.REBATE_START_PERIOD = r.REBATE_START_PERIOD
#     and rp.REBATE_END_PERIOD = r.REBATE_END_PERIOD
# left join rental_charges_eligible_for_rebate_per_customer c on c.CUSTOMER_NAME = r.CUSTOMER_NAME and c.CUSTOMER_ID = r.CUSTOMER_ID and c.rebate_start_period = r.rebate_start_period and c.REBATE_END_PERIOD = r.REBATE_END_PERIOD
# -- left join rental_charges_eligible_for_rebate rce
# --         on r.customer_id = rce.CUSTOMER_ID
# --         and r.REBATE_END_PERIOD = rce.REBATE_END_PERIOD
# --         and r.REBATE_START_PERIOD = rce.REBATE_START_PERIOD
# -- WHERE r.CUSTOMER_ID = 5652 --performance contractors
# -- WHERE r.CUSTOMER_ID in (30441,5652,48614,29659) --performance contractors
# --group by 1,2,3,4,5,6,7,8,9 order by 1,2,3,4,5,6,7,8,9
# )


# SELECT * FROM rebate_eligibility_and_percent
#   ;;
#   }

  dimension:  key {
    primary_key: yes
    type: number
    hidden:  yes
    sql:  ${TABLE}."KEY" ;;
  }


  dimension:  customer_id {
    type: number
    sql:  ${TABLE}."CUSTOMER_ID" ;;
  }

  dimension:  tier {
    # hidden:  yes
    type: number
    sql:  ${TABLE}."TIER" ;;
  }

  dimension_group: rebate_start_period {
    type: time
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: CAST(${TABLE}."REBATE_START_PERIOD" AS TIMESTAMP_NTZ) ;;
  }

  dimension_group: rebate_end_period {
    type: time
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: CAST(${TABLE}."REBATE_END_PERIOD" AS TIMESTAMP_NTZ) ;;
  }

  dimension: parent_customer_id {
    type: number
    sql: ${TABLE}."GROUP_ID" ;;
    value_format: "###########0"
  }

  dimension: parent_customer_name {
    type: string
    sql: ${TABLE}."GROUP_NAME" ;;
  }

  dimension: customer_name {
    type: string
    sql: ${TABLE}."CUSTOMER_NAME" ;;
  }

  dimension: customer_rebate_eligible {
    type: string
    sql: ${TABLE}."CUSTOMER_REBATE_ELIGIBLE" ;;
  }

  dimension: customer_rebate_eligible_amount {
    type: number
    sql: ${TABLE}."TOTAL_REBATE_ELIGIBLE_AMOUNT_PER_CUSTOMER" ;;
  }

  dimension: rebate_percent_achieved {
    type: number
    sql: ${TABLE}."REBATE_PERCENT_ACHIEVED" ;;
    value_format: "0.0%"
  }

  # dimension: overall_rebate_percent {
  #   type: number
  #   sql: ${TABLE}."OVERALL_REBATE_PERCENT" ;;
  # }

  dimension: total_rebate_eligible_amount {
    type: number
    sql: ${TABLE}.total_rebate_eligible_amount_per_parent_company ;;
  }

  dimension: total_rebate_amount {
    type: number
    sql: ${TABLE}.total_rebate_amount_per_customer ;;
  }

  measure:  drill_fields_rebate{
    hidden:  yes
    type:  sum
    sql:  0;;
    drill_fields: [rebate_amount_per_customer.parent_customer_name, customer_rebates.customer_name, customer_rebates.customer_id, markets.name, markets.market_id, v_line_items.rental_charges, v_line_items.rental_charges_eligible_for_rebate, rebate_amount_per_customer.rebate_percent_achieved, v_line_items.rebate_amount]
  }

  measure: rebates_per_market {
    type:  sum
    sql: ${rebate_amount_per_customer.total_rebate_amount};; # ${rebate_amount_per_customer.rebate_percent_achieved} * ${v_line_items.rental_charges_eligible_for_rebate};;
    # drill_fields: [rebate_amount_per_customer.parent_customer_name, customer_rebates.customer_name, markets.name, markets.market_id, rental_charges, rental_charges_eligible_for_rebate, rebate_amount_per_customer.rebate_percent_achieved, rebate_amount]#, rebates_per_market]
    value_format: "$#,##0"
    # filters: [customer_rebates.tier_number: "1"]
    filters: [tier: "1"]
    link: {
      label: "Rebate Amount per Market"
      url: "{{ drill_fields_rebate._link}}"
    }
  }

  # dimension: total_rebate_eligible_after_min_spend {
  #   type: number
  #   sql: ${TABLE}."TOTAL_REBATE_ELIGIBLE_AFTER_MIN_SPEND" ;;
  # }

  # dimension: rebate_amount_owed {
  #   type: number
  #   sql: ${TABLE}."REBATE_AMOUNT_OWED" ;;
  # }
}
