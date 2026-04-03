view: historic_market_employee_loss_count {
    sql_table_name: "ANALYTICS"."CLAIMS"."HISTORIC_MARKET_EMPLOYEE_LOSS_COUNT"
      ;;

    dimension: loss_count {
      type: number
      sql: ${TABLE}."LOSS_COUNT" ;;
    }

    dimension: market_id {
      type: number
      sql: ${TABLE}."MARKET_ID" ;;
    }

    dimension_group: month {
      type: time
      timeframes: [
        raw,
        date,
        week,
        month,
        quarter,
        year
      ]
      convert_tz: no
      datatype: date
      sql: ${TABLE}."DATE_MONTH" ;;
    }

    dimension: emp_count {
      type: number
      sql: ${TABLE}."EMP_COUNT" ;;
    }

    measure: count {
      type: count
      drill_fields: []
    }

    dimension: last_12 {
      type: yesno
      sql: ${month_date} > dateadd(year, -1, current_date) ;;
    }

    measure: average_employee_count_last_12 {
      type: average
      sql: ${emp_count};;
      filters: [last_12: "yes"]
      link: {
        label: "View Work Comp Accidents"
        url: "https://equipmentshare.looker.com/dashboards/825?Market+Name={{ _filters['market_region_xwalk.market_name'] }}"
      }
    }

    measure: count_loss_last_12 {
      type: sum
      sql: ${loss_count};;
      filters: [last_12: "yes"]
      link: {
        label: "View Work Comp Accidents"
        url: "https://equipmentshare.looker.com/dashboards/825?Market+Name={{ _filters['market_region_xwalk.market_name'] }}"
      }
    }


  }
