view: top_rev_by_sales_rep {
  derived_table: {
    # datagroup_trigger: 6AM_update
    sql: WITH sales_rev_by_rep_by_market as
         (
             SELECT sum(li.AMOUNT) as amount,
                    i.SALESPERSON_USER_ID,
                    li.BRANCH_ID as market_id
             FROM ES_WAREHOUSE.PUBLIC.INVOICES i
                      JOIN ANALYTICS.PUBLIC.V_LINE_ITEMS li
                           ON i.INVOICE_ID = li.INVOICE_ID
             WHERE i.BILLING_APPROVED
               AND li.LINE_ITEM_TYPE_ID IN (6,8,108,109)
               AND li.GL_BILLING_APPROVED_DATE > dateadd(day, -365, current_date)
             GROUP BY li.BRANCH_ID, i.SALESPERSON_USER_ID
         ),
  rank_cte as
      (
          SELECT srb.*,
                 rank() over (partition by srb.SALESPERSON_USER_ID ORDER BY srb.amount desc) as rank
          FROM sales_rev_by_rep_by_market srb
          ORDER BY SALESPERSON_USER_ID, rank
      )
SELECT r.amount as AMOUNT, r.SALESPERSON_USER_ID as SALESPERSON_USER_ID, r.MARKET_ID, r.RANK as RANK,
u.EMAIL_ADDRESS as EMAIL_ADDRESS
FROM rank_cte as r
inner join ES_WAREHOUSE.PUBLIC.users as u
on r.SALESPERSON_USER_ID = u.USER_ID
WHERE  rank = 1
union all
select 0 as amount, 63835 as salesperson_user_id, 1 as market_id, 1 as rank,
'jacob.hayes@equipmentshare.com' as email_address
union all
select 0 as amount, 70753 as salesperson_user_id, 34742 as market_id, 1 as rank,
'brian.wilson@equipmentshare.com' as email_address
          ;;
  }

 dimension: amount {
    type: number
    sql: ${TABLE}."AMOUNT" ;;
  }

  dimension: salesperson_user_id {
    type: number
    sql: ${TABLE}."SALESPERSON_USER_ID" ;;
  }

  dimension: market_id {
    type: number
    sql: case when ${salesperson_user_id} = 55033 then 15971 else ${TABLE}."MARKET_ID" end ;;
  }

  dimension: rank {
    type: number
    sql: ${TABLE}."RANK" ;;
  }

  dimension: email_address {
    type: string
    sql: ${TABLE}."EMAIL_ADDRESS" ;;
  }
  }
