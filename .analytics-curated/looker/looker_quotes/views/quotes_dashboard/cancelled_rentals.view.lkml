view: cancelled_rentals {
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
    select
    m.REGION_NAME as location,
    q.quote_number,
    q.order_id,
    q.created_date as quote_created_date,
    q.order_created_date,
    q.company_id,
    coalesce(c.NAME,q.new_company_name) as complete_company_names,
    concat(u.FIRST_NAME, ' ', u.LAST_NAME) as salesperson_full_name,

    coalesce(equipment_class_name,concat('Bulk Item - ',et.part_id)) as full_equipment_name,

    coalesce(cat.SINGULAR_NAME,'Bulk Items') as category,
    CASE WHEN
    dr.date BETWEEN {% date_start ultimate_date_filter%} AND {% date_end ultimate_date_filter%} THEN 'Current'
    WHEN dr.date BETWEEN (dateadd(day,datediff(day,{% date_end ultimate_date_filter %},{% date_start ultimate_date_filter %}),{% date_start ultimate_date_filter %})) AND (dateadd(day,-1,{% date_start ultimate_date_filter %})) THEN 'Previous'
    END as timeframe,
    dr.date,
    qp.rental_subtotal,

     r.rental_id,r.cancel_reason_note,
    COALESCE(r.cancel_reason_type, 'None Listed') as cancel_reason_type,

    rr.id AS online_rental_request_id,
    cd.employee_title AS created_by_title

    from quotes.quotes.quote as q

    left join rental_order_request.public.rental_requests rr
     on q.id = rr.quote_id

    left join es_warehouse.public.users u2
      on q.created_by = u2.user_id

    left join analytics.payroll.company_directory cd
      on u2.email_address = cd.work_email

    left join QUOTES.QUOTES.EQUIPMENT_TYPE et
      on q.ID = et.QUOTE_ID

    join es_warehouse.public.rentals r
    on r.order_id = q.order_id and r.rental_status_id = 8

    left join ES_WAREHOUSE.PUBLIC.EQUIPMENT_CLASSES ec
    on et.EQUIPMENT_CLASS_ID = ec.EQUIPMENT_CLASS_ID

    left join ES_WAREHOUSE.PUBLIC.CATEGORIES cat
    on ec.CATEGORY_ID = cat.CATEGORY_ID

    left join ANALYTICS.PUBLIC.MARKET_REGION_XWALK as m
    on q.branch_id = m.MARKET_ID

    left join ES_WAREHOUSE.PUBLIC.COMPANIES as c
    on c.COMPANY_ID = q.company_id

    left join ES_WAREHOUSE.PUBLIC.USERS as u
    on u.USER_ID = q.sales_rep_id

    join date_range as dr
    on date_trunc('day', q.ORDER_CREATED_DATE) = dr.date

    left join quotes.quotes.quote_pricing qp
    on q.ID = qp.QUOTE_ID




    where
    {% condition customer_name %} coalesce(c.NAME,q.new_company_name) {% endcondition %}
    AND {% condition salesperson_name %} concat(u.FIRST_NAME, ' ', u.LAST_NAME) {% endcondition %}
    AND {% condition locations %} m.REGION_NAME {% endcondition %}







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
    select
    m.DISTRICT as location,
    q.quote_number,
    q.order_id,

    q.created_date as quote_created_date,
    q.order_created_date,
    q.company_id,
    coalesce(c.NAME,q.new_company_name) as complete_company_names,
    concat(u.FIRST_NAME, ' ', u.LAST_NAME) as salesperson_full_name,

    coalesce(equipment_class_name,concat('Bulk Item - ',et.part_id)) as full_equipment_name,

    coalesce(cat.SINGULAR_NAME,'Bulk Items') as category,
    CASE WHEN
    dr.date BETWEEN {% date_start ultimate_date_filter%} AND {% date_end ultimate_date_filter%} THEN 'Current'
    WHEN dr.date BETWEEN (dateadd(day,datediff(day,{% date_end ultimate_date_filter %},{% date_start ultimate_date_filter %}),{% date_start ultimate_date_filter %})) AND (dateadd(day,-1,{% date_start ultimate_date_filter %})) THEN 'Previous'
    END as timeframe,
    dr.date,
    qp.rental_subtotal,

     r.rental_id,
    r.cancel_reason_note,
    COALESCE(r.cancel_reason_type, 'None Listed') as cancel_reason_type,

        rr.id AS online_rental_request_id,
    cd.employee_title AS created_by_title

    from quotes.quotes.quote as q

    join es_warehouse.public.rentals r
    on r.order_id = q.order_id and r.rental_status_id = 8

    left join rental_order_request.public.rental_requests rr
     on q.id = rr.quote_id

    left join es_warehouse.public.users u2
      on q.created_by = u2.user_id

    left join analytics.payroll.company_directory cd
      on u2.email_address = cd.work_email

    left join QUOTES.QUOTES.EQUIPMENT_TYPE et
      on q.ID = et.QUOTE_ID

    left join ES_WAREHOUSE.PUBLIC.EQUIPMENT_CLASSES ec
    on et.EQUIPMENT_CLASS_ID = ec.EQUIPMENT_CLASS_ID

    left join ES_WAREHOUSE.PUBLIC.CATEGORIES cat
    on ec.CATEGORY_ID = cat.CATEGORY_ID

    left join ANALYTICS.PUBLIC.MARKET_REGION_XWALK as m
    on q.branch_id = m.MARKET_ID

    left join ES_WAREHOUSE.PUBLIC.COMPANIES as c
    on c.COMPANY_ID = q.company_id

    left join ES_WAREHOUSE.PUBLIC.USERS as u
    on u.USER_ID = q.sales_rep_id

    join date_range as dr
    on date_trunc('day', q.ORDER_CREATED_DATE) = dr.date

    left join quotes.quotes.quote_pricing qp
    on q.ID = qp.QUOTE_ID




    where
    {% condition customer_name %} coalesce(c.NAME,q.new_company_name) {% endcondition %}
    AND {% condition salesperson_name %} concat(u.FIRST_NAME, ' ', u.LAST_NAME) {% endcondition %}
    AND {% condition locations %} m.DISTRICT {% endcondition %}








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
    select
    m.MARKET_NAME as location,
    q.quote_number,
    q.order_id,
    q.created_date as quote_created_date,
    q.order_created_date,
    q.company_id,
    coalesce(c.NAME,q.new_company_name) as complete_company_names,
    concat(u.FIRST_NAME, ' ', u.LAST_NAME) as salesperson_full_name,

    coalesce(equipment_class_name,concat('Bulk Item - ',et.part_id)) as full_equipment_name,

    coalesce(cat.SINGULAR_NAME,'Bulk Items') as category,
    CASE WHEN
    dr.date BETWEEN {% date_start ultimate_date_filter%} AND {% date_end ultimate_date_filter%} THEN 'Current'
    WHEN dr.date BETWEEN (dateadd(day,datediff(day,{% date_end ultimate_date_filter %},{% date_start ultimate_date_filter %}),{% date_start ultimate_date_filter %})) AND (dateadd(day,-1,{% date_start ultimate_date_filter %})) THEN 'Previous'
    END as timeframe,
    dr.date,
    qp.rental_subtotal,

     r.rental_id,r.cancel_reason_note,
    COALESCE(r.cancel_reason_type, 'None Listed') as cancel_reason_type,

    rr.id AS online_rental_request_id,
    cd.employee_title AS created_by_title

    from quotes.quotes.quote as q

    join es_warehouse.public.rentals r
    on r.order_id = q.order_id and r.rental_status_id = 8

    left join rental_order_request.public.rental_requests rr
     on q.id = rr.quote_id

    left join es_warehouse.public.users u2
      on q.created_by = u2.user_id

    left join analytics.payroll.company_directory cd
      on u2.email_address = cd.work_email

    left join QUOTES.QUOTES.EQUIPMENT_TYPE et
      on q.ID = et.QUOTE_ID

    left join ES_WAREHOUSE.PUBLIC.EQUIPMENT_CLASSES ec
    on et.EQUIPMENT_CLASS_ID = ec.EQUIPMENT_CLASS_ID

    left join ES_WAREHOUSE.PUBLIC.CATEGORIES cat
    on ec.CATEGORY_ID = cat.CATEGORY_ID

    left join ANALYTICS.PUBLIC.MARKET_REGION_XWALK as m
    on q.branch_id = m.MARKET_ID

    left join ES_WAREHOUSE.PUBLIC.COMPANIES as c
    on c.COMPANY_ID = q.company_id

    left join ES_WAREHOUSE.PUBLIC.USERS as u
    on u.USER_ID = q.sales_rep_id

    join date_range as dr
    on date_trunc('day', q.ORDER_CREATED_DATE) = dr.date

    left join quotes.quotes.quote_pricing qp
    on q.ID = qp.QUOTE_ID




    where
    {% condition customer_name %} coalesce(c.NAME,q.new_company_name) {% endcondition %}
    AND {% condition salesperson_name %} concat(u.FIRST_NAME, ' ', u.LAST_NAME) {% endcondition %}
    AND {% condition locations %} m.MARKET_NAME {% endcondition %}




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

  dimension: rental_id {
    type: string
    sql: ${TABLE}."RENTAL_ID" ;;
  }

  dimension_group: ultimate_date {
    type: time
    sql: ${TABLE}."DATE" ;;
    html: {{ rendered_value | date: "%b %d, %Y" }};;
  }

  dimension_group: quote_created_date {
    label: "Quote Created"
    type: time
    sql: ${TABLE}."QUOTE_CREATED_DATE" ;;
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
    html:  {% if company_id._value == null  %} {{rendered_value}}

    {% else %}
   {{rendered_value}}
          <td>
            <span style="color: #8C8C8C;"> Company ID: {{company_id._value}} </span>
            </td>
    {% endif %};;
  }

  dimension: salesperson_full_name {
    type: string
    label: "Salesperson"
    sql: ${TABLE}."SALESPERSON_FULL_NAME" ;;
  }


  dimension: equipment_name {
    type: string
    sql: ${TABLE}."FULL_EQUIPMENT_NAME" ;;
  }

  dimension: category {
    type: string
    sql: ${TABLE}."CATEGORY" ;;
    html:  {% if equipment_name._value == null  %} {{rendered_value}}

          {% else %}
         {{rendered_value}}
                <td>
                  <span style="color: #8C8C8C;">{{equipment_name._value}} </span>
                  </td>
          {% endif %};;
  }



  dimension: rental_subtotal {
    type: number
    sql: ${TABLE}."RENTAL_SUBTOTAL" ;;
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

  dimension: created_by_title {
    type: string
    sql: ${TABLE}."CREATED_BY_TITLE" ;;
  }

  dimension: lead_source {
    type: string
    sql: CASE
      WHEN ${online_rental_request_id} IS NOT NULL THEN 'Online'
      WHEN ${created_by_title} ILIKE '%Customer Support%' THEN 'Customer Support'
      ELSE 'Other'
    END ;;
    suggestions: ["Online","Customer Support","Other"]
  }



  measure: difference_in_cancelled_rentals {
    type: number
    sql: ${total_count_of_cancelled_rentals} - ${total_count_of_previous_cancelled_rentals} ;;
  }

  measure: total_count_of_cancelled_rentals_unformatted{
    type: count_distinct
    sql: ${rental_id};;
    filters: [timeframe: "Current", quote_number: "-NULL"]
    drill_fields: [cancelled_rental_info*]
  }


  measure: total_count_of_previous_cancelled_rentals {
    type: count_distinct
    sql: ${rental_id} ;;
    filters: [timeframe: "Previous", quote_number: "-NULL"]
    drill_fields: [cancelled_rental_info*]
  }

  measure: total_count_of_cancelled_rentals {
    type: count_distinct
    label: "Total Count of Current Cancelled Rentals"
    sql: ${rental_id} ;;
    filters: [timeframe: "Current", quote_number: "-NULL"]
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
    drill_fields: [cancelled_rental_info*]
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

  }

  dimension: curr_canceled_rentals_no_listed_reason_tf {
    type: yesno
    group_label: "Cancelled Rental Category Check"
    sql: CASE WHEN ${timeframe} = 'Current' AND (${cancel_reason_type} ILIKE 'none listed') THEN TRUE ELSE FALSE END ;;
  }
  measure: total_cancelled_rentals_no_listed_reason {
    group_label: "Cancelled Rental Types"
    label: "Current Cancelled Rentals - No Reason Listed"
    type: count_distinct
    sql: CASE WHEN ${cancel_reason_type} ILIKE 'none listed' THEN ${rental_id} ELSE NULL END ;;
    filters: [timeframe: "Current", curr_canceled_rentals_no_listed_reason_tf: "TRUE"]
    drill_fields: [cancelled_rental_info*]

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
      order_created_date_date,
      complete_company_names,

      salesperson_full_name,

      category,
      cancel_reason_type]
  }



}
