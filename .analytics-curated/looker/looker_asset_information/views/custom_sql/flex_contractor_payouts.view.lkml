view: flex_contractor_payouts {
  derived_table: {
    sql: WITH current_month_invoices_cte as
         (
             SELECT a.ASSET_ID,
                    i.end_date::date                          as invoice_end_date,
                    date_trunc('month', i.end_date)::date     as payout_month,
                    li.INVOICE_ID,
                    amount,
                    sum(amount) OVER (partition by date_trunc('month', i.end_date)::date,
                        a.asset_id
                        ORDER BY i.end_date, i.INVOICE_ID)    as cumulative_amt,
                    row_number() OVER (partition by date_trunc('month', i.end_date)::date,
                        a.asset_id
                        ORDER BY i.end_date, i.INVOICE_ID)    as rank,
                    round((rb.MONTH_BENCHMARK / 1.05 * 1.2)::INT, 2) as benchmark,
                    rb.YEAR_QUARTER,
                    c.NAME as company_name,
                    c.company_id,
                    a.CLASS,
                    m.name as market_name,
                    m.market_id as market_id,
                    pp.asset_payout_percentage
             FROM ES_WAREHOUSE.PUBLIC.ORDERS o
                      JOIN ES_WAREHOUSE.PUBLIC.RENTALS r
                           ON o.ORDER_ID = r.ORDER_ID
                      JOIN MARKET_REGION_XWALK rm
                           ON o.MARKET_ID = rm.MARKET_ID
                      JOIN (SELECT INVOICE_ID, RENTAL_ID, sum(AMOUNT) as amount
                            FROM ES_WAREHOUSE.PUBLIC.LINE_ITEMS
                            WHERE LINE_ITEM_TYPE_ID = 8
                            GROUP BY INVOICE_ID, RENTAL_ID) li
                           ON r.RENTAL_ID = li.RENTAL_ID
                      JOIN ES_WAREHOUSE.PUBLIC.INVOICES i
                           ON li.INVOICE_ID = i.INVOICE_ID
                      JOIN ES_WAREHOUSE.PUBLIC.ASSETS_AGGREGATE a
                           ON r.ASSET_ID = a.asset_id
                      LEFT JOIN rateachievement_benchmark rb
                                ON a.equipment_class_id = rb.equipment_class_id::INT
                                    and O.MARKET_ID = RB.MARKET_ID
                      JOIN ES_WAREHOUSE.PUBLIC.COMPANIES c
                           ON c.company_id = a.company_id
                      JOIN ES_WAREHOUSE.PUBLIC.MARKETS m
                           ON m.market_id = o.market_id
                      JOIN ES_WAREHOUSE.PUBLIC.v_payout_programs pp
                           on pp.asset_id = a.asset_id
             WHERE
                amount > 0
                AND c.is_eligible_for_payouts = TRUE
                AND i.end_date between pp.start_date and coalesce(pp.end_date,'2099-12-31')
                AND pp.asset_payout_percentage is not null
             ORDER BY ASSET_ID, i.end_date, INVOICE_ID
         ),
     current_month_cte as
         (
             SELECT *
             FROM current_month_invoices_cte
             WHERE rank = 1
                OR benchmark >= cumulative_amt
         )
        ,
     leftover_cte as
         (
             SELECT cmic1.ASSET_ID,
                    cmic1.invoice_end_date,
                    cmic1.payout_month + interval '1 month'            as payout_month,
                    cmic1.INVOICE_ID,
                    cmic1.amount,
                    sum(cmic1.amount) OVER (partition by date_trunc('month', cmic1.invoice_end_date)::date,
                        cmic1.asset_id
                        ORDER BY cmic1.invoice_end_date, cmic1.INVOICE_ID) as cumulative_amt,
                    row_number() OVER (partition by date_trunc('month', cmic1.invoice_end_date)::date,
                        cmic1.asset_id
                        ORDER BY cmic1.invoice_end_date, cmic1.INVOICE_ID) as rank,
                    cmic1.benchmark,
                    cmic1.YEAR_QUARTER,
                    cmic1.company_name,
                    cmic1.company_id,
                    cmic1.class,
                    cmic1.market_name,
                    cmic1.market_id,
                    cmic1.asset_payout_percentage
             FROM current_month_invoices_cte cmic1
                      LEFT JOIN current_month_invoices_cte cmic2
                                ON cmic1.ASSET_ID = cmic2.ASSET_ID
                                    AND cmic1.payout_month = add_months(cmic2.payout_month, -1)
             WHERE cmic2.ASSET_ID is null
               and (cmic1.rank <> 1
                 and cmic1.benchmark < cmic1.cumulative_amt)
         ),
             leftover_filter_cte as
         (
             SELECT *
             FROM leftover_cte
             WHERE rank = 1
                OR benchmark >= cumulative_amt
         ),
     output_cte as
         (
             SELECT *, 'current_month' as source
             FROM current_month_cte
             UNION ALL
             SELECT *, 'leftover' as source
             FROM leftover_filter_cte
             ORDER BY ASSET_ID, payout_month
         )
SELECT
    asset_id,
    invoice_end_date,
    payout_month,
    invoice_id,
    amount,
    cumulative_amt,
    rank,
    benchmark,
    year_quarter,
    company_name,
    company_id,
    class,
    market_name,
    market_id,
    asset_payout_percentage,
    amount*asset_payout_percentage as payout_amount,
    source
FROM output_cte
group by
    asset_id,
    invoice_end_date,
    payout_month,
    invoice_id,
    amount,
    cumulative_amt,
    rank,
    benchmark,
    year_quarter,
    company_name,
    company_id,
    class,
    market_name,
    market_id,
    asset_payout_percentage,
    source
order by payout_month desc, asset_id desc
 ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: asset_id {
    type: number
    sql: ${TABLE}."ASSET_ID" ;;
  }

  dimension: invoice_end_date {
    type: date
    sql: ${TABLE}."INVOICE_END_DATE" ;;
  }

  dimension: payout_month {
    type: date
    sql: ${TABLE}."PAYOUT_MONTH" ;;
  }

  dimension: invoice_id {
    type: number
    sql: ${TABLE}."INVOICE_ID" ;;
  }

  dimension: amount {
    type: number
    sql: ${TABLE}."AMOUNT" ;;
  }

  dimension: cumulative_amt {
    type: number
    sql: ${TABLE}."CUMULATIVE_AMT" ;;
  }

  dimension: rank {
    type: number
    sql: ${TABLE}."RANK" ;;
  }

  dimension: benchmark {
    type: number
    sql: ${TABLE}."BENCHMARK" ;;
  }

  dimension: year_quarter {
    type: string
    sql: ${TABLE}."YEAR_QUARTER" ;;
  }

  dimension: company_name {
    type: string
    sql: ${TABLE}."COMPANY_NAME" ;;
  }

  dimension: company_id {
    type: number
    sql: ${TABLE}."COMPANY_ID" ;;
  }

  dimension: class {
    type: string
    sql: ${TABLE}."CLASS" ;;
  }

  dimension: market_name {
    type: string
    sql: ${TABLE}."MARKET_NAME" ;;
  }

  dimension: market_id {
    type: number
    sql: ${TABLE}."MARKET_ID" ;;
  }

  dimension: asset_payout_percentage {
    type: number
    sql: ${TABLE}."ASSET_PAYOUT_PERCENTAGE" ;;
  }

  dimension: payout_amount {
    type: number
    sql: ${TABLE}."PAYOUT_AMOUNT" ;;
  }

  dimension: source {
    type: string
    sql: ${TABLE}."SOURCE" ;;
  }

  measure: asset_payout_amount {
    type: sum
    sql: ${payout_amount} ;;
    value_format_name: usd
  }

  dimension: pay_on_this_month {
    type: yesno
    sql: ${payout_month} = date_trunc('month',add_months(current_date(),-1)) ;;
  }

  set: detail {
    fields: [
      asset_id,
      invoice_end_date,
      payout_month,
      invoice_id,
      amount,
      cumulative_amt,
      rank,
      benchmark,
      year_quarter,
      company_name,
      company_id,
      class,
      market_name,
      market_id,
      asset_payout_percentage,
      payout_amount,
      source
    ]
  }
}
