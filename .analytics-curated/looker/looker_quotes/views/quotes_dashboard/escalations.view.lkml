
view: escalations {
  derived_table: {
    sql:

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
escalation_info as (
    select xw.REGION_NAME as location,
             q.QUOTE_NUMBER,
             q.CREATED_DATE as quote_created_date,
             q.EXPIRY_DATE,
             concat(sales_rep.FIRST_NAME, ' ', sales_rep.LAST_NAME) as salesperson_full_name,
             c.company_id,
             coalesce(c.NAME,q.new_company_name) as complete_company_names,
             q.ORDER_ID,
             q.ORDER_CREATED_DATE,
             e.MESSAGE as escalation_message,
             e.CREATED_AT as escalation_create_date,
             e.USER_NAME as escalation_created_by,
             q.LAST_MODIFIED_DATE,
             q.MISSED_RENTAL_REASON,
             q.MISSED_RENTAL_REASON_OTHER,
             case when MISSED_RENTAL_REASON is not null or MISSED_RENTAL_REASON_OTHER is not null then LAST_MODIFIED_DATE --- Assuming they will not touch the quote after it's missed
                  when ORDER_ID is not null then ORDER_CREATED_DATE
                  else EXPIRY_DATE end as current_status,
             datediff(day, e.CREATED_AT, current_status) as days_escalated,
             case when MISSED_RENTAL_REASON is not null or MISSED_RENTAL_REASON_OTHER is not null then 'Missed Rental'
                  when ORDER_ID is not null then 'Order Created'
                  when date_trunc(day, EXPIRY_DATE) <= current_date then 'Expired'
                  else 'Currently in Escalation' end as path,
             CASE WHEN
                      dr.date BETWEEN {% date_start ultimate_date_filter%} AND {% date_end ultimate_date_filter%} THEN 'Current'
                      WHEN dr.date BETWEEN (dateadd(day,datediff(day,{% date_end ultimate_date_filter %},{% date_start ultimate_date_filter %}),{% date_start ultimate_date_filter %})) AND (dateadd(day,-1,{% date_start ultimate_date_filter %})) THEN 'Previous'
                      END as timeframe,
              rr.id AS online_rental_request_id,
              cd.employee_title AS created_by_title,
              coalesce(pcat.singular_name, cat.singular_name, 'Bulk Items') AS parent_category_name,
              CASE
                WHEN cat.singular_name IS NULL THEN 'Bulk Items'
                WHEN cat.parent_category_id IS NOT NULL THEN cat.singular_name
                ELSE NULL
              END AS sub_category_name
      from quotes.quotes.quote q
      left join rental_order_request.public.rental_requests rr on q.id = rr.quote_id
      left join es_warehouse.public.users u2 on q.created_by = u2.user_id
      left join analytics.payroll.company_directory cd on u2.email_address = cd.work_email
      left join quotes.quotes.escalations e on q.ESCALATION_ID = e.ESCALATION_ID
      left join QUOTES.QUOTES.EQUIPMENT_TYPE et on q.ID = et.QUOTE_ID
      left join ES_WAREHOUSE.PUBLIC.EQUIPMENT_CLASSES ec on et.EQUIPMENT_CLASS_ID = ec.EQUIPMENT_CLASS_ID
      left join ES_WAREHOUSE.PUBLIC.CATEGORIES cat on ec.CATEGORY_ID = cat.CATEGORY_ID
      left join ES_WAREHOUSE.PUBLIC.CATEGORIES pcat on cat.PARENT_CATEGORY_ID = pcat.CATEGORY_ID
      left join analytics.public.market_region_xwalk xw on q.BRANCH_ID = xw.MARKET_ID
      left join es_warehouse.public.users sales_rep on q.SALES_REP_ID = sales_rep.USER_ID
      left join es_warehouse.public.companies c on q.COMPANY_ID = c.COMPANY_ID
      join date_range dr on date_trunc('day', e.CREATED_AT) = dr.date
      where q.ESCALATION_ID is not null
            and q.QUOTE_NUMBER <> 245898
            and {% condition customer_name %} coalesce(c.NAME,q.new_company_name) {% endcondition %}
            AND {% condition salesperson_name %} concat(sales_rep.FIRST_NAME, ' ', sales_rep.LAST_NAME) {% endcondition %}
            AND {% condition locations %} xw.REGION_NAME {% endcondition %}
            AND {% condition parent_cat_name %}  coalesce(pcat.singular_name, cat.singular_name, 'Bulk Items') {% endcondition %}
            AND {% condition sub_cat_name %}
                  CASE
                  WHEN cat.singular_name IS NULL THEN 'Bulk Items'
                  WHEN cat.parent_category_id IS NOT NULL THEN cat.singular_name
                  ELSE NULL END {% endcondition %}
      )
select *
from escalation_info ei




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
escalation_info as (
    select xw.DISTRICT as location,
             q.QUOTE_NUMBER,
             q.CREATED_DATE as quote_created_date,
             q.EXPIRY_DATE,
             concat(sales_rep.FIRST_NAME, ' ', sales_rep.LAST_NAME) as salesperson_full_name,
             c.company_id,
             coalesce(c.NAME,q.new_company_name) as complete_company_names,
             q.ORDER_ID,
             q.ORDER_CREATED_DATE,
             e.MESSAGE as escalation_message,
             e.CREATED_AT as escalation_create_date,
             e.USER_NAME as escalation_created_by,
             q.LAST_MODIFIED_DATE,
             q.MISSED_RENTAL_REASON,
             q.MISSED_RENTAL_REASON_OTHER,
             case when MISSED_RENTAL_REASON is not null or MISSED_RENTAL_REASON_OTHER is not null then LAST_MODIFIED_DATE --- Assuming they will not touch the quote after it's missed
                  when ORDER_ID is not null then ORDER_CREATED_DATE
                  else EXPIRY_DATE end as current_status,
             datediff(day, e.CREATED_AT, current_status) as days_escalated,
             case when MISSED_RENTAL_REASON is not null or MISSED_RENTAL_REASON_OTHER is not null then 'Missed Rental'
                  when ORDER_ID is not null then 'Order Created'
                  when date_trunc(day, EXPIRY_DATE) <= current_date then 'Expired'
                  else 'Currently in Escalation' end as path,
             CASE WHEN
                      dr.date BETWEEN {% date_start ultimate_date_filter%} AND {% date_end ultimate_date_filter%} THEN 'Current'
                      WHEN dr.date BETWEEN (dateadd(day,datediff(day,{% date_end ultimate_date_filter %},{% date_start ultimate_date_filter %}),{% date_start ultimate_date_filter %})) AND (dateadd(day,-1,{% date_start ultimate_date_filter %})) THEN 'Previous'
                      END as timeframe,
            rr.id AS online_rental_request_id,
            cd.employee_title AS created_by_title,
            coalesce(pcat.singular_name, cat.singular_name, 'Bulk Items') AS parent_category_name,
            CASE
              WHEN cat.singular_name IS NULL THEN 'Bulk Items'
              WHEN cat.parent_category_id IS NOT NULL THEN cat.singular_name
              ELSE NULL
            END AS sub_category_name
      from quotes.quotes.quote q
      left join rental_order_request.public.rental_requests rr on q.id = rr.quote_id
      left join es_warehouse.public.users u2 on q.created_by = u2.user_id
      left join analytics.payroll.company_directory cd on u2.email_address = cd.work_email
      left join quotes.quotes.escalations e on q.ESCALATION_ID = e.ESCALATION_ID
      left join QUOTES.QUOTES.EQUIPMENT_TYPE et on q.ID = et.QUOTE_ID
      left join ES_WAREHOUSE.PUBLIC.EQUIPMENT_CLASSES ec on et.EQUIPMENT_CLASS_ID = ec.EQUIPMENT_CLASS_ID
      left join ES_WAREHOUSE.PUBLIC.CATEGORIES cat on ec.CATEGORY_ID = cat.CATEGORY_ID
      left join ES_WAREHOUSE.PUBLIC.CATEGORIES pcat on cat.PARENT_CATEGORY_ID = pcat.CATEGORY_ID
      left join analytics.public.market_region_xwalk xw on q.BRANCH_ID = xw.MARKET_ID
      left join es_warehouse.public.users sales_rep on q.SALES_REP_ID = sales_rep.USER_ID
      left join es_warehouse.public.companies c on q.COMPANY_ID = c.COMPANY_ID
      join date_range dr on date_trunc('day', e.CREATED_AT) = dr.date
      where q.ESCALATION_ID is not null
            and q.QUOTE_NUMBER <> 245898
            and {% condition customer_name %} coalesce(c.NAME,q.new_company_name) {% endcondition %}
            AND {% condition salesperson_name %} concat(sales_rep.FIRST_NAME, ' ', sales_rep.LAST_NAME) {% endcondition %}
            AND {% condition locations %} xw.district {% endcondition %}
            AND {% condition parent_cat_name %}  coalesce(pcat.singular_name, cat.singular_name, 'Bulk Items') {% endcondition %}
            AND {% condition sub_cat_name %}
                  CASE
                  WHEN cat.singular_name IS NULL THEN 'Bulk Items'
                  WHEN cat.parent_category_id IS NOT NULL THEN cat.singular_name
                  ELSE NULL END {% endcondition %}
      )
select *
from escalation_info ei


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
escalation_info as (
    select xw.MARKET_NAME as location,
             q.QUOTE_NUMBER,
             q.CREATED_DATE as quote_created_date,
             q.EXPIRY_DATE,
             concat(sales_rep.FIRST_NAME, ' ', sales_rep.LAST_NAME) as salesperson_full_name,
             c.company_id,
             coalesce(c.NAME,q.new_company_name) as complete_company_names,
             q.ORDER_ID,
             q.ORDER_CREATED_DATE,
             e.MESSAGE as escalation_message,
             e.CREATED_AT as escalation_create_date,
             e.USER_NAME as escalation_created_by,
             q.LAST_MODIFIED_DATE,
             q.MISSED_RENTAL_REASON,
             q.MISSED_RENTAL_REASON_OTHER,
             case when MISSED_RENTAL_REASON is not null or MISSED_RENTAL_REASON_OTHER is not null then LAST_MODIFIED_DATE --- Assuming they will not touch the quote after it's missed
                  when ORDER_ID is not null then ORDER_CREATED_DATE
                  else EXPIRY_DATE end as current_status,
             datediff(day, e.CREATED_AT, current_status) as days_escalated,
             case when MISSED_RENTAL_REASON is not null or MISSED_RENTAL_REASON_OTHER is not null then 'Missed Rental'
                  when ORDER_ID is not null then 'Order Created'
                  when date_trunc(day, EXPIRY_DATE) <= current_date then 'Expired'
                  else 'Currently in Escalation' end as path,
             CASE WHEN
                      dr.date BETWEEN {% date_start ultimate_date_filter%} AND {% date_end ultimate_date_filter%} THEN 'Current'
                      WHEN dr.date BETWEEN (dateadd(day,datediff(day,{% date_end ultimate_date_filter %},{% date_start ultimate_date_filter %}),{% date_start ultimate_date_filter %})) AND (dateadd(day,-1,{% date_start ultimate_date_filter %})) THEN 'Previous'
                      END as timeframe,
              rr.id AS online_rental_request_id,
              cd.employee_title AS created_by_title,
              coalesce(pcat.singular_name, cat.singular_name, 'Bulk Items') AS parent_category_name,
              CASE
                WHEN cat.singular_name IS NULL THEN 'Bulk Items'
                WHEN cat.parent_category_id IS NOT NULL THEN cat.singular_name
                ELSE NULL
              END AS sub_category_name

    from quotes.quotes.quote as q

      left join rental_order_request.public.rental_requests rr on q.id = rr.quote_id
      left join es_warehouse.public.users u2 on q.created_by = u2.user_id
      left join analytics.payroll.company_directory cd on u2.email_address = cd.work_email
      left join quotes.quotes.escalations e on q.ESCALATION_ID = e.ESCALATION_ID
      left join QUOTES.QUOTES.EQUIPMENT_TYPE et on q.ID = et.QUOTE_ID
      left join ES_WAREHOUSE.PUBLIC.EQUIPMENT_CLASSES ec on et.EQUIPMENT_CLASS_ID = ec.EQUIPMENT_CLASS_ID
      left join ES_WAREHOUSE.PUBLIC.CATEGORIES cat on ec.CATEGORY_ID = cat.CATEGORY_ID
      left join ES_WAREHOUSE.PUBLIC.CATEGORIES pcat on cat.PARENT_CATEGORY_ID = pcat.CATEGORY_ID
      left join analytics.public.market_region_xwalk xw on q.BRANCH_ID = xw.MARKET_ID
      left join es_warehouse.public.users sales_rep on q.SALES_REP_ID = sales_rep.USER_ID
      left join es_warehouse.public.companies c on q.COMPANY_ID = c.COMPANY_ID
      join date_range dr on date_trunc('day', e.CREATED_AT) = dr.date
      where q.ESCALATION_ID is not null
            and q.QUOTE_NUMBER <> 245898
            and {% condition customer_name %} coalesce(c.NAME,q.new_company_name) {% endcondition %}
            AND {% condition salesperson_name %} concat(sales_rep.FIRST_NAME, ' ', sales_rep.LAST_NAME) {% endcondition %}
            AND {% condition locations %} xw.market_name {% endcondition %}
            AND {% condition parent_cat_name %}  coalesce(pcat.singular_name, cat.singular_name, 'Bulk Items') {% endcondition %}
            AND {% condition sub_cat_name %}
                  CASE
                  WHEN cat.singular_name IS NULL THEN 'Bulk Items'
                  WHEN cat.parent_category_id IS NOT NULL THEN cat.singular_name
                  ELSE NULL END {% endcondition %}
      )
select *
from escalation_info ei



                                                  {% endif %};;
  }

  measure: count {
    type: count
  }

  # dimension: region_name {
  #   type: string
  #   sql: ${TABLE}."REGION_NAME" ;;
  # }

  # dimension: district {
  #   type: string
  #   sql: ${TABLE}."DISTRICT" ;;
  # }

  # dimension: market_id {
  #   type: number
  #   sql: ${TABLE}."MARKET_ID" ;;
  # }

  # dimension: market_name {
  #   type: string
  #   sql: ${TABLE}."MARKET_NAME" ;;
  # }

  dimension: location {
    type: string
    sql: ${TABLE}."LOCATION" ;;
  }

  dimension: timeframe {
    type: string
    sql: ${TABLE}."TIMEFRAME" ;;
  }

  dimension: quote_number {
    type: string
    sql: ${TABLE}."QUOTE_NUMBER" ;;
    primary_key: yes
  }

  dimension_group: quote_created {
    type: time
    sql: ${TABLE}."QUOTE_CREATED_DATE" ;;
  }

  dimension_group: quote_expiration {
    type: time
    sql: ${TABLE}."EXPIRY_DATE" ;;
  }

  dimension: salesperson {
    type: string
    sql: ${TABLE}."SALESPERSON_FULL_NAME" ;;
  }

  dimension: company_id {
    type: string
    sql: ${TABLE}."COMPANY_ID" ;;
  }

  dimension: customer {
    type: string
    sql: ${TABLE}."COMPLETE_COMPANY_NAMES" ;;
  }

  dimension: order_id {
    type: string
    sql: ${TABLE}."ORDER_ID" ;;
  }

  dimension_group: order_created {
    type: time
    sql: ${TABLE}."ORDER_CREATED_DATE" ;;
  }

  dimension: escalation_message {
    type: string
    sql: ${TABLE}."ESCALATION_MESSAGE" ;;
  }

  dimension_group: escalation_created {
    type: time
    sql: ${TABLE}."ESCALATION_CREATE_DATE" ;;
  }

  dimension: escalation_created_by {
    type: string
    sql: ${TABLE}."ESCALATION_CREATED_BY" ;;
  }

  dimension_group: quote_last_modified {
    type: time
    sql: ${TABLE}."LAST_MODIFIED_DATE" ;;
  }

  dimension: missed_rental_reason {
    type: string
    sql: ${TABLE}."MISSED_RENTAL_REASON" ;;
  }

  dimension: missed_rental_reason_other {
    type: string
    sql: ${TABLE}."MISSED_RENTAL_REASON_OTHER" ;;
  }

  dimension_group: current_status {
    type: time
    sql: ${TABLE}."CURRENT_STATUS" ;;
  }

  dimension: days_escalated {
    type: number
    sql: ${TABLE}."DAYS_ESCALATED" ;;
  }

  dimension: path {
    type: string
    sql: ${TABLE}."PATH" ;;
  }

  dimension: online_rental_request_id {
    type: string
    sql: ${TABLE}."ONLINE_RENTAL_REQUEST_ID" ;;
  }

  dimension: created_by_title {
    type: string
    sql: ${TABLE}."CREATED_BY_TITLE" ;;
  }

  dimension: parent_category_name {
    type: string
    sql: ${TABLE}."PARENT_CATEGORY_NAME" ;;
  }

  dimension: sub_category_name {
    type: string
    sql: ${TABLE}."SUB_CATEGORY_NAME" ;;
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

  measure: total_count_of_escalated_quotes_current {
    description: "This is the total count of quotes that have ever been escalated. Quotes currently escalated gives a more real time, what's currently escalated."
    label: "Total Count of Current Quotes Escalated (All Paths)"
    type: count
    filters: [timeframe: "Current"]
    drill_fields: [escalation_detail*]
    html:
    <a href="#drillmenu" style = "color:#000000;" target="_self">
    {{ rendered_value }} {% if difference_in_escalated_quotes._value > 0 %}

    {% assign indicator = "green,▲" | split: ',' %}

    {% elsif difference_in_escalated_quotes._value < 0 %}

    {% assign indicator = "red,▼" | split: ',' %}

    {% else %}

    {% endif %}

    <font color="{{indicator[0]}}">

    {% if value == 99999.12345 %} &infin

    {% else %}({{ difference_in_escalated_quotes._rendered_value }})

    {% endif %} {{indicator[1]}}

    </font>
    </a>;;
  }

  measure: total_count_of_escalated_quotes_previous {
    description: "This is the total count of quotes that have ever been escalated. Quotes currently escalated gives a more real time, what's currently escalated."
    label: "Total Count of Previous Quotes Escalated (All Paths)"
    type: count
    filters: [timeframe: "Previous"]
    drill_fields: [escalation_detail*]
  }

  measure: quotes_currently_in_escalation {
    label: "Total Count of Current Quotes In Escalation"
    type: count
    filters: [path: "Currently in Escalation", timeframe: "Current"]
    drill_fields: [escalation_detail*]
  }

  measure: total_orders_created_after_escalation {
    type: count
    label: "Total Count of Current Escalated Quotes Created Into Orders"
    filters: [path: "Order Created", timeframe: "Current"]
    drill_fields: [escalation_order_detail*]
  }

  measure: total_missed_rentals_after_escalation {
    type: count
    label: "Total Count of Current Escalated Quotes With Missed Rentals"
    filters: [path: "Missed Rental"]
    drill_fields: [escalation_missed_rental_detail*]
  }

  measure: total_expired_quotes_after_escalation {
    type: count
    label: "Total Count of Current Escalated Quotes Expired"
    filters: [path: "Expired"]
    drill_fields: [escalation_detail*]
  }

  measure: difference_in_escalated_quotes {
    type: number
    sql: ${total_count_of_escalated_quotes_current} - ${total_count_of_escalated_quotes_previous} ;;
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

  set: escalation_detail {
    fields: [location,
      quote_number,
      customer,
      salesperson,
      escalation_created_date,
      escalation_created_by,
      escalation_message,
      days_escalated,
      path]
  }

  set: escalation_order_detail {
    fields: [location,
      quote_number,
      customer,
      salesperson,
      escalation_created_date,
      escalation_created_by,
      escalation_message,
      order_created_date,
      days_escalated,
      path]
  }

  set: escalation_missed_rental_detail {
    fields: [location,
      quote_number,
      customer,
      salesperson,
      escalation_created_date,
      escalation_created_by,
      escalation_message,
      days_escalated,
      missed_rental_reason,
      missed_rental_reason_other,
      path]
  }

  # set: detail {
  #   fields: [
  #       region_name,
  # district,
  # market_id,
  # market_name,
  # quote_number,
  # quote_created_date_time,
  # expiry_date_time,
  # salesperson_full_name,
  # complete_company_names,
  # order_id,
  # order_created_date_time,
  # escalation_message,
  # escalation_create_date_time,
  # escalation_created_by,
  # last_modified_date_time,
  # missed_rental_reason,
  # missed_rental_reason_other,
  # current_status_time,
  # days_escalated,
  # path
  #   ]
  # }
}
