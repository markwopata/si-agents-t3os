view: sold_asset_tracker_2a {
  derived_table: {
    sql:with tbl1 as (
          select a.ASSET_ID, COALESCE(D.SERIAL_NUMBER, D.VIN) AS SERIAL_NUMBER,
                 F.NAME AS CURRENT_OWNER,
                 purchaser.name as PURCHASER,
                 b.INVOICE_NO,
                 B.INVOICE_DATE AS CUSTOMER_INVOICE_DATE,
                 round(a.AMOUNT,2) AS ASSET_AMOUNT_OWED,
                 B.DUE_DATE AS PMT_DUE_DT,
                 D.MAKE AS MANUFACTURER,
                 round(b.OWED_AMOUNT,2) as INVOICE_AMOUNT_OWED,
                 g.SCHEDULE,
                 round(g.PAYOFF_AMT,2) as PAYOFF_AMT,
                 round(b.BILLED_AMOUNT,2) as BILLED_AMOUNT,
          IFF(b.billing_approved = 'false', 'Unapproved',
              IFF(b.OWED_AMOUNT > 0 and b.OWED_AMOUNT < b.BILLED_AMOUNT,'Partially Paid',
                 IFF(b.DUE_DATE < current_date,'Past Due','Unpaid') )) as status
          from ES_WAREHOUSE.PUBLIC.LINE_ITEMS as a
                   left join
               ES_WAREHOUSE.PUBLIC.INVOICES b
               on a.INVOICE_ID = b.INVOICE_ID
                   left join
               ES_WAREHOUSE.PUBLIC.ASSET_PURCHASE_HISTORY c
               on a.asset_id = c.asset_id
                   left join
               ES_WAREHOUSE.PUBLIC.assets d
               on a.ASSET_ID = d.ASSET_ID
              left join ES_WAREHOUSE.PUBLIC.CREDIT_NOTE_LINE_ITEMS e
              on a.LINE_ITEM_ID = e.LINE_ITEM_ID
               LEFT JOIN
                   ES_WAREHOUSE.PUBLIC.COMPANIES F
                  ON D.COMPANY_ID = F.COMPANY_ID
              left join ANALYTICS.DEBT.ASSET_NBV_ALL_OWNERS_VIEW G
                  on a.ASSET_ID = g.ASSET_ID
              left join ES_WAREHOUSE.PUBLIC.PURCHASE_ORDERS H
                  on b.PURCHASE_ORDER_ID = h.PURCHASE_ORDER_ID
              left join ES_WAREHOUSE.PUBLIC.COMPANIES purchaser
                  on h.COMPANY_ID = purchaser.COMPANY_ID
          where (b.PAID = 'false' or b.PAID is null)
            and a.LINE_ITEM_TYPE_ID = 80
            and (c.FINANCIAL_SCHEDULE_ID not in (2097,1539,1357,1359,2770,2769,2399,1615,2736,1391)
          and e.CREDIT_NOTE_LINE_ITEM_ID is null
      ))
      ,get_distinct_invoice as (
          select distinct INVOICE_NO, INVOICE_AMOUNT_OWED
          from tbl1
          where status <> 'Unapproved'
      )
      ,get_total_owed as (
          select round(sum(INVOICE_AMOUNT_OWED),2) as total_AR
          from get_distinct_invoice
      )
      ,get_distinct_assets as (
          select distinct asset_id
          from tbl1
          where status <> 'Unapproved'
      )
      ,get_asset_count as (
          select count(asset_id) as number_of_assets
          from get_distinct_assets
      )
      select a.*, b.*, c.*
      from tbl1 a,
           get_total_owed b,
           get_asset_count c
      where a.status <> 'Unapproved';;
  }
  dimension: asset_id {
    type: number
    sql: ${TABLE}.asset_id ;;
  }
  dimension: serial_number {
    type: string
    sql: ${TABLE}.serial_number ;;
  }
  dimension: current_owner {
    type: string
    sql: ${TABLE}.current_owner ;;
  }
  dimension: purchaser {
    type: string
    sql: ${TABLE}.purchaser ;;
  }
  dimension: invoice_no {
    type: string
    sql: ${TABLE}.invoice_no ;;
  }
  dimension: customer_invoice_date {
    type: date
    sql: ${TABLE}.customer_invoice_date;;
  }
  dimension: asset_amount_owed {
    type: number
    sql: ${TABLE}.asset_amount_owed;;
  }
  dimension: pmt_due_dt {
    type: date
    sql: ${TABLE}.pmt_due_dt ;;
  }
  dimension: manufacturer {
    type: string
    sql: ${TABLE}.manufacturer ;;
  }
  dimension: invoice_amount_owed {
    type: number
    sql: ${TABLE}.invoice_amount_owed ;;
  }
  dimension: schedule {
    type: string
    sql: ${TABLE}.schedule ;;
  }
  dimension: payoff_amt {
    type: number
    sql: ${TABLE}.payoff_amt;;
  }
  dimension: billed_amount {
    type: number
    sql: ${TABLE}.billed_amount;;
  }
  dimension: status {
    type: string
    sql: ${TABLE}.status ;;
  }
  dimension: total_ar {
    type: number
    sql: ${TABLE}.total_ar;;
  }
  dimension: number_of_assets{
    type: number
    sql: ${TABLE}.number_of_assets;;
  }
}
