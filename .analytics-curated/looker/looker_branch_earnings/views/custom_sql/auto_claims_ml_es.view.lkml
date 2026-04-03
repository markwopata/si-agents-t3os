view: auto_claims_ml_es {
  #builds table for autoclaims opened and closed for Insurance Finance Operation Review
  derived_table: {
    sql:
  with v_day as (select sum(vehicle_count) as vehicle_count,
                      date
               from analytics.claims.HISTORIC_MARKET_VEHICLE_LOSS_COUNT
               group by date),

     lc_day as (select sum(loss_count) as loss_count,
                       date
                from analytics.claims.HISTORIC_MARKET_VEHICLE_LOSS_COUNT
                group by date),

     agg_vehic_counts as (select date_trunc(quarter, lc_day.date)   as            quarter_start_date,
                                 year(lc_day.date) || 'Q' || quarter(lc_day.date) year_quarter,
                                 round(avg(v_day.vehicle_count), 0) as            vehicle_count,
                                 sum(lc_day.loss_count)             as            loss_count
                          from lc_day
                                   left join v_day
                                             on last_day(v_day.DATE, 'quarter') = lc_day.date
                          where lc_day.date >= {% parameter start_date %}::date
                            and lc_day.date < {% parameter end_date %}::date
                          group by date_trunc(quarter, lc_day.date), year(lc_day.date) || 'Q' || quarter(lc_day.date)
                          order by quarter_start_date)
select date_trunc(quarter, efor.date_of_loss::date)                   quarter_start_date,
       year(quarter_start_date) || 'Q' || quarter(quarter_start_date) year_quarter,
       count(*)                                                       claim_count,
       sum(iff(efor.AT_FAULT_PAYER = 'ES', 1, 0))                     es_fault_claims,
       es_fault_claims / claim_count                                  pct_es_fault,
       sum(iff(efor.MATERIAL_LOSS_ = 'Yes', 1, 0))                    material_loss,
       material_loss / es_fault_claims                                pct_material_loss,
       claim_count / sum(avc.vehicle_count)                           pct_of_vehicles
from (SELECT es.STATUS, es.DATE_OF_LOSS, es.AT_FAULT_PAYER, es.MATERIAL_LOSS_
      FROM analytics.claims.ES_FLEET_ON_ROAD es
      union all
      SELECT esc.STATUS, esc.DATE_OF_LOSS, esc.AT_FAULT_PAYER, esc.MATERIAL_LOSS_
      FROM analytics.claims.ES_FLEET_ON_ROAD_CLOSED esc) AS efor -- includes close and open claim status
         join agg_vehic_counts avc
              on date_trunc(quarter, efor.date_of_loss::date) = avc.quarter_start_date
where efor.DATE_OF_LOSS::date >= {% parameter start_date %}::date
  and efor.DATE_OF_LOSS::date < {% parameter end_date %}::date
group by all
order by quarter_start_date
;;
  }

    parameter: start_date {
    type: date
  }

  parameter: end_date {
    type: date
  }

  measure: count {
    type: count
  }

  measure: es_fault_claims {
    type: sum
    sql: ${TABLE}."es_fault_claims" ;;
  }

  measure: material_loss {
    type: sum
    sql: ${TABLE}."material_loss" ;;
  }

  dimension: pct_es_fault {
    type: number
    value_format: "#,##0_);(#,##0);-"
    sql: ${TABLE}."pct_es_fault" ;;
  }

  dimension: pct_material_loss {
    type: number
    value_format: "#,##0_);(#,##0);-"
    sql: ${TABLE}."pct_material_loss" ;;
  }



}
