
view: employee_and_vehicle_accidents {
  derived_table: {
    sql:
    with vehicle_average as (
select vl.MARKET_ID,
       avg(VEHICLE_COUNT) vehicle_average
from ANALYTICS.CLAIMS.HISTORIC_MARKET_VEHICLE_LOSS_COUNT vl
where vl.DATE >= dateadd(day, -365, current_date)
group by vl.MARKET_ID
),
employee_average as (
select el.MARKET_ID,
       avg(EMP_COUNT) as employee_average
from ANALYTICS.CLAIMS.HISTORIC_MARKET_EMPLOYEE_LOSS_COUNT el
where el.DATE_MONTH >= dateadd(day, -365, current_date)
group by el.MARKET_ID
),
main as (
select date_trunc(month, vl.DATE) as vehicle_month,
       sum(vl.LOSS_COUNT) as vehicle_loss_count_month,
       vl.MARKET_ID,
       xw.MARKET_NAME,
       xw.DISTRICT,
       xw.REGION_NAME,
       el.DATE_MONTH,
       el.EMP_COUNT,
       el.LOSS_COUNT as employee_loss_count,
       va.vehicle_average,
       ea.employee_average
from ANALYTICS.CLAIMS.HISTORIC_MARKET_VEHICLE_LOSS_COUNT vl
     left join ANALYTICS.CLAIMS.HISTORIC_MARKET_EMPLOYEE_LOSS_COUNT el
               on vl.MARKET_ID = el.MARKET_ID and date_trunc(month,vl.DATE) = date_trunc(month,el.DATE_MONTH)
     left join ANALYTICS.PUBLIC.MARKET_REGION_XWALK xw
               on vl.MARKET_ID = xw.MARKET_ID
     left join ES_WAREHOUSE.PUBLIC.MARKETS m
               on m.MARKET_ID = vl.MARKET_ID
     join vehicle_average va
               on va.MARKET_ID = vl.MARKET_ID
     join employee_average ea
               on ea.MARKET_ID = vl.MARKET_ID
where vl.DATE >= dateadd(day, -365, current_date) and xw.MARKET_NAME is not null --- filtering out corporate or non-xwalk markets since they aren't active markets
group by date_trunc(month, vl.DATE),
         vl.MARKET_ID,
         xw.MARKET_NAME,
         xw.DISTRICT,
         xw.REGION_NAME,
         m.NAME,
         el.DATE_MONTH,
         el.EMP_COUNT,
         el.LOSS_COUNT,
         va.vehicle_average,
         ea.employee_average

)
select m.MARKET_ID,
       m.MARKET_NAME,
       count(distinct m.MARKET_ID) as count_of_markets,
       m.DISTRICT,
       m.REGION_NAME,
       sum(vehicle_loss_count_month) as vehicle_loss_count,
       sum(employee_loss_count) as employee_loss_count,
       m.vehicle_average,
       m.employee_average
from main m
group by m.MARKET_ID,
         m.MARKET_NAME,
         m.DISTRICT,
         m.REGION_NAME,
         m.vehicle_average,
         m.employee_average ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: market_id {
    type: string
    sql: ${TABLE}."MARKET_ID" ;;
  }

  dimension: market_name {
    type: string
    sql: ${TABLE}."MARKET_NAME" ;;
  }

  dimension: distinct_count_of_markets {
    type: number
    sql: ${TABLE}."COUNT_OF_MARKETS" ;;
  }

  dimension: district {
    type: string
    sql: ${TABLE}."DISTRICT" ;;
  }

  dimension: region_name {
    type: string
    sql: ${TABLE}."REGION_NAME" ;;
  }

  dimension: vehicle_loss_count {
    type: number
    sql: ${TABLE}."VEHICLE_LOSS_COUNT" ;;
  }

  dimension: employee_loss_count {
    type: number
    sql: ${TABLE}."EMPLOYEE_LOSS_COUNT" ;;
  }

  dimension: vehicle_average {
    type: number
    sql: ${TABLE}."VEHICLE_AVERAGE" ;;
  }

  dimension: employee_average {
    type: number
    sql: ${TABLE}."EMPLOYEE_AVERAGE" ;;
  }

  measure: total_market_count {
    type: sum
    sql: ${distinct_count_of_markets} ;;
  }

  measure: total_vehicle_loss_count {
    type: sum
    sql: ${vehicle_loss_count} ;;
    link: {
      label: "View Auto Accidents Dashboard"
      url: "https://equipmentshare.looker.com/dashboards/816?Market={{ _filters['employee_and_vehicle_accidents.market_name'] | url_encode }}&District=&Region="
    }
  }

  measure: total_employee_loss_count {
    type: sum
    sql: ${employee_loss_count} ;;
    link: {
      label: "View Work Comp Accidents Dashboard"
      url: "https://equipmentshare.looker.com/dashboards/825?Market={{ _filters['employee_and_vehicle_accidents.market_name'] | url_encode }}&District=&Region="
    }
  }

  measure: vehicle_average_measure {
    type: average
    sql: ${vehicle_average} ;;
  }

  measure: employee_average_measure {
    type: average
    sql: ${employee_average} ;;
  }

  measure: vehicle_accident_rate {
    type: number
    sql: ${total_vehicle_loss_count}/(${vehicle_average_measure}*${total_market_count}) ;;
    value_format_name: percent_1
    link: {
      label: "View Auto Accidents Dashboard"
      url: "https://equipmentshare.looker.com/dashboards/816?Market={{ _filters['employee_and_vehicle_accidents.market_name'] | url_encode }}&District=&Region="
      }
  }

  measure: work_comp_accident_rate {
    type: number
    sql: ${total_employee_loss_count}/(${employee_average_measure}*${total_market_count}) ;;
    value_format_name: percent_1
    link: {
      label: "View Work Comp Accidents Dashboard"
      url: "https://equipmentshare.looker.com/dashboards/825?Market={{ _filters['employee_and_vehicle_accidents.market_name'] | url_encode }}&District=&Region="
    }
  }


  set: detail {
    fields: [
        market_id,
  market_name,
  district,
  region_name
    ]
  }
}
