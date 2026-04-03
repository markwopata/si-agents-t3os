view: discount_leaderboard {
  derived_table: {
    sql:with first_table as(
select
salesperson_user_id
,salesperson
,rental_year_quarter
,count( distinct invoice_id) as total_invoices
,final_market
,final_region
,sum(amount) as amount
,avg(percent_discount)::numeric(20,6) as percent_discount
from analytics.public.rateachievement_points
where date_trunc('quarter',current_timestamp()::date - interval '3 months') <= date_created::date
and hit_revenue_target = 'Yes'
and salesperson not like '%House%'
group by
salesperson_user_id
,salesperson
,rental_year_quarter
,final_market
,final_region
)
, second_table as(
select
*
,RANK() OVER(
  partition by rental_year_quarter
  order by percent_discount asc
  ) as rank
from first_table
where total_invoices > 10
)
, points_off_lead_table as(
select
*
,MIN(percent_discount) OVER(
  partition by rental_year_quarter
  order by percent_discount asc
  ) as first_place_percent
from second_table
group by
salesperson_user_id
,salesperson
,rental_year_quarter
,total_invoices
,amount
,percent_discount
,final_market
,final_region
,rank
)
select
salesperson_user_id
,salesperson
,rental_year_quarter
,total_invoices
,amount as total_invoice_amt
,final_market as main_market
,final_region as rate_region
, case when (rank != 1) then (percent_discount - (first_place_percent)) else 0 end as difference_from_lead
,rank
,percent_discount
from points_off_lead_table
group by
salesperson_user_id
,salesperson
,rental_year_quarter
,total_invoices
,amount
,final_market
,final_region
,rank
,percent_discount
,first_place_percent
             ;;
  }

  dimension: salesperson_user_id {
    type: number
    sql: ${TABLE}."SALESPERSON_USER_ID" ;;
  }

  dimension: salesperson {
    type: string
    sql: TRIM(${TABLE}."SALESPERSON") ;;
  }

  dimension: rental_year_quarter {
    type: string
    sql: ${TABLE}."RENTAL_YEAR_QUARTER" ;;
  }

  dimension: main_market {
    type: string
    sql: TRIM(${TABLE}."MAIN_MARKET") ;;
  }

  dimension: rate_region {
    type: string
    sql: ${TABLE}."RATE_REGION" ;;
  }

  dimension: total_invoices {
    type: number
    sql: ${TABLE}."TOTAL_INVOICES" ;;
  }

  dimension: total_invoice_amt {
    type: number
    sql: ${TABLE}."TOTAL_INVOICE_AMT" ;;
  }

  dimension: percent_discount {
    type: number
    sql: ${TABLE}."PERCENT_DISCOUNT" ;;
  }

  dimension: difference_from_lead {
    type: number
    sql: ${TABLE}."DIFFERENCE_FROM_LEAD" ;;
  }

  dimension: Rank {
    type: number
    sql: ${TABLE}."RANK";;
  }

  dimension: rank_link_to_competitions {
    type: string
    sql: ${Rank} ;;

    link: {
      label: "View Quarterly Competitions"
      url: "https://equipmentshare.looker.com/dashboards/24"
    }
  }

}
