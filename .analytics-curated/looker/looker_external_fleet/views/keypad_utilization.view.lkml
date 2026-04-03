view: keypad_utilization {
derived_table: {
    sql:
WITH company_assets AS (
    SELECT DISTINCT company_id, al.asset_id, custom_name
    FROM table(assetlist({{ _user_attributes['user_id'] }}::numeric)) al
    LEFT JOIN assets a ON al.asset_id = a.asset_id
),
rental_assets AS (
select
rsi.asset_id,
rsi.rental_id,
rsi.rental_start_datetime as start_date,
rsi.rental_end_datetime as end_date
from
business_intelligence.triage.stg_t3__rental_status_info rsi
left join company_assets ca ON ca.asset_id = rsi.asset_id
WHERE COALESCE(ca.company_id,0) <> ({{ _user_attributes['company_id']}}::numeric)
AND rsi.rental_start_datetime <= CONVERT_TIMEZONE('{{ _user_attributes['user_timezone'] }}', 'UTC', {% date_start date_filter %}::timestamp_ntz)
AND rsi.rental_end_datetime >= CONVERT_TIMEZONE('{{ _user_attributes['user_timezone'] }}', 'UTC', {% date_end date_filter %}::timestamp_ntz)
AND rsi.asset_id is not null




--SELECT a.ASSET_ID, a.RENTAL_ID, a.RENTAL_TYPE_NAME, a.START_DATE, a.END_DATE
--FROM TABLE(public.RENTAL_ASSET_LIST({{ _user_attributes['user_id'] }}::numeric,
--        CONVERT_TIMEZONE('{{ _user_attributes['user_timezone'] }}', 'UTC', {% date_start date_filter %}::timestamp_ntz),
--        CONVERT_TIMEZONE('{{ _user_attributes['user_timezone'] }}', 'UTC', {% date_end date_filter %}::timestamp_ntz),
--        '{{ _user_attributes['user_timezone'] }}')) a
--LEFT JOIN company_assets ca ON ca.asset_id = a.asset_id
--WHERE COALESCE(ca.company_id,0) <> ({{ _user_attributes['company_id']}}::numeric)
),
all_assets_rented AS ( -- Query when 'rented' is 'Yes' (Includes RENTAL_ASSET_LIST join)
    SELECT t.trip_id,
           t.asset_id,
           t.start_timestamp,
           t.end_timestamp,
           round(t.trip_time_seconds/60::numeric, 1) AS trip_mins,
           t.asset_keypad_entry_id,
           coalesce(ake.keypad_code, kc.code) AS keypad_code,
           kc.code,
           ake.keypad_timestamp,
           coalesce(ake.user_id::text, ckeys.user_id::text, ckeys.name) AS keypad_code_name,
           ckeys.company_id
    FROM rental_assets a
    JOIN public.trips t ON a.asset_id = t.asset_id
       AND t.start_timestamp >= a.start_date
       AND t.start_timestamp <= a.end_date
    LEFT JOIN public.asset_keypad_entries ake ON t.asset_keypad_entry_id = ake.asset_keypad_entry_id
    JOIN public.keypads k on a.asset_id = k.asset_id
    LEFT JOIN public.keypad_code_assignments kca ON kca.keypad_code_assignment_id = ake.keypad_code_assignment_id
    LEFT JOIN public.keypad_codes kc ON kca.keypad_code_id = kc.keypad_code_id
    LEFT JOIN public.company_keypad_codes ckeys ON kca.company_keypad_code_id = ckeys.company_keypad_code_id
    WHERE t.start_timestamp >= CONVERT_TIMEZONE('{{ _user_attributes['user_timezone'] }}', 'UTC', {% date_start date_filter %}::timestamp_ntz)::timestamptz
      AND t.start_timestamp < CONVERT_TIMEZONE('{{ _user_attributes['user_timezone'] }}', 'UTC', {% date_end date_filter %}::timestamp_ntz)::timestamptz
      AND t.trip_type_id NOT IN (3,6)
),
all_assets_owned AS (-- Query when 'rented' is 'No' (Does NOT use RENTAL_ASSET_LIST join)
    SELECT t.trip_id,
           t.asset_id,
           t.start_timestamp,
           t.end_timestamp,
           round(t.trip_time_seconds/60::numeric, 1) AS trip_mins,
           t.asset_keypad_entry_id,
           coalesce(ake.keypad_code, kc.code) AS keypad_code,
           kc.code,
           ake.keypad_timestamp,
           coalesce(ake.user_id::text, ckeys.user_id::text, ckeys.name) AS keypad_code_name,
           ckeys.company_id
    FROM public.trips t
    LEFT JOIN public.asset_keypad_entries ake ON t.asset_keypad_entry_id = ake.asset_keypad_entry_id
    JOIN public.keypads k on t.asset_id = k.asset_id
    LEFT JOIN public.keypad_code_assignments kca ON kca.keypad_code_assignment_id = ake.keypad_code_assignment_id
    LEFT JOIN public.keypad_codes kc ON kca.keypad_code_id = kc.keypad_code_id
    LEFT JOIN public.company_keypad_codes ckeys ON kca.company_keypad_code_id = ckeys.company_keypad_code_id
    WHERE t.asset_id IN (SELECT DISTINCT asset_id FROM company_assets)
      AND t.start_timestamp >= CONVERT_TIMEZONE('{{ _user_attributes['user_timezone'] }}', 'UTC', {% date_start date_filter %}::timestamp_ntz)::timestamptz
      AND t.start_timestamp < CONVERT_TIMEZONE('{{ _user_attributes['user_timezone'] }}', 'UTC', {% date_end date_filter %}::timestamp_ntz)::timestamptz
      AND t.trip_type_id NOT IN (3,6)
)
SELECT a.trip_id,
       a.asset_id,
       ca.custom_name,
       CONVERT_TIMEZONE('{{ _user_attributes['user_timezone'] }}', a.start_timestamp) AS start_timestamp,
       CONVERT_TIMEZONE('{{ _user_attributes['user_timezone'] }}', a.end_timestamp) AS end_timestamp,
       a.trip_mins,
       a.asset_keypad_entry_id,
       CASE
           WHEN a.company_id = 1854 AND {{ _user_attributes['company_id']}}::numeric <> 1854
           THEN '******'
           ELSE a.keypad_code
       END AS keypad_code,
       a.code,
       CASE
           WHEN a.asset_id IN (SELECT asset_id FROM company_assets)
           THEN 'No'
           ELSE 'Yes'
       END AS rented,
       CONVERT_TIMEZONE('{{ _user_attributes['user_timezone'] }}', a.keypad_timestamp) AS keypad_timestamp,
       CASE
           WHEN a.company_id = 1854 AND {{ _user_attributes['company_id']}}::numeric <> 1854
           THEN '******'
           ELSE a.keypad_code_name
       END as keypad_code_name,
       a.company_id
FROM (
    SELECT * FROM all_assets_rented
    UNION
    SELECT * FROM all_assets_owned
) a
LEFT JOIN assets ca ON ca.asset_id = a.asset_id

;;


}

  dimension: trip_id {
    primary_key: yes
    type: number
    sql: ${TABLE}."TRIP_ID" ;;
  }

  dimension: asset_id {
    type: number
    sql: ${TABLE}."ASSET_ID" ;;
  }

  dimension: custom_name {
    label: "Asset"
    type: string
    sql: ${TABLE}."CUSTOM_NAME" ;;
  }

  dimension_group: start_timestamp {
    type: time
    sql: ${TABLE}."START_TIMESTAMP" ;;
    html: {{rendered_value | date: "%b %d, %Y %r"}} {{ _user_attributes['user_timezone_label'] }};;
  }

  dimension_group: end_timestamp {
    type: time
    sql: ${TABLE}."END_TIMESTAMP" ;;
    html: {{rendered_value | date: "%b %d, %Y %r"}} {{ _user_attributes['user_timezone_label'] }};;
  }

  dimension: trip_mins {
    type: number
    sql: ${TABLE}."TRIP_MINS" ;;
  }

  dimension: asset_keypad_entry_id {
    type: number
    sql: ${TABLE}."ASSET_KEYPAD_ENTRY_ID" ;;
  }

  dimension: keypad_code {
    type: string
    sql: coalesce(${TABLE}."KEYPAD_CODE", 'None') ;;
  }

  dimension_group: keypad_timestamp {
    type: time
    sql: ${TABLE}."END_TIMESTAMP" ;;
  }

  dimension: rented {
    label: "Ownership"
    type: string
    sql:  case when ${TABLE}."RENTED" = 'Yes' then 'Rented'
          ELSE 'Owned'
          END;;
  }

  dimension: keypad_code_name {
    type: string
    sql: ${TABLE}."KEYPAD_CODE_NAME" ;;
  }

  filter: date_filter {
    type: date_time
  }

  measure: total_utilization_hours {
    label: "Total Hours w/ Label"
    type: sum
    sql: ${trip_mins} / 60 ;;
    html: {{rendered_value}} Hours ;;
    value_format: "#,##0.00"
  }

  measure: total_utilization_hours_raw {
    label: "Total Hours"
    type: sum
    sql: ${trip_mins} / 60 ;;
    value_format: "#,##0.00"
  }

  measure: total_non_keycode_hours {
    label: "Total Hours w/o Keypad Code"
    type: sum
    sql: ${trip_mins} / 60 ;;
    html: {{rendered_value}} Hours ({{percent_non_keycode._rendered_value}}%) w/ No Keypad Code ;;
    filters: [keypad_code: "None"]
    value_format: "#,##0.00"
  }

  measure: percent_non_keycode {
    label: "% of Utilization w/ No Keypad Code"
    type: number
    sql: (${total_non_keycode_hours} / case when ${total_utilization_hours} = 0 then null else ${total_utilization_hours} end) * 100 ;;
    html: {{rendered_value}}% ;;
    value_format: "0.00"
  }

}
