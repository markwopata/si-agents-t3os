view: elogs_driver_summary {

 derived_table: {
   sql:
    WITH
      base AS (
        SELECT
          dls.date,
          dls.driver_id,
          first_name,
          last_name,
          concat(first_name, ' ', last_name) as driver,
          d.hours_of_service_type_id,
          -- TODO: seconds_to_interval() was used here originally; is this equivalent?
          round(dls.on_duty / 3600, 2) AS hours,
          dls.distance,
          NULLIF( RTRIM ( CONCAT (
            CASE WHEN violation_break = 'TRUE' THEN 'Break, ' ELSE '' END,
            CASE WHEN violation_cycle = 'TRUE' THEN 'Cycle, ' ELSE '' END,
            CASE WHEN violation_drive = 'TRUE' THEN 'Drive, ' ELSE '' END,
            CASE WHEN violation_shift = 'TRUE' THEN 'Shift, ' ELSE '' END ),', ' ), '' ) AS violations,
          dls.signed_by,
          CASE WHEN l.nickname is NOT NULL THEN concat('(',l.nickname,')') ELSE NULL END AS nickname,
          concat_ws(', ', l.street_1, l.city, s.abbreviation) AS address,
          l.zip_code,
          l.location_id
        FROM        elogs.driver_log_summary dls
          JOIN      public.users u  ON u.user_id = dls.driver_id
          JOIN      elogs.drivers d ON d.driver_id = dls.driver_id
          LEFT JOIN locations l     ON l.location_id = d.reporting_location_id
          LEFT JOIN states s        ON s.state_id = l.state_id
        WHERE
          u.company_id = {{ _user_attributes['company_id'] }}
          AND dls.date >= {% date_start elogs_driver_summary.date_filter %}
          AND dls.date < {% date_end elogs_driver_summary.date_filter %}
        -- vvv: where dls.driver_id in [list of target driver_id's]
          --AND $X{IN, dls.driver_id::text, driver_id}
        -- vvv: when no Signature filter select all, else select where SIGNED
          --AND CASE WHEN $P{Signature} = FALSE THEN 1=1 else SIGNED = TRUE end
        -- vvv: where l.location_id in [list of target location_id's]
          --AND $X{IN, l.location_id, locations}
 --       order by concat(first_name, ' ', last_name), date
      )
        SELECT
          base.driver_id,
          first_name,
          last_name,
          initcap(driver) as driver,
 --         aph.asset_id as asset_id,
          listagg(distinct coalesce(a.custom_name, 'No Paired Asset'), ', ') as paired_assets,
          hos.display_name as hours_of_service,
          base.hours,
          distance,
          date,
          violations,
          concat_ws(' ', nickname, address, zip_code) AS location_name,
          signed_by,
          base.location_id,
          CASE WHEN violations is NULL THEN FALSE
               ELSE TRUE END AS violation_boolean_check
        FROM base
          JOIN public.hours_of_service_types hos on base.hours_of_service_type_id = hos.hours_of_service_type_id
          -- TODO: get _all_ assets in cases where a driver uses more than one in a given day
          --       (e.g. if a driver uses 3 assets in one day, emit "asset_id0, asset_id1, asset_id2")
          LEFT JOIN elogs.driver_asset_pairing_history aph on base.driver_id = aph.driver_id
                            and overlaps(aph.start_date, coalesce(aph.end_date, current_date), convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC', {% date_start elogs_driver_summary.date_filter %}),
                                                                                               convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC', {% date_end elogs_driver_summary.date_filter %}))
          LEFT JOIN assets a on a.asset_id = aph.asset_id
        GROUP BY base.driver_id, date, first_name, last_name, driver, hours_of_service,
                  base.hours, distance, violations,
                 location_name, base.location_id, signed_by
        ORDER BY driver, date
  ;;
}

filter: date_filter {
  type: date_time
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

dimension: violations_boolean_check {
  type: yesno
  sql: ${TABLE}."VIOLATIONS_BOOLEAN_CHECK" ;;
}

dimension: violations {
  type: string
  sql: ${TABLE}."VIOLATIONS" ;;
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

measure: total_hours {
  type: sum
  sql: ${hours} ;;
}

  measure: max_hours {
    type: max
    sql: ${hours} ;;
  }

measure: total_distance {
  type: sum
  sql: ${distance} ;;
}

  measure: max_distance {
    type: max
    sql: ${distance} ;;
  }

}
