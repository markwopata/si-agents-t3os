view: customer_support_rental_requests {
    derived_table: {
      sql: with deals as (
      select
              _ROW, _FIVETRAN_SYNCED, PROGRESS, REQUEST_SOURCE, EQUIPMENT, POC, NAME_, DATE, NOTES,
              NULL as MISSED_REASON,
              LOCATION, REQUEST_OWNER
              from
              ANALYTICS.GOOGLE_SHEETS.RENTAL_REQUEST_TRACKING
             UNION

              select
               _ROW, _FIVETRAN_SYNCED, PROGRESS, REQUEST_SOURCE, EQUIPMENT, POC, NAME_, DATE, NOTES, MISSED_REASON, LOCATION
              , 'Amy Howard' as request_owner
              from
              ANALYTICS.GOOGLE_SHEETS.RENTAL_TRACKING_DEAD_DEALS
      )
      select *
      , case when progress = 'Dead Deal' then 1 else 0 end as dead_deal_flag from deals
      order by Date

              ;;
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

  dimension: dead_deal_flag {
    type: number
    sql: ${TABLE}."DEAD_DEAL_FLAG" ;;
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
        dead_deal_flag,
        equipment,
        poc,
        name_,
        notes,
        location
      ]
    }
  }
