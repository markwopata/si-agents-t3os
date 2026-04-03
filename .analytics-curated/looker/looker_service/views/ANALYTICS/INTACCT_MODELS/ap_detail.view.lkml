view: ap_detail {
  sql_table_name: "ANALYTICS"."INTACCT_MODELS"."AP_DETAIL" ;;
  drill_fields: [pk_ap_detail_id]

  dimension: pk_ap_detail_id {
    primary_key: yes
    type: number
    sql: ${TABLE}."PK_AP_DETAIL_ID" ;;
  }
  dimension: account_name {
    type: string
    sql: ${TABLE}."ACCOUNT_NAME" ;;
  }
  dimension: account_number {
    type: string
    sql: ${TABLE}."ACCOUNT_NUMBER" ;;
  }
  dimension: amount {
    type: number
    value_format_name: usd
    sql: ${TABLE}."AMOUNT" ;;
  }
  dimension: ap_header_type {
    type: string
    sql: ${TABLE}."AP_HEADER_TYPE" ;;
  }
  dimension: ap_line_type {
    type: string
    sql: ${TABLE}."AP_LINE_TYPE" ;;
  }
  dimension: bank_account {
    type: string
    sql: ${TABLE}."BANK_ACCOUNT" ;;
  }
  dimension: created_by_name {
    type: string
    sql: ${TABLE}."CREATED_BY_NAME" ;;
  }
  dimension: created_by_username {
    type: string
    sql: ${TABLE}."CREATED_BY_USERNAME" ;;
  }
  dimension: customer_id {
    type: string
    sql: ${TABLE}."CUSTOMER_ID" ;;
  }
  dimension: customer_is_related_party {
    type: yesno
    sql: ${TABLE}."CUSTOMER_IS_RELATED_PARTY" ;;
  }
  dimension: customer_name {
    type: string
    sql: ${TABLE}."CUSTOMER_NAME" ;;
  }
  dimension: debit_credit_sign {
    type: number
    sql: ${TABLE}."DEBIT_CREDIT_SIGN" ;;
  }
  dimension: department_id {
    type: string
    sql: ${TABLE}."DEPARTMENT_ID" ;;
  }
  dimension: department_name {
    type: string
    sql: ${TABLE}."DEPARTMENT_NAME" ;;
  }
  dimension: description {
    type: string
    sql: ${TABLE}."DESCRIPTION" ;;
  }
  dimension: description2 {
    type: string
    sql: ${TABLE}."DESCRIPTION2" ;;
  }
  dimension: document_number {
    type: string
    sql: ${TABLE}."DOCUMENT_NUMBER" ;;
  }
  dimension_group: due {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."DUE_DATE" ;;
  }
  dimension: entity_id {
    type: string
    sql: ${TABLE}."ENTITY_ID" ;;
  }
  dimension: entity_name {
    type: string
    sql: ${TABLE}."ENTITY_NAME" ;;
  }
  dimension: expense_account_number {
    type: string
    sql: ${TABLE}."EXPENSE_ACCOUNT_NUMBER" ;;
  }
  dimension: expense_type {
    type: string
    sql: ${TABLE}."EXPENSE_TYPE" ;;
  }
  dimension: financial_entity {
    type: string
    sql: ${TABLE}."FINANCIAL_ENTITY" ;;
  }
  dimension: fk_ap_header_id {
    type: number
    sql: ${TABLE}."FK_AP_HEADER_ID" ;;
  }
  dimension: fk_ap_line_id {
    type: number
    sql: ${TABLE}."FK_AP_LINE_ID" ;;
  }
  dimension: fk_created_by_user_id {
    type: number
    sql: ${TABLE}."FK_CREATED_BY_USER_ID" ;;
  }
  dimension: fk_expense_type_id {
    type: number
    sql: ${TABLE}."FK_EXPENSE_TYPE_ID" ;;
  }
  dimension: fk_parent_ap_line_id {
    type: number
    sql: ${TABLE}."FK_PARENT_AP_LINE_ID" ;;
  }
  dimension: fk_updated_by_user_id {
    type: number
    sql: ${TABLE}."FK_UPDATED_BY_USER_ID" ;;
  }
  dimension_group: gl {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."GL_DATE" ;;
  }
  dimension_group: invoice {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."INVOICE_DATE" ;;
  }
  dimension: invoice_memo {
    type: string
    sql: ${TABLE}."INVOICE_MEMO" ;;
  }
  dimension: invoice_number {
    type: string
    sql: ${TABLE}."INVOICE_NUMBER" ;;
  }
  dimension: invoice_state {
    type: string
    sql: ${TABLE}."INVOICE_STATE" ;;
  }
  dimension: item_id {
    type: string
    sql: ${TABLE}."ITEM_ID" ;;
  }
  dimension: line_description {
    type: string
    sql: ${TABLE}."LINE_DESCRIPTION" ;;
  }
  dimension: line_number {
    type: number
    sql: ${TABLE}."LINE_NUMBER" ;;
  }
  dimension: offset_account_name {
    type: string
    sql: ${TABLE}."OFFSET_ACCOUNT_NAME" ;;
  }
  dimension: offset_account_number {
    type: string
    sql: ${TABLE}."OFFSET_ACCOUNT_NUMBER" ;;
  }
  dimension: payment_type {
    type: string
    sql: ${TABLE}."PAYMENT_TYPE" ;;
  }
  dimension: secondary_line_number {
    type: number
    sql: ${TABLE}."SECONDARY_LINE_NUMBER" ;;
  }
  dimension: source_document_name {
    type: string
    sql: ${TABLE}."SOURCE_DOCUMENT_NAME" ;;
  }
  dimension: updated_by_name {
    type: string
    sql: ${TABLE}."UPDATED_BY_NAME" ;;
  }
  dimension: updated_by_username {
    type: string
    sql: ${TABLE}."UPDATED_BY_USERNAME" ;;
  }
  dimension: url_concur {
    type: string
    sql: ${TABLE}."URL_CONCUR" ;;
  }
  dimension: url_invoice {
    type: string
    sql: ${TABLE}."URL_INVOICE" ;;
  }
  dimension: vendor_id {
    type: string
    sql: ${TABLE}."VENDOR_ID" ;;
  }
  dimension: url_concur_with_link {
    type: string
    sql: ${url_concur} ;;
    html: <a href="{{ url_concur._value }}" target="new" style="color: #0063f3; text-decoration: underline;">{{source_document_name._value }}</a>;;
  }
  dimension: url_invoice_with_link {
    type: string
    sql: ${url_invoice} ;;
    html: <a href="{{ url_invoice._value }}" target="new" style="color: #0063f3; text-decoration: underline;">{{url_invoice._value }}</a>;;
  }
  dimension: vendor_is_related_party {
    type: yesno
    sql: ${TABLE}."VENDOR_IS_RELATED_PARTY" ;;
  }
  dimension: vendor_name {
    type: string
    sql: ${TABLE}."VENDOR_NAME" ;;
  }
  measure: count {
    type: count
    drill_fields: [detail_market*]
  }
  measure: sum_service_outside_labor {
    type: sum
    value_format_name: usd
    # sql: ${TABLE}."AMOUNT" ;;
    sql: CASE WHEN ${TABLE}.ACCOUNT_NUMBER = 6302 THEN ${TABLE}.AMOUNT END ;;
  }
  measure: avg_service_outside_labor {
    type: average
    value_format_name: usd
    # sql: ${TABLE}."AMOUNT" ;;
    sql: CASE WHEN ${TABLE}.ACCOUNT_NUMBER = 6302 THEN ${TABLE}.AMOUNT END ;;
  }
  measure: sum_amount {
    type: sum
    value_format_name: usd
    sql: ${TABLE}."AMOUNT" ;;
  }
  measure: sum_amount_region_drill {
    label: "Sum Amount"
    type: sum
    value_format_name: usd
    sql: ${TABLE}."AMOUNT" ;;
    drill_fields: [detail_region*]
  }
  measure: sum_amount_market_drill {
    label: "Sum Amount"
    hidden: yes
    type: sum
    value_format_name: usd
    sql: ${TABLE}."AMOUNT" ;;
    drill_fields: [detail_market*]
  }

  dimension: account_is_misc_spend {
    type: yesno
    description: "Misc Spend Accounts for the Supplier Performance and Vendor Scorecard Dashboards. List managed by Kaelen Jones"
    sql:
      iff(
        coalesce(${expense_account_number}, ${account_number}) not in (1301, 1307, 1316, 6026, 2303, 2390) -- Restarting Misc spend designations in 11/2025 --TA
          --6306
          --, 7614
          --, 7403
          --, 7400
          --, 1501
          --, 1505
          --, 1610
          --, 5021
          --, 6007
          --, 6302
          --, 6307
          --, 6327
          --, 6305
          --, 6320
          --, 6016
          --, 7304
          --, 6014
          --, 1504
          --, 6032
          --, 1310
          --, 6300)
          , true
          , false);;
  }

  dimension: is_supplier_performance_account {
    type: yesno
    description: "Spend Accounts for the Supplier Performance and Vendor Scorecard Dashboards. List managed by Kaelen Jones"
    sql:
      iff(
        coalesce(${expense_account_number}, ${account_number}) not in (1307, 1316, 6026, 2303, 2390) -- Restarting Misc spend designations in 11/2025 --TA
          --6306
          --, 7614
          --, 7403
          --, 7400
          --, 1501
          --, 1505
          --, 1610
          --, 5021
          --, 6007
          --, 6302
          --, 6307
          --, 6327
          --, 6305
          --, 6320
          --, 6016
          --, 7304
          --, 6014
          --, 1504
          --, 6032
          --, 1310
          --, 6300
          --, 1301)
          , true
          , false);;
  }

  measure: supplier_performance_total {
    type: sum
    value_format_name: usd_0
    filters: [is_supplier_performance_account: "yes"]
    sql: ${TABLE}.amount ;;
  }

  measure: current_year_supplier_performance_total {
    type: sum
    value_format_name: usd_0
    filters: [is_supplier_performance_account: "yes", is_current_year: "yes"]
    sql: ${TABLE}.amount ;;
  }

  dimension: days_into_year {
    type: number
    sql: datediff(day, date_trunc(year, current_date), current_date) ;;
  }
  dimension: days_left_in_year {
    type: number
    sql: datediff(day, current_date, date_trunc(year, dateadd(year, 1, current_date))) ;;
  }
  dimension: is_current_year {
    type: yesno
    sql: ${gl_year} = year(current_date) ;;
  }
  measure: remaining_year_amount_projection {
    type: number
    value_format_name: usd
    sql: (${current_year_supplier_performance_total} / ${days_into_year}) * ${days_left_in_year}  ;;
  }

  measure: sum_amount_supplier_scorecard_drill1 {
    type: sum
    value_format_name: usd_0
    sql: ${TABLE}."AMOUNT" ;;
    drill_fields: [
        glaccount.accountno
        , glaccount.title
        , sum_amount_supplier_scorecard_drill2
        ]
  }

  measure: sum_amount_supplier_scorecard_drill2 {
    label: "Sum Amount Invoice Detail"
    type: sum
    value_format_name: usd_0
    sql: ${TABLE}."AMOUNT" ;;
    drill_fields: [
      vendor_id
      , vendor_name
      , department_name
      , invoice_date
      , document_number
      , invoice_number
      , line_description
      , amount
      , glaccount.accountno
      , url_concur_with_link
      , url_invoice_with_link
    ]
  }

  # ----- Sets of fields for drilling ------
  set: detail_region {
    fields: [
            market_region_xwalk.market_name,
            sum_amount_market_drill
            ]
  }
  set: detail_market {
    fields: [
            market_region_xwalk.market_name,
            updated_by_name,
            vendor_name,
            ap_header_type,
            document_number,
            source_document_name,
            invoice_number,
            amount,
            url_concur_with_link,
            url_invoice_with_link
            ]
  }
  set: details_needs_deleted {
    fields: [
            ap_line_type,
            fk_expense_type_id,
            fk_parent_ap_line_id,
            gl_date,
            market_region_xwalk.market_name,
            updated_by_name,
            vendor_name,
            ap_header_type,
            document_number,
            source_document_name,
            invoice_number,
            amount,
            url_concur_with_link,
            url_invoice_with_link

            ]
  }
}

