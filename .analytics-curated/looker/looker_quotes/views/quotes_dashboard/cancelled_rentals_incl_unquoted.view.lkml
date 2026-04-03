view: cancelled_rentals_incl_unquoted {
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
    )

    -- ,timeframe as (
  SELECT
    xw.region_name AS location,
    o.order_id,
    o.date_created as order_date_created,
    r.rental_id,
    COALESCE(uc.company_id, q.company_id) as company_id,
    COALESCE(c.name, q.new_company_name) as company_name,
   -- concat(uc.FIRST_NAME, ' ', uc.LAST_NAME) as company_contact_full_name,
    concat(ur.FIRST_NAME, ' ', ur.LAST_NAME) as primary_salesperson_full_name,
    CASE WHEN dr.date BETWEEN {% date_start ultimate_date_filter%} AND {% date_end ultimate_date_filter%} THEN 'Current'
    WHEN dr.date BETWEEN (dateadd(day,datediff(day,{% date_end ultimate_date_filter %},{% date_start ultimate_date_filter %}),{% date_start ultimate_date_filter %})) AND (dateadd(day,-1,{% date_start ultimate_date_filter %})) THEN 'Previous' END as timeframe,
    r.cancel_reason_note,
    r.cancel_reason_type,
    r.equipment_class_id,
    ec.name as equipment_class_name,
    cat.SINGULAR_NAME as equipment_category,
    coalesce(pcat.singular_name, cat.singular_name, 'Bulk Items') AS parent_category_name,
    CASE
      WHEN cat.singular_name IS NULL THEN 'Bulk Items'
      WHEN cat.parent_category_id IS NOT NULL THEN cat.singular_name
      ELSE NULL
    END AS sub_category_name,
    q.id as quote_id,
    q.quote_number,
    CASE WHEN q.id IS NULL then FALSE ELSE TRUE END as order_has_quote,
    qp.rental_subtotal as quoted_subtotal_for_order_id,

    r.start_date as est_start_date, -- rough estimates FROM when the order/rental was originally put in
    r.end_date as est_end_date,
    CASE WHEN datediff(day, r.start_date, r.end_date) = 0 THEN 1 ELSE datediff(day, r.start_date, r.end_date) END as est_num_days,
    ROUND(est_num_days/7, 2) AS est_num_weeks,
    ROUND(est_num_days/28, 2) AS est_num_months,
    r.price_per_day,
    r.price_per_week,
    r.price_per_month,
    est_num_days * r.price_per_day AS day_cost,
    (floor(est_num_weeks) * r.price_per_week) + (r.price_per_day * (est_num_days-floor(est_num_weeks)*7)) AS round_down_week_plus_day_cost,
    ceil(est_num_weeks) * r.price_per_week AS round_up_week_cost,
    ceil(est_num_months) * r.price_per_month AS round_up_month_cost,
    LEAST(day_cost, round_down_week_plus_day_cost, round_up_week_cost, round_up_month_cost) as cheapest_option,
    rr.id AS online_rental_request_id,
    cd.employee_title AS quote_created_by_title
   /* CASE
        WHEN datediff(day, r.start_date, r.end_date) = 0 then r.price_per_day
        WHEN datediff(day, r.start_date, r.end_date) < 7 then datediff(day, r.start_date, r.end_date) * r.price_per_day
        WHEN datediff(day, r.start_date, r.end_date) < 28 then ROUND(DIV0NULL(datediff(day, r.start_date, r.end_date),7) * r.price_per_week, 0)
        WHEN datediff(day, r.start_date, r.end_date) >= 28 then ROUND(DIV0NULL(datediff(day, r.start_date, r.end_date),28) * r.price_per_month,0)
        ELSE NULL END as rental_estimation_price,*/

    FROM es_warehouse.public.orders o
    JOIN es_warehouse.public.rentals r ON r.order_id = o.order_id AND r.rental_status_id = 8
    JOIN analytics.public.market_region_xwalk xw ON xw.market_id = o.market_id
    LEFT JOIN es_warehouse.public.equipment_classes ec ON ec.equipment_class_id = r.equipment_class_id
    LEFT JOIN es_warehouse.public.categories cat ON ec.category_id = cat.category_id
    LEFT JOIN ES_WAREHOUSE.PUBLIC.CATEGORIES pcat ON cat.PARENT_CATEGORY_ID = pcat.CATEGORY_ID
    LEFT JOIN quotes.quotes.quote q ON q.order_id = o.order_id
    LEFT JOIN quotes.quotes.quote_pricing qp ON qp.quote_id = q.id
    LEFT JOIN es_warehouse.public.users uq ON q.created_by = uq.user_id
    LEFT JOIN analytics.payroll.company_directory cd ON uq.email_address = cd.work_email


    LEFT JOIN es_warehouse.public.users uc ON uc.user_id = o.user_id
    LEFT JOIN es_warehouse.public.companies c ON c.company_id = uc.company_id
    LEFT JOIN rental_order_request.public.rental_requests rr ON q.id = rr.quote_id
    LEFT JOIN es_warehouse.public.order_salespersons os ON os.order_id = o.order_id

    LEFT JOIN es_warehouse.public.users ur ON ur.user_id = os.user_id
    join date_range as dr on date_trunc('day', o.date_created) = dr.date
    where os.salesperson_type_id = 1
    AND {% condition customer_name %} COALESCE(c.name, q.new_company_name) {% endcondition %}
    AND {% condition salesperson_name %} concat(ur.FIRST_NAME, ' ', ur.LAST_NAME) {% endcondition %}
    AND {% condition locations %} xw.region_name {% endcondition %}
    AND {% condition parent_cat_name %}  coalesce(pcat.singular_name, cat.singular_name, 'Bulk Items') {% endcondition %}
    AND {% condition sub_cat_name %}
          CASE
          WHEN cat.singular_name IS NULL THEN 'Bulk Items'
          WHEN cat.parent_category_id IS NOT NULL THEN cat.singular_name
          ELSE NULL END {% endcondition %}




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

    )


    -- ,timeframe as (
   SELECT
    xw.district AS location,
    o.order_id,
    o.date_created as order_date_created,
    r.rental_id,
    COALESCE(uc.company_id, q.company_id) as company_id,
    COALESCE(c.name, q.new_company_name) as company_name,
   -- concat(uc.FIRST_NAME, ' ', uc.LAST_NAME) as company_contact_full_name,
    concat(ur.FIRST_NAME, ' ', ur.LAST_NAME) as primary_salesperson_full_name,
    CASE WHEN dr.date BETWEEN {% date_start ultimate_date_filter%} AND {% date_end ultimate_date_filter%} THEN 'Current'
    WHEN dr.date BETWEEN (dateadd(day,datediff(day,{% date_end ultimate_date_filter %},{% date_start ultimate_date_filter %}),{% date_start ultimate_date_filter %})) AND (dateadd(day,-1,{% date_start ultimate_date_filter %})) THEN 'Previous' END as timeframe,
    r.cancel_reason_note,
    r.cancel_reason_type,
    r.equipment_class_id,
    ec.name as equipment_class_name,
    cat.SINGULAR_NAME as equipment_category,
    coalesce(pcat.singular_name, cat.singular_name, 'Bulk Items') AS parent_category_name,
    CASE
      WHEN cat.singular_name IS NULL THEN 'Bulk Items'
      WHEN cat.parent_category_id IS NOT NULL THEN cat.singular_name
      ELSE NULL
    END AS sub_category_name,

    q.id as quote_id,
    q.quote_number,
    CASE WHEN q.id IS NULL then FALSE ELSE TRUE END as order_has_quote,
    qp.rental_subtotal as quoted_subtotal_for_order_id,

    r.start_date as est_start_date, -- rough estimates FROM when the order/rental was originally put in
    r.end_date as est_end_date,
    CASE WHEN datediff(day, r.start_date, r.end_date) = 0 THEN 1 ELSE datediff(day, r.start_date, r.end_date) END as est_num_days,
    ROUND(est_num_days/7, 2) AS est_num_weeks,
    ROUND(est_num_days/28, 2) AS est_num_months,
    r.price_per_day,
    r.price_per_week,
    r.price_per_month,
    est_num_days * r.price_per_day AS day_cost,
    (floor(est_num_weeks) * r.price_per_week) + (r.price_per_day * (est_num_days-floor(est_num_weeks)*7)) AS round_down_week_plus_day_cost,
    ceil(est_num_weeks) * r.price_per_week AS round_up_week_cost,
    ceil(est_num_months) * r.price_per_month AS round_up_month_cost,
    LEAST(day_cost, round_down_week_plus_day_cost, round_up_week_cost, round_up_month_cost) as cheapest_option,
    rr.id AS online_rental_request_id,
    cd.employee_title AS quote_created_by_title
   /* CASE
        WHEN datediff(day, r.start_date, r.end_date) = 0 then r.price_per_day
        WHEN datediff(day, r.start_date, r.end_date) < 7 then datediff(day, r.start_date, r.end_date) * r.price_per_day
        WHEN datediff(day, r.start_date, r.end_date) < 28 then ROUND(DIV0NULL(datediff(day, r.start_date, r.end_date),7) * r.price_per_week, 0)
        WHEN datediff(day, r.start_date, r.end_date) >= 28 then ROUND(DIV0NULL(datediff(day, r.start_date, r.end_date),28) * r.price_per_month,0)
        ELSE NULL END as rental_estimation_price,*/

    FROM es_warehouse.public.orders o
    JOIN es_warehouse.public.rentals r ON r.order_id = o.order_id AND r.rental_status_id = 8
    JOIN analytics.public.market_region_xwalk xw ON xw.market_id = o.market_id
    LEFT JOIN es_warehouse.public.equipment_classes ec ON ec.equipment_class_id = r.equipment_class_id
    LEFT JOIN es_warehouse.public.categories cat ON ec.category_id = cat.category_id
    LEFT JOIN ES_WAREHOUSE.PUBLIC.CATEGORIES pcat ON cat.PARENT_CATEGORY_ID = pcat.CATEGORY_ID
    LEFT JOIN quotes.quotes.quote q ON q.order_id = o.order_id
    LEFT JOIN quotes.quotes.quote_pricing qp ON qp.quote_id = q.id
    LEFT JOIN es_warehouse.public.users uq ON q.created_by = uq.user_id
    LEFT JOIN analytics.payroll.company_directory cd ON uq.email_address = cd.work_email

    LEFT JOIN es_warehouse.public.users uc ON uc.user_id = o.user_id
    LEFT JOIN es_warehouse.public.companies c ON c.company_id = uc.company_id
    LEFT JOIN rental_order_request.public.rental_requests rr ON q.id = rr.quote_id
    LEFT JOIN es_warehouse.public.order_salespersons os ON os.order_id = o.order_id
    LEFT JOIN es_warehouse.public.users ur ON ur.user_id = os.user_id
    join date_range as dr on date_trunc('day', o.date_created) = dr.date
    where os.salesperson_type_id = 1
    AND {% condition customer_name %} COALESCE(c.name, q.new_company_name) {% endcondition %}
    AND {% condition salesperson_name %} concat(ur.FIRST_NAME, ' ', ur.LAST_NAME) {% endcondition %}
    AND {% condition locations %} xw.district {% endcondition %}
    AND {% condition parent_cat_name %}  coalesce(pcat.singular_name, cat.singular_name, 'Bulk Items') {% endcondition %}
    AND {% condition sub_cat_name %}
          CASE
          WHEN cat.singular_name IS NULL THEN 'Bulk Items'
          WHEN cat.parent_category_id IS NOT NULL THEN cat.singular_name
          ELSE NULL END {% endcondition %}








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

    )


    -- ,timeframe as (
    SELECT
    xw.market_name AS location,
    o.order_id,
    o.date_created as order_date_created,
    r.rental_id,
    COALESCE(uc.company_id, q.company_id) as company_id,
    COALESCE(c.name, q.new_company_name) as company_name,
   -- concat(uc.FIRST_NAME, ' ', uc.LAST_NAME) as company_contact_full_name,
    concat(ur.FIRST_NAME, ' ', ur.LAST_NAME) as primary_salesperson_full_name,
    CASE WHEN dr.date BETWEEN {% date_start ultimate_date_filter%} AND {% date_end ultimate_date_filter%} THEN 'Current'
    WHEN dr.date BETWEEN (dateadd(day,datediff(day,{% date_end ultimate_date_filter %},{% date_start ultimate_date_filter %}),{% date_start ultimate_date_filter %})) AND (dateadd(day,-1,{% date_start ultimate_date_filter %})) THEN 'Previous' END as timeframe,
    r.cancel_reason_note,
    r.cancel_reason_type,
    r.equipment_class_id,
    ec.name as equipment_class_name,
    cat.SINGULAR_NAME as equipment_category,
    coalesce(pcat.singular_name, cat.singular_name, 'Bulk Items') AS parent_category_name,
    CASE
      WHEN cat.singular_name IS NULL THEN 'Bulk Items'
      WHEN cat.parent_category_id IS NOT NULL THEN cat.singular_name
      ELSE NULL
    END AS sub_category_name,

    q.id as quote_id,
    q.quote_number,
    CASE WHEN q.id IS NULL then FALSE ELSE TRUE END as order_has_quote,
    qp.rental_subtotal as quoted_subtotal_for_order_id,

    r.start_date as est_start_date, -- rough estimates FROM when the order/rental was originally put in
    r.end_date as est_end_date,
    CASE WHEN datediff(day, r.start_date, r.end_date) = 0 THEN 1 ELSE datediff(day, r.start_date, r.end_date) END as est_num_days,
    ROUND(est_num_days/7, 2) AS est_num_weeks,
    ROUND(est_num_days/28, 2) AS est_num_months,
    r.price_per_day,
    r.price_per_week,
    r.price_per_month,
    est_num_days * r.price_per_day AS day_cost,
    (floor(est_num_weeks) * r.price_per_week) + (r.price_per_day * (est_num_days-floor(est_num_weeks)*7)) AS round_down_week_plus_day_cost,
    ceil(est_num_weeks) * r.price_per_week AS round_up_week_cost,
    ceil(est_num_months) * r.price_per_month AS round_up_month_cost,
    LEAST(day_cost, round_down_week_plus_day_cost, round_up_week_cost, round_up_month_cost) as cheapest_option,
    rr.id AS online_rental_request_id,
    cd.employee_title AS quote_created_by_title
   /* CASE
        WHEN datediff(day, r.start_date, r.end_date) = 0 then r.price_per_day
        WHEN datediff(day, r.start_date, r.end_date) < 7 then datediff(day, r.start_date, r.end_date) * r.price_per_day
        WHEN datediff(day, r.start_date, r.end_date) < 28 then ROUND(DIV0NULL(datediff(day, r.start_date, r.end_date),7) * r.price_per_week, 0)
        WHEN datediff(day, r.start_date, r.end_date) >= 28 then ROUND(DIV0NULL(datediff(day, r.start_date, r.end_date),28) * r.price_per_month,0)
        ELSE NULL END as rental_estimation_price,*/

    FROM es_warehouse.public.orders o
    JOIN es_warehouse.public.rentals r ON r.order_id = o.order_id AND r.rental_status_id = 8
    JOIN analytics.public.market_region_xwalk xw ON xw.market_id = o.market_id
    LEFT JOIN es_warehouse.public.equipment_classes ec ON ec.equipment_class_id = r.equipment_class_id
    LEFT JOIN es_warehouse.public.categories cat ON ec.category_id = cat.category_id
    LEFT JOIN ES_WAREHOUSE.PUBLIC.CATEGORIES pcat ON cat.PARENT_CATEGORY_ID = pcat.CATEGORY_ID
    LEFT JOIN quotes.quotes.quote q ON q.order_id = o.order_id
    LEFT JOIN quotes.quotes.quote_pricing qp ON qp.quote_id = q.id
    LEFT JOIN es_warehouse.public.users uq ON q.created_by = uq.user_id
    LEFT JOIN analytics.payroll.company_directory cd ON uq.email_address = cd.work_email

    LEFT JOIN es_warehouse.public.users uc ON uc.user_id = o.user_id
    LEFT JOIN es_warehouse.public.companies c ON c.company_id = uc.company_id
    LEFT JOIN rental_order_request.public.rental_requests rr ON q.id = rr.quote_id
    LEFT JOIN es_warehouse.public.order_salespersons os ON os.order_id = o.order_id
    LEFT JOIN es_warehouse.public.users ur ON ur.user_id = os.user_id
    join date_range as dr on date_trunc('day', o.date_created) = dr.date
    where os.salesperson_type_id = 1
    AND {% condition customer_name %} COALESCE(c.name, q.new_company_name) {% endcondition %}
    AND {% condition salesperson_name %} concat(ur.FIRST_NAME, ' ', ur.LAST_NAME) {% endcondition %}
    AND {% condition locations %} xw.market_name {% endcondition %}
    AND {% condition parent_cat_name %}  coalesce(pcat.singular_name, cat.singular_name, 'Bulk Items') {% endcondition %}
    AND {% condition sub_cat_name %}
          CASE
          WHEN cat.singular_name IS NULL THEN 'Bulk Items'
          WHEN cat.parent_category_id IS NOT NULL THEN cat.singular_name
          ELSE NULL END {% endcondition %}




    {% endif %};;
}
dimension: timeframe {
  type: string
  sql: ${TABLE}."TIMEFRAME" ;;
}

  dimension: pk {
    type: string
    primary_key: yes
    sql:  concat( ${TABLE}."ORDER_ID" ,  ${TABLE}."RENTAL_ID",  ${TABLE}."CHEAPEST_OPTION")  ;;
  }

