view: customer_first_rental {
 derived_table: {
   sql:
    select m.market_id, m.name as branch, c.company_id as customer_id, c.name as customer,
      rental_id as first_rental_id,
      r.start_date as first_rental_date
    --   row_number() over (partition by m.market_id, m.name, c.company_id, c.name order by r.end_date desc, start_date) as row_num
    from ES_WAREHOUSE.public.orders o
    join ES_WAREHOUSE.public.rentals r on o.order_id = r.order_id
    join ES_WAREHOUSE.public.markets m on m.market_id = o.market_id
    left join ES_WAREHOUSE.public.users u on o.user_id = u.user_id
    left join ES_WAREHOUSE.public.companies c on u.company_id = c.company_id
    where m.company_id = {{ _user_attributes['company_id'] }}
    qualify row_number() over (partition by m.market_id, m.name, c.company_id, c.name order by r.start_date) = 1
    order by c.name
    ;;
 }

  dimension: market_id {
    type: number
    sql: ${TABLE}."MARKET_ID";;
    value_format_name: id
  }

  dimension: branch {
    type: string
    sql: ${TABLE}."BRANCH";;
  }

  dimension:customer_id {
    primary_key: yes
    type: number
    sql: ${TABLE}."CUSTOMER_ID";;
    value_format_name: id
  }

  dimension: customer {
    type: string
    sql: ${TABLE}."CUSTOMER";;
  }

  dimension: first_rental_id {
    type: string
    sql: ${TABLE}."FIRST_RENTAL_ID";;
    html: <font color="blue"><u><a href="https://manage.estrack.io/rentops/rentals/{{ first_rental_id._filterable_value }}" target="_blank">{{value}}</a></font></u>;;
  }

  dimension_group: first_rental_date {
    type: time
    timeframes: [
      raw,
      date,
      week,
      month,
      year
    ]
    sql: CONVERT_TIMEZONE('{{ _user_attributes['user_timezone'] }}', CAST(${TABLE}."FIRST_RENTAL_DATE" AS TIMESTAMP_NTZ));;
  }

  measure: num_customers {
    type: count
    value_format_name: decimal_0
    drill_fields: [details*]
  }

  set: details {
    fields: [branch, customer, first_rental_id, first_rental_date_date]
  }

}
