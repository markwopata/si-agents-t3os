view: forsight {

  derived_table: {
    sql:
     SELECT convert_timezone('America/Chicago',START_TIMESTAMP) AS START_TIMESTAMP, convert_timezone('America/Chicago',END_TIMESTAMP) AS END_TIMESTAMP, EVENT_TYPE AS EVENT_TYPE,
INITCAP(LOCATION) AS LOCATION, URL AS URL
FROM ES_WAREHOUSE.forsight.aggregated_events
WHERE  datediff(second, START_TIMESTAMP, END_TIMESTAMP ) > 1
AND EVENT_TYPE = 'Motion'
ORDER BY START_TIMESTAMP DESC
                         ;;
  }

  dimension: start_timestamp {
    type: date_time
    sql: ${TABLE}.START_TIMESTAMP ;;
  }

  dimension: end_timestamp {
    type: date_time
    sql: ${TABLE}.END_TIMESTAMP ;;
  }

  dimension: event_type {
    type: string
    sql: ${TABLE}.EVENT_TYPE ;;
  }

  dimension: location {
    type: string
    sql: ${TABLE}.LOCATION ;;
  }


  dimension: actual_url {
    type: string
    sql: ${TABLE}.URL ;;
  }

  dimension: url {
    type: string
    html: <font color="blue "><u><a href = {{ url._value }} target="_blank">Link to Video</a></font></u> ;;
    sql: ${TABLE}.URL ;;
  }




  }
