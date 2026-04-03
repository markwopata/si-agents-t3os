view: conversion_rate_testing {
  derived_table: {
    sql:



                                  ------------------------ Region Parameter Break ------------------------



                                        {% if location_breakdown._parameter_value == "'Region'" %}

with date_range as (
      SELECT CASE WHEN
                  datediff(day,{% date_start ultimate_date_filter %},{% date_end ultimate_date_filter %}) < 7
             THEN
                  dateadd(day,-7,{% date_start ultimate_date_filter %})
             ELSE
                  dateadd(day,datediff(day,{% date_end ultimate_date_filter %},{% date_start ultimate_date_filter %}),{% date_start ultimate_date_filter %})
             END as date
      --- This date is here because it will bring in a lagging 7 days incase a user selects less than 7 days in the date filter. This is needed because of the 7 conversion rate
      UNION ALL
      SELECT dateadd('day',1,date)
      FROM date_range
      WHERE  date_range.date BETWEEN date_range.date and {% date_end ultimate_date_filter%}
      ),
timeframe as (
select
                      m.REGION_NAME as location,
                      q.quote_number,
                      NULL as order_id,
                      q.created_date,
                      q.start_date,
                      q.end_date,
                      NULL as order_created_date,
                      q.company_id,
                      coalesce(c.NAME,q.new_company_name) as complete_company_names,
                      concat(u.FIRST_NAME, ' ', u.LAST_NAME) as salesperson_full_name,
                      q.missed_rental_reason,
                      q.missed_rental_reason_other,
                      coalesce(equipment_class_name,concat('Bulk Item - ',et.part_id)) as full_equipment_name,
                      et.day_rate,
                      et.week_rate,
                      et.four_week_rate,
                      CASE WHEN
                      dr.date BETWEEN {% date_start ultimate_date_filter%} AND {% date_end ultimate_date_filter%} THEN 'Current'
                      WHEN dr.date BETWEEN (dateadd(day,datediff(day,{% date_end ultimate_date_filter %},{% date_start ultimate_date_filter %}),{% date_start ultimate_date_filter %})) AND (dateadd(day,-1,{% date_start ultimate_date_filter %})) THEN 'Previous'
                      END as timeframe,
                      dr.date
                  from quotes.quotes.quote as q
                  left join QUOTES.QUOTES.EQUIPMENT_TYPE et
                            on q.ID = et.QUOTE_ID
                  left join ANALYTICS.PUBLIC.MARKET_REGION_XWALK as m
                            on q.branch_id = m.MARKET_ID
                  left join ES_WAREHOUSE.PUBLIC.COMPANIES as c
                            on c.COMPANY_ID = q.company_id
                  left join ES_WAREHOUSE.PUBLIC.USERS as u
                            on u.USER_ID = q.sales_rep_id
                  join date_range as dr
                            on date_trunc('day', q.CREATED_DATE) = dr.date
            where
            {% condition customer_name %} coalesce(c.NAME,q.new_company_name) {% endcondition %}
            AND {% condition salesperson_name %} concat(u.FIRST_NAME, ' ', u.LAST_NAME) {% endcondition %}
            AND {% condition locations %} m.REGION_NAME {% endcondition %}
UNION ALL
select
                      m.REGION_NAME,
                      NULL,
                      q.order_id,
                      NULL,
                      NULL,
                      NULL,
                      q.order_created_date,
                      q.company_id,
                      coalesce(c.NAME,q.new_company_name),
                      concat(u.FIRST_NAME, ' ', u.LAST_NAME),
                      NULL,
                      NULL,
                      coalesce(equipment_class_name,concat('Bulk Item - ',et.part_id)) as full_equipment_name,
                      et.day_rate,
                      et.week_rate,
                      et.four_week_rate,
                      CASE WHEN
                      dr.date BETWEEN {% date_start ultimate_date_filter%} AND {% date_end ultimate_date_filter%} THEN 'Current'
                      WHEN dr.date BETWEEN (dateadd(day,datediff(day,{% date_end ultimate_date_filter %},{% date_start ultimate_date_filter %}),{% date_start ultimate_date_filter %})) AND (dateadd(day,-1,{% date_start ultimate_date_filter %})) THEN 'Previous'
                      END,
                      dr.date
                  from quotes.quotes.quote as q
                  left join QUOTES.QUOTES.EQUIPMENT_TYPE et
                            on q.ID = et.QUOTE_ID
                  left join ANALYTICS.PUBLIC.MARKET_REGION_XWALK as m
                            on q.branch_id = m.MARKET_ID
                  left join ES_WAREHOUSE.PUBLIC.COMPANIES as c
                            on c.COMPANY_ID = q.company_id
                  left join ES_WAREHOUSE.PUBLIC.USERS as u
                            on u.USER_ID = q.sales_rep_id
                  join date_range as dr
                            on date_trunc('day', q.ORDER_CREATED_DATE) = dr.date
            where
            {% condition customer_name %} coalesce(c.NAME,q.new_company_name) {% endcondition %}
            AND {% condition salesperson_name %} concat(u.FIRST_NAME, ' ', u.LAST_NAME) {% endcondition %}
            AND {% condition locations %} m.REGION_NAME {% endcondition %}
),
quote_count as (
    select t.date as quote_created_date,
           count( distinct t.quote_number) as count_of_quotes
    from timeframe t
    group by t.date
),
order_count as (
    select t2.date as order_created_date,
           count(distinct t2.order_id) count_of_orders
    from timeframe t2
    group by t2.date
),
quote_order_main as (
select dr.date as conversion_date,
       coalesce(qc.count_of_quotes,0) as total_count_of_quotes,
       coalesce(oc.count_of_orders,0) as total_count_of_orders,
      --coalesce((count_of_orders/case when count_of_quotes = 0 then null else count_of_quotes end),0) as conversion_percent
       coalesce(count_of_orders/nullifzero(count_of_quotes),0) as conversion_percent
from date_range dr
    left join quote_count qc
    on dr.date = qc.quote_created_date
    left join order_count oc
    on dr.date = oc.order_created_date
),
rolling_av as (
select m.*,
      avg(m.conversion_percent) over (order by m.conversion_date, m.conversion_date rows between 6 preceding and current row) as rolling_avg_percent
from quote_order_main m
),
final_rolling as (
select *
from rolling_av fra
where fra.conversion_date BETWEEN fra.conversion_date AND {% date_end ultimate_date_filter%} --- This date is the same as date_range.date (reference CTE above)
)
select t3.*,
       fa.rolling_avg_percent
from timeframe t3
left join final_rolling fa
on t3.date = fa.conversion_date







                                  ------------------------ District Parameter Break ------------------------



                                        {% elsif location_breakdown._parameter_value == "'District'" %}

with date_range as (
      SELECT CASE WHEN
                  datediff(day,{% date_start ultimate_date_filter %},{% date_end ultimate_date_filter %}) < 7
             THEN
                  dateadd(day,-7,{% date_start ultimate_date_filter %})
             ELSE
                  dateadd(day,datediff(day,{% date_end ultimate_date_filter %},{% date_start ultimate_date_filter %}),{% date_start ultimate_date_filter %})
             END as date
      --- This date is here because it will bring in a lagging 7 days incase a user selects less than 7 days in the date filter. This is needed because of the 7 conversion rate
      UNION ALL
      SELECT dateadd('day',1,date)
      FROM date_range
      WHERE  date_range.date BETWEEN date_range.date and {% date_end ultimate_date_filter%}
      ),
timeframe as (
select
                      m.DISTRICT as location,
                      q.quote_number,
                      NULL as order_id,
                      q.created_date,
                      q.start_date,
                      q.end_date,
                      NULL as order_created_date,
                      q.company_id,
                      coalesce(c.NAME,q.new_company_name) as complete_company_names,
                      concat(u.FIRST_NAME, ' ', u.LAST_NAME) as salesperson_full_name,
                      q.missed_rental_reason,
                      q.missed_rental_reason_other,
                      coalesce(equipment_class_name,concat('Bulk Item - ',et.part_id)) as full_equipment_name,
                      et.day_rate,
                      et.week_rate,
                      et.four_week_rate,
                      CASE WHEN
                      dr.date BETWEEN {% date_start ultimate_date_filter%} AND {% date_end ultimate_date_filter%} THEN 'Current'
                      WHEN dr.date BETWEEN (dateadd(day,datediff(day,{% date_end ultimate_date_filter %},{% date_start ultimate_date_filter %}),{% date_start ultimate_date_filter %})) AND (dateadd(day,-1,{% date_start ultimate_date_filter %})) THEN 'Previous'
                      END as timeframe,
                      dr.date
                  from quotes.quotes.quote as q
                  left join QUOTES.QUOTES.EQUIPMENT_TYPE et
                            on q.ID = et.QUOTE_ID
                  left join ANALYTICS.PUBLIC.MARKET_REGION_XWALK as m
                            on q.branch_id = m.MARKET_ID
                  left join ES_WAREHOUSE.PUBLIC.COMPANIES as c
                            on c.COMPANY_ID = q.company_id
                  left join ES_WAREHOUSE.PUBLIC.USERS as u
                            on u.USER_ID = q.sales_rep_id
                  join date_range as dr
                            on date_trunc('day', q.CREATED_DATE) = dr.date
            where
            {% condition customer_name %} coalesce(c.NAME,q.new_company_name) {% endcondition %}
            AND {% condition salesperson_name %} concat(u.FIRST_NAME, ' ', u.LAST_NAME) {% endcondition %}
            AND {% condition locations %} m.DISTRICT {% endcondition %}
UNION ALL
select
                      m.DISTRICT,
                      NULL,
                      q.order_id,
                      NULL,
                      NULL,
                      NULL,
                      q.order_created_date,
                      q.company_id,
                      coalesce(c.NAME,q.new_company_name),
                      concat(u.FIRST_NAME, ' ', u.LAST_NAME),
                      NULL,
                      NULL,
                      coalesce(equipment_class_name,concat('Bulk Item - ',et.part_id)) as full_equipment_name,
                      et.day_rate,
                      et.week_rate,
                      et.four_week_rate,
                      CASE WHEN
                      dr.date BETWEEN {% date_start ultimate_date_filter%} AND {% date_end ultimate_date_filter%} THEN 'Current'
                      WHEN dr.date BETWEEN (dateadd(day,datediff(day,{% date_end ultimate_date_filter %},{% date_start ultimate_date_filter %}),{% date_start ultimate_date_filter %})) AND (dateadd(day,-1,{% date_start ultimate_date_filter %})) THEN 'Previous'
                      END,
                      dr.date
                  from quotes.quotes.quote as q
                  left join QUOTES.QUOTES.EQUIPMENT_TYPE et
                            on q.ID = et.QUOTE_ID
                  left join ANALYTICS.PUBLIC.MARKET_REGION_XWALK as m
                            on q.branch_id = m.MARKET_ID
                  left join ES_WAREHOUSE.PUBLIC.COMPANIES as c
                            on c.COMPANY_ID = q.company_id
                  left join ES_WAREHOUSE.PUBLIC.USERS as u
                            on u.USER_ID = q.sales_rep_id
                  join date_range as dr
                            on date_trunc('day', q.ORDER_CREATED_DATE) = dr.date
            where
            {% condition customer_name %} coalesce(c.NAME,q.new_company_name) {% endcondition %}
            AND {% condition salesperson_name %} concat(u.FIRST_NAME, ' ', u.LAST_NAME) {% endcondition %}
            AND {% condition locations %} m.DISTRICT {% endcondition %}
),
quote_count as (
    select t.date as quote_created_date,
           count( distinct t.quote_number) as count_of_quotes
    from timeframe t
    group by t.date
),
order_count as (
    select t2.date as order_created_date,
           count(distinct t2.order_id) count_of_orders
    from timeframe t2
    group by t2.date
),
quote_order_main as (
select dr.date as conversion_date,
       coalesce(qc.count_of_quotes,0) as total_count_of_quotes,
       coalesce(oc.count_of_orders,0) as total_count_of_orders,
      --coalesce((count_of_orders/case when count_of_quotes = 0 then null else count_of_quotes end),0) as conversion_percent
       coalesce(count_of_orders/nullifzero(count_of_quotes),0) as conversion_percent
from date_range dr
    left join quote_count qc
    on dr.date = qc.quote_created_date
    left join order_count oc
    on dr.date = oc.order_created_date
),
rolling_av as (
select m.*,
      avg(m.conversion_percent) over (order by m.conversion_date, m.conversion_date rows between 6 preceding and current row) as rolling_avg_percent
from quote_order_main m
),
final_rolling as (
select *
from rolling_av fra
where fra.conversion_date BETWEEN fra.conversion_date AND {% date_end ultimate_date_filter%} --- This date is the same as date_range.date (reference CTE above)
)
select t3.*,
       fa.rolling_avg_percent
from timeframe t3
left join final_rolling fa
on t3.date = fa.conversion_date








                                  ------------------------ Market Parameter Break ------------------------



                                                                 {% else %}

with date_range as (
      SELECT CASE WHEN
                  datediff(day,{% date_start ultimate_date_filter %},{% date_end ultimate_date_filter %}) < 7
             THEN
                  dateadd(day,-7,{% date_start ultimate_date_filter %})
             ELSE
                  dateadd(day,datediff(day,{% date_end ultimate_date_filter %},{% date_start ultimate_date_filter %}),{% date_start ultimate_date_filter %})
             END as date
      --- This date is here because it will bring in a lagging 7 days incase a user selects less than 7 days in the date filter. This is needed because of the 7 conversion rate
      UNION ALL
      SELECT dateadd('day',1,date)
      FROM date_range
      WHERE  date_range.date BETWEEN date_range.date and {% date_end ultimate_date_filter%}
      ),
timeframe as (
select
                      m.MARKET_NAME as location,
                      q.quote_number,
                      NULL as order_id,
                      q.created_date,
                      q.start_date,
                      q.end_date,
                      NULL as order_created_date,
                      q.company_id,
                      coalesce(c.NAME,q.new_company_name) as complete_company_names,
                      concat(u.FIRST_NAME, ' ', u.LAST_NAME) as salesperson_full_name,
                      q.missed_rental_reason,
                      q.missed_rental_reason_other,
                      coalesce(equipment_class_name,concat('Bulk Item - ',et.part_id)) as full_equipment_name,
                      et.day_rate,
                      et.week_rate,
                      et.four_week_rate,
                      CASE WHEN
                      dr.date BETWEEN {% date_start ultimate_date_filter%} AND {% date_end ultimate_date_filter%} THEN 'Current'
                      WHEN dr.date BETWEEN (dateadd(day,datediff(day,{% date_end ultimate_date_filter %},{% date_start ultimate_date_filter %}),{% date_start ultimate_date_filter %})) AND (dateadd(day,-1,{% date_start ultimate_date_filter %})) THEN 'Previous'
                      END as timeframe,
                      dr.date
                  from quotes.quotes.quote as q
                  left join QUOTES.QUOTES.EQUIPMENT_TYPE et
                            on q.ID = et.QUOTE_ID
                  left join ANALYTICS.PUBLIC.MARKET_REGION_XWALK as m
                            on q.branch_id = m.MARKET_ID
                  left join ES_WAREHOUSE.PUBLIC.COMPANIES as c
                            on c.COMPANY_ID = q.company_id
                  left join ES_WAREHOUSE.PUBLIC.USERS as u
                            on u.USER_ID = q.sales_rep_id
                  join date_range as dr
                            on date_trunc('day', q.CREATED_DATE) = dr.date
            where
            {% condition customer_name %} coalesce(c.NAME,q.new_company_name) {% endcondition %}
            AND {% condition salesperson_name %} concat(u.FIRST_NAME, ' ', u.LAST_NAME) {% endcondition %}
            AND {% condition locations %} m.MARKET_NAME {% endcondition %}
UNION ALL
select
                      m.MARKET_NAME,
                      NULL,
                      q.order_id,
                      NULL,
                      NULL,
                      NULL,
                      q.order_created_date,
                      q.company_id,
                      coalesce(c.NAME,q.new_company_name),
                      concat(u.FIRST_NAME, ' ', u.LAST_NAME),
                      NULL,
                      NULL,
                      coalesce(equipment_class_name,concat('Bulk Item - ',et.part_id)) as full_equipment_name,
                      et.day_rate,
                      et.week_rate,
                      et.four_week_rate,
                      CASE WHEN
                      dr.date BETWEEN {% date_start ultimate_date_filter%} AND {% date_end ultimate_date_filter%} THEN 'Current'
                      WHEN dr.date BETWEEN (dateadd(day,datediff(day,{% date_end ultimate_date_filter %},{% date_start ultimate_date_filter %}),{% date_start ultimate_date_filter %})) AND (dateadd(day,-1,{% date_start ultimate_date_filter %})) THEN 'Previous'
                      END,
                      dr.date
                  from quotes.quotes.quote as q
                  left join QUOTES.QUOTES.EQUIPMENT_TYPE et
                            on q.ID = et.QUOTE_ID
                  left join ANALYTICS.PUBLIC.MARKET_REGION_XWALK as m
                            on q.branch_id = m.MARKET_ID
                  left join ES_WAREHOUSE.PUBLIC.COMPANIES as c
                            on c.COMPANY_ID = q.company_id
                  left join ES_WAREHOUSE.PUBLIC.USERS as u
                            on u.USER_ID = q.sales_rep_id
                  join date_range as dr
                            on date_trunc('day', q.ORDER_CREATED_DATE) = dr.date
            where
            {% condition customer_name %} coalesce(c.NAME,q.new_company_name) {% endcondition %}
            AND {% condition salesperson_name %} concat(u.FIRST_NAME, ' ', u.LAST_NAME) {% endcondition %}
            AND {% condition locations %} m.MARKET_NAME {% endcondition %}
),
quote_count as (
    select t.date as quote_created_date,
           count( distinct t.quote_number) as count_of_quotes
    from timeframe t
    group by t.date
),
order_count as (
    select t2.date as order_created_date,
           count(distinct t2.order_id) count_of_orders
    from timeframe t2
    group by t2.date
),
quote_order_main as (
select dr.date as conversion_date,
       coalesce(qc.count_of_quotes,0) as total_count_of_quotes,
       coalesce(oc.count_of_orders,0) as total_count_of_orders,
      --coalesce((count_of_orders/case when count_of_quotes = 0 then null else count_of_quotes end),0) as conversion_percent
       coalesce(count_of_orders/nullifzero(count_of_quotes),0) as conversion_percent
from date_range dr
    left join quote_count qc
    on dr.date = qc.quote_created_date
    left join order_count oc
    on dr.date = oc.order_created_date
),
rolling_av as (
select m.*,
      avg(m.conversion_percent) over (order by m.conversion_date, m.conversion_date rows between 6 preceding and current row) as rolling_avg_percent
from quote_order_main m
),
final_rolling as (
select *
from rolling_av fra
where fra.conversion_date BETWEEN fra.conversion_date AND {% date_end ultimate_date_filter%} --- This date is the same as date_range.date (reference CTE above)
)
select t3.*,
       fa.rolling_avg_percent
from timeframe t3
left join final_rolling fa
on t3.date = fa.conversion_date




                                                                 {% endif %};;
  }

  dimension: timeframe {
    type: string
    sql: ${TABLE}."TIMEFRAME" ;;
  }

  dimension: location {
    type: string
    sql: ${TABLE}."LOCATION" ;;
  }

  dimension: quote_number {
    type: string
    primary_key: yes
    sql: ${TABLE}."QUOTE_NUMBER" ;;
  }

  dimension: order_id {
    type: string
    sql: ${TABLE}."ORDER_ID" ;;
  }

  dimension_group: ultimate_date {
    type: time
    sql: ${TABLE}."DATE" ;;
    html: {{ rendered_value | date: "%b %d, %Y" }};;
  }

  dimension_group: created_date {
    label: "Quote Created"
    type: time
    sql: ${TABLE}."CREATED_DATE" ;;
  }

  dimension_group: start_date {
    label: "Rental Start"
    type: time
    sql: ${TABLE}."START_DATE" ;;
  }

  dimension_group: end_date {
    label: "Rental End"
    type: time
    sql: ${TABLE}."END_DATE" ;;
  }

  dimension_group: order_created_date {
    label: "Order Created"
    type: time
    sql: ${TABLE}."ORDER_CREATED_DATE" ;;
  }

  dimension: company_id {
    type: string
    sql: ${TABLE}."COMPANY_ID" ;;
  }

  dimension: complete_company_names {
    label: "Customer Name"
    type: string
    sql: ${TABLE}."COMPLETE_COMPANY_NAMES" ;;
  }

  dimension: salesperson_full_name {
    type: string
    label: "Salesperson"
    sql: ${TABLE}."SALESPERSON_FULL_NAME" ;;
  }

  dimension: missed_rental_reason {
    type: string
    sql: ${TABLE}."MISSED_RENTAL_REASON" ;;
  }

  dimension: other_reason {
    type: string
    sql: ${TABLE}."MISSED_RENTAL_REASON_OTHER" ;;
  }

  dimension: equipment_name {
    type: string
    sql: ${TABLE}."FULL_EQUIPMENT_NAME" ;;
  }

  dimension: day_rate {
    type: number
    sql: ${TABLE}."DAY_RATE" ;;
    value_format_name: usd_0
  }

  dimension: week_rate {
    type: number
    sql: ${TABLE}."WEEK_RATE" ;;
    value_format_name: usd_0
  }

  dimension: four_week_rate {
    type: number
    sql: ${TABLE}."FOUR_WEEK_RATE" ;;
    value_format_name: usd_0
  }

  # dimension_group: rental_days {
  #   type: duration
  #   intervals: [day]
  #   sql_start: ${start_date_date} ;;
  #   sql_end: ${end_date_date};;
  # }

  measure: count_of_quotes_per_day {
    type: count_distinct
    sql: ${quote_number} ;;
    filters: [quote_number: "-NULL"]
    drill_fields: [quote_info*]
  }

  measure: count_of_orders_per_day {
    type: count_distinct
    sql: ${order_id} ;;
    filters: [order_id: "-NULL"]
    drill_fields: [order_info*]
  }

  measure: total_count_of_current_quotes {
    type: count_distinct
    sql: ${quote_number} ;;
    filters: [timeframe: "Current", quote_number: "-NULL"]
    html:
    <a href="#drillmenu" style = "color:#000000;" target="_self">
    {{ rendered_value }} {% if difference_in_quotes._value > 0 %}

      {% assign indicator = "green,▲" | split: ',' %}

      {% elsif difference_in_quotes._value < 0 %}

      {% assign indicator = "red,▼" | split: ',' %}

      {% else %}

      {% endif %}

      <font color="{{indicator[0]}}">

      {% if value == 99999.12345 %} &infin

      {% else %}({{ difference_in_quotes._rendered_value }})

      {% endif %} {{indicator[1]}}

      </font>
      </a>;;
    drill_fields: [quote_info*]
  }

  measure: total_count_of_current_quotes_unformatted{
    type: count_distinct
    sql: ${quote_number};;
    filters: [timeframe: "Current", quote_number: "-NULL"]
    drill_fields: [quote_info*]
  }

  measure: total_count_of_current_other_missed_rental_reason {
    group_label: "Missed Rental Reasons"
    type: count_distinct
    sql: ${quote_number};;
    filters: [timeframe: "Current", quote_number: "-NULL", missed_rental_reason: "Other"]
    drill_fields: [other_missed_rental_reason_detail*]
  }

  measure: total_count_of_current_availability_missed_rental_reason {
    group_label: "Missed Rental Reasons"
    type: count_distinct
    sql: ${quote_number};;
    filters: [timeframe: "Current", quote_number: "-NULL", missed_rental_reason: "Availability"]
    drill_fields: [missed_rental_reason_details*]
  }

  measure: total_count_of_current_rate_missed_rental_reason {
    group_label: "Missed Rental Reasons"
    type: count_distinct
    sql: ${quote_number};;
    filters: [timeframe: "Current", quote_number: "-NULL", missed_rental_reason: "Rate"]
    drill_fields: [missed_rental_reason_details*]
  }

  measure: total_count_of_current_lack_of_transport_missed_rental_reason {
    group_label: "Missed Rental Reasons"
    type: count_distinct
    sql: ${quote_number};;
    filters: [timeframe: "Current", quote_number: "-NULL", missed_rental_reason: "Lack of Transport"]
    drill_fields: [missed_rental_reason_details*]
  }

  measure: total_count_of_current_orders {
    type: count_distinct
    sql: ${order_id} ;;
    filters: [timeframe: "Current", order_id: "-NULL"]
    html:
    <a href="#drillmenu" style = "color:#000000;" target="_self">
    {{ rendered_value }} {% if difference_in_orders._value > 0 %}

      {% assign indicator = "green,▲" | split: ',' %}

      {% elsif difference_in_orders._value < 0 %}

      {% assign indicator = "red,▼" | split: ',' %}

      {% else %}

      {% endif %}

      <font color="{{indicator[0]}}">

      {% if value == 99999.12345 %} &infin

      {% else %}({{ difference_in_orders._rendered_value }})

      {% endif %} {{indicator[1]}}

      </font>
      </a>;;
    drill_fields: [order_info*]
  }

  measure: total_count_of_current_orders_unformatted{
    type: count_distinct
    sql: ${order_id};;
    filters: [timeframe: "Current", order_id: "-NULL"]
    drill_fields: [order_info*]
  }

  measure: total_count_of_previous_quotes {
    type: count_distinct
    sql: ${quote_number} ;;
    filters: [timeframe: "Previous", quote_number: "-NULL"]
    drill_fields: [quote_info*]
  }

  measure: total_count_of_previous_orders {
    type: count_distinct
    sql: ${order_id};;
    filters: [timeframe: "Previous", order_id: "-NULL"]
    drill_fields: [order_info*]
  }

  measure: conversion_rate {
    type: number
    sql: ${total_count_of_current_orders}/case when ${total_count_of_current_quotes} = 0 then null else ${total_count_of_current_quotes} end ;;
    value_format_name: percent_1
    #drill_fields: [conversion_detail*]
  }

  dimension: rolling_average_conversion_rate {
    type: number
    sql: ${TABLE}."ROLLING_AVG_PERCENT";;
  }

  measure: rolling_average_conversion_rate_measure {
    type: number
    sql: ${rolling_average_conversion_rate} ;;
    value_format_name: percent_1
  }

  measure: difference_in_quotes {
    type: number
    sql: ${total_count_of_current_quotes} - ${total_count_of_previous_quotes} ;;
  }

  measure: difference_in_orders {
    type: number
    sql: ${total_count_of_current_orders} - ${total_count_of_previous_orders} ;;
  }

  # dimension: date_granularity {
  #   label_from_parameter: date_grain
  #   type: string
  #   sql:
  #     CASE
  #     WHEN {% parameter date_grain %} = 'Day' THEN ${ultimate_date_date}
  #     WHEN {% parameter date_grain %} = 'Week' THEN ${ultimate_date_week}
  #     WHEN {% parameter date_grain %} = 'Month' THEN ${ultimate_date_month}       --- Removing this because it doesn't work due to the 7 day rolling avg conversion rate
  #     ELSE NULL END;;
  #   html: {% if date_grain._parameter_value == "'Day'" %}
  #         {{ rendered_value | date: "%b %d, %Y" }}
  #         {% elsif date_grain._parameter_value == "'Week'"  %}
  #         {{ rendered_value | date: "%b %d, %Y" }}
  #         {% else %}
  #         {{ rendered_value | append: "-01" | date: "%b %Y" }}
  #         {% endif %} ;;
  # }


  # filter: date_filter {
  #   label: "Date Range"
  #   type: date_time
  # }

  filter: customer_name {
    type: string
  }

  filter: salesperson_name {
    type: string
  }

  filter: locations {
    type: string
  }

  filter: ultimate_date_filter {
    type: date_time
  }

  parameter: location_breakdown {
    type: string
    allowed_value: { value: "Region"}
    allowed_value: { value: "District"}
    allowed_value: { value: "Market"}
  }

  # parameter: date_grain {
  #   type: string
  #   allowed_value: {value: "Day"}
  #   allowed_value: {value: "Week"}
  #   allowed_value: {value: "Month"}
  # }

  set: quote_info {
    fields: [location,
      quote_number,
      created_date_date,
      complete_company_names,
      company_id,
      salesperson_full_name,
      equipment_name,
      day_rate,
      week_rate,
      four_week_rate]
  }

  set: order_info {
    fields: [location,
      order_id,
      order_created_date_date,
      complete_company_names,
      company_id,
      salesperson_full_name]
  }

  # set: conversion_detail {
  #   fields: [
  #     location,
  #     quote_number,
  #     created_date_date,
  #     order_id,                              ---- This drill doesn't really make sense
  #     order_created_date_date,
  #     complete_company_names,
  #     company_id,
  #     salesperson_full_name
  #   ]
  # }

  set: other_missed_rental_reason_detail {
    fields: [location,
      quote_number,
      created_date_date,
      complete_company_names,
      salesperson_full_name,
      missed_rental_reason,
      other_reason,
      equipment_name,
      day_rate,
      week_rate,
      four_week_rate]
  }

  set: missed_rental_reason_details {
    fields: [location,
      quote_number,
      created_date_date,
      complete_company_names,
      salesperson_full_name,
      missed_rental_reason,
      equipment_name,
      day_rate,
      week_rate,
      four_week_rate]
  }
}