dimension: location {
  type: string
  sql: ${TABLE}."LOCATION" ;;
}

  dimension: quote_id {
    type: string
    sql: ${TABLE}."QUOTE_ID" ;;
  }

  dimension: quote_number {
    type: string
    sql: ${TABLE}."QUOTE_NUMBER" ;;
    html:
    {% if  rendered_value  != null  %}
      <font color="#0063f3"><a href="https://quotes.estrack.com/{{quote_id._rendered_value}}"target="_blank"><b>{{ rendered_value }} ➔</b>
        {% else %}
          No Quote
        {% endif %}

 ;;
  }

dimension: order_has_quote {
  type: yesno
  sql: ${TABLE}."ORDER_HAS_QUOTE" ;;
}

dimension: order_id {
  type: string
  sql: ${TABLE}."ORDER_ID" ;;
}

dimension: rental_id {
  type: string
  sql: ${TABLE}."RENTAL_ID" ;;
}

dimension_group: ultimate_date {
  type: time
  sql: ${TABLE}."DATE" ;;
  html: {{ rendered_value | date: "%b %d, %Y" }};;
}

dimension_group: order_date_created {
  label: "Order Created"
  type: time
  sql: ${TABLE}."ORDER_DATE_CREATED" ;;
  html: {{ rendered_value | date: "%b %d, %Y" }};;
}

