view: asset_location {
  derived_table: {
    sql:
  WITH tracker_location AS (SELECT ask.asset_id,
                                   MAX(ask.updated)                                                             AS tracker_location_time,
                                   CONCAT(MAX(IFF(ask.name = 'street', COALESCE(value, 'Unknown'), '')), ', ', MAX(IFF(ask.name = 'city', value, '')), ' ',
                                          MAX(s.abbreviation), ' ', MAX(IFF(ask.name = 'zip_code', value, ''))) AS address
                              FROM es_warehouse.public.asset_status_key_values ask
                                   LEFT OUTER JOIN es_warehouse.public.states s
                                                   ON ask.name = 'state_id' AND TRY_CAST(ask.value AS number) = s.state_id
                                   LEFT OUTER JOIN es_warehouse.public.assets a
                                                   ON ask.asset_id = a.asset_id
                                   LEFT OUTER JOIN es_warehouse.public.markets m
                                                   ON a.service_branch_id = m.market_id
                             WHERE ask.name IN ('city', 'street', 'state_id', 'zip_code')
                               AND ask.updated >= DATEADD('year', -1, CURRENT_DATE())
                               AND m.company_id = 1854
                             GROUP BY ask.asset_id),

       last_delivery    AS (SELECT asset_id,
                                   completed_date AS completed_date,
                                   location_id    AS last_location_id
                              FROM es_warehouse.public.deliveries
                             WHERE location_id IS NOT NULL
                               AND delivery_status_id = 3 QUALIFY ROW_NUMBER() OVER (PARTITION BY asset_id ORDER BY completed_date DESC NULLS LAST) = 1)

SELECT a.asset_id                                       AS asset_id,
       a.tracker_id,
       tl.tracker_location_time,
       ST_Y(TO_GEOGRAPHY(ask.value))                    AS latitude,
       ST_X(TO_GEOGRAPHY(ask.value))                    AS longitude,
       ld.completed_date                                AS last_delivery_date,
       ld.last_location_id,
       IFF(COALESCE(tl.tracker_location_time, '1900-01-01') >= COALESCE(ld.completed_date, '1900-01-01') AND tl.address IS NOT NULL OR ask.value IS NOT NULL,
           tl.tracker_location_time, ld.completed_date) AS location_info_date,
       -- Prefer the tracker address if it has one
       CASE WHEN COALESCE(tl.tracker_location_time, '1900-01-01') >= COALESCE(ld.completed_date, '1900-01-01') AND tl.address IS NOT NULL THEN 'Tracker'
            WHEN COALESCE(ld.completed_date, '1900-01-01') > COALESCE(tl.tracker_location_time, '1900-01-01') OR tl.address IS NULL AND l.street_1 IS NOT NULL
                THEN 'Last Delivery Record'
            ELSE 'No records in past year' END          AS location_source,

       CASE WHEN location_source = 'Tracker' THEN tl.address
            WHEN location_source = 'Last Delivery Record' THEN CONCAT(IFF(LEN(l.street_1) < 2, 'Unknown', l.street_1), ', ', l.city, ' ', s.abbreviation)
            ELSE 'No address available' END             AS address

  FROM es_warehouse.public.assets a
       LEFT OUTER JOIN tracker_location tl
                       ON a.asset_id = tl.asset_id
       LEFT OUTER JOIN last_delivery ld
                       ON a.asset_id = ld.asset_id
       LEFT OUTER JOIN es_warehouse.public.locations l
                       ON ld.last_location_id = l.location_id
       LEFT OUTER JOIN es_warehouse.public.states s
                       ON l.state_id = s.state_id
       LEFT OUTER JOIN es_warehouse.public.asset_status_key_values ask
                       ON tl.asset_id = ask.asset_id AND ask.name = 'location';;
  }

  dimension: asset_id {
    type: number
    sql: ${TABLE}."ASSET_ID" ;;
  }

  dimension: tracker_id {
    type: number
    sql: ${TABLE}."TRACKER_ID" ;;
  }

  dimension: tracker_location_time {
    type: date
    sql: ${TABLE}."TRACKER_LOCATION_TIME" ;;
  }

  dimension: latitude {
    type: number
    sql: ${TABLE}."LATITUDE" ;;
  }

  dimension: longitude {
    type: number
    sql: ${TABLE}."LONGITUDE" ;;
  }

  dimension: last_delivery_date {
    type: date
    sql: ${TABLE}."LAST_DELIVERY_DATE" ;;
  }

  dimension: location_info_date {
    type: date
    sql: ${TABLE}."LOCATION_INFO_DATE" ;;
  }

  dimension: location_source {
    type: string
    sql: ${TABLE}."LOCATION_SOURCE" ;;
  }

  dimension: address {
    type: string
    sql: ${TABLE}."ADDRESS" ;;
  }

  dimension: map_link {
    type: string
    sql: COALESCE(CONCAT_WS(',', ${latitude}, ${longitude}), 'No coordinates available') ;;
    html:
    {% if tracker_id._value == null %}
    No tracker
    {% elsif map_link._value == "No coordinates available" %}
    No coordinates from tracker
    {% else %}
    <u><font color="blue"><a href="https://maps.google.com/maps?q={{rendered_value}}">MAP</a></u>
    {% endif %};;
  }
}
