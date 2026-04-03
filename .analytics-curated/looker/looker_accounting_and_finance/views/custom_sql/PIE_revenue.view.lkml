view: pie_revenue {
  derived_table: {
    sql: with DATE_SERIES_CTE as
         (select SERIES::date as DTE
          from table (ES_WAREHOUSE.PUBLIC.GENERATE_SERIES('2021-08-01'::timestamp_tz,
                                                          date_trunc('month', current_timestamp)::timestamp_tz,
                                                          'month')))
,add_payouts as
    (select DSC.DTE,
            M.NAME                                   as MARKET_NAME,
            INV.BRANCH_ID                            as MARKET_ID,
            INV.INVOICE_ID,
            INV.INVOICE_NO,
            SCD.COMPANY_ID,
            C.NAME                                   as COMPANY_NAME,
            C.IS_ELIGIBLE_FOR_PAYOUTS,
            VPP.ASSET_ID,
            AA.MAKE,
            AA.MODEL,
            AA.CLASS,
            DSC.DTE                                  as PAYOUT_MONTH,
            VPP.ASSET_PAYOUT_PERCENTAGE,
            VPP.START_DATE,
            INV.AMOUNT                               as Revenue,
            INV.AMOUNT * VPP.ASSET_PAYOUT_PERCENTAGE as ASSET_PAYOUT_AMOUNT
     from ES_WAREHOUSE.PUBLIC.V_PAYOUT_PROGRAMS VPP
              join ES_WAREHOUSE.PUBLIC.ASSETS_AGGREGATE AA
                   on VPP.ASSET_ID = AA.ASSET_ID
              join DATE_SERIES_CTE DSC
                   on dateadd(day, 1, DSC.DTE) between VPP.START_DATE and coalesce(VPP.END_DATE, '2099-12-31')
              left join (select LI.ASSET_ID,
                                date_trunc('month', I.BILLING_APPROVED_DATE) as                            BILLING_APPROVED_DATE,
                                listagg(I.INVOICE_ID, ', ') within group ( order by BILLING_APPROVED_DATE) INVOICE_ID,
                                listagg(I.INVOICE_NO, ', ') within group ( order by BILLING_APPROVED_DATE) INVOICE_NO,
                                LI.BRANCH_ID,
                                sum(LI.AMOUNT)                               as                            AMOUNT
                         from ES_WAREHOUSE.PUBLIC.INVOICES I
                                  join ES_WAREHOUSE.PUBLIC.LINE_ITEMS LI
                                       on I.INVOICE_ID = LI.INVOICE_ID
                         where LI.LINE_ITEM_TYPE_ID = 8
                         group by LI.ASSET_ID, date_trunc('month', I.BILLING_APPROVED_DATE), LI.BRANCH_ID) INV
                        on VPP.ASSET_ID = INV.ASSET_ID
                            and DSC.DTE = date_trunc('month', INV.BILLING_APPROVED_DATE)
              left join ES_WAREHOUSE.PUBLIC.MARKETS M
                        on INV.BRANCH_ID = M.MARKET_ID
              left join ES_WAREHOUSE.SCD.SCD_ASSET_COMPANY scd
                        on vpp.ASSET_ID = scd.ASSET_ID
                            -- do not use "and last_day(DSC.DTE) between scd.DATE_START::date and scd.DATE_END::date"
-- because it is all inclusive.  Assets that change companies
-- on the last day of the month will return two rows for that month since the old company's
-- end date will qualify, and the new company's start date will also qualify.  We only want the
-- newest company in this situation.
                            and last_day(DSC.DTE) >= scd.DATE_START::date
                            AND last_day(DSC.DTE) < scd.DATE_END::date
              left join ES_WAREHOUSE.PUBLIC.COMPANIES c
                        on scd.COMPANY_ID = c.COMPANY_ID
     where VPP.PAYOUT_PROGRAM_ID not in (4)
       and VPP.ASSET_PAYOUT_PERCENTAGE is not null
       and c.COMPANY_ID in (55525, 102983))
select *
from add_payouts
where DTE::date = dateadd('MONTH',-1,date_trunc(MONTH,current_date))::date
order by ASSET_ID
                ;;
  }
  dimension: asset_id {
    type: number
    sql: ${TABLE}."ASSET_ID" ;;
  }

  measure: asset_payout_amount {
    type: sum
    value_format_name: usd
    sql: ${TABLE}."ASSET_PAYOUT_AMOUNT" ;;
  }

  measure: revenue {
    type: sum
    value_format_name: usd
    sql: ${TABLE}."REVENUE" ;;
  }

  dimension: asset_payout_percentage {
    type: number
    sql: ${TABLE}."ASSET_PAYOUT_PERCENTAGE" ;;
  }

  dimension: class {
    type: string
    sql: ${TABLE}."CLASS" ;;
  }

  dimension: company_id {
    type: number
    sql: ${TABLE}."COMPANY_ID" ;;
  }

  dimension: company_name {
    type: string
    sql: ${TABLE}."COMPANY_NAME" ;;
  }

  dimension_group: dte {
    type: time
    timeframes: [
      raw,
      date,
      week,
      month,
      quarter,
      year
    ]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."DTE" ;;
  }

  dimension: invoice_id {
    type: string
    sql: ${TABLE}."INVOICE_ID" ;;
  }

  dimension: invoice_no {
    type: string
    sql: ${TABLE}."INVOICE_NO" ;;
  }

  dimension: market_id {
    type: number
    sql: ${TABLE}."MARKET_ID" ;;
  }

  dimension: market_name {
    type: string
    sql: ${TABLE}."MARKET_NAME" ;;
  }

  dimension_group: payout_month {
    type: time
    timeframes: [
      raw,
      date,
      week,
      month,
      quarter,
      year
    ]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."PAYOUT_MONTH" ;;
  }

  dimension: payout_month_string {
    type: string
    sql: ${payout_month_month} ;;
  }

  measure: count {
    type: count
    drill_fields: [company_name, market_name]
  }

  dimension: make {
    type: string
    sql: ${TABLE}."MAKE" ;;
  }

  dimension: model {
    type: string
    sql: ${TABLE}."MODEL" ;;
  }

  dimension_group: start_date {
    type: time
    timeframes: [
      raw,
      date,
      week,
      month,
      quarter,
      year
    ]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."START_DATE" ;;
  }
}