dimension: company_id {
  type: string
  sql: ${TABLE}."COMPANY_ID" ;;
}

dimension: company_name {
  label: "Customer Name"
  type: string
  sql: ${TABLE}."COMPANY_NAME" ;;
  html:  {% if company_id._value == null  %} {{rendered_value}}
        {% else %}
       {{rendered_value}}
              <td>
                <span style="color: #8C8C8C;"> Company ID: {{company_id._value}} </span>
                </td>
        {% endif %};;
}

dimension: primary_salesperson_full_name {
  type: string
  label: "Salesperson"
  sql: ${TABLE}."PRIMARY_SALESPERSON_FULL_NAME" ;;
}

  dimension: equipment_class_id {
    type: string
    sql: ${TABLE}."EQUIPMENT_CLASS_ID" ;;
  }

dimension: equipment_class_name {
  type: string
  sql: ${TABLE}."EQUIPMENT_CLASS_NAME" ;;
}

dimension: equipment_category {
  type: string
  sql: ${TABLE}."EQUIPMENT_CATEGORY" ;;
  html:  {% if equipment_class_name._value == null  %} {{rendered_value}}

              {% else %}
             {{rendered_value}}
                    <td>
                      <span style="color: #8C8C8C;">{{equipment_class_name._value}} </span>
                      </td>
              {% endif %};;
}