view: ap_detail_part_spend {
  derived_table: {
    sql:
      select vendor_id
        , date_trunc(month, gl_date) as invoice_month
        , sum(iff(expense_account_number = 1301,amount,0)) as part_spend
        , sum(iff(expense_account_number = 1310,amount,0)) as freight_spend
      from ${ap_detail.SQL_TABLE_NAME}
      where expense_account_number in (1301,1310)
        and ap_header_type ilike 'apbill'
      group by vendor_id, invoice_month
      ;;
  }

  dimension: invoice_month {
    type: date_month
    sql: ${TABLE}.invoice_month ;;
  }
  dimension: vendor_id {
    type: string
    sql: ${TABLE}.vendor_id ;;
  }
  dimension: primary_key {
    type: string
    primary_key: yes
    sql: concat(${invoice_month}, ${vendor_id}) ;;
  }
  dimension: part_spend {
    type: number
    value_format_name: usd_0
    sql: ${TABLE}.part_spend ;;
  }
  dimension: freight_spend {
    type: number
    value_format_name: usd_0
    sql: ${TABLE}.freight_spend ;;
  }
  measure: total_freight_spend {
    type: sum
    value_format_name: usd_0
    sql: ${freight_spend} ;;
  }
  measure: parts_spend {
    type: sum
    value_format_name: usd_0
    sql: ${part_spend} ;;
  }
  measure: freight_part_spend_ratio {
    type: number
    value_format_name: percent_1
    sql: ${total_freight_spend} / nullifzero(${parts_spend});;
  }

}

