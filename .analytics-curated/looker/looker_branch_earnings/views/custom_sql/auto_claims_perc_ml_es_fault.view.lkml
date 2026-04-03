view: auto_claims_perc_ml_es_fault {
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
                                 round(avg(v_day.vehicle_count), 0) as            vehicle_count,
                                 sum(lc_day.loss_count)             as            loss_count
                          from lc_day
                                   left join v_day
                                             on last_day(v_day.DATE, 'quarter') = lc_day.date
                          where lc_day.date >= {% parameter start_date %}::date
                            and lc_day.date < {% parameter end_date %}::date
                          group by date_trunc(quarter, lc_day.date)
                          order by quarter_start_date)
select date_trunc(quarter, efor.date_of_loss::date)                   quarter_start_date,
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

    dimension: quarter_start_date {
      label: "Quarter Start Date"
      type: date
      sql: ${TABLE}.quarter_start_date ;;
    }

    dimension: claim_count {
      label: "Claim Count"
      type: number
      sql: ${TABLE}.claim_count ;;
    }

  dimension: es_fault_claims {
    label: "ES Fault Claims"
    type: number
    sql: ${TABLE}.es_fault_claims ;;
  }

  dimension: pct_es_fault {
    label: "% ES Fault"
    type: number
    sql: ${TABLE}.pct_es_fault ;;
  }

  dimension: material_loss {
    label: "Material Loss"
    type: number
    sql: ${TABLE}.material_loss ;;
  }

  dimension: pct_material_loss {
    label: "% Material Loss"
    type: number
    sql: ${TABLE}.pct_material_loss ;;
  }

  dimension: pct_of_vehicles {
    label: "% of Vehicles"
    type: number
    sql: ${TABLE}.pct_of_vehicles ;;
  }

}