dimension: quoted_subtotal_for_order_id {
  type: number
  sql: ${TABLE}."QUOTED_SUBTOTAL_FOR_ORDER_ID" ;;
  value_format_name: usd_0
}

dimension: cancel_reason_note {
  type: string
  sql: ${TABLE}."CANCEL_REASON_NOTE" ;;
}

dimension: cancel_reason_type {
  type: string
  sql: ${TABLE}."CANCEL_REASON_TYPE" ;;
  html:
    {% if cancel_reason_type._value == null  %} None Listed

        {% elsif cancel_reason_note._value == null  %}

    {{rendered_value}}
    {% else %}
    {{rendered_value}}
    <td>
    <span style="color: #8C8C8C;"> {{cancel_reason_note._value}} </span>
    </td>
    {% endif %} ;;
}

dimension: online_rental_request_id {
  type: string
  sql: ${TABLE}."ONLINE_RENTAL_REQUEST_ID" ;;
}

dimension: quote_created_by_title {
  type: string
  sql: ${TABLE}."QUOTE_CREATED_BY_TITLE" ;;
}

dimension: quote_lead_source {
  type: string
  sql: CASE
      WHEN ${order_has_quote} = FALSE THEN 'No Quote'
      WHEN ${online_rental_request_id} IS NOT NULL THEN 'Online'
      WHEN ${quote_created_by_title} ILIKE '%Customer Support%' THEN 'Customer Support'
      ELSE 'Other'
    END ;;
  suggestions: ["Online","Customer Support","Other", ]
}


  dimension: est_start_date {
      label: "Estimated Rental Start Date"
      type: date
      sql: ${TABLE}."EST_START_DATE" ;;
  }

  dimension: est_end_date {
    label: "Estimated Rental End Date"
    type: date
    sql: ${TABLE}."EST_END_DATE" ;;
  }

  dimension: est_num_days {
    label: "Estimated Number of Rental Days"
    type: number
    sql: ${TABLE}."EST_NUM_DAYS" ;;
  }

  dimension: est_num_weeks {
    label: "Estimated Number of Rental Weeks"
    type: number
    sql: ${TABLE}."EST_NUM_WEEKS" ;;
  }

  dimension: est_num_months {
    label: "Estimated Number of Rental Months"
    type: number
    sql: ${TABLE}."EST_NUM_MONTHS" ;;
  }

  dimension: price_per_day {
    type: number
    sql: ${TABLE}."PRICE_PER_DAY" ;;
    value_format_name: usd_0
  }
  dimension: price_per_week {
    type: number
    sql: ${TABLE}."PRICE_PER_WEEK" ;;
    value_format_name: usd_0
  }

  dimension: price_per_month {
    type: number
    sql: ${TABLE}."PRICE_PER_MONTH" ;;
    value_format_name: usd_0
  }

  dimension: day_cost {
    type: number
    sql: ${TABLE}."DAY_COST" ;;
    value_format_name: usd_0
  }

  dimension: round_down_week_plus_day_cost {
    type: number
    sql: ${TABLE}."ROUND_DOWN_WEEK_PLUS_DAY_COST" ;;
    value_format_name: usd_0
  }

  dimension: round_up_week_cost {
    type: number
    sql: ${TABLE}."ROUND_UP_WEEK_COST" ;;
    value_format_name: usd_0
  }

  dimension: round_up_month_cost {
    type: number
    sql: ${TABLE}."ROUND_UP_MONTH_COST" ;;
    value_format_name: usd_0
  }

  dimension: cheapest_option {
    type: number
    sql: ${TABLE}."CHEAPEST_OPTION" ;;
    value_format_name: usd_0
  }

  dimension: parent_category_name {
    type: string
    sql: ${TABLE}."PARENT_CATEGORY_NAME" ;;
  }

  dimension: sub_category_name {
    type: string
    sql: ${TABLE}."SUB_CATEGORY_NAME" ;;
  }

