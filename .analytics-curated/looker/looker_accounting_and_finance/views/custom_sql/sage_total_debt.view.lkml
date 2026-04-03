view: sage_total_debt {
  parameter: as_of_date {
    type: date
  }
  derived_table: {
    sql:with filter_date as (
  select --'2021-06-30'::date as filter_date
         case when {% parameter as_of_date %} is null then
              current_timestamp::date
          else
              {% parameter as_of_date %} end filter_date
)
,get_amounts as (
    SELECT
           glt.ACCOUNTNO,
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
        and ul.name in (select distinct SAGE_LOAN_ID from ANALYTICS.DEBT.PHOENIX_ID_TYPES)
)
,get_sage_2500_balances as
    (
        select a.ACCOUNTNO, a.sage_id, round(sum(a.princ_amt), 2) as current_balance
        from get_amounts a
        group by a.ACCOUNTNO, a.sage_id
    )
  -- select * from get_sage_2500_balances;
,add_other_accts as (
       with tbl1 as
    (
    SELECT
    *,
    (cast(glt.tr_type as integer)*-1)*cast(glt.amount as float) as current_balance
    from
    ANALYTICS.INTACCT.GLENTRY glt,
    filter_date fd
    WHERE
    glt.state = 'Posted'
    and glt.accountno in (
'2423',
'2507',
'2418',
'2501',
'2421',
'2417',
'2508',
'2422',
'2311',
'2401',
'2402'
)
    and glt.entry_date <= fd.filter_date
    )
    select
    ACCOUNTNO,
    'not needed' as sage_id,
    sum(current_balance) as current_balance
       from tbl1
    group by ACCOUNTNO
)
   --select * from add_other_accts where ACCOUNTNO in ('2414', '2419');
,final as (
    select *
    from get_sage_2500_balances
    where abs(current_balance) > 1
    union
    select *
    from add_other_accts
),total_all as (
select sum(current_balance) as total_of_all from final
)
select a.*, b.*
from final a,
     total_all b ;;
  }
  dimension:  ACCOUNTNO {
    type: string
    sql: ${TABLE}.ACCOUNTNO ;;
  }
  dimension:  sage_id {
    type: string
    sql: ${TABLE}.sage_id ;;
  }
  dimension: current_balance {
    type: number
    sql: ${TABLE}.current_balance ;;
  }
  dimension: total_of_all {
    type: number
    sql: ${TABLE}.total_of_all ;;
  }
  measure: display_as_of_date {
    description: "Total debt according to Sage as of this date"
    label: "Total debt according to Sage as of this date"
    type: date
    label_from_parameter: as_of_date
    sql:  {% parameter as_of_date %}
          --(date (date (date_trunc('month', {% parameter as_of_date %})) + interval '1 year') - interval '1 day')::date
          ;;
  }
  # # You can specify the table name if it's different from the view name:
  # sql_table_name: my_schema_name.tester ;;
  #
  # # Define your dimensions and measures here, like this:
  # dimension: user_id {
  #   description: "Unique ID for each user that has ordered"
  #   type: number
  #   sql: ${TABLE}.user_id ;;
  # }
  #
  # dimension: lifetime_orders {
  #   description: "The total number of orders for each user"
  #   type: number
  #   sql: ${TABLE}.lifetime_orders ;;
  # }
  #
  # dimension_group: most_recent_purchase {
  #   description: "The date when each user last ordered"
  #   type: time
  #   timeframes: [date, week, month, year]
  #   sql: ${TABLE}.most_recent_purchase_at ;;
  # }
  #
  # measure: total_lifetime_orders {
  #   description: "Use this for counting lifetime orders across many users"
  #   type: sum
  #   sql: ${lifetime_orders} ;;
  # }
}
