view: company_salesperson_rank {
  derived_table: {
    # datagroup_trigger: Every_Two_Hours_Update
    sql:  with invoices_info as (
        SELECT
          i.company_id,
          c.name,
          ais.PRIMARY_SALESPERSON_ID as salesperson_user_id,
          concat(u2.first_name,' ',u2.last_name) as salesperson_name,
          sum(li.amount) as total_spend,
          max(i.start_date::DATE) as latest_invoice_date
        FROM
          ES_WAREHOUSE.PUBLIC.INVOICES i
          join ES_WAREHOUSE.PUBLIC.companies c on i.company_id = c.company_id
          join ES_WAREHOUSE.PUBLIC.APPROVED_INVOICE_SALESPERSONS ais on i.INVOICE_ID = ais.INVOICE_ID
          join ES_WAREHOUSE.PUBLIC.users u2 on ais.PRIMARY_SALESPERSON_ID = u2.user_id
          join ANALYTICS.PUBLIC.V_LINE_ITEMS li on i.INVOICE_ID = li.INVOICE_ID
        WHERE
          li.GL_BILLING_APPROVED_DATE > (current_date - INTERVAL '12 months')
          AND li.LINE_ITEM_TYPE_ID in (6,8,108,109)
          and li.amount > 0
          AND {% condition customer_name %} REPLACE(TRIM(c.name),CHAR(9), '') {% endcondition %}
        GROUP BY
          i.company_id,
          c.name,
          ais.PRIMARY_SALESPERSON_ID,
          concat(u2.first_name,' ',u2.last_name)
),
     rank_last_invoice as (
        select
          *,
          rank ()
          over (
          partition by
            company_id
          order by
            latest_invoice_date desc
          ) rank_number
        from
          invoices_info
        where
          total_spend > 0
        order by
          company_id
        ),
        rank_total_spend as (
        select
          *,
          rank ()
          over (
          partition by
            company_id
          order by
            total_spend desc
          ) spend_rank_number
        from
          invoices_info
        where
          total_spend > 0
        order by
          company_id
        ),
        sales_rep_rank_one as (
        select
          company_id,
          case when spend_rank_number = 1 then salesperson_name end as sales_rep_rank_one,
          case when spend_rank_number = 1 then salesperson_user_id end as sales_rep_rank_one_id
        from
          rank_total_spend
        where
            spend_rank_number = 1
        ),
        sales_rep_rank_two as (
        select
          company_id,
          case when spend_rank_number = 2 then salesperson_name end as sales_rep_rank_two,
          case when spend_rank_number = 2 then salesperson_user_id end as sales_rep_rank_two_id
        from
          rank_total_spend
        where
            spend_rank_number = 2
        ),
        sales_rep_rank_three as (
        select
          company_id,
          case when spend_rank_number = 3 then salesperson_name end as sales_rep_rank_three,
          case when spend_rank_number = 3 then salesperson_user_id end as sales_rep_rank_three_id
        from
          rank_total_spend
        where
            spend_rank_number = 3
        ),
        company_sales_rep_spend_rank as (
        select
          r1.company_id,
          r1.sales_rep_rank_one,
          r1.sales_rep_rank_one_id,
          r2.sales_rep_rank_two,
          r2.sales_rep_rank_two_id,
          r3.sales_rep_rank_three,
          r3.sales_rep_rank_three_id
        from
          sales_rep_rank_one r1
          left join sales_rep_rank_two r2 on r1.company_id = r2.company_id
          left join sales_rep_rank_three r3 on r1.company_id = r3.company_id)
         select
          r.*,
          c.sales_rep_rank_one,
          c.sales_rep_rank_one_id,
          c.sales_rep_rank_two,
          c.sales_rep_rank_two_id,
          c.sales_rep_rank_three,
          c.sales_rep_rank_three_id
        from
          rank_last_invoice r
        left join company_sales_rep_spend_rank c on c.company_id = r.company_id
       ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: company_id {
    type: number
    sql: ${TABLE}."COMPANY_ID" ;;
  }

  dimension: name {
    type: string
    sql: TRIM(${TABLE}."NAME") ;;
  }

  dimension: salesperson_user_id {
    type: number
    sql: ${TABLE}."SALESPERSON_USER_ID" ;;
  }

  dimension: salesperson_name {
    type: string
    sql: ${TABLE}."SALESPERSON_NAME" ;;
  }

  dimension: total_spend {
    type: number
    sql: ${TABLE}."TOTAL_SPEND" ;;
    drill_fields: [salesperson_name,invoices.invoice_id,invoices.start_date,invoices.end_date,total_spend]
  }

  dimension: latest_invoice_date {
    type: date
    sql: ${TABLE}."LATEST_INVOICE_DATE" ;;
  }

  dimension: rank_number {
    type: number
    sql: ${TABLE}."RANK_NUMBER" ;;
  }

  dimension: full_name_with_id {
    type: string
    sql: concat(${salesperson_name}, ' - ',${salesperson_user_id})  ;;
  }


  # These are sales reps ranked according to invoice amount, not latest invoice date
  dimension: sales_rep_rank_one {
    type: string
    sql: ${TABLE}."SALES_REP_RANK_ONE" ;;
  }

  dimension: sales_rep_rank_one_id {
    type: number
    sql: ${TABLE}."SALES_REP_RANK_ONE_ID" ;;
  }

  dimension: sales_rep_rank_two {
    type: string
    sql: ${TABLE}."SALES_REP_RANK_TWO" ;;
  }

  dimension: sales_rep_rank_two_id {
    type: number
    sql: ${TABLE}."SALES_REP_RANK_TWO_ID" ;;
  }

  dimension: sales_rep_rank_three {
    type: string
    sql: ${TABLE}."SALES_REP_RANK_THREE" ;;
  }

  dimension: sales_rep_rank_three_id {
    type: number
    sql: ${TABLE}."SALES_REP_RANK_THREE_ID" ;;
  }

  dimension: sales_rep_id_link_to_salesperson_dashboard {
    type: string
    sql: ${full_name_with_id} ;;

    link: {
      label: "View Salesperson Dashboard"
      url: "https://equipmentshare.looker.com/dashboards/5?Sales%20Rep={{ value | url_encode }}"
      #8&Market=&District=&Region=&Customer%20Terms%20(AR%20Past%20Due)=&National%20Sales%20Rep=&Do%20Not%20Rent%20Customers=
    }
    description: "This links out to the Salesperson dashboard"
  }

  measure: total_rental_amt {
    type: sum
    value_format_name: "usd"
    sql: ${TABLE}."TOTAL_SPEND";;
    drill_fields: [salesperson_name,invoices.invoice_id,invoices.start_date,invoices.end_date,total_spend]
  }

  filter: customer_name {
    type: string
  }


  set: detail {
    fields: [
      company_id,
      name,
      salesperson_user_id,
      salesperson_name,
      total_spend,
      latest_invoice_date,
      rank_number
    ]
  }
}
