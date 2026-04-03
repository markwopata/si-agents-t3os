view: be_vs_mkt_db_rent_rev {
  derived_table: {
    sql: with final_db as ( with mkt_db as (
            select coalesce(cn.CREDIT_NOTE_NUMBER ,i.INVOICE_NO)                       invoice_no,
                   round(sum(li.AMOUNT), 2)                                            amount,
                   o.MARKET_ID                                                         o_market_id,
                   i.SHIP_FROM:branch_id                                               i_market_id,
                   li.LINE_ITEM_TYPE_ID                                                li_type,
                   GL_BILLING_APPROVED_DATE                                            gl_date,
                   date_trunc(month, GL_BILLING_APPROVED_DATE)                         month_
            from es_warehouse.public.invoices i
                     join analytics.public.v_line_items li
                          on i.invoice_id = li.invoice_id
                     left join es_warehouse.public.credit_notes cn
                          on li.CREDIT_NOTE_ID = cn.CREDIT_NOTE_ID
                     join es_warehouse.public.orders o
                          on i.ORDER_ID = o.ORDER_ID
                     join ES_WAREHOUSE.PUBLIC.ORDER_SALESPERSONS os
                          on i.ORDER_ID = os.ORDER_ID
                          and os.SALESPERSON_TYPE_ID = 1
            where li.LINE_ITEM_TYPE_ID in (8, 6, 44, 108, 109)
              and i.INVOICE_ID != 724307
            group by cn.CREDIT_NOTE_NUMBER, i.invoice_no, o.market_id, i.ship_from:branch_id,
                     li.LINE_ITEM_TYPE_ID, GL_BILLING_APPROVED_DATE, li.CREDIT_NOTE_LINE_ITEM_ID
            having sum(li.amount) <> 0
  ),
       beds as (
           select beds1.mkt_id,
                  beds1.mkt_name,
                  beds1.doc_no,
                  beds1.AR_TYPE,
                  round(sum(beds1.amt),2) amt,
                  beds1.gl_date,
                  date_trunc(month, gl_date) month_
           from analytics.public.BRANCH_EARNINGS_DDS_SNAP beds1
           where beds1.acctno = '5000'
           group by beds1.mkt_id,
                    beds1.mkt_name,
                    beds1.doc_no,
                    beds1.ar_type,
                    beds1.gl_date
           having sum(beds1.amt) <> 0
       )

  select md1.o_market_id::text    market_id,
         m.name             market_name,
         md1.invoice_no     doc_no,
         md1.amount,
         'Market Dashboard' type,
         md1.gl_date
  from mkt_db md1
  join es_warehouse.public.markets m
     on md1.o_market_id = m.MARKET_ID
  where md1.li_type != 44

  union all

  select md1.o_market_id::text    market_id,
         m.name             market_name,
         md1.invoice_no     doc_no,
         md1.amount,
         'Non-serialized Rental Revenue' type,
         md1.gl_date
  from mkt_db md1
  join es_warehouse.public.markets m
     on md1.o_market_id = m.MARKET_ID
  where md1.li_type = 44

  union all

  select md1.o_market_id::text       market_id,
         m.name                market_name,
         md1.invoice_no        doc_no,
         -md1.amount amount,
         'Contract Reassigned' type,
         md1.gl_date
  from mkt_db md1
  join es_warehouse.public.markets m
     on md1.o_market_id = m.MARKET_ID
  where md1.li_type != 44
     and md1.i_market_id <> md1.o_market_id

  union all

  select beds.MKT_ID   market_id,
         beds.mkt_name market_name,
         beds.doc_no,
         beds.amt      amount,
         'Other'       type,
         beds.gl_date
  from beds
  where beds.ar_type is null
     or beds.ar_type = ''

  union all

  select beds.MKT_ID   market_id,
         beds.mkt_name market_name,
         beds.doc_no,
         beds.amt      amount,
         'Additional Invoices on Earnings' type,
         beds.gl_date
  from beds
  left join mkt_db md
     on beds.doc_no = md.invoice_no
  where md.o_market_id is null
     and beds.ar_type = 'Invoice'

  union all

  select md1.o_market_id::text    market_id,
         m.name             market_name,
         md1.invoice_no     doc_no,
         -md1.amount,
         'Invoice not Synced' type,
         md1.gl_date
  from mkt_db md1
  join es_warehouse.public.markets m
     on md1.o_market_id = m.MARKET_ID
  left join beds
    on md1.invoice_no = beds.DOC_NO
  where md1.li_type != 44
    and beds.DOC_NO is null

  union all

  select md1.o_market_id::text       market_id,
         m.name                      market_name,
         md1.invoice_no              doc_no,
         -md1.amount                 amount,
         'Database Timezone Difference'   type,
         md1.gl_date
  from mkt_db md1
  join beds
     on md1.invoice_no = beds.doc_no
     and md1.month_ > beds.month_
  join es_warehouse.public.markets m
     on md1.o_market_id = m.MARKET_ID
  where md1.li_type != 44

  union all

  select beds.MKT_ID                 market_id,
         beds.mkt_name               market_name,
         beds.doc_no,
         beds.amt                    amount,
         'Database Timezone Difference'   type,
         beds.gl_date
  from beds
  join mkt_db md1
     on beds.doc_no = md1.invoice_no
     and beds.month_ < md1.month_
     and md1.li_type != 44
  join es_warehouse.public.markets m
     on md1.o_market_id = m.MARKET_ID
    )
    select
      row_number() over (order by market_id) as pk,
      fdb.*
    from final_db as fdb
     ;;
  }

  measure: count {
    type: count
    drill_fields: []
  }

  measure: amount {
    type: sum
    label: "Amount"
    value_format: "#,##0_);(#,##0);-"
    sql: ${TABLE}."AMOUNT" ;;
    drill_fields: [detail*]
  }

  dimension: market_id {
    type: number
    label: "Market ID"
    sql: ${TABLE}."MARKET_ID" ;;
  }

  dimension: market_name {
    type: string
    label: "Market Name"
    sql: ${TABLE}."MARKET_NAME" ;;
  }


  dimension: doc_no {
    type: string
    label: "Document Number"
    sql: ${TABLE}."DOC_NO" ;;
  }

  dimension: type {
    type: string
    label: "Type"
    sql: ${TABLE}."TYPE" ;;
  }

  dimension: gl_date {
    type: date
    label: "GL Date"
    convert_tz: no
    sql: ${TABLE}."GL_DATE" ;;
  }

  dimension: months_open {
    type: number
    sql: datediff(months, ${revmodel_market_rollout_conservative.branch_earnings_start_month_raw}, ${plexi_periods.date})+1 ;;
  }

  dimension: greater_twelve_months_open {
    label: "Markets Greater Than 12 Months Open?"
    type: yesno
    sql: ${months_open} > 12;;
  }

  dimension: pk {
    type: number
    primary_key: yes
    hidden: yes
    sql: ${TABLE}."PK" ;;
  }

  set: detail {
    fields: [
      doc_no,
      amount,
      type,
      gl_date,
      market_name
    ]
  }
}