measure: cheapest_option_sum {
  label: "Estimated Rental Revenue Lost"
  type: sum
  sql: ${cheapest_option} ;;
  value_format_name: usd_0
}

measure: difference_in_cancelled_rentals {
  type: number
  sql: ${total_count_of_cancelled_rentals} - ${total_count_of_previous_cancelled_rentals} ;;
}

measure: total_count_of_cancelled_rentals_unformatted{
  label: "Current Cancelled Rentals"
  type: count_distinct
  sql: ${rental_id};;
  filters: [timeframe: "Current"]
  drill_fields: [cancelled_rental_info*]
}


measure: total_count_of_previous_cancelled_rentals {
  label: "Previous Cancelled Rentals"
  type: count_distinct
  sql: ${rental_id} ;;
  filters: [timeframe: "Previous"]
  drill_fields: [cancelled_rental_info*]
}

measure: total_count_of_cancelled_rentals {
  type: count_distinct
  label: "Total Count of Current Cancelled Rentals"
  sql: ${rental_id} ;;
  filters: [timeframe: "Current"]
  html:
    <a href="#drillmenu" style = "color:#000000;" target="_self">
    {{ rendered_value }} {% if difference_in_cancelled_rentals._value > 0 %}

    {% assign indicator = "green,▲" | split: ',' %}

    {% elsif difference_in_cancelled_rentals._value < 0 %}

    {% assign indicator = "red,▼" | split: ',' %}

    {% else %}

    {% endif %}

    <font color="{{indicator[0]}}">

    {% if value == 99999.12345 %} &infin

    {% else %}({{ difference_in_cancelled_rentals._rendered_value }})

    {% endif %} {{indicator[1]}}

    </font>
    </a>;;
  drill_fields: [cancelled_rental_info*]
}

