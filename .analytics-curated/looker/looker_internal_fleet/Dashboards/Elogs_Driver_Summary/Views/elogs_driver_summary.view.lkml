#
# The purpose of this view is to get driver and violation information for fleet to
# monitor internal violation occurances over time.
#
# Britt Shanklin | Built 2022-06-16 | Last Updated 2022-07-21 BES
view: elogs_driver_summary {
   derived_table: {
    # SQL updated - changed {{ _user_attributes['company_id'] }} to 1854 to reflect internal dashboard 2022-06-16 BShanklin
     sql: WITH
      base AS (
        SELECT
          dls.date,
          dls.driver_id,
          dls.signed,
          first_name,
          last_name,
          concat(first_name, ' ', last_name) as driver,
          d.hours_of_service_type_id,
          round(dls.on_duty / 3600, 2) AS hours,
          dls.distance,
          NULLIF( RTRIM ( CONCAT (
            CASE WHEN violation_break = 'TRUE' THEN 'Break, ' ELSE '' END,
            CASE WHEN violation_cycle = 'TRUE' THEN 'Cycle, ' ELSE '' END,
            CASE WHEN violation_drive = 'TRUE' THEN 'Drive, ' ELSE '' END,
            CASE WHEN violation_shift = 'TRUE' THEN 'Shift, ' ELSE '' END ),', ' ), ', ' ) AS violations,
          dls.signed_by,
          CASE WHEN l.nickname is NOT NULL THEN concat('(',l.nickname,')') ELSE NULL END AS nickname,
          concat_ws(', ', l.street_1, l.city, s.abbreviation) AS address,
          l.zip_code,
          l.location_id
        FROM        es_warehouse.elogs.driver_log_summary dls
          JOIN      es_warehouse.public.users u  ON u.user_id = dls.driver_id
          JOIN      es_warehouse.elogs.drivers d ON d.driver_id = dls.driver_id
          LEFT JOIN es_warehouse.public.locations l     ON l.location_id = d.reporting_location_id
          LEFT JOIN es_warehouse.public.states s        ON s.state_id = l.state_id
        WHERE
          u.company_id = 1854
          AND dls.date >= {% date_start elogs_driver_summary.date_filter %}
          AND dls.date < {% date_end elogs_driver_summary.date_filter %}
      )
        SELECT
          base.driver_id,
          first_name,
          last_name,
          initcap(driver) as driver,
          listagg(distinct coalesce(a.custom_name, 'No Paired Asset'), ', ') as paired_assets,
          hos.display_name as hours_of_service,
          base.hours,
          distance,
          date,
          violations,
          concat_ws(' ', nickname, address, zip_code) AS location_name,
          signed_by,
          base.location_id,
          signed,
          CASE WHEN violations is NULL THEN FALSE
               ELSE TRUE END AS violation_boolean_check
        FROM base
          JOIN es_warehouse.public.hours_of_service_types hos on base.hours_of_service_type_id = hos.hours_of_service_type_id
          LEFT JOIN es_warehouse.elogs.driver_asset_pairing_history aph on base.driver_id = aph.driver_id
                            and overlaps(aph.start_date, coalesce(aph.end_date, current_date), {% date_start elogs_driver_summary.date_filter %},
                                                                                               {% date_end elogs_driver_summary.date_filter %})
          LEFT JOIN es_warehouse.public.assets a on a.asset_id = aph.asset_id
        GROUP BY base.driver_id, date, first_name, last_name, driver, hours_of_service,
                  base.hours, distance, violations,
                 location_name, base.location_id, signed_by, signed
        ORDER BY driver, date
        -- comments from external looker removed
       ;;
   }

filter: date_filter  {
  type: date
}

dimension: primary_key {
  primary_key: yes
  sql: concat(${driver_id},${date}) ;;
}

dimension: paired_assets {
  label: "Paired Asset(s)"
  sql: ${TABLE}."PAIRED_ASSETS" ;;
}

dimension: driver_id {
  type: number
  sql: ${TABLE}."DRIVER_ID" ;;
}

dimension: signed {
  type: yesno
  sql: ${TABLE}."SIGNED" ;;
}

dimension: first_name {
  type: string
  sql: ${TABLE}."FIRST_NAME" ;;
}

dimension: last_name {
  type: string
  sql: ${TABLE}."LAST_NAME" ;;
}

dimension: driver {
  type: string
  sql: ${TABLE}."DRIVER" ;;
}

dimension: hours {
  type: number
  sql: ${TABLE}."HOURS" ;;
}

dimension: hours_of_service {
  type: string
  sql: ${TABLE}."HOURS_OF_SERVICE" ;;
}

dimension: distance {
  type: number
  sql: ${TABLE}."DISTANCE" ;;
}

dimension: date {
  type: date
  sql: ${TABLE}."DATE" ;;
  html: {{ value | date: "%b %d, %Y"  }};;
}

dimension_group: violation_date {
  type: time
  timeframes: [time, date, day_of_week, month, year]
  sql: ${date} ;;
}

dimension: violations_boolean_check {
  type: yesno
  sql: ${TABLE}."VIOLATION_BOOLEAN_CHECK" ;;
}

dimension: violations_raw {
  type: string
  sql: ${TABLE}."VIOLATIONS" ;;
}

dimension: violations {
  type: string
  sql: SPLIT_PART(${violations_raw},',',1) ;;
}

dimension: location {
  type: string
  sql: ${TABLE}."LOCATION_NAME" ;;
}

dimension: location_id {
  type: number
  sql: ${TABLE}."LOCATION_ID" ;;
}

dimension: signed_by {
  type: string
  sql: ${TABLE}."SIGNED_BY" ;;
}

dimension: link_to_elogs_drivers_page {
  label: "To Driver Elog Details"
  sql: ${driver_id};;
  html: <font color="#0063f3"><u><a href="https://app.estrack.com/e-logs/drivers/{{ driver_id._filterable_value }}/{{ date._filterable_value}}" target="_blank">View Details</a></font?</u>;;
}

dimension: full_name {
  sql: CONCAT(${first_name}, ' ', ${last_name})  ;;
}

measure: total_hours {
  type: sum
  sql: ${hours} ;;
}

measure: total_violations {
  type: count_distinct
  filters: [violations: "- "]
  drill_fields: [violation_details*]
  sql: ${primary_key} ;;
}

measure: total_distance {
  type: sum
  sql: ${distance} ;;
}

set: violation_details {
  fields: [driver_id, full_name, paired_assets, date, link_to_elogs_drivers_page]
}

}
