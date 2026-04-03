view: credit_card_inventory_reclass {
  derived_table: {
    sql: with
-- 1) Citi Bank Allocation GL detail lines (bounded for perf)
gl_detail_allocated_txns as (
    select distinct
        split_part(ENTRY_DESCRIPTION,';',3) as cc_txn_id,
        ACCOUNT_NUMBER
    from ANALYTICS.INTACCT_MODELS.GL_DETAIL gld
    where gld.JOURNAL_TITLE ilike '1009 - Citi Bank Allocation%'
      and gld.ENTRY_DATE >= '2025-01-01' --
),

-- 2) PIT vs CC per *txn month*; keep rows where PIT cost <= CC amount
inventory_greater_than_filter_out as (
    select
        date_trunc('month', tv.TRANSACTION_DATE)              as period_month,
        pit.MARKET_ID,
        pit.MARKET_NAME,
        gld.ACCOUNT_NUMBER,
        'Double Bill Credit Card/Inventory Credit;Credit Card Txn #:' || tv.TRANSACTION_ID ||
        ';Credit Card Txn Date:' || tv.TRANSACTION_DATE::date ||
        ';CostCapture Txn #:'    || p.PURCHASE_ID ||
        ';CostCapture Txn Date:' || p.PURCHASED_AT::date ||
        ';Part Inventory Txn #:' || pit.TRANSACTION_ID ||
        ';Part Inventory Txn Date:' || pit.MONTH_::date        as memo,
        pit.TRANSACTION_ID                                     as part_inventory_txn_id,
        tv.TRANSACTION_ID                                      as citi_txn_id,
        last_day(date_trunc('month', tv.TRANSACTION_DATE))     as entry_date,
        tv.TRANSACTION_AMOUNT                                  as transaction_amount,
        sum(pit.QUANTITY * pit.COST_PER_ITEM)                     as total_pit_cost,
        sum(pit.QUANTITY * pit.COST_PER_ITEM) - tv.TRANSACTION_AMOUNT as pit_raw_txn_diff
    from procurement.public.purchases p
    join procurement.public.purchase_receipts pr
      on p.purchase_id = pr.purchase_id
    join analytics.intacct_models.part_inventory_transactions pit
      on pr.purchase_receipt_id = pit.from_uuid_id
    join analytics.credit_card.transaction_verification tv
      on pr.purchase_id = tv.upload_id
    join analytics.gs.MCC m
      on tv.TRANSACTION_MCC_CODE = m.MCC_NO_
    join gl_detail_allocated_txns gld
      on upper(tv.TRANSACTION_ID) = upper(gld.cc_txn_id)
     and m.INTACCT_ACCOUNT       = gld.ACCOUNT_NUMBER
    where p.SUBMITTED_AT >= dateadd(day, 25, dateadd(month, -1, date_trunc('month', tv.TRANSACTION_DATE)))
      and p.SUBMITTED_AT <  dateadd(day, 25, date_trunc('month', tv.TRANSACTION_DATE))
      and ((pit.QUANTITY * pit.COST_PER_ITEM) - tv.TRANSACTION_AMOUNT) <= 0
group by pit.MARKET_ID,
        pit.MARKET_NAME,
        gld.ACCOUNT_NUMBER,
        tv.TRANSACTION_ID,
        TRANSACTION_TYPE,
        pit.TRANSACTION_ID,
        p.PURCHASE_ID,
        tv.TRANSACTION_DATE,
        p.PURCHASED_AT,
        pit.MONTH_,
        tv.TRANSACTION_AMOUNT
),

-- 3) Inventory reclass at PIT market (credit CC expense acct, debit 6300)
inventory_reclass_entry as (
    -- Credit to CC expense account @ PIT market
    select
        entry_date,                                -- 1
        ACCOUNT_NUMBER  as account_number,         -- 2 (expense acct from MCC map)
        memo,                                      -- 3
        MARKET_ID       as department_id,          -- 4
        MARKET_NAME     as department_name,        -- 5
        cast(null as number(38,2)) as debit,       -- 6
        total_pit_cost              as credit,     -- 7
        citi_txn_id                 as txn_id,     -- 8
        'Inventory Reclass - Credit to CC Account' as flag  -- 9
    from inventory_greater_than_filter_out

    union all

    -- Debit 6300 @ PIT market
    select
        entry_date,
        '6300'          as account_number,
        memo,
        MARKET_ID       as department_id,
        MARKET_NAME     as department_name,
        total_pit_cost  as debit,
        cast(null as number(38,2)) as credit,
        citi_txn_id     as txn_id,
        'Inventory Reclass - Debit 6300' as flag
    from inventory_greater_than_filter_out
),

-- 4) Txn ids included in the monthly reclass set (deduped)
monthly_reclass_txn_ids as (
    select distinct txn_id from inventory_reclass_entry
),

