view: call_conversion {
  derived_table: {
    sql: with
quote as (
SELECT q._es_update_timestamp::datetime as timestamp,
        contact_phone,
        CASE
          WHEN LENGTH(REGEXP_REPLACE(TO_VARCHAR(contact_phone), '[^0-9]', '')) >= 11
               AND LEFT(REGEXP_REPLACE(TO_VARCHAR(contact_phone), '[^0-9]', ''), 1) = '1'
            THEN '+1' || SUBSTR(REGEXP_REPLACE(TO_VARCHAR(contact_phone), '[^0-9]', ''), 2, 10)
          WHEN LENGTH(REGEXP_REPLACE(TO_VARCHAR(contact_phone), '[^0-9]', '')) >= 10
            THEN '+1' || SUBSTR(REGEXP_REPLACE(TO_VARCHAR(contact_phone), '[^0-9]', ''), 1, 10)
          ELSE NULL
        END AS contact_phone_e164,
        qp.created_date,
        q.company_name,
        contact_name,
        contact_email,
        concat(u.first_name, ' ', u.last_name) as sales_rep,
        rpp_name,
        quote_number,
        order_id,
        total
from quotes.quotes.quote q
left join quotes.quotes.quote_pricing qp on qp.quote_id = q.id
left join es_warehouse.public.users u on u.user_id = q.sales_rep_id
)
, first_quote as (
select
        company_name,
        contact_phone_e164,
        MIN(created_date) AS first_quote
FROM quote
GROUP BY company_name, contact_phone_e164
)
, company_first_quote AS (
select
        company_name,
        MIN(first_quote) AS first_quote
FROM first_quote
GROUP BY company_name
)
,conversion as (
select distinct
        right(w.origin,len(origin)-1) as origin_lookup,
        w.origin,
        case when w.connected_duration > 0 then TRUE else FALSE end as answered,
        w.flow_activity_name,
        w.matched_skill_name as queue_name,
        w.queue_duration,
        w.hold_duration,
        w.connected_duration,
        convert_timezone('UTC','America/Chicago',w.created_at) as created_at_cst,
        w.created_at,
        q.created_date,
        q.company_name,
        q.contact_name,
        q.contact_email,
        q.sales_rep,
        q.rpp_name,
        q.quote_number,
        q.order_id,
        q.total as quote_total,
        case when q.quote_number is not null then TRUE else FALSE end as quote_converted,
        case when q.order_id is not null then TRUE else FALSE end as order_converted,
        concat(origin,TO_VARCHAR(DATE(created_at_cst), 'YYYY-MM-DD')) as call_join_key,
        case when fq.first_quote = q.created_date then TRUE else FALSE end as first_quote,
        case when fcq.first_quote = q.created_date then TRUE else FALSE end as first_company_quote
from BUSINESS_INTELLIGENCE.WEBEX.STG_WEBEX_CONTACT_CENTER_CALL_DETAILS w
left join quote q on q.contact_phone_e164 = w.origin
and left(w.created_at,10) = left(q.created_date,10) -- Webex call was on the same day as the quote being created
and q.created_date >= w.created_at -- Ensure no mismatch on quotes created before the call
left join first_quote fq on fq.company_name = q.company_name and fq.contact_phone_e164 = q.contact_phone_e164
left join company_first_quote fcq on fcq.company_name = q.company_name
),
google_ads as (
select
        'Google Ads' as source,
        REGEXP_REPLACE(caller_phone_number, '[^0-9+]', '') AS contact_phone_e164, -- PLUS
        TO_DATE(COALESCE(
  TRY_TO_TIMESTAMP_NTZ(REPLACE(start_time, '\u202F', ' '), 'Mon DD, YYYY, HH12:MI:SS AM'),
  TRY_TO_TIMESTAMP_NTZ(REPLACE(start_time, '\u202F', ' '), 'MM/DD/YYYY HH24:MI:SS')
)) AS start_date,
        case when contact_phone_e164 is null then null else concat(contact_phone_e164, TO_VARCHAR(start_date, 'YYYY-MM-DD')) end as join_key,
        campaign,
        campaign_group,
        duration_seconds_ as duration_seconds,
        null as caller_name,
        null as landing_page,
        null as keywords
from ANALYTICS.GOOGLE_ADS.FIVETRAN_PAID_ADVERTISING
where start_date::date >= {% date_start date_filter %}
and start_date::date <= {% date_end date_filter %}
),
callrail as (
        select
        'CallRail' as source,
        '+1' || REGEXP_REPLACE(phone_number, '[^0-9]', '') AS contact_phone_e164, -- PLUS
        TO_DATE(start_time) as start_date,
        case when contact_phone_e164 is null then null else concat(contact_phone_e164, TO_VARCHAR(start_date, 'YYYY-MM-DD')) end as join_key,
        campaign,
        campaign_group,
        duration_seconds_ as duration_seconds,
        name as caller_name,
        landing_page,
        keywords
from ANALYTICS.CALLRAIL.FIVETRAN_PAID_ADVERTISING
where start_date::date >= {% date_start date_filter %}
and start_date::date <= {% date_end date_filter %}
),
callrail_google_combined as (
select * from callrail
union
select * from google_ads
)
select *
from callrail_google_combined ga
left join conversion c on c.call_join_key = ga.join_key
  ;;
  }

### Call Info
  dimension: source {
    description: "Data source of call"
    type: string
    sql: ${TABLE}.source ;;
  }

  dimension: campaign_group {
    description: "Campaign named standardized across the data sources"
    type: string
    sql: ${TABLE}.campaign_group ;;
  }

  dimension: contact_phone_e164 {
    description: "Caller phone number formatted to E164"
    type: string
    sql: ${TABLE}.contact_phone_e164 ;;
  }

  dimension: start_date {
    type: date
    description: "Date phone call was received"
    sql: ${TABLE}.start_date ;;
  }

  dimension: join_key {
    description: "Date & phone number combined to match to quote data"
    type: string
    sql: ${TABLE}.join_key ;;
  }

  dimension: campaign {
    description: "Campaign that the call was a part of"
    type: string
    sql: ${TABLE}.campaign ;;
  }

  dimension: duration_seconds {
    description: "Duration of the phone call in seconds"
    type: number
    sql: ${TABLE}.duration_seconds ;;
  }

  dimension: caller_name {
    description: "Name of party calling - Only CallRail"
    type: string
    sql: ${TABLE}.caller_name ;;
  }

  dimension: landing_page {
    description: "Page caller initiated call from - Only CallRail"
    type: string
    sql: ${TABLE}.landing_page ;;
  }

  dimension: keywords {
    description: "Keywords used in call - Only CallRail"
    type: string
    sql: ${TABLE}.keywords ;;
  }

### Quote Linked Info

  dimension: origin {
    description: "Caller number associated with quote"
    type: number
    sql: ${TABLE}.origin ;;
  }

  dimension: answered {
    description: "Was the phone call answered - T/F"
    type: string
    sql: ${TABLE}.answered ;;
  }

  dimension: flow_activity_name {
    description: "Script used by call agent"
    type: string
    sql: ${TABLE}.flow_activity_name ;;
  }

  dimension: queue_name {
    description: "Queue that caller was in"
    type: string
    sql: ${TABLE}.queue_name ;;
  }

  dimension: queue_duration_seconds {
    description: "How long caller waited in queue - in seconds"
    type: number
    sql: ${TABLE}.queue_duration ;;
  }

  dimension: queue_duration_minutes {
    description: "How long caller waited in queue - in minutes"
    type: number
    sql:coalesce(${TABLE}.queue_duration,0) / 60 ;;
  }

  dimension: hold_duration_seconds {
    description: "How long caller waited on hold - in seconds"
    type: number
    sql: ${TABLE}.hold_duration ;;
  }

  dimension: hold_duration_minutes {
    description: "How long caller waited on hold - in minutes"
    type: number
    sql:coalesce(${TABLE}.hold_duration,0) / 60 ;;
  }

  dimension: connected_duration_seconds {
    description: "How long caller was connected on call - in seconds"
    type: number
    sql: ${TABLE}.connected_duration ;;
  }

  dimension: connected_duration_minutes {
    description: "How long caller was connected on call - in minutes"
    type: number
    sql:coalesce(${TABLE}.connected_duration,0) / 60 ;;
  }

  dimension: created_at_cst {
    description: "Date & time call took place - central standard time"
    type: date_time
    sql: ${TABLE}.created_at_cst ;;
  }

  dimension: created_at {
    description: "Date & time call took place - UTC"
    type: date_time
    sql: ${TABLE}.created_at ;;
  }

  dimension: created_date {
    description: "Date quote was created"
    type: date
    sql: ${TABLE}.created_date ;;
  }

  dimension: company_name {
    description: "Name of company that requested quote"
    type: string
    sql: ${TABLE}.company_name ;;
  }

  dimension: contact_name {
    description: "Name of contact that requested quote"
    type: string
    sql: ${TABLE}.contact_name ;;
  }

  dimension: contact_email {
    description: "Email of contact that requested quote"
    type: string
    sql: ${TABLE}.contact_email ;;
  }

  dimension: sales_rep {
    description: "Sales representative of requested quote"
    type: string
    sql: ${TABLE}.sales_rep ;;
  }

  dimension: rpp_name {
    description: "Rental Protection Plan - agreed protection charge"
    type: string
    sql: ${TABLE}.rpp_name ;;
  }

  dimension: quote_number {
    description: "ID assocated with the requested quote"
    type: string
    sql: ${TABLE}.quote_number ;;
  }

  dimension: order_id {
    description: "Order ID associated with the requested quote"
    type: string
    sql: ${TABLE}.order_id ;;
  }

  dimension: quote_total {
    description: "Total charges associated with the requested quote"
    type: number
    sql: ${TABLE}.quote_total ;;
  }

  dimension: quote_converted {
    description: "Was the call converted to a quote - T/F"
    type: string
    sql: ${TABLE}.quote_converted ;;
  }

  dimension: order_converted {
    description: "Was the call converted to an order - T/F"
    type: string
    sql: ${TABLE}.order_converted ;;
  }

  dimension: call_join_key {
    description: "Date & phone number combined to match to call data"
    type: string
    sql: ${TABLE}.call_join_key ;;
  }

  dimension: first_quote {
    description: "Was this the first quote requested by the user / phone number - T/F"
    type: string
    sql: ${TABLE}.first_quote ;;
  }

  dimension: first_company_quote {
    description: "Was this the first quote requested by the company - T/F"
    type: string
    sql: ${TABLE}.first_company_quote ;;
  }

  dimension: is_duplicate_pair {
    type: yesno
    sql: EXISTS (
        SELECT 1
        FROM ${TABLE} t2
        WHERE t2.contact_phone_e164 = ${contact_phone_e164}
          AND t2.start_date         = ${start_date}
          AND t2.duration_seconds   = ${duration_seconds}
        GROUP BY t2.contact_phone_e164, t2.start_date, t2.duration_seconds
        HAVING COUNT(*) = 2
           AND COUNT(DISTINCT t2.source) = 2
      ) ;;
  }

  dimension: is_primary_in_pair {
    type: yesno
    sql:
    ${is_duplicate_pair} AND
    ${source} = (
      SELECT MIN(t3.source)
      FROM ${TABLE} t3
      WHERE t3.contact_phone_e164 = ${contact_phone_e164}
        AND t3.start_date         = ${start_date}
        AND t3.duration_seconds   = ${duration_seconds}
    ) ;;
  }


### Filters
filter: date_filter {type:date}


### Measures
measure: quote_total_amount {
  type: sum
  sql: ${quote_total} ;;
  drill_fields: [created_at_cst, sales_rep, company_name, contact_name, contact_email, quote_number, quote_total]
  value_format_name: "usd"
}

measure: quotes {
  type: count_distinct
  sql: ${quote_number} ;;
}

measure: orders {
  type: count_distinct
  sql: ${order_id} ;;
}

measure: calls {
  type: count_distinct
  sql: ${join_key} ;;
}

measure: calls_to_quotes {
  sql: ${quotes}/nullif(${calls},0) ;;
  value_format: "0.0%"
}

measure: calls_to_orders {
  sql: ${orders}/nullif(${calls},0) ;;
  value_format: "0.0%"
}

measure: quotes_to_orders {
  sql: ${orders}/nullif(${quotes},0) ;;
  value_format: "0.0%"
}

measure: new_customers {
  type: count_distinct
  sql: ${company_name} ;;
  filters: [first_company_quote: "true"]
}

measure: new_customers_with_order{
  type: count_distinct
  sql: ${company_name} ;;
  filters: [first_company_quote: "true",quote_converted: "true"]
}

# Number of duplicate calls (pairs) — one per pair
  measure: duplicate_calls_pairs {
    type: count
    filters: [is_duplicate_pair: "yes", is_primary_in_pair: "yes"]
    value_format_name: "decimal_0"
  }

# Quote dollars that were double-counted — sum once per pair
  measure: duplicate_quote_overcount {
    type: sum
    sql: CASE WHEN ${is_duplicate_pair} AND ${is_primary_in_pair} THEN ${quote_total} END ;;
    value_format_name: "usd"
  }

# Calls after removing duplicates
  measure: calls_adjusted {
    type: number
    sql: ${calls} - ${duplicate_calls_pairs} ;;
    value_format_name: "decimal_0"
  }

# Quote total after removing duplicate dollars
  measure: quote_total_amount_adjusted {
    type: number
    sql: ${quote_total_amount} - ${duplicate_quote_overcount} ;;
    drill_fields: [created_date, sales_rep, company_name, contact_name, contact_email, quote_number, quote_total_amount_adjusted]
    value_format_name: "usd"
  }

  measure: calls_to_quotes_adjusted {
    sql: ${quotes}/nullif(${calls_adjusted},0) ;;
    value_format: "0.0%"
  }

  measure: calls_to_orders_adjusted {
    sql: ${orders}/nullif(${calls_adjusted},0) ;;
    value_format: "0.0%"
  }
}
