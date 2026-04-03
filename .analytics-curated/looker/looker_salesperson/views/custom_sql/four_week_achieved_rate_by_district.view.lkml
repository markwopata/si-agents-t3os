view: four_week_achieved_rate_by_district {
  derived_table: {
    sql:
with invoice_data as (
    select
       li.LINE_ITEM_ID,
       r.EQUIPMENT_CLASS_ID,
       rr.DISTRICT,
       rr.REGION,
       amount,
       li.EXTENDED_DATA:rental:cheapest_period_hour_count      as hours,
                           li.EXTENDED_DATA:rental:cheapest_period_day_count       as days,
                           li.EXTENDED_DATA:rental:cheapest_period_week_count      as weeks,
                           li.EXTENDED_DATA:rental:cheapest_period_four_week_count as four_weeks,
                           li.EXTENDED_DATA:rental:cheapest_period_month_count     as months,
                           li.EXTENDED_DATA:rental:price_per_month as month_price,
       datediff(day, i.START_DATE, i.END_DATE)                 as cycle_length,
       case
           when r.PRICE_PER_WEEK is null and r.PRICE_PER_MONTH is null and
                r.PRICE_PER_DAY is not null then true
           else false end                                      as DAILY_BILLING_FLAG,
       case
           when li.EXTENDED_DATA:rental:price_per_four_weeks::number is not null then 'four_week'
           when li.EXTENDED_DATA:rental:price_per_month::number is not null then 'monthly'
           else null end                                       as BILLING_TYPE,
        li.EXTENDED_DATA:rental:shift_info:shift_type_id AS shift_type_id,
       case
       when daily_billing_flag = true then li.EXTENDED_DATA:rental:price_per_day *28
       when BILLING_TYPE = 'four_week' then li.EXTENDED_DATA:rental:price_per_four_weeks
       when BILLING_TYPE = 'monthly' then iff(cycle_length > 28,
                                              li.EXTENDED_DATA:rental:price_per_month / cycle_length * 28,
                                              li.EXTENDED_DATA:rental:price_per_month) end as raw_four_week_rate,
        CASE
            WHEN SHIFT_TYPE_ID = 3 then raw_four_week_rate/2
            WHEN SHIFT_TYPE_ID = 2 then raw_four_week_rate/1.5
            else raw_four_week_rate end as four_week_rate
from ES_WAREHOUSE.PUBLIC.LINE_ITEMS li
         left join ES_WAREHOUSE.PUBLIC.INVOICES i on li.INVOICE_ID = i.INVOICE_ID
         left join ES_WAREHOUSE.PUBLIC.RENTALS r on li.RENTAL_ID = r.RENTAL_ID
         left join ES_WAREHOUSE.PUBLIC.ORDERS o on r.ORDER_ID = o.ORDER_ID
         left join ES_WAREHOUSE.PUBLIC.MARKETS m on o.MARKET_ID = m.MARKET_ID
         left join ES_WAREHOUSE.PUBLIC.EQUIPMENT_CLASSES ec
                   on r.EQUIPMENT_CLASS_ID = ec.EQUIPMENT_CLASS_ID
         left join RATE_ACHIEVEMENT.RATE_REGIONS rr on li.BRANCH_ID = rr.MARKET_ID
where li.LINE_ITEM_TYPE_ID = 8
  and m.COMPANY_ID = 1854
  and i.BILLING_APPROVED_DATE >= DATEADD('month', -3, CURRENT_DATE())
  and amount >1
-- and LINE_ITEM_ID = 189567912
    )

SELECT
    region,
    district,
    EQUIPMENT_CLASS_ID,
    round(avg(four_week_rate)) as average_four_week_rate
FROM invoice_data
group by 1,2,3
    ;;
  }

  dimension: region {
    type: string
    sql: ${TABLE}.region ;;
  }

  dimension: district {
    type: string
    sql: ${TABLE}.district ;;
  }

  dimension: equipment_class_id {
    type: number
    value_format: "0"
    sql: ${TABLE}.equipment_class_id ;;
  }

  dimension: average_four_week_rate {
    type: number
    value_format: "$#,##0"
    sql: ${TABLE}.average_four_week_rate ;;
    label: "Avg 4-Week Rate"
  }

  # measure: average_four_week_rate_sum {
  #   type: average
  #   value_format: "$#,##0"
  #   sql: ${TABLE}.average_four_week_rate ;;
  #   label: "Avg 4-Week Rate"
  # }
}
