
view: salesperson_quotes {
  derived_table: {
    sql:
    with company_history AS (
     select company_id,
        h.assets_on_rent as aor_30_days_ago,
        c.assets_on_rent as aor_today,

        h.num_primary_salesreps as sp_count_30_days_ago,
        c.num_primary_salesreps as sp_count_today,

        h.num_markets as market_count_30_days_ago,
        c.num_markets as market_count_today,

        h.OEC_on_rent as oec_30_days_ago,
        c.OEC_on_rent as oec_today

      from (select * from analytics.bi_ops.company_oec_aor_historical where date = dateadd(day, '-30', CONVERT_TIMEZONE('America/Chicago', current_timestamp)::DATE)) h
      LEFT JOIN analytics.bi_ops.company_oec_aor_current c USING(company_id)
  )


    select
            mrx.market_name,
            q.id,
            q.quote_number,
            q.order_id,
            -- We were getting differences between dates on ES MAX and mine because of these conversions to central
            --CONVERT_TIMEZONE('UTC', 'America/Chicago', q.created_date)::DATE as quote_created_date,
            q.created_date::DATE as quote_created_date,
            --CONVERT_TIMEZONE('UTC', 'America/Chicago', q.start_date)::DATE as quote_start_date,
            q.start_date::DATE as quote_start_date,
            --CONVERT_TIMEZONE('UTC', 'America/Chicago', q.end_date)::DATE as quote_end_date,
            q.end_date::DATE as quote_end_date,
            --CONVERT_TIMEZONE('UTC', 'America/Chicago', q.order_created_date)::DATE as order_created_date,
            q.order_created_date::DATE as order_created_date,
            q.company_id,
            coalesce(c.NAME,q.new_company_name) AS complete_company_name,
            INITCAP(q.contact_name) as company_contact_name,
            q.contact_phone as company_contact_phone,
            INITCAP(q.site_contact_name) as site_contact_name,
            q.site_contact_phone,
            COALESCE(si.name, concat(u.first_name, ' ', u.last_name)) as salesperson_full_name,
            q.sales_rep_id as salesperson_user_id,
            COALESCE(si.home_market_dated, CASE WHEN si.district_dated IS NULL THEN NULL ELSE concat('District ', si.district_dated) END, si.region_name_dated) as salesperson_current_location,
            q.missed_rental_reason as missed_quote_reason,
            q.missed_rental_reason_other as missed_quote_reason_other,
            coalesce(equipment_class_name,concat('Bulk Item - ',et.part_id)) AS full_equipment_name,
            et.day_rate,
            et.week_rate,
            et.four_week_rate,
            coalesce(cat.SINGULAR_NAME,'Bulk Items') AS category,
            CASE
            WHEN COALESCE(CONVERT_TIMEZONE('America/Chicago', q.order_created_date)::DATE, CONVERT_TIMEZONE( 'America/Chicago', q.created_date)::DATE) >= dateadd(day, '-30', CONVERT_TIMEZONE('America/Chicago', current_date))::DATE AND COALESCE(CONVERT_TIMEZONE('America/Chicago', q.order_created_date)::DATE, CONVERT_TIMEZONE('America/Chicago', q.created_date)::DATE) <=  CONVERT_TIMEZONE('America/Chicago', current_timestamp)::DATE
                      THEN 'Current'
            WHEN COALESCE(CONVERT_TIMEZONE('America/Chicago', q.order_created_date)::DATE, CONVERT_TIMEZONE( 'America/Chicago', q.created_date)::DATE) >= dateadd(day, '-60', CONVERT_TIMEZONE('America/Chicago', current_timestamp))::DATE AND COALESCE(CONVERT_TIMEZONE('America/Chicago', q.order_created_date)::DATE, CONVERT_TIMEZONE('America/Chicago', q.created_date)::DATE) <= dateadd(day, '-31', CONVERT_TIMEZONE( 'America/Chicago', current_timestamp))::DATE
                      THEN 'Previous'
            END AS timeframe,
            --dr.date,
             --CONVERT_TIMEZONE('UTC', 'America/Chicago', q.expiry_date)::DATE as expiration_date,
            q.expiry_date::DATE as expiration_date,
            q.project_type,
            qp.rental_subtotal,
            q.location_description,
            mrx.district,
            mrx.region,
            mrx.region_name,

             q.escalation_id,
             e.MESSAGE as escalation_message,
             e.CREATED_AT as escalation_create_date,
             e.USER_NAME as escalation_created_by,
            --CONVERT_TIMEZONE('UTC', 'America/Chicago', q.LAST_MODIFIED_DATE)::DATE as last_modified_date,
            q.LAST_MODIFIED_DATE::DATE as last_modified_date,
             CASE WHEN missed_rental_reason IS NOT NULL OR missed_rental_reason_other IS NOT NULL
                    --THEN CONVERT_TIMEZONE('UTC', 'America/Chicago', q.LAST_MODIFIED_DATE)::DATE
                    THEN q.LAST_MODIFIED_DATE::DATE
                    --- Assuming they will not touch the quote after it's missed
                  WHEN q.order_id IS NOT NULL
                   -- THEN CONVERT_TIMEZONE('UTC', 'America/Chicago', q.order_created_date)::DATE
                  THEN q.order_created_date::DATE
                  ELSE expiration_date END AS current_status,

             CASE WHEN q.escalation_id IS NOT NULL AND order_id IS NULL
               -- THEN datediff(day, CONVERT_TIMEZONE('UTC', 'America/Chicago', e.CREATED_AT)::DATE, current_status)
                  THEN datediff(day,  e.CREATED_AT::DATE, current_status)
                ELSE null END as days_escalated,

             CASE WHEN order_id IS NOT NULL
                    THEN 'Order Created'
                  WHEN missed_quote_reason IS NOT NULL OR missed_quote_reason_other IS NOT NULL
                    THEN 'Missed Quote'
                  WHEN  DATE_TRUNC(day, EXPIRATION_DATE) <= current_date()
                    THEN 'Expired'
                   WHEN q.escalation_id IS NOT NULL
                    THEN 'Escalated'
                  ELSE 'Open' END as path,
            COALESCE(ch.aor_30_days_ago,0) as aor_30_days_ago,
            COALESCE(ch.oec_30_days_ago,0) as oec_30_days_ago,
            COALESCE(ch.aor_today,0) as aor_today,
            COALESCE(ch.oec_today,0) as oec_today,
            COALESCE(ch.sp_count_30_days_ago,0) as sp_count_30_days_ago,
            COALESCE(ch.sp_count_today,0) as sp_count_today,
            COALESCE(ch.market_count_30_days_ago,0) as market_count_30_days_ago,
            COALESCE(ch.market_count_today,0) as market_count_today



        FROM quotes.quotes.quote AS q

        LEFT JOIN QUOTES.QUOTES.EQUIPMENT_TYPE et
                  ON q.ID = et.QUOTE_ID
        LEFT JOIN ES_WAREHOUSE.PUBLIC.EQUIPMENT_CLASSES ec
                  ON et.EQUIPMENT_CLASS_ID = ec.EQUIPMENT_CLASS_ID
        LEFT JOIN ES_WAREHOUSE.PUBLIC.CATEGORIES cat
                  ON ec.CATEGORY_ID = cat.CATEGORY_ID
        LEFT JOIN ANALYTICS.PUBLIC.MARKET_REGION_XWALK AS mrx
                  ON q.branch_id = mrx.MARKET_ID
        LEFT JOIN ES_WAREHOUSE.PUBLIC.COMPANIES AS c
                  ON c.COMPANY_ID = q.company_id
        LEFT JOIN ES_WAREHOUSE.PUBLIC.USERS AS u
                  ON u.USER_ID = q.sales_rep_id
        LEFT JOIN analytics.bi_ops.salesperson_info si
                  ON q.sales_rep_id = si.user_id and record_ineffective_date IS NULL
        --JOIN date_range AS dr ON date_trunc('day', q.CREATED_DATE) = dr.date
        LEFT JOIN quotes.quotes.quote_pricing qp ON q.ID = qp.QUOTE_ID

        LEFT JOIN quotes.quotes.escalations e on q.ESCALATION_ID = e.ESCALATION_ID
            -- >= dateadd(day, '-60', CONVERT_TIMEZONE('UTC', 'America/Chicago', current_timestamp)::DATE)
        LEFT JOIN company_history ch on ch.company_id = q.company_id

      WHERE COALESCE(q.order_created_date::DATE, q.created_date::DATE) >= dateadd(day, '-60', current_date())
;;

  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }



  dimension: pk {
    type: string
    primary_key: yes
    sql:  concat( ${TABLE}."ID" ,  ${TABLE}."RENTAL_SUBTOTAL",  ${TABLE}."SALESPERSON_FULL_NAME", ${TABLE}."QUOTE_NUMBER")  ;;
  }


  dimension: market_name {
    type: string
    sql: ${TABLE}."MARKET_NAME" ;;
  }

  dimension: id {
    type: string
    sql: ${TABLE}."ID" ;;
  }

  dimension: quote_number {
    type: string
    sql: ${TABLE}."QUOTE_NUMBER" ;;
    html:
    <font color="#0063f3"><a href="https://quotes.estrack.com/{{id._rendered_value}}"target="_blank"><b>{{ rendered_value }} ➔</b>
 ;;
  }

  measure: total_quotes {
    type: count_distinct
    sql:  ${id} ;;
    drill_fields: [quote_detail*]
  }

  measure: total_quote_last_30 {
    type: count_distinct
    sql:  CASE WHEN ${quote_created_date_date} BETWEEN dateadd(day, '-30', current_date()) AND current_date() THEN ${id} ELSE NULL END;;
    html: <a href="#drillmenu" target="_self"> {{rendered_value}} <img src="https://imgur.com/ZCNurvk.png" height="15" width="15"></font></a>;;
    drill_fields: [quote_detail*]
  }


  measure: total_quote_last_30_plain {
    type: count_distinct
    sql:  CASE WHEN ${quote_created_date_date} BETWEEN dateadd(day, '-30', current_date()) AND current_date() THEN ${id} ELSE NULL END;;

    drill_fields: [quote_detail*]
  }

  measure: total_quote_prior_30 {
    type: count_distinct
    sql:  CASE WHEN ${quote_created_date_date} BETWEEN dateadd(day, '-60', current_date()) AND dateadd(day, '-31', current_date()) THEN ${id} ELSE NULL END;;
  }

  measure: diff_total_quote {
    type: number
    sql: ${total_quote_last_30} - ${total_quote_prior_30} ;;
    html:
    {% if value > 0 %}
    <font color="#00CB86">
    <strong>&#9650;&nbsp;{{rendered_value}}</strong></font> <!-- Up Triangle with space -->
    {% elsif value == 0 %}
    <font color="#808080">
    <strong>{{rendered_value}}</strong></font>
    {% elsif value < 0 %}
    <font color="#DA344D">
    <strong>&#9660;&nbsp;{{rendered_value}}</strong></font> <!-- Down Triangle with space -->
    {% else %}
    <font color="#808080">
    <strong>{{rendered_value}}</strong></font>
    {% endif %};;
  }

  measure: conversion_rate {
    type: number
    sql: DIV0NULL(COUNT(distinct ${order_id}), COUNT(distinct ${id})) ;;
    value_format_name: percent_1
  }

  measure: conversion_rate_last_30 {
    type: number
    sql: DIV0NULL(${total_order_last_30}, ${total_quote_last_30}) ;;
    value_format_name: percent_1
  }

  measure: conversion_rate_prior_30 {
    type: number
    sql: DIV0NULL(${total_order_prior_30}, ${total_quote_prior_30}) ;;
    value_format_name: percent_1
  }

  measure: diff_conversion {
    type: number
    sql: ${conversion_rate_last_30} - ${conversion_rate_prior_30} ;;
    html:
    {% if value > 0 %}
    <font color="#00CB86">
    <strong>&#9650;&nbsp;{{rendered_value}}</strong></font> <!-- Up Triangle with space -->
    {% elsif value == 0 %}
    <font color="#808080">
    <strong>{{rendered_value}}</strong></font>
    {% elsif value < 0 %}
    <font color="#DA344D">
    <strong>&#9660;&nbsp;{{rendered_value}}</strong></font> <!-- Down Triangle with space -->
    {% else %}
    <font color="#808080">
    <strong>{{rendered_value}}</strong></font>
    {% endif %};;
    value_format_name: percent_1
  }


  dimension: order_id {
    type: string
    sql: ${TABLE}."ORDER_ID" ;;
  }

  measure: total_orders {
    type: count_distinct
    sql: ${order_id} ;;
    drill_fields: [order_detail*]
  }

  measure: total_order_last_30 {
    type: count_distinct
    sql:  CASE WHEN ${order_created_date_date}  BETWEEN dateadd(day, '-30', current_date()) AND current_date() THEN ${order_id} ELSE NULL END;;
    html: <a href="#drillmenu" target="_self"> {{rendered_value}} <img src="https://imgur.com/ZCNurvk.png" height="15" width="15"></font></a>;;
    drill_fields: [order_detail*]

  }

  measure: total_order_last_30_plain {
    type: count_distinct
    sql:  CASE WHEN ${order_created_date_date}  BETWEEN dateadd(day, '-30', current_date()) AND current_date() THEN ${order_id} ELSE NULL END;;

    drill_fields: [order_detail*]

  }

  measure: total_order_prior_30 {
    type: count_distinct
    sql:  CASE WHEN ${order_created_date_date} BETWEEN dateadd(day, '-60', current_date()) AND dateadd(day, '-31', current_date()) THEN ${order_id} ELSE NULL END;;
    drill_fields: [order_detail*]
  }

  measure: diff_total_order {
    type: number
    sql: ${total_order_last_30} - ${total_order_prior_30} ;;
    html:
    {% if value > 0 %}
    <font color="#00CB86">
    <strong>&#9650;&nbsp;{{rendered_value}}</strong></font> <!-- Up Triangle with space -->
    {% elsif value == 0 %}
    <font color="#808080">
    <strong>{{rendered_value}}</strong></font>
    {% elsif value < 0 %}
    <font color="#DA344D">
    <strong>&#9660;&nbsp;{{rendered_value}}</strong></font> <!-- Down Triangle with space -->
    {% else %}
    <font color="#808080">
    <strong>{{rendered_value}}</strong></font>
    {% endif %};;
  }

  dimension_group: quote_created_date {
    type: time
    label: "Quote Created"
    sql: ${TABLE}."QUOTE_CREATED_DATE" ;;
    html: {{ rendered_value | date: "%b %d, %Y" }};;
  }

  dimension_group: quote_start_date {
    label: "Quote Start"
    type: time
    sql: ${TABLE}."QUOTE_START_DATE" ;;
    html: {{ rendered_value | date: "%b %d, %Y" }};;
  }

  dimension_group: quote_end_date {
    type: time
    label: "Quote End"
    sql: ${TABLE}."QUOTE_END_DATE" ;;
    html: {{ rendered_value | date: "%b %d, %Y" }};;
  }

  dimension_group: order_created_date {
    type: time
    label: "Order Created"
    sql: ${TABLE}."ORDER_CREATED_DATE" ;;
    html: {{ rendered_value | date: "%b %d, %Y" }};;
  }

  dimension: company_id {
    type: string
    sql: ${TABLE}."COMPANY_ID" ;;
  }

  dimension: customer_prospect {
    type: string
    sql: case when ${company_id} is null then 'Prospect' else 'Customer' end ;;
  }

  measure: new_co_count_last_30 {
    type: count_distinct
    sql:  CASE WHEN ${company_id} IS NULL AND ${quote_created_date_date} >= dateadd(day, '-30', current_date) THEN ${complete_company_name} ELSE NULL END ;;
    drill_fields: [quote_detail*]
  }

  dimension: complete_company_name {
    label: "Company Name"
    type: string
    sql: ${TABLE}."COMPLETE_COMPANY_NAME" ;;
  }

  dimension: company_contact_name {
    type: string
    sql: ${TABLE}."COMPANY_CONTACT_NAME" ;;
    drill_fields: [company_contact_name, company_contact_phone, site_contact_name, site_contact_phone]
  }

  dimension: company_contact_phone {
    type: string
    sql: ${TABLE}."COMPANY_CONTACT_PHONE" ;;
  }

  dimension: site_contact_name {
    type: string
    sql: ${TABLE}."SITE_CONTACT_NAME" ;;
  }

  dimension: site_contact_phone {
    type: string
    sql: ${TABLE}."SITE_CONTACT_PHONE" ;;
  }

  dimension: salesperson_full_name {
    type: string
    sql: ${TABLE}."SALESPERSON_FULL_NAME" ;;
  }

  dimension: salesperson_user_id {
    type: string
    sql: ${TABLE}."SALESPERSON_USER_ID" ;;
  }

  dimension: salesperson_current_location {
    type: string
    sql: ${TABLE}."SALESPERSON_CURRENT_LOCATION" ;;

  }

  dimension: salesperson_location {
    label: "Rep - Current Location"
    type: string
    sql: concat(${salesperson_full_name}, ' - ', ${salesperson_current_location}) ;;
  }

  dimension: missed_quote_reason {
    type: string
    sql: ${TABLE}."MISSED_QUOTE_REASON" ;;
  }

  dimension: missed_quote_reason_other {
    type: string
    sql: ${TABLE}."MISSED_QUOTE_REASON_OTHER" ;;
  }

  dimension: missed_quote_reasoning {
    type:  string
    sql:  CASE WHEN ${missed_quote_reason} ILIKE '%other%' OR ${missed_quote_reason} IS NULL then ${missed_quote_reason_other} ELSE ${missed_quote_reason} END  ;;
  }

  dimension: full_equipment_name {
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

  dimension: rate_summary {
    type: string
    label: "Day / Week / Four-Week Rate"
    description: "Day / Week / Four Week Rate"
    sql: CONCAT('$', ${day_rate}, ' / ', '$', ${week_rate}, ' / ', '$', ${four_week_rate}) ;;
    value_format_name: usd_0
  }

  dimension: category {
    type: string
    sql: ${TABLE}."CATEGORY" ;;
    html: <font color="#000000">
      {{rendered_value}}
    <br />
    <font style="color: #8C8C8C; text-align: right;">{{full_equipment_name._rendered_value}}</font>
    </font> ;;
  }

  dimension: timeframe {
    type: string
    sql: ${TABLE}."TIMEFRAME" ;;
  }

  dimension_group: expiration_date {
    type: time
    sql: ${TABLE}."EXPIRATION_DATE" ;;
    html: {{ rendered_value | date: "%b %d, %Y" }};;
  }

  dimension: project_type {
    type: string
    sql: ${TABLE}."PROJECT_TYPE" ;;
  }

  dimension: rental_subtotal {
    type: number
    sql: ${TABLE}."RENTAL_SUBTOTAL" ;;
    value_format_name: usd_0
  }

  measure: rental_subtotal_sum {
    type: sum_distinct
    sql:  ${rental_subtotal} ;;
    value_format_name: usd_0
    drill_fields: [detail*]
  }

  dimension: location_description {
    type: string
    sql: ${TABLE}."LOCATION_DESCRIPTION" ;;
  }

  dimension: district {
    type: string
    sql: ${TABLE}."DISTRICT" ;;
  }

  dimension: region {
    type: string
    sql: ${TABLE}."REGION" ;;
  }

  dimension: region_name {
    type: string
    sql: ${TABLE}."REGION_NAME" ;;
  }

  dimension: escalation_id {
    type: string
    sql:${TABLE}."ESCALATION_ID" ;;
  }

  dimension: escalation_message {
    type: string
    sql:${TABLE}."ESCALATION_MESSAGE" ;;
  }

  dimension_group: escalation_create_date {
    type: time
    label: "Escalation Create"
    sql:${TABLE}."ESCALATION_CREATE_DATE" ;;
    html: {{ rendered_value | date: "%b %d, %Y" }};;
  }

  dimension: escalation_created_by {
    type: string
    sql:${TABLE}."ESCALATION_CREATED_BY" ;;
  }

  dimension: current_status {
    type: string
    sql:${TABLE}."CURRENT_STATUS" ;;
  }

  dimension_group: last_modified_date {
    type: time
    sql:${TABLE}."LAST_MODIFIED_DATE" ;;
    html: {{ rendered_value | date: "%b %d, %Y" }};;
  }

  dimension: days_escalated {
    type: number
    sql:${TABLE}."DAYS_ESCALATED" ;;
  }
  dimension: path {
    type: string
    label: "Quote Status - Current"
    sql:${TABLE}."PATH" ;;
    }

  dimension: path2 {
    type: string
    label: "Current Quote Status"
    sql:${TABLE}."PATH" ;;
    html:
     {% if rendered_value == 'Order Created' %}
       <font color="#4a6f8c">
       <strong>{{ rendered_value }}</strong>
    <br />
    <font style="color: #8C8C8C; text-align: right;">Order ID: {{order_id._rendered_value}}</font>
    </font>

     {% elsif rendered_value == 'Escalated' %}
    <font color="#a57cc6">
     <strong>{{ rendered_value }}</strong>
    <br />
    <font style="color: #8C8C8C; text-align: right;">As of {{escalation_create_date_date._rendered_value| date: "%b %d, %Y" }}</font>
    </font>

    {% elsif rendered_value == 'Missed Quote' %}
    <font color="#d1b13a">
     <strong>{{ rendered_value }}</strong>
    <br />
    <font style="color: #8C8C8C; text-align: right;">{{missed_quote_reasoning._rendered_value}}</font>
    </font>

    {% elsif rendered_value == 'Expired' %}
    <font color="#DA344D">
     <strong>{{ rendered_value }}</strong>

    {% else %}
    <font color="#007747">
     <strong>{{ rendered_value }}</strong>

    {% endif %};;
  }

  dimension: path2_export {
    type: string
    group_label: "Export Ready"
    label: "Current Quote Status"
    sql: CASE
      WHEN ${TABLE}."PATH" = 'Missed Quote' THEN 'Missed Quote - ' || ${missed_quote_reasoning}
      WHEN ${TABLE}."PATH" = 'Order Created' THEN 'Order Created - Order ID: ' || ${order_id}
      WHEN ${TABLE}."PATH" = 'Escalated' THEN 'Escalated - As of ' || ${escalation_create_date_date}
      ELSE ${TABLE}."PATH"
    END ;;
    html:
    {% if path._rendered_value == 'Order Created' %}
    <font color="#4a6f8c">
    <strong>{{ path._rendered_value }}</strong>
    <br />
    <font style="color: #8C8C8C; text-align: right;">Order ID: {{order_id._rendered_value}}</font>
    </font>

    {% elsif path._rendered_value == 'Escalated' %}
    <font color="#a57cc6">
    <strong>{{ path._rendered_value }}</strong>
    <br />
    <font style="color: #8C8C8C; text-align: right;">As of {{escalation_create_date_date._rendered_value| date: "%b %d, %Y" }}</font>
    </font>

    {% elsif path._rendered_value == 'Missed Quote' %}
    <font color="#d1b13a">
    <strong>{{ path._rendered_value }}</strong>
    <br />
    <font style="color: #8C8C8C; text-align: right;">{{missed_quote_reasoning._rendered_value}}</font>
    </font>

    {% elsif rendered_value == 'Expired' %}
    <font color="#DA344D">
    <strong>{{ rendered_value }}</strong>

    {% else %}
    <font color="#007747">
    <strong>{{ rendered_value }}</strong>

    {% endif %};;

  }

  dimension: customer_name_and_id_with_na_icon_and_link {
    label: "Customer"
    type: string
    sql: coalesce(${complete_company_name},${companies.name}) ;;
    html:
    {% if companies.company_id._value == null  %}

    {{rendered_value}}

    {% elsif national_account_companies.customer_name._value == null %}

    <font color="0063f3 "><a href="https://equipmentshare.looker.com/dashboards/28?Company+Name={{ filterable_value | url_encode }}" target="_blank">{{rendered_value}} ➔ </a></font>
          <td>
            <span style="color: #8C8C8C;"> ID: {{company_id._value}} </span>
            </td>

    {% else %}
    <img src="https://cdn-icons-png.flaticon.com/512/63/63811.png" title="National Account" height="15" width="15"> <font color="0063f3 "><a href="https://equipmentshare.looker.com/dashboards/28?Company+Name={{ filterable_value | url_encode }}" target="_blank">{{rendered_value}} ➔ </a></font>
          <td>
            <span style="color: #8C8C8C;"> ID: {{company_id._value}} </span>
            </td>
    {% endif %}
     ;;

  }

  dimension: aor_30_days_ago {
    group_label: "Company Metrics"
    type: number
    sql:  ${TABLE}."AOR_30_DAYS_AGO";;
  }

  measure: aor_30_days_ago_avg {
    group_label: "Company Metrics"

    label: "AOR - 30 Days Ago"
    type: average
    sql:  ${aor_30_days_ago};;
  }


  dimension: oec_30_days_ago {
    group_label: "Company Metrics"

    type: number
    sql:  ${TABLE}."OEC_30_DAYS_AGO";;
    value_format_name: usd_0
  }

  measure: OEC_30_days_ago_avg {
    group_label: "Company Metrics"

    label: "OEC - 30 Days Ago"
    type: average
    sql:  ${oec_30_days_ago};;
    value_format_name: usd_0

  }

  dimension: aor_today {
    group_label: "Company Metrics"

    type: number
    sql:  ${TABLE}."AOR_TODAY";;
  }

  measure: aor_today_avg {
    group_label: "Company Metrics"

    label: "AOR - Today"
    type: average
    sql:  ${aor_today};;
  }

  dimension: oec_today {
    group_label: "Company Metrics"

    type: number
    sql:  ${TABLE}."OEC_TODAY";;
    value_format_name: usd_0

  }

  measure: OEC_today_avg {
    group_label: "Company Metrics"

    label: "OEC - Today"
    type: average
    sql:  ${oec_today};;
    value_format_name: usd_0

  }


  measure: diff_aor {
    group_label: "Company Metrics"

    label: "AOR Change Over 30 Days"
    type: average
    sql: ${aor_today} - ${aor_30_days_ago} ;;
    html:{% if value > 0 %}
        <font color="#00CB86">
        <strong>&#9650;&nbsp;{{rendered_value}}</strong></font> <!-- Up Triangle with space -->
    {% elsif value == 0 %}
        <font color="#808080">
        <strong>{{rendered_value}}</strong></font>
    {% elsif value < 0 %}
        <font color="#DA344D">
        <strong>&#9660;&nbsp;{{rendered_value}}</strong></font> <!-- Down Triangle with space -->
    {% else %}
        <font color="#808080">
        <strong>{{rendered_value}}</strong></font>
    {% endif %}  ;;
  }

  measure: diff_oec {
    group_label: "Company Metrics"

    label: "OEC Change Over 30 Days"
    type: average
    sql: ROUND(${oec_today} - ${oec_30_days_ago},2) ;;
    html:{% if value > 0 %}
    <font color="#00CB86">
    <strong>&#9650;&nbsp;{{ rendered_value }}</strong></font>
{% elsif value == 0 %}
    <font color="#808080">
    <strong>{{ rendered_value }}</strong></font>
{% elsif value < 0 %}
    <font color="#DA344D">
    <strong>&#9660;&nbsp;{{ rendered_value }}</strong></font>
{% else %}
    <font color="#808080">
    <strong>{{ rendered_value }}</strong></font>
{% endif %} ;;
value_format_name: usd_0
  }





  set: detail {
    fields: [
        market_name,
  quote_number,
      quote_created_date_date,
      expiration_date_date,
      company_id,
      complete_company_name,
      salesperson_full_name,
      order_id,
      order_created_date_date,

      rental_subtotal,
      missed_quote_reason,
      missed_quote_reason_other,

      escalation_create_date_date,
      days_escalated,
      escalation_created_by,
      path
    ]
  }

  set: company_detail {
    fields: [
      quote_number,
      quote_created_date_date,
      expiration_date_date,
      company_id,
      complete_company_name,
      salesperson_full_name,
      order_id,
      order_created_date_date,
      rate_summary,
      rental_subtotal,
      missed_quote_reason,
      missed_quote_reason_other,

      escalation_create_date_date,
      days_escalated,
      escalation_created_by,
      path


    ]
  }

  set: quote_detail {
    fields: [
      quote_number,
      quote_created_date_date,
      salesperson_location,
      customer_name_and_id_with_na_icon_and_link,
      path2,
      rental_subtotal
    ]
  }
  set: order_detail {
    fields: [
      quote_number,
      quote_created_date_date,
      order_created_date_date,
      salesperson_location,
      customer_name_and_id_with_na_icon_and_link,
      path2,
      rental_subtotal
    ]
  }
}