dimension: curr_canceled_rentals_rates_tf {
  type: yesno
  group_label: "Cancelled Rental Category Check"

  sql: CASE WHEN ${timeframe} = 'Current' AND (${cancel_reason_type} ILIKE 'eqs_rates' OR ${cancel_reason_type} ILIKE 'pricing') THEN TRUE ELSE FALSE END ;;
}

measure: total_cancelled_rentals_rates {
  group_label: "Cancelled Rental Types"
  label: "Current Cancelled Rentals - Rates"
  type: count_distinct
  sql: CASE WHEN ${cancel_reason_type} ILIKE 'eqs_rates' OR ${cancel_reason_type} ILIKE 'pricing' THEN ${rental_id} ELSE NULL END;;
  filters: [timeframe: "Current", curr_canceled_rentals_rates_tf: "TRUE"]
  html: {{rendered_value}}
  <td>
  <span style="color: #8C8C8C; font-size: 12px;"> {{total_cancelled_rentals_rates_missed_revenue._rendered_value}} Est. Missed Revenue </span>
  </td>;;
  drill_fields: [cancelled_rental_info*]
}

  measure: total_cancelled_rentals_rates_missed_revenue {
    group_label: "Missed Revenue"
    label: "Missed Revenue from CR - Rates "
    type: sum
    sql: ${cheapest_option};;
    filters: [timeframe: "Current", curr_canceled_rentals_rates_tf: "TRUE"]
    drill_fields: [cancelled_rental_info*]
    value_format_name: usd_0
  }


dimension: curr_canceled_rentals_competitor_tf {
  type: yesno
  group_label: "Cancelled Rental Category Check"

  sql: CASE WHEN ${timeframe} = 'Current' AND (${cancel_reason_type} ILIKE 'chose_competitor') THEN TRUE ELSE FALSE END ;;
}

measure: total_cancelled_rentals_competitor {
  group_label: "Cancelled Rental Types"
  label: "Current Cancelled Rentals - Competitor"
  type: count_distinct
  sql: CASE WHEN ${cancel_reason_type} ILIKE 'chose_competitor' THEN ${rental_id} ELSE NULL END;;
  filters: [timeframe: "Current", curr_canceled_rentals_competitor_tf: "TRUE"]
  drill_fields: [cancelled_rental_info*]
  html: {{rendered_value}}
  <td>
  <span style="color: #8C8C8C; font-size: 12px;"> {{total_cancelled_rentals_competitor_missed_revenue._rendered_value}} Est. Missed Revenue </span>
  </td>;;

}

  measure: total_cancelled_rentals_competitor_missed_revenue {
    group_label: "Missed Revenue"
    label: "Missed Revenue from CR - Competitor"
    type: sum
    sql: ${cheapest_option};;
    filters: [timeframe: "Current", curr_canceled_rentals_competitor_tf: "TRUE"]
    drill_fields: [cancelled_rental_info*]
    value_format_name: usd_0
  }

dimension: curr_canceled_rentals_duplicate_error_tf {
  type: yesno
  group_label: "Cancelled Rental Category Check"

  sql: CASE WHEN ${timeframe} = 'Current' AND (${cancel_reason_type} ILIKE 'duplicate/order_error' OR ${cancel_reason_type} ILIKE 'quote_issue') THEN TRUE ELSE FALSE END ;;
}
measure: total_cancelled_rentals_duplicate_error {
  group_label: "Cancelled Rental Types"
  label: "Current Cancelled Rentals - Error"
  type: count_distinct
  sql: CASE WHEN ${cancel_reason_type} ILIKE 'duplicate/order_error' OR ${cancel_reason_type} ILIKE 'quote_issue' THEN ${rental_id} ELSE NULL END;;
  filters: [timeframe: "Current", curr_canceled_rentals_duplicate_error_tf: "TRUE"]
  drill_fields: [cancelled_rental_info*]
  html: {{rendered_value}}
  <td>
  <span style="color: #8C8C8C; font-size: 12px;"> {{total_cancelled_rentals_duplicate_error_missed_revenue._rendered_value}} Est. Missed Revenue </span>
  </td>;;
}

  measure: total_cancelled_rentals_duplicate_error_missed_revenue {
    group_label: "Missed Revenue"
    label: "Missed Revenue from CR - Error"
    type: sum
    sql: ${cheapest_option};;
    filters: [timeframe: "Current", curr_canceled_rentals_duplicate_error_tf: "TRUE"]
    drill_fields: [cancelled_rental_info*]
    value_format_name: usd_0
  }

