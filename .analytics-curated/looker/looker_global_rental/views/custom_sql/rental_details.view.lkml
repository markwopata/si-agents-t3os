view: rental_details {
derived_table: {
  # datagroup_trigger: Every_5_Min_Update
  sql:
  with avg_class_rates as (
  select ec.equipment_class_id,
            ec.name as asset_class,
            avg(r.price_per_day) as daily_class_avg,
            avg(r.price_per_week) as weekly_class_avg,
            avg(r.price_per_month) as monthly_class_avg,
            avg(r.price_per_hour) as hourly_class_avg
        from ES_WAREHOUSE.public.orders o
            join ES_WAREHOUSE.public.rentals r on o.order_id = r.order_id
            join ES_WAREHOUSE.public.markets m on m.market_id = o.market_id
        --    left join ES_WAREHOUSE.public.equipment_assignments ea on r.rental_id = ea.rental_id and coalesce(ea.end_date, current_timestamp) >= r.end_date
            left join ES_WAREHOUSE.public.equipment_classes ec on ec.equipment_class_id = r.equipment_class_id
        where m.company_id =  {{ _user_attributes['company_id'] }}
        group by ec.equipment_class_id, ec.name
  )
  select distinct o.order_id, r.rental_id,
          r.equipment_class_id,
          ec.name as asset_class,
          m.market_id as branch_id,
          m.name as branch,
          rst.name as rental_status,
  --        o.purchase_order_reference as purchase_order,
          po.name as purchase_order,
          u.company_id as customer_id,
          c.name as customer,
          nt.name as account_net_terms,
          coalesce(ea.asset_id, r.asset_id) as asset_id,
          initcap(aty.name) as asset_type,
          owner.name as asset_owner,
          l.nickname as jobsite,
          concat(l.nickname, ' - ', l.street_1, ', ', l.city, ', ', st.abbreviation,', ', l.zip_code) as jobsite_location,
          CONVERT_TIMEZONE('{{ _user_attributes['user_timezone'] }}', r.start_date) as rental_start,
          r.end_date as rental_end,
          r.price_per_day, r.price_per_week, r.price_per_month, r.price_per_hour, rpo.name as rpo_options,
          r.has_re_rent as subrent,
          r.drop_off_delivery_id,
          r.return_delivery_id,
          m.company_id as renter_company_id,
          coalesce(concat(salesperson.last_name, ', ', salesperson.first_name), 'No Assigned Salesperson') as salesperson,
          cr.daily_class_avg,
          cr.weekly_class_avg,
          cr.monthly_class_avg,
          cr.hourly_class_avg
          from ES_WAREHOUSE.public.orders o
            join ES_WAREHOUSE.public.rentals r on o.order_id = r.order_id
            join ES_WAREHOUSE.public.markets m on m.market_id = o.market_id
            left join ES_WAREHOUSE.public.equipment_assignments ea on r.rental_id = ea.rental_id and coalesce(ea.end_date, current_timestamp) >= r.end_date
 -- Updating logic to show last asset on a rent to remove duplicate rows
 --             and ES_WAREHOUSE.public.overlaps(r.end_date, r.end_date, ea.start_date, coalesce(ea.end_date, current_timestamp))
            left join ES_WAREHOUSE.public.rental_statuses rst on rst.rental_status_id = r.rental_status_id
            left join ES_WAREHOUSE.public.equipment_classes ec on ec.equipment_class_id = r.equipment_class_id
            left join ES_WAREHOUSE.public.order_salespersons os on o.order_id = os.order_id
            left join ES_WAREHOUSE.public.users u on o.user_id = u.user_id
            left join ES_WAREHOUSE.public.users salesperson on o.salesperson_user_id = salesperson.user_id or os.user_id = salesperson.user_id
            left join ES_WAREHOUSE.public.companies c on u.company_id = c.company_id
            left join  ES_WAREHOUSE.public.rental_location_assignments rla on r.rental_id = rla.rental_id
            left join  ES_WAREHOUSE.public.locations l on l.location_id = rla.location_id
            left join ES_WAREHOUSE.public.states st on l.state_id = st.state_id
            left join ES_WAREHOUSE.public.rental_purchase_options rpo on r.rental_purchase_option_id = rpo.rental_purchase_option_id
            left join ES_WAREHOUSE.PUBLIC.purchase_orders po on o.purchase_order_id = po.purchase_order_id
            left join ES_WAREHOUSE.PUBLIC.assets a on coalesce(ea.asset_id, r.asset_id) = a.asset_id
            left join ES_WAREHOUSE.PUBLIC.asset_types aty on a.asset_type_id = aty.asset_type_id
            left join ES_WAREHOUSE.PUBLIC.companies owner ON a.company_id = owner.company_id
            left join ES_WAREHOUSE.PUBLIC.net_terms nt on c.net_terms_id = nt.net_terms_id
            left join avg_class_rates cr on cr.equipment_class_id = r.equipment_class_id
        where
          m.company_id = {{ _user_attributes['company_id'] }}
          AND r.rental_status_id <> 8
       ;;
}

  dimension: compound_primary_key {
    primary_key: yes
    type: number
    sql: concat(${rental_id},${asset_id}) ;;
  }

  dimension: rental_id {
    type: string
    sql: ${TABLE}."RENTAL_ID";;
    value_format_name: id
    html: <font color="blue"><u><a href="https://manage.estrack.io/rentops/rentals/{{ rental_id._filterable_value }}" target="_blank">{{value}}</a></font></u>;;
  }

  dimension: order_id {
    type: string
    sql: ${TABLE}."ORDER_ID";;
    value_format_name: id
    html: <font color="blue"><u><a href="https://manage.estrack.io/rentops/orders/{{ order_id._filterable_value }}" target="_blank">{{value}}</a></font></u>;;
  }

  dimension: branch_id {
    type: number
    sql: ${TABLE}."BRANCH_ID";;
    value_format_name: id
  }

  dimension: equipment_class_id {
    type: number
    sql: ${TABLE}."EQUIPMENT_CLASS_ID";;
    value_format_name: id
  }

  dimension: asset_class {
    type: string
    sql: ${TABLE}."ASSET_CLASS";;
  }

  dimension: purchase_order {
    type: string
    sql: ${TABLE}."PURCHASE_ORDER";;
  }

  dimension: rental_status {
    type: string
    sql: ${TABLE}."RENTAL_STATUS";;
  }

  dimension: branch {
    type: string
    sql: ${TABLE}."BRANCH";;
  }

dimension: customer_id {
  type: number
  sql: ${TABLE}."CUSTOMER_ID" ;;
  value_format_name: id
}

  dimension: customer {
    type: string
    sql: ${TABLE}."CUSTOMER";;
  }

  dimension: account_net_terms {
    type: string
    sql: ${TABLE}."ACCOUNT_NET_TERMS";;
  }

  dimension: asset_id {
    type: string
    sql: ${TABLE}."ASSET_ID" ;;
    value_format_name: id
  }

  dimension: asset_type {
    type: string
    sql: ${TABLE}."ASSET_TYPE";;
  }

  dimension: asset_owner {
    type: string
    sql: ${TABLE}."ASSET_OWNER";;
  }

  dimension: jobsite {
    type: string
    sql: ${TABLE}."JOBSITE";;
  }

  dimension: jobsite_location {
    type: string
    sql: ${TABLE}."JOBSITE_LOCATION";;
  }

  dimension_group: rental_start {
    type: time
    timeframes: [
      raw,
      date,
      week,
      month,
      year
    ]
    sql: CAST(${TABLE}."RENTAL_START" AS TIMESTAMP_NTZ) ;;
    # html: {{ rendered_value | date: "%b %e, %Y %H:%M:%S" }};;
    }

  dimension_group: rental_end {
    type: time
    timeframes: [
      raw,
      date,
      week,
      month,
      year
    ]
    sql: CONVERT_TIMEZONE('{{ _user_attributes['user_timezone'] }}', CAST(${TABLE}."RENTAL_END" AS TIMESTAMP_NTZ)) ;;
    # html: {{ rendered_value | date: "%b %e, %Y %H:%M:%S" }};;
  }

  dimension: price_per_month {
    label: "4wk Rate"
    type: string
    sql: ${TABLE}."PRICE_PER_MONTH" ;;
    value_format_name: usd
    drill_fields: [asset_class,
                  asset_id,
                  asset_class_rate_averages.monthly_class_avg
                  ]
  }

  dimension: price_per_week {
    label: "Week Rate"
    type: string
    sql: ${TABLE}."PRICE_PER_WEEK" ;;
    value_format_name: usd
    drill_fields: [asset_class,
      asset_id,
      asset_class_rate_averages.weekly_class_avg
    ]
  }

  dimension: price_per_day {
    label: "Day Rate"
    type: string
    sql: ${TABLE}."PRICE_PER_DAY" ;;
    value_format_name: usd
    drill_fields: [asset_class,
      asset_id,
      asset_class_rate_averages.daily_class_avg
    ]
  }

  dimension: price_per_hour {
    label: "Hr Rate"
    type: string
    sql: ${TABLE}."PRICE_PER_HOUR" ;;
    value_format_name: usd
    drill_fields: [asset_class,
      asset_id,
      asset_class_rate_averages.hourly_class_avg
    ]
  }

  dimension: rpo_option {
    label: "Rental Protection Plan"
    type: string
    sql: ${TABLE}."RPO_OPTION" ;;
  }

  dimension: subrent {
    type: yesno
    sql: ${TABLE}."SUBRENT" ;;
  }

  dimension: drop_off_delivery_id {
    type: number
    sql: ${TABLE}."DROP_OFF_DELIVERY_ID" ;;
    value_format_name: id
  }

  dimension: return_delivery_id {
    type: number
    sql: ${TABLE}."RETURN_DELIVERY_ID" ;;
    value_format_name: id
  }

  dimension: renter_company_id {
    label: "RentOps_company_id"
    type: number
    sql: ${TABLE}."RENTER_COMPANY_ID" ;;
    value_format_name: id
  }

  dimension: salesperson {
    type: string
    sql: ${TABLE}."SALESPERSON";;
  }

  dimension: daily_class_avg {
    type: number
    sql: ${TABLE}."DAILY_CLASS_AVG";;
    value_format_name: usd
  }

  dimension: weekly_class_avg {
    type: number
    sql: ${TABLE}."WEEKLY_CLASS_AVG";;
    value_format_name: usd
  }

  dimension: monthly_class_avg {
    type: number
    sql: ${TABLE}."MONTHLY_CLASS_AVG";;
    value_format_name: usd
  }

  dimension: hourly_class_avg {
    type: number
    sql: ${TABLE}."HOURLY_CLASS_AVG";;
    value_format_name: usd
  }

  dimension_group: rental_duration {
    type: duration
    sql_start: ${rental_start_date} ;;  # often this is a single database column
    sql_end: ${rental_end_date} ;;  # often this is a single database column
    intervals: [month, day] # valid intervals described below
  }

  dimension: rentalID_link_to_Rentops {
    label: "Link to Rental"
    type: string
    sql: ${rental_id};;
    html: <font color="blue"><u><a href="https://manage.dev.estrack.io/rentops/rentals/{{ rental_id._filterable_value }}" target="_blank">{{value}}</a></font></u>;;
  }

  measure: num_distinct_customers {
    type: count_distinct
    sql: ${customer} ;;
    value_format_name: decimal_0
    drill_fields: [customer, num_rentals]
  }

  measure: num_rentals {
    type: count_distinct
    sql: ${rental_id} ;;
    value_format_name: decimal_0
    drill_fields: [rental_details*]
  }

  measure: num_onrent_rentals {
    label: "On Rent Rentals"
    type: count_distinct
    sql: ${rental_id} ;;
    filters: [rental_status: "On Rent"]
    value_format_name: decimal_0
    drill_fields: [rental_details*]
  }

  measure: date_of_last_rent {
    type: date
    sql: max(${rental_start_date}) ;;
    html: {{ rendered_value | date: "%B %d, %Y" }} ;;
  }

  measure: first_rental_date {
    type: date
    sql: min(${rental_end_raw}) ;;
    html: {{ rendered_value | date: "%B %d, %Y" }} ;;
  }

  measure: days_since_last_rental {
    type: number
    value_format_name: decimal_0
    sql: DATEDIFF(DAYS, ${rental_end_raw}, current_timestamp()) ;;
  }

  measure: monthly_avg_rate_diff {
    required_fields: [monthly_class_avg,price_per_month]
    type: number
    sql: (${price_per_month}-${monthly_class_avg})/case when ${monthly_class_avg} = 0 then null else ${monthly_class_avg} end  ;;
    value_format_name: percent_1
  }

  measure: daily_avg_rate_diff {
    required_fields: [daily_class_avg, price_per_day]
    type: number
    sql: (${price_per_day}-${daily_class_avg})/case when ${daily_class_avg} = 0 then null else ${daily_class_avg} end ;;
    value_format_name: percent_1
  }

  measure: weekly_avg_rate_diff {
    required_fields: [weekly_class_avg, price_per_week]
    type: number
    sql: (${price_per_week}-${weekly_class_avg})/case when ${weekly_class_avg} = 0 then null else ${weekly_class_avg} end ;;
    value_format_name: percent_1
  }

  measure: hourly_avg_rate_diff {
    required_fields: [hourly_class_avg, price_per_hour]
    type: number
    sql: (${price_per_hour}-${hourly_class_avg})/case when ${hourly_class_avg} = 0 then null else ${hourly_class_avg} end ;;
    value_format_name: percent_1
  }

  set: rental_details {
    fields: [rental_id, rental_status, customer, asset_id, asset_class, equipmentclass_category_parentcategory.asset_class, jobsite, rental_start_date, rental_end_date, price_per_month, price_per_week, price_per_day]
  }
  }