view: ap_detail_total_daily_spend {
  derived_table: {
    sql:
      select apd.gl_date::Date as gl_date
        , apd.vendor_id
        , coalesce(expense_account_number, account_number) as account_no
        , apd.department_name
        , sum(apd.amount) as total_spend
      from ${ap_detail.SQL_TABLE_NAME} apd
      join ANALYTICS.INTACCT.GLACCOUNT gl
        on gl.accountno = coalesce(apd.expense_account_number, apd.account_number)
      where apd.ap_header_type ilike 'apbill'
      group by 1,2,3,4
      ;;
  }

  dimension: invoice_date {
    type: date
    description: "Later changed to GL Date but left dimension naming as is for simplicity"
    sql: ${TABLE}.gl_date ;;
  }

  dimension: invoice_year {
    type: number
    description: "Later changed to GL Date but left dimension naming as is for simplicity"
    sql: year(${TABLE}.gl_date) ;;
  }

  dimension: date_is_minus_3_years {
    type: yesno
    sql: iff(${invoice_year} = year(dateadd(year, -3, current_date)), true, false) ;;
  }

  dimension: date_is_minus_2_years {
    type: yesno
    sql: iff(${invoice_year} = year(dateadd(year, -2, current_date)), true, false) ;;
  }

  dimension: date_is_last_year {
    type: yesno
    sql: iff(${invoice_year} = year(dateadd(year, -1, current_date)), true, false) ;;
  }

  dimension: date_is_this_year {
    type: yesno
    sql: iff(${invoice_year} = year(current_date), true, false) ;;
  }

  dimension: vendor_id {
    type: string
    sql: ${TABLE}.vendor_id ;;
  }

  dimension: account_no {
    type: number
    value_format_name: id
    sql: ${TABLE}.account_no ;;
  }

  dimension: department_name {
    type: string
    sql: ${TABLE}.department_name ;;
  }

  dimension: primary_key {
    type: string
    primary_key: yes
    sql: concat(${invoice_date}, ${vendor_id}, ${account_no}, ${department_name}) ;;
  }

  dimension: total_spend {
    type: number
    value_format_name: usd_0
    sql: ${TABLE}.total_spend ;;
  }

  measure: sum_total_spend {
    label: "Total Spend"
    type: sum
    value_format_name: usd_0
    sql: ${total_spend} ;;
  }

  measure: minus_3_year_spend {
    label: "Parts and Misc Spend 3 Years Ago"
    type: sum
    value_format_name: usd_0
    filters: [date_is_minus_3_years: "yes", ap_detail_total_daily_spend_gl_account.is_supplier_performance_account: "yes"]
    sql: ${total_spend} ;;
  }

  measure: minus_2_year_spend {
    label: "Parts and Misc Spend 2 Years Ago"
    type: sum
    value_format_name: usd_0
    filters: [date_is_minus_2_years: "yes", ap_detail_total_daily_spend_gl_account.is_supplier_performance_account: "yes"]
    sql: ${total_spend} ;;
  }

  measure: last_year_spend {
    label: "Parts and Misc Spend Last Year"
    type: sum
    value_format_name: usd_0
    filters: [date_is_last_year: "yes", ap_detail_total_daily_spend_gl_account.is_supplier_performance_account: "yes"]
    sql: ${total_spend} ;;
  }

  measure: 1307_last_year_spend {
    label: "Spend in Pre-Rental Assets Last Year"
    type: sum
    value_format_name: usd_0
    filters: [date_is_last_year: "yes", account_no: "1307"]
    sql: ${total_spend} ;;
  }

  measure: ytd_spend {
    label: "Parts and Misc Spend YTD"
    type: sum
    value_format_name: usd_0
    filters: [date_is_this_year: "yes", ap_detail_total_daily_spend_gl_account.is_supplier_performance_account: "yes"]
    sql: ${total_spend} ;;
  }

  measure: parts_and_misc_spend {
    label: "Parts and Misc Spend"
    type: sum
    value_format_name: usd_0
    filters: [ap_detail_total_daily_spend_gl_account.is_supplier_performance_account: "yes"]
    sql: ${total_spend} ;;
  }

  measure: 1307_ytd_spend {
    label: "Spend in Pre-Rental Assets YTD"
    type: sum
    value_format_name: usd_0
    filters: [date_is_this_year: "yes", account_no: "1307"]
    sql: ${total_spend} ;;
  }

  measure: 1307_spend {
    label: "Spend in Pre-Rental Assets"
    type: sum
    value_format_name: usd_0
    filters: [account_no: "1307"]
    sql: ${total_spend} ;;
  }

  dimension: days_into_year {
    type: number
    sql: datediff(day, date_trunc(year, current_date), current_date) ;;
  }
  dimension: days_left_in_year {
    type: number
    sql: datediff(day, current_date, date_trunc(year, dateadd(year, 1, current_date))) ;;
  }
  measure: total_year_spend_projection {
    label: "Full Year Parts and Misc Spend Projection"
    type: number
    value_format_name: usd_0
    sql: ((${ytd_spend} / ${days_into_year}) * ${days_left_in_year}) + ${ytd_spend}  ;;
  }
  measure: perc_change {
    label: "% Change Last Year to Projected Current Year Spend"
    type: number
    value_format_name: percent_1
    sql: (${total_year_spend_projection} - ${last_year_spend}) / nullifzero(${last_year_spend}) ;;
  }
}

