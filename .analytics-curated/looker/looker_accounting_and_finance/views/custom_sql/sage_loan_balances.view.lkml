view: sage_loan_balances {
  parameter: as_of_date {
    type: date
  }
  derived_table: {
    sql:with filter_date as (
  select
         case when {% parameter as_of_date %} is null then
              current_timestamp::date
          else
              {% parameter as_of_date %} end filter_date
)
,get_amounts as (
    SELECT
           ul.name as sage_id,
           (cast(glt.tr_type as integer)*-1)*cast(glt.amount as float) as princ_amt
    FROM
         ANALYTICS.INTACCT.UD_LOAN ul
    LEFT JOIN
            ANALYTICS.INTACCT.VENDOR vd
    ON cast(vd.recordno as text) = ul.rvendor
    LEFT JOIN
             ANALYTICS.INTACCT.GLENTRY glt
    ON ul.id = cast(glt.gldimud_loan as text),
        filter_date fd
    WHERE
          glt.state = 'Posted'
        AND glt.accountno = '2500'
        and glt.entry_date <= fd.filter_date
)
select
       a.sage_id,
       --cast(round(sum(a.princ_amt),2) as float) as current_balance
        round(sum(a.princ_amt),2) as current_balance
from
     get_amounts a
group by a.sage_id
            ;;
  }
  dimension: sage_id {
    description: "Sage ID"
    type: string
    sql: ${TABLE}.sage_id ;;
  }
  dimension: current_balance {
    description: "Balance according to Sage"
    type: number
    sql: ${TABLE}.current_balance ;;
  }
  measure: display_as_of_date {
    description: "Balance as of this date"
    label: "Balance as of this date"
    type: date
    label_from_parameter: as_of_date
    sql:  {% parameter as_of_date %}
          --(date (date (date_trunc('month', {% parameter as_of_date %})) + interval '1 year') - interval '1 day')::date
          ;;
  }
}
