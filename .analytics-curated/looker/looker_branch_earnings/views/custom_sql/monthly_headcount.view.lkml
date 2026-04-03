view: monthly_headcount {
derived_table: {
  sql:
        with employee_partition as (select *
              from analytics.payroll.company_directory_vault as cdv
                            qualify
                                row_number() over (partition by cdv.employee_id, date_trunc(month, _es_update_timestamp) order by _es_update_timestamp desc) =
                                1)
select ep.market_id,
       date_trunc(month, ep._es_update_timestamp::date) as gl_date,
       coalesce(m.name, d.title)                       as market_name,
       count(employee_id)                              as total_headcount
from employee_partition as ep
         left join es_warehouse.public.markets m
                   on ep.market_id::varchar = m.market_id::varchar
         left join analytics.intacct.department d
                   on ep.market_id::varchar = d.departmentid::varchar
where lower(ep.employee_status) not in
      ('not in payroll', 'terminated', 'never started', 'inactive')
      and gl_date in (
        select
        trunc::date
        from
        analytics.gs.plexi_periods
        where {% condition period_name %} display {% endcondition %})
      group by all;;
}

  filter: period_name {
    type: string
    suggest_explore: plexi_periods
    suggest_dimension: plexi_periods.display
  }

  dimension: market_id {
    type: string
    sql: ${TABLE}."MARKET_ID" ;;
  }

  dimension: market_name {
    type: string
    sql: ${TABLE}."MARKET_NAME" ;;
  }

  dimension: gl_date {
    type: date
    sql: ${TABLE}."GL_DATE" ;;
  }

    measure: total_headcount {
      type: sum
      sql: ${TABLE}."TOTAL_HEADCOUNT" ;;
    }

}
