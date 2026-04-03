#
# The purpose of this view is to capture rateachievement metrics.
# Initially this is just an average discount which was weighted based on online rate.
#
#Related story:
# [https://app.shortcut.com/businessanalytics/story/278895/salesperson-overview-section-refresh]
#
# Britt Shanklin | Built 2023-08-15 | Modified 2023-08-16
view: rateachievement {
  derived_table: {
    sql:
    select salesperson_user_id,
           case when sum(online_rate) != 0 and sum(percent_discount) is not null then (sum(percent_discount*online_rate)/sum(online_rate))
                else null end as avg_percent_discount
    from analytics.public.rateachievement_points
    where salesperson_user_id = try_to_number(split_part({{ _filters['salesperson_rateachievement.full_name_with_id'] | sql_quote }}, '-', 2))
      and date_created > (current_date - INTERVAL '30 Days')
    group by salesperson_user_id
      ;;
  }

  dimension: salesperson_user_id {
    type: string
    sql: ${TABLE}."SALESPERSON_USER_ID" ;;
  }

  dimension: avg_percent_discount_base {
    hidden: yes
    type: number
    sql: ${TABLE}."AVG_PERCENT_DISCOUNT" ;;
  }

  measure: avg_percent_discount {
    type: number
    sql: ${avg_percent_discount_base} ;;
    value_format: "0.00%"
  }

}