view: service_year {
  derived_table: {
    sql:
    SELECT
        m.market_id,
        EXTRACT(YEAR FROM ap.invoice_date) AS year,
        SUM(ap.amount) AS sum_service
      FROM ANALYTICS.INTACCT_MODELS.AP_DETAIL ap
      LEFT JOIN fleet_optimization.gold.dim_markets_fleet_opt m
        ON TRY_CAST(ap.department_id AS NUMBER) = m.market_id
    WHERE ap.account_number = 6302
      GROUP BY 1,2 ;;
  }
  dimension: market_year_key {
    primary_key: yes
    type: string
    sql: CONCAT(${market_id}, '-', ${year}) ;;
  }
  dimension: market_id {
    type: number
    sql: ${TABLE}.market_id ;;
  }
  dimension: year {
    type: number
    sql: ${TABLE}.year ;;
  }
  dimension: sum_service {
    type: number
    value_format_name: usd
    sql: ${TABLE}.sum_service ;; }
}

view: vendor_ap_detail_score {
  derived_table: {
    sql:
with vendor_oec as (
select v.mapped_vendor_name
    , sum(zeroifnull(rental_fleet_oec)) / count(distinct daily_timestamp::DATE) as avg_oec
from ANALYTICS.ASSETS.INT_ASSET_HISTORICAL a
join (
        select vendorid
            , vendor_name
            , mapped_vendor_name
            , vendor_type
            , iff(mapped_vendor_name <> 'Doosan / Bobcat', mapped_vendor_name, 'DOOSAN') as join1
            , iff(join1 = 'DOOSAN', 'BOBCAT', null) as join2
        from "ANALYTICS"."PARTS_INVENTORY"."TOP_VENDOR_MAPPING" v
        where primary_vendor ilike 'yes' and mapped_vendor_name is not null
        ) v
    on upper(join1) = a.make or upper(join2) = a.make
where a.daily_timestamp::DATE >= dateadd(month, -12, date_trunc(month, current_date))
group by 1
having avg_oec > 0
)

, agg as (
    select tvm.mapped_vendor_name
        , tvm.vendor_type
        , sum(iff(apd.expense_account_number = 1301,amount,0)) as part_spend
        , sum(iff(apd.expense_account_number <> 1301,amount,0)) as misc_spend
        , vo.avg_oec
    from ${ap_detail.SQL_TABLE_NAME}  apd
    left join ANALYTICS.PARTS_INVENTORY.TOP_VENDOR_MAPPING tvm
        on tvm.vendorid = apd.vendor_id
    left join vendor_oec vo
        on vo.mapped_vendor_name = tvm.mapped_vendor_name
    where expense_account_number in (
        1301 --Parts Spend
        , 6306 --Here and down are the hardcoded Misc Spend accounts
        , 7614
        , 7403
        , 7400
        , 1501
        , 1505
        , 1610
        , 5021
        , 6007
        , 6302
        , 6307
        , 6327
        , 6305
        , 6320)
        and ap_header_type ilike 'apbill'
        and apd.gl_date >= dateadd(month, -12, date_trunc(month, current_date))
    group by 1,2, vo.avg_oec
)

select v.vendorid as vendor_id
    , (a.part_spend / a.avg_oec) as vendor_part_spend_oec
    , (sum(zeroifnull(pa.part_spend)) / sum(pa.avg_oec)) as peers_part_spend_oec
    , least(coalesce(peers_part_spend_oec, 1), 0.0025) as part_spend_oec_target
    , iff(((part_spend_oec_target / nullifzero(vendor_part_spend_oec)) * (1/14)) > (1/14), (1/14), (part_spend_oec_target / nullifzero(vendor_part_spend_oec)) * (1/14)) as part_spend_oec_score
    , iff(((part_spend_oec_target / nullifzero(vendor_part_spend_oec)) * 10) > 10, 10, (part_spend_oec_target / nullifzero(vendor_part_spend_oec)) * 10 ) as part_spend_oec_score10

    , (a.misc_spend / a.avg_oec) as vendor_misc_spend_oec
    , (sum(zeroifnull(pa.misc_spend)) / sum(pa.avg_oec)) as peers_misc_spend_oec
    , least(coalesce(peers_misc_spend_oec, 1), 0.0015) as misc_spend_oec_target
    , iff(((misc_spend_oec_target / nullifzero(vendor_misc_spend_oec)) * (1/14)) > (1/14), (1/14), (misc_spend_oec_target / nullifzero(vendor_misc_spend_oec)) * (1/14)) as misc_spend_oec_score
    , iff(((misc_spend_oec_target / nullifzero(vendor_misc_spend_oec)) * 10) > 10, 10, (misc_spend_oec_target / nullifzero(vendor_misc_spend_oec)) * 10 ) as misc_spend_oec_score10
from agg a
left join agg pa
    on pa.mapped_vendor_name <> a.mapped_vendor_name
        and pa.vendor_type = a.vendor_type
left join "ANALYTICS"."PARTS_INVENTORY"."TOP_VENDOR_MAPPING" v
    on primary_vendor ilike 'yes'
        and v.mapped_vendor_name = a.mapped_vendor_name
group by 1,2, vendor_misc_spend_oec
;;
  }
  dimension: vendor_id {
    type: string
    sql: ${TABLE}.vendor_id ;;
  }
  dimension: vendor_part_spend_oec {
    type: number
    value_format_name: percent_2
    sql: ${TABLE}.vendor_part_spend_oec ;;
  }
  dimension: peers_part_spend_oec {
    type: number
    value_format_name: percent_2
    sql: ${TABLE}.peers_part_spend_oec ;;
  }
  dimension: part_spend_oec_target {
    type: number
    value_format_name: percent_2
    sql: ${TABLE}.part_spend_oec_target ;;
  }
  dimension: part_spend_oec_score {
    type: number
    value_format_name: decimal_2
    sql: coalesce(${TABLE}.part_spend_oec_score, 0) ;;
  }
  dimension: part_spend_oec_score10 {
    type: number
    value_format_name: decimal_1
    sql: coalesce(${TABLE}.part_spend_oec_score10, 0) ;;
  }
  dimension: vendor_misc_spend_oec {
    type: number
    value_format_name: percent_2
    sql: ${TABLE}.vendor_misc_spend_oec ;;
  }
  dimension: peers_misc_spend_oec {
    type: number
    value_format_name: percent_2
    sql: ${TABLE}.peers_misc_spend_oec ;;
  }
  dimension: misc_spend_oec_target {
    type: number
    value_format_name: percent_2
    sql: ${TABLE}.misc_spend_oec_target ;;
  }
  dimension: misc_spend_oec_score {
    type: number
    value_format_name: decimal_2
    sql: coalesce(${TABLE}.misc_spend_oec_score, 0) ;;
  }
  dimension: misc_spend_oec_score10 {
    type: number
    value_format_name: decimal_1
    sql: coalesce(${TABLE}.misc_spend_oec_score10, 0) ;;
  }
}
