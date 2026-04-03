view: order_salespersons_pivot {
   derived_table: {
     sql: with ordered_reps as (
    select *,
           row_number() over (
               partition by ORDER_ID
               order by SALESPERSON_TYPE_ID
               ) row_num
    from ES_WAREHOUSE.PUBLIC.ORDER_SALESPERSONS
    ),
    primary_rep as (
    select ORDER_ID,
           ORDER_SALESPERSON_ID as rep_1
    from ordered_reps
    where row_num = 1
    ),
    secondary_rep as (
    select ORDER_ID,
           ORDER_SALESPERSON_ID as rep_2
    from ordered_reps
    where row_num = 2
    ),
     third_rep as (
    select ORDER_ID,
           ORDER_SALESPERSON_ID as rep_3
    from ordered_reps
    where row_num = 3
    )
select pr.ORDER_ID,
       pr.rep_1,
       sr.rep_2,
       tr.rep_3,
       case when rep_2 is not null then 'Yes' else 'No' end as secondary_rep_ind
from primary_rep pr
    left join secondary_rep sr on pr.ORDER_ID = sr.ORDER_ID
    left join third_rep tr on pr.ORDER_ID = tr.ORDER_ID
       ;;
   }

   dimension: order_id {
     type: number
     sql: ${TABLE}."ORDER_ID" ;;
   }

   dimension: rep_1 {
     label: "Primary Salesperson"
     description: "Salesperson ID for primary rep on order"
     type: number
     sql: ${TABLE}."REP_1" ;;
   }

  dimension: rep_2 {
    label: "First Secondary Salesperson"
    description: "Salesperson ID for first secondary rep on order"
    type: number
    sql: ${TABLE}."REP_2" ;;
  }

  dimension: rep_3 {
    label: "Second Secondary Salesperson"
    description: "Salesperson ID for second secondary rep on order"
    type: number
    sql: ${TABLE}."REP_3" ;;
  }

  dimension: secondary_rep_ind {
    description: "Indicator for secondary salesperon on order"
    type: string
    sql: ${TABLE}."SECONDARY_REP_IND" ;;
    html: <p style="text-align: center">{{rendered_value}}</p> ;;
  }

 }
