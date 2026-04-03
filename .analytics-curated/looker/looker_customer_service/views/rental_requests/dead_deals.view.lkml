view: dead_deals {

    derived_table: {
      sql: select
              *
              from
              ANALYTICS.GOOGLE_SHEETS.RENTAL_TRACKING_DEAD_DEALS
              order by _row  ;;
    }

    measure: count {
      type: count
      drill_fields: [detail*]
    }

    dimension: _row {
      type: number
      sql: ${TABLE}."_ROW" ;;
    }

    dimension_group: _fivetran_synced {
      type: time
      sql: ${TABLE}."_FIVETRAN_SYNCED" ;;
    }

    dimension: request_source {
      type: string
      sql: trim(${TABLE}."REQUEST_SOURCE") ;;
    }

    dimension: progress {
      type: string
      sql: ${TABLE}."PROGRESS" ;;
    }

    dimension: equipment {
      type: string
      sql: ${TABLE}."EQUIPMENT" ;;
    }

    dimension: poc {
      type: string
      sql: ${TABLE}."POC" ;;
    }

    dimension: name_ {
      type: string
      sql: ${TABLE}."NAME_" ;;
    }

    dimension_group: date {
      type: time
      sql: ${TABLE}."DATE" ;;
    }

    dimension: notes {
      type: string
      sql: ${TABLE}."NOTES" ;;
    }

    dimension: location {
      type: string
      sql: ${TABLE}."LOCATION" ;;
    }

    set: detail {
      fields: [
        _row,
        _fivetran_synced_time,
        request_source,
        progress,
        equipment,
        poc,
        name_,
        notes,
        location
      ]
    }
  }
