view: concor_pl_bs {
  derived_table: {
    sql:
with balance_sheet_data as (select date_trunc(month, entry_date) as gl_date,
                                   case
                                       when account_number in
                                            (1149, 1137, 1117, 1071, 1072, 1400, 1214, 1204, 1400, 1724, 1064,
                                             1723, 1178, 1171, 1141, 1173, 1177, 1203, 1617, 1722, 1120, 1176)
                                           then '1. Assets'
                                       when account_number in
                                            (2320, 1204, 2516, 1723, 2012, 2518, 2012, 2236, 2700, 1700, 2000, 2512,
                                             2513, 2703, 2321)
                                           then '2. Liabilities'
                                       when account_number in (3100, 3111, 3001, 3900, 1172, 1171) then '3. Equity'
                                       end                       as account_type,
                                   'balancesheet'                as financial_statement,
                                   case
                                       when account_number in
                                            (7414, 1149, 1137, 1117, 1071, 1072, 1400, 1214, 1204, 1141, 1203, 1120,
                                             1176)
                                           then '1. Current Assets'
                                       when account_number in
                                            (1400, 1724, 1064, 1723, 1178, 1171, 1173, 1177, 1617, 1722)
                                           then '2. Other Assets'
                                       when account_number in (2012, 2236, 2000) then '3. Accounts Payable'
                                       when account_number in
                                            (2320, 1204, 2516, 1723, 2012, 2518, 2700, 1700, 2512, 2513, 2703, 2321)
                                           then '4. Other Liabilities'
                                       when account_number in (3100, 3111, 3001, 3900, 1172, 1171) then '5. Equity'
                                       end                       as sub_account_type,
                                   account_number,
                                   account_name,
                                   amount
                            from analytics.intacct_models.gl_detail
                            where entity_id = 'S1'
                              and account_type = 'balancesheet')

   , balance_sheet_total as (select gl_date
                                  , account_type
                                  , financial_statement
                                  , sub_account_type
                                  , account_number
                                  , account_name
                                  , sum(sum(amount))
                                      over (partition by account_type, sub_account_type, account_number
                                            order by gl_date rows between unbounded preceding and current row) as amount
                             from balance_sheet_data
                             group by all
                             order by gl_date desc, account_type, sub_account_type,
                                      account_number)

, income_statement as (select date_trunc(month, entry_date) as gl_date,
                                 case
                                     when account_number in (7414,7412) then '1. Underwriting Income'
                                     when account_number in (7416, 7417, 7415, 7413) then '2. Underwriting Expenses'
                                     when account_number in (7105, 7402, 7415, 8311, 7100,7004)
                                         then '3. General and Administrative Expenses'
                                     when account_number in (5980, 5996, 5981, 8311,8307) then '4. Investment Income'
                                     when account_number in (7803, 7807) then '5. Taxes'
                                     end                       as account_type,
                                 'incomestatement'             as financial_statement,
                                 case
                                     when account_number in (7414,7412) then 'Premium Income'
                                     when account_number in (7416, 7417, 7415, 7413) then 'Cost of Goods Sold - COGS'
                                     when account_number in (7105, 7402, 7415, 8311, 7100,7004) then 'Operating Expenses'
                                     when account_number in (5980, 5996, 5981, 8311,8307) then 'Investment Income/Expenses'
                                     when account_number in (7803, 7807) then 'Tax Expenses'
                                     end                       as sub_account_type,
                                 account_number,
                                 account_name,
                                 sum(amount)                   as amount
                          from analytics.intacct_models.gl_detail gd
                          where account_type = 'incomestatement'
                            and gd.entity_id = 'S1'
                          group by all
                          order by date_trunc(month, entry_date) desc, account_type, sub_account_type,
                                   account_number)

select *
from income_statement as ins
inner join analytics.gs.plexi_periods plexi_periods
    on date_trunc(month, ins.gl_date::date) = plexi_periods.trunc
where 1=1
and ins.gl_date between add_months((select trunc from analytics.gs.plexi_periods where {% condition Period %} display {% endcondition %}),-11)::date and (select trunc from analytics.gs.plexi_periods where {% condition Period %} display {% endcondition %})::date --selecting LTM

union all

select *
from balance_sheet_total bst
  inner join analytics.gs.plexi_periods plexi_periods
    on date_trunc(month, bst.gl_date::date) = plexi_periods.trunc
where 1=1
and bst.gl_date between add_months((select trunc from analytics.gs.plexi_periods where {% condition Period %} display {% endcondition %}),-11)::date and (select trunc from analytics.gs.plexi_periods where {% condition Period %} display {% endcondition %})::date--to get total amounts, sum since inception
order by financial_statement, account_type, sub_account_type, account_number;;

  }

  filter: Period {
    suggest_dimension: plexi_periods.display
    suggest_explore: plexi_periods
  }

  dimension: gl_date {
    type: date
    convert_tz: no
    sql: ${TABLE}."GL_DATE" ;;
  }

  dimension_group: gl_date {
    type: time
    timeframes: [month, quarter, year, raw]
    convert_tz: no
    sql: ${TABLE}."GL_DATE" ;;
  }

  dimension: account_type {
    type: string
    label: "Account Type"
    sql: ${TABLE}."ACCOUNT_TYPE" ;;
  }

  dimension: financial_statement {
    type: string
    label: "Financial Statement"
    sql: ${TABLE}."FINANCIAL_STATEMENT" ;;
  }

  dimension: sub_account_type {
    type: string
    label: "Sub Account Type"
    sql: ${TABLE}."SUB_ACCOUNT_TYPE" ;;
  }

  dimension: account_number {
    type: string
    label: "Account Number"
    sql: ${TABLE}."ACCOUNT_NUMBER" ;;
  }

  dimension: account_name {
    type: string
    label: "Account Name"
    sql: ${TABLE}."ACCOUNT_NAME" ;;
  }

  measure: amount {
    type: sum
    value_format: "$#,##0;-$#,##0;-"
    sql: ${TABLE}."AMOUNT" ;;
  }

}