dimension: curr_canceled_rentals_delivery_tf {
  type: yesno
  group_label: "Cancelled Rental Category Check"

  sql: CASE WHEN ${timeframe} = 'Current' AND (${cancel_reason_type} ILIKE 'delivery/timeline') THEN TRUE ELSE FALSE END ;;
}

measure: total_cancelled_rentals_delivery {
  group_label: "Cancelled Rental Types"
  label: "Current Cancelled Rentals - Timeline"
  type: count_distinct
  sql: CASE WHEN ${cancel_reason_type} ILIKE 'delivery/timeline' THEN ${rental_id} ELSE NULL END;;
  filters: [timeframe: "Current", curr_canceled_rentals_delivery_tf: "TRUE"]
  drill_fields: [cancelled_rental_info*]
  html: {{rendered_value}}
  <td>
  <span style="color: #8C8C8C; font-size: 12px;"> {{total_cancelled_rentals_delivery_missed_revenue._rendered_value}} Est. Missed Revenue </span>
  </td>;;
}

  measure: total_cancelled_rentals_delivery_missed_revenue {
    group_label: "Missed Revenue"
    label: "Missed Revenue from CR - Timeline"
    type: sum
    sql: ${cheapest_option};;
    filters: [timeframe: "Current", curr_canceled_rentals_delivery_tf: "TRUE"]
    drill_fields: [cancelled_rental_info*]
    value_format_name: usd_0
  }



dimension: curr_canceled_rentals_availability_tf {
  type: yesno
  group_label: "Cancelled Rental Category Check"
  sql: CASE WHEN ${timeframe} = 'Current' AND (${cancel_reason_type} ILIKE 'eqs_availability' OR ${cancel_reason_type} ILIKE 'asset_unavailable') THEN TRUE ELSE FALSE END ;;
}
measure: total_cancelled_rentals_availability {
  group_label: "Cancelled Rental Types"
  label: "Current Cancelled Rentals - Availability"
  type: count_distinct
  sql: CASE WHEN ${cancel_reason_type} ILIKE 'eqs_availability' OR ${cancel_reason_type} ILIKE 'asset_unavailable' THEN ${rental_id} ELSE NULL END;;
  filters: [timeframe: "Current", curr_canceled_rentals_availability_tf: "TRUE"]
  drill_fields: [cancelled_rental_info*]
  html: {{rendered_value}}
  <td>
  <span style="color: #8C8C8C; font-size: 12px;"> {{total_cancelled_rentals_availability_missed_revenue._rendered_value}} Est. Missed Revenue </span>
  </td>;;

}

  measure: total_cancelled_rentals_availability_missed_revenue {
    group_label: "Missed Revenue"
    label: "Missed Revenue from CR - Availability"
    type: sum
    sql: ${cheapest_option};;
    filters: [timeframe: "Current", curr_canceled_rentals_availability_tf: "TRUE"]
    drill_fields: [cancelled_rental_info*]
    value_format_name: usd_0
  }

dimension: curr_canceled_rentals_dont_need_tf {
  type: yesno
  group_label: "Cancelled Rental Category Check"
  sql: CASE WHEN ${timeframe} = 'Current' AND (${cancel_reason_type} ILIKE 'customer_dont_need' OR ${cancel_reason_type} ILIKE 'no_longer_needed') THEN TRUE ELSE FALSE END ;;
}
measure: total_cancelled_rentals_dont_need {
  group_label: "Cancelled Rental Types"
  label: "Current Cancelled Rentals - Unnecessary"
  type: count_distinct
  sql: CASE WHEN ${cancel_reason_type} ILIKE 'customer_dont_need' OR ${cancel_reason_type} ILIKE 'no_longer_needed' THEN ${rental_id} ELSE NULL END;;
  filters: [timeframe: "Current", curr_canceled_rentals_dont_need_tf: "TRUE"]
  drill_fields: [cancelled_rental_info*]
  html: {{rendered_value}}
  <td>
  <span style="color: #8C8C8C; font-size: 12px;"> {{total_cancelled_rentals_dont_need_missed_revenue._rendered_value}} Est. Missed Revenue </span>
  </td>;;
}

  measure: total_cancelled_rentals_dont_need_missed_revenue {
    group_label: "Missed Revenue"
    label: "Missed Revenue from CR - Unnecessary"
    type: sum
    sql: ${cheapest_option};;
    filters: [timeframe: "Current", curr_canceled_rentals_dont_need_tf: "TRUE"]
    drill_fields: [cancelled_rental_info*]
    value_format_name: usd_0
  }

