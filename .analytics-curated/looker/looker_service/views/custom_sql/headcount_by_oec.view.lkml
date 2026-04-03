view: headcount_by_oec {
  derived_table: {
    sql: with get_past_days as (
    select
        date(dateadd(day, '-' || row_number() over (order by null),
        dateadd(day, '+1', current_timestamp()))) as generateddate
    from table (generator(rowcount => 366))
)

,count_tech as (
select
    date(_es_update_timestamp) as the_date,
    market_id,
    case
        when employee_title ilike '%Field%' then 'Field'
        when employee_title ilike '%Yard%' then 'Service'
        when employee_title ilike '%Service%' then 'Service'
        when employee_title ilike '%Shop%' then 'Service'
        else 'Other'
    end as job_type,
    count(distinct employee_id) as count_tech
from analytics.payroll.company_directory_vault
where employee_status = 'Active'
and employee_title ilike '%Tech%'
group by the_date, market_id, job_type
)

,oec_by_market_and_day as (
select
    a.market_id,
    generateddate,
    sum(oec) as oec
from ES_WAREHOUSE.PUBLIC.ASSETS_AGGREGATE aa
left join ES_WAREHOUSE.PUBLIC.ASSETS a
    on a.asset_id = aa.asset_id
join get_past_days gd
    on gd.generateddate >= aa.purchase_date
where a.market_id is not null
group by market_id,generateddate
)

,field_tech_by_day as (
select
    gd.generateddate,
    ct.market_id,
    coalesce(ct.count_tech,lag(ct.count_tech) ignore nulls over (partition by market_id order by generateddate)) as field_techs
from get_past_days gd
left join count_tech ct
    on ct.the_date = gd.generateddate
where job_type = 'Field'
)

,service_tech_by_day as (
select
    gd.generateddate,
    ct.market_id,
    coalesce(ct.count_tech,lag(ct.count_tech) ignore nulls over (partition by market_id order by generateddate)) as service_techs
from get_past_days gd
left join count_tech ct
    on ct.the_date = gd.generateddate
where job_type = 'Service'
)

select
    f.market_id,
    f.generateddate,
    o.oec,
    f.field_techs,
    s.service_techs,
    oec / iff(field_techs = 0, null, field_techs) as oec_by_field_tech,
    oec / iff(service_techs = 0, null, service_techs) as oec_by_service_tech
from oec_by_market_and_day o
left join field_tech_by_day f
    on o.market_id = f.market_id
    and o.generateddate = f.generateddate
left join service_tech_by_day s
    on s.market_id = f.market_id
    and s.generateddate = f.generateddate;;
  }

  dimension: market_id {
    type: number
    sql: ${TABLE}."MARKET_ID" ;;
  }

  dimension_group: date {
    type: time
    timeframes: [raw,date,time,week,month,quarter,year]
    sql: ${TABLE}."GENERATEDDATE";;
  }

  dimension: oec {
    type: number
    sql: ${TABLE}."OEC" ;;
  }

  dimension: field_techs {
    type: number
    sql: ${TABLE}."FIELD_TECHS" ;;
  }

  dimension: service_techs {
    type: number
    sql: ${TABLE}."SERVICE_TECHS" ;;
  }

  dimension: oec_by_field_tech {
    type: number
    sql: ${TABLE}."OEC_BY_FIELD_TECH" ;;
  }

  dimension: oec_by_service_tech {
    type: number
    sql: ${TABLE}."OEC_BY_SERVICE_TECH" ;;
  }

  measure: sum_oec {
    type: sum
    sql: ${oec};;
  }

  measure: sum_field_techs {
    type: sum
    sql: ${field_techs} ;;
  }

  measure: sum_service_techs {
    type: sum
    sql: ${service_techs} ;;
  }

  measure: avg_oec {
    type: average
    sql: ${oec};;
  }

  measure: avg_field_techs {
    type: average
    sql: ${field_techs} ;;
  }

  measure: avg_service_techs {
    type: average
    sql: ${service_techs} ;;
  }

  measure: avg_oec_by_field_tech {
    type: average
    sql: ${oec_by_field_tech} ;;
  }

  measure: avg_oec_by_service_tech {
    type: average
    sql: ${oec_by_service_tech} ;;
  }
}