-- 5) Allocation details joined to PIT posting location for those txn_ids only
allocation_data as (
    select distinct
        gld.ENTRY_DATE,
        date_trunc('month', tv.TRANSACTION_DATE)               as period_month,
        split_part(gld.ENTRY_DESCRIPTION, ';', 3)              as txn_id,
        gld.DEPARTMENT_ID                                      as gld_department_id,
        gld.DEPARTMENT_NAME                                    as gld_department_name,
        pit.MARKET_ID                                          as pit_market_id,
        pit.MARKET_NAME                                        as pit_market_name,
        gld.ACCOUNT_NUMBER,
        gld.AMOUNT,
        gld.ENTRY_DESCRIPTION
    from procurement.public.purchases p
    join procurement.public.purchase_receipts pr
      on p.purchase_id = pr.purchase_id
    join analytics.intacct_models.part_inventory_transactions pit
      on pr.purchase_receipt_id = pit.from_uuid_id
    join analytics.credit_card.transaction_verification tv
      on p.purchase_id = tv.upload_id
    left join analytics.gs.MCC m
      on tv.TRANSACTION_MCC_CODE = m.MCC_NO_
    join ANALYTICS.INTACCT_MODELS.GL_DETAIL gld
      on upper(tv.TRANSACTION_ID) = upper(split_part(gld.ENTRY_DESCRIPTION, ';', 3))
     and date_trunc(month, tv.TRANSACTION_DATE) = date_trunc(month, gld.ENTRY_DATE)
     and m.INTACCT_ACCOUNT = gld.ACCOUNT_NUMBER              -- expense side only
    where gld.JOURNAL_TITLE ilike '1009 - Citi Bank Allocation%'
      and split_part(gld.ENTRY_DESCRIPTION, ';', 3) in (select txn_id from monthly_reclass_txn_ids)
),

-- 6) Identify txns that actually need a FULL reversal (i.e., there is ANY non-PIT allocation)
txns_requiring_full_reversal as (
    select
        txn_id,
        ACCOUNT_NUMBER,
        pit_market_id
    from allocation_data
    group by txn_id, ACCOUNT_NUMBER, pit_market_id
    having count_if( coalesce(gld_department_id, -1) <> coalesce(pit_market_id, -1) ) > 0
),

-- 7) Scope the allocation lines to ONLY those txns that need a full reversal
allocation_debit_lines as (
    select ad.*
    from allocation_data ad
    join txns_requiring_full_reversal t
      on ad.txn_id = t.txn_id
     and ad.ACCOUNT_NUMBER = t.ACCOUNT_NUMBER
     and ad.pit_market_id  = t.pit_market_id
    where coalesce(ad.AMOUNT,0) <> 0
),

-- 8) FULL reversal for those txns (credit every allocated line incl. PIT), then FULL repost to PIT
cc_alloc_full_reversal_and_repost as (
    -- (a) Reverse: credit each original allocated department line (incl. PIT if present)
    select
        ENTRY_DATE                      as entry_date,
        ACCOUNT_NUMBER                  as account_number,
        ENTRY_DESCRIPTION               as memo,
        gld_department_id               as department_id,
        gld_department_name             as department_name,
        cast(null as number(38,2))      as debit,
        abs(AMOUNT)                     as credit,
        txn_id,
        'CC Alloc Reversal - GL Line'   as flag
    from allocation_debit_lines

    union all

    -- (b) Repost FULL amount to PIT (one debit per txn/account)
    select
        ENTRY_DATE                      as entry_date,
        ACCOUNT_NUMBER                  as account_number,
        min(ENTRY_DESCRIPTION)          as memo,
        pit_market_id                   as department_id,
        pit_market_name                 as department_name,
        sum(abs(AMOUNT))                as debit,
        cast(null as number(38,2))      as credit,
        txn_id,
        'CC Alloc Repost - PIT Market'  as flag
    from allocation_debit_lines
    group by ENTRY_DATE, ACCOUNT_NUMBER, pit_market_id, pit_market_name, txn_id
)

-- 9) Single unified output (safe SELECT *; align/order matches)
select *
from (
    select * from inventory_reclass_entry
    union all
    select * from cc_alloc_full_reversal_and_repost
) final_out
-- optional month filter for Looker:
order by entry_date, txn_id, flag, account_number, department_id ;;
  }

  dimension_group: entry_date {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    sql: ${TABLE}.entry_date ;;
  }

  dimension: account_number {
    type: string
    sql: ${TABLE}.account_number ;;
    description: "Expense account (e.g., 6300)."
  }

  dimension: memo {
    type: string
    sql: ${TABLE}.memo ;;
  }

  dimension: department_id {
    type: number
    sql: ${TABLE}.department_id ;;
  }

  dimension: department_name {
    type: string
    sql: ${TABLE}.department_name ;;
  }

  dimension: txn_id {
    type: string
    sql: ${TABLE}.txn_id ;;
    description: "Credit card transaction id parsed from GL (SPLIT_PART #3)."
  }

  dimension: flag {
    type: string
    sql: ${TABLE}.flag ;;
    description: "Row type: Inventory Reclass - Credit to CC Account | Inventory Reclass - Debit 6300 | CC Alloc Reversal - GL Line | CC Alloc Repost - PIT Market."
  }

  dimension: debit {
    type: number
    value_format: "$#,##0.00"
    sql: ${TABLE}.debit ;;
  }

  dimension: credit {
    type: number
    value_format: "$#,##0.00"
    sql: ${TABLE}.credit ;;
  }

  measure: rows {
    type: count
    drill_fields: [entry_date_raw, account_number, department_id, department_name, txn_id, flag, memo]
  }

  measure: distinct_txns {
    type: count_distinct
    sql: ${txn_id} ;;
  }

  measure: distinct_departments {
    type: count_distinct
    sql: ${department_id} ;;
  }

  measure: total_debit {
    type: sum
    sql: ${debit} ;;
    value_format: "$#,##0.00"
  }

  measure: total_credit {
    type: sum
    sql: ${credit} ;;
    value_format: "$#,##0.00"
  }

}