dimension: curr_canceled_rentals_weather_tf {
  type: yesno
  group_label: "Cancelled Rental Category Check"
  sql: CASE WHEN ${timeframe} = 'Current' AND (${cancel_reason_type} ILIKE 'customer_weather' OR ${cancel_reason_type} ILIKE 'weather/project_delay') THEN TRUE ELSE FALSE END ;;
}
measure: total_cancelled_rentals_weather {
  group_label: "Cancelled Rental Types"
  label: "Current Cancelled Rentals - Weather"
  type: count_distinct
  sql: CASE WHEN ${cancel_reason_type} ILIKE 'customer_weather' OR ${cancel_reason_type} ILIKE 'weather/project_delay' THEN ${rental_id} ELSE NULL END;;
  filters: [timeframe: "Current", curr_canceled_rentals_weather_tf: "TRUE"]
  drill_fields: [cancelled_rental_info*]
  html: {{rendered_value}}
  <td>
  <span style="color: #8C8C8C; font-size: 12px;"> {{total_cancelled_rentals_weather_missed_revenue._rendered_value}} Est. Missed Revenue </span>
  </td>;;

}

  measure: total_cancelled_rentals_weather_missed_revenue {
    group_label: "Missed Revenue"
    label: "Missed Revenue from CR - Weather"
    type: sum
    sql: ${cheapest_option};;
    filters: [timeframe: "Current", curr_canceled_rentals_weather_tf: "TRUE"]
    drill_fields: [cancelled_rental_info*]
    value_format_name: usd_0
  }


dimension: curr_canceled_rentals_other_tf {
  type: yesno
  group_label: "Cancelled Rental Category Check"
  sql: CASE WHEN ${timeframe} = 'Current' AND (${cancel_reason_type} ILIKE 'other') THEN TRUE ELSE FALSE END ;;
}
measure: total_cancelled_rentals_other {
  group_label: "Cancelled Rental Types"
  label: "Current Cancelled Rentals - Other"
  type: count_distinct
  sql: CASE WHEN ${cancel_reason_type} ILIKE 'other' THEN ${rental_id} ELSE NULL END;;
  filters: [timeframe: "Current", curr_canceled_rentals_other_tf: "TRUE"]
  drill_fields: [cancelled_rental_info*]
  html: {{rendered_value}}
  <td>
  <span style="color: #8C8C8C; font-size: 12px;"> {{total_cancelled_rentals_other_missed_revenue._rendered_value}} Est. Missed Revenue </span>
  </td>;;

}


  measure: total_cancelled_rentals_other_missed_revenue {
    group_label: "Missed Revenue"
    label: "Missed Revenue from CR - Other"
    type: sum
    sql: ${cheapest_option};;
    filters: [timeframe: "Current", curr_canceled_rentals_other_tf: "TRUE"]
    drill_fields: [cancelled_rental_info*]
    value_format_name: usd_0
  }


dimension: curr_canceled_rentals_no_listed_reason_tf {
  type: yesno
  group_label: "Cancelled Rental Category Check"
  sql: CASE WHEN ${timeframe} = 'Current' AND (${cancel_reason_type} ILIKE 'none listed' OR ${cancel_reason_type} IS NULL) THEN TRUE ELSE FALSE END ;;
}
measure: total_cancelled_rentals_no_listed_reason {
  group_label: "Cancelled Rental Types"
  label: "Current Cancelled Rentals - No Reason Listed"
  type: count_distinct
  sql: CASE WHEN ${cancel_reason_type} ILIKE 'none listed' OR ${cancel_reason_type} IS NULL THEN ${rental_id} ELSE NULL END ;;
  filters: [timeframe: "Current", curr_canceled_rentals_no_listed_reason_tf: "TRUE"]
  drill_fields: [cancelled_rental_info*]
  html: {{rendered_value}}
  <td>
  <span style="color: #8C8C8C; font-size: 12px;"> {{total_cancelled_rentals_no_listed_reason_missed_revenue._rendered_value}} Est. Missed Revenue </span>
  </td>;;

}


  measure: total_cancelled_rentals_no_listed_reason_missed_revenue {
    group_label: "Missed Revenue"
    label: "Missed Revenue from CR - No Listed Reason"
    type: sum
    sql: ${cheapest_option};;
    filters: [timeframe: "Current", curr_canceled_rentals_no_listed_reason_tf: "TRUE"]
    drill_fields: [cancelled_rental_info*]
    value_format_name: usd_0
  }

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

  filter: parent_cat_name {
    type: string
  }

  filter: sub_cat_name {
    type: string
  }

parameter: location_breakdown {
  type: string
  allowed_value: { value: "Region"}
  allowed_value: { value: "District"}
  allowed_value: { value: "Market"}
}



set: cancelled_rental_info {
  fields: [location,
    quote_number,
    order_id,
    rental_id,
    order_date_created_date,
    company_name,
    primary_salesperson_full_name,
    equipment_class_name,
    equipment_category,
    cancel_reason_type,
    cancel_reason_note,
    est_num_days,
    cheapest_option_sum
    ]
}



}
