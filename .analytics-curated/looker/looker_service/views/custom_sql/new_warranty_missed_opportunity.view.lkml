view: warranty_missed_opportunity {
 sql_table_name: "ANALYTICS"."WARRANTIES"."NEW_MISSED_WARRANTY_OPPORTUNITY_TMP" ;;

dimension: likely_missed_opportunity {
  type: yesno
  sql: ${TABLE}.likely_missed_opportunity;;
}

dimension: reviewed {
  type: yesno
  sql: ${TABLE}.reviewed ;;
}

dimension: work_order_id {
  type: number
  value_format_name: id
  sql: ${TABLE}.work_order_id ;;
  html: <font color="blue "><u><a href="https://app.estrack.com/#/service/work-orders/{{ work_order_id._value }}" target="_blank">{{ work_order_id._value }}</a></font></u> ;;
}

dimension: market_name {
  type: string
  sql: ${TABLE}.market_name ;;
}

dimension: originator {
  type: string
  sql: ${TABLE}.originator ;;
}

dimension: date_completed {
  type: date
  sql: ${TABLE}.date_completed ;;
}

dimension: wo_date_billed {
  type: date
  sql: ${TABLE}.wo_date_billed ;;
}

dimension: invoice_no {
  type: string
  sql: ${TABLE}.invoice ;;
  html: <font color="blue "><u><a href="https://admin.equipmentshare.com/#/home/transactions/invoices/{{ invoice_no._value }}" target="_blank">{{ invoice_no._value }}</a></font></u> ;;
}

dimension: internal_billing {
  type: yesno
  sql: ${TABLE}.internal_billing ;;
}

dimension: warranty_billing {
  type: yesno
  sql: ${TABLE}.warranty_billing ;;
}

dimension: billing_date {
  type: date
  sql: ${TABLE}.billing_date ;;
}

  dimension: billed_company {
    type: string
    sql: ${TABLE}.billed_company ;;
}

dimension: billing_type {
  type: string
  sql: ${TABLE}.billing_type ;;
}

  dimension: wo_description {
    type: string
    sql: ${TABLE}.wo_description ;;
  }

  dimension: asset_id {
    type: number
    value_format_name: id
    sql: ${TABLE}.asset_id ;;
  }

  dimension: make {
    type: string
    sql: ${TABLE}.make ;;
  }

  dimension: model {
    type: string
    sql: ${TABLE}.model ;;
  }

  dimension: asset_year {
    type: number
    value_format_name: id
    sql: ${TABLE}.year ;;
  }

  dimension: class {
    type: string
    sql: ${TABLE}.class ;;
  }

  dimension: hours_at_service {
    type: number
    sql: ${TABLE}.hours_at_service ;;
  }

  dimension: warranties {
    type: string
    sql: ${TABLE}.warranties ;;
  }

  dimension: warranties_description {
    type: string
    sql: ${TABLE}.warranties_description ;;
  }

  dimension: warrantable_parts_used {
    type: yesno
    sql: ${TABLE}.warrantable_parts_used ;;
  }

  dimension: warrantable_parts {
    type: number
    sql: ${TABLE}.warrantable_parts ;;
  }

  dimension: parts {
    type: string
    sql: ${TABLE}.parts ;;
  }

  dimension: part_descriptions {
    type: string
    sql: ${TABLE}.parts_descriptions ;;
  }

  dimension: warrantable_parts_cost {
    type: number
    value_format_name: usd_0
    sql: ${TABLE}.warrantable_part_cost ;;
  }

  dimension: estimated_labor {
    type: number
    value_format_name: usd_0
    sql: ${TABLE}.estimated_labor;;
  }

  dimension: total_cost {
    type: number
    value_format_name: usd
    sql: ${TABLE}.total_cost ;;
  }

  dimension: last_tech_entry {
    type: date
    sql: ${TABLE}.last_tech_entry ;;
  }

  dimension: tags {
    type: string
    sql: ${TABLE}.tags ;;
  }
}

view: new_missed_warranty_by_quarter {
  derived_table: {
    sql: select date_trunc(quarter, date_completed) as quarter
    , make
    , sum(total_cost) as missed_opportunity
from ${warranty_missed_opportunity.SQL_TABLE_NAME}
where likely_missed_opportunity =  true
group by quarter, make ;;
  }

dimension: quarter {
  type: date
  sql: ${TABLE}.quarter ;;
}

dimension: make {
  type: string
  sql: ${TABLE}.make ;;
}

dimension: missed_opportunity {
  type: number
  value_format_name: usd_0
  sql: ${TABLE}.missed_opportunity ;;
}
}

view: missed_opportunity_weekly_stats {
  derived_table: {
    sql: with generated_dates as (
    SELECT dateadd(week, '-' || row_number() over (order by null), dateadd('week', +1, date_trunc('week', current_date()))
        ) as generated_date
    FROM table(generator(rowcount => 1000))
)

, work_order_reviewed as (
    select wos.make
        , ca.parameters:work_order_id wo_id
        , min(ca.date_created::DATE) as reviewed_date
        , wos.warranty_billing
        , wos.total_cost
        , zeroifnull(wi.total_amt) as warranty_billed
    from ES_WAREHOUSE.PUBLIC.COMMAND_AUDIT ca
    join ${warranty_missed_opportunity.SQL_TABLE_NAME} wos
        on wos.work_order_id = ca.parameters:work_order_id
    left join ANALYTICS.WARRANTIES.WARRANTY_INVOICES wi
        on wi.invoice_id::STRING = wos.invoice
    where ((SUBSTRING(ca.parameters:changes:description, 1, 2) = 'HH')
        or (SUBSTRING(ca.parameters:changes:description, 1, 2) = 'SS'))
        and wos.wo_date_billed is not null
    group by wo_id, wos.warranty_billing, wos.total_cost, warranty_billed, wos.make
)

, nmi as (
    select distinct wo_id
        , total_cost
    from ES_WAREHOUSE.PUBLIC.COMMAND_AUDIT ca
    join work_order_reviewed wos
        on wos.wo_id = ca.parameters:work_order_id
    where command = 'CreateAndAssociateCompanyTag'
        and parameters:tag_name ilike 'Needs More Information'
)

    select gd.generated_date
        , wos.make
        , count(wos.wo_id) as reviewed_wo
        , round(sum(wos.total_cost), 2) as warranty_value_reviewed --bc only warrantable part cost included
        , count(iff(wos.warranty_billing = true, wos.wo_id, null)) as billed_missed_opp
        , round(sum(warranty_billed), 2) as warranty_billed
        , count(nmi.wo_id) as tagged_needs_more_info
        , round(sum(nmi.total_cost), 2) as value_tagged
    from generated_dates gd
    join work_order_reviewed wos
        on wos.reviewed_date < generated_date
        and wos.reviewed_date >= dateadd(week, -1, generated_date)
    left join nmi
        on nmi.wo_id = wos.wo_id
    group by gd.generated_date, wos.make ;;
  }

  dimension: report_date {
    type: date
    sql: ${TABLE}.generated_date ;;
  }

  dimension: make {
    type: string
    sql: ${TABLE}.make ;;
  }

  dimension: reviewed_wo {
    type: number
    sql: ${TABLE}.reviewed_wo ;;
  }

  measure: wo_reviewed {
    type: sum
    sql: ${reviewed_wo} ;;
  }

  dimension: reviewed_wo_warrantable_value {
    type: number
    value_format_name: usd
    sql: ${TABLE}.warranty_value_reviewed ;;
  }

  measure: warrantable_wo_reviewed_value {
    type: sum
    value_format_name: usd
    sql: ${reviewed_wo_warrantable_value} ;;
  }

  dimension: billed_missed_opp {
    type: number
    sql: ${TABLE}.billed_missed_opp ;;
  }

  measure: wo_billed_missed_opp {
    type: sum
    sql: ${billed_missed_opp} ;;
  }

  dimension: warranty_billed {
    type: number
    value_format_name: usd
    sql: ${TABLE}.warranty_billed;;
  }

  measure: billed_warranty {
    type: sum
    value_format_name: usd
    sql: ${warranty_billed} ;;
  }

  dimension: tagged_needs_more_info {
    type: number
    sql: ${TABLE}.tagged_needs_more_info;;
  }

  measure: needs_more_info_tagged {
    type: sum
    sql: ${tagged_needs_more_info};;
  }

  dimension: tagged_value {
    type: number
    value_format_name: usd
    sql: ${TABLE}.value_tagged;;
  }

  measure: value_tagged {
    type: sum
    value_format_name: usd
    sql: ${tagged_value};;
  }
}

view: monthly_missed_opportunity_by_market {
  derived_table: {
    sql: with generated_dates as (
    SELECT dateadd(month, '-' || row_number() over (order by null), dateadd(month, 1, date_trunc('month', current_date()))
        ) as generated_date
    FROM table(generator(rowcount => 1000))
    qualify generated_date > '2023-12-31'
)

select gd.generated_date as applicable_month
    , m.market_id
    , mo.market_name
    , mo.work_order_id
    , mo.date_completed
    , mo.billing_type
    , mo.asset_id
    , mo.make
    , mo.model
    , mo.parts
    , mo.warrantable_part_cost
    , mo.estimated_labor
    , mo.total_cost
from generated_dates gd
join ${warranty_missed_opportunity.SQL_TABLE_NAME} mo
    on date_trunc(month, mo.date_completed) = gd.generated_date
join ANALYTICS.PUBLIC.MARKET_REGION_XWALK m
    on m.market_name = mo.market_name
where likely_missed_opportunity =  true ;;
  }

  dimension: month {
    type: date
    sql: ${TABLE}.applicable_month ;;
  }

  dimension_group: month_expanded {
    type: time
    timeframes: [
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: CAST(${TABLE}.applicable_month AS TIMESTAMP_NTZ) ;;
  }

  dimension: market_id {
    type: number
    value_format_name: id
    sql: ${TABLE}.market_id ;;
  }

  dimension: work_order_id {
    primary_key: yes
    type: number
    value_format_name: id
    sql: ${TABLE}.work_order_id ;;
    html: <font color="blue "><u><a href="https://app.estrack.com/#/service/work-orders/{{ work_order_id._value }}" target="_blank">{{ work_order_id._value }}</a></font></u> ;;
  }

  measure: work_orders {
    type: count_distinct
    sql: ${work_order_id} ;;
  }

  dimension: market_name {
    type: string
    sql: ${TABLE}.market_name ;;
  }

  dimension: date_completed {
    type: date
    sql: ${TABLE}.date_completed ;;
  }

  dimension: billing_type {
    type: string
    sql: ${TABLE}.billing_type ;;
  }

  dimension: asset_id {
    type: number
    value_format_name: id
    sql: ${TABLE}.asset_id ;;
  }

  dimension: make {
    type: string
    sql: ${TABLE}.make ;;
  }

  dimension: model {
    type: string
    sql: ${TABLE}.model ;;
  }

  dimension: parts {
    type: string
    sql: ${TABLE}.parts ;;
  }

  dimension: warrantable_parts_cost {
    type: number
    value_format_name: usd_0
    sql: ${TABLE}.warrantable_part_cost ;;
  }

  dimension: estimated_labor {
    type: number
    value_format_name: usd_0
    sql: ${TABLE}.estimated_labor;;
  }

  dimension: total_cost {
    type: number
    value_format_name: usd
    sql: ${TABLE}.total_cost ;;
  }

  measure: total_missed_opp_value {
    type: sum
    value_format_name: usd_0
    sql: ${total_cost} ;;
    drill_fields: [
        work_order_id
        , date_completed
        , billing_type
        , asset_id
        , make
        , model
        , parts
        , warrantable_parts_cost
        , estimated_labor
        , total_cost]
  link: {
    label: "Missed Opportunity Dashboard"
    url: "https://equipmentshare.looker.com/dashboards/1502?Region+Name={{ _filters['market_region_xwalk.region_name'] | url_encode }}&Market+Name{{ _filters['market_region_xwalk.market_name'] | url_encode }}&District={{ _filters['market_region_xwalk.district'] | url_encode }}&toggle=det"
  }
  }
}

# view: missed_opp_by_branch_agg {
#   derived_table: {
#     sql:
# select applicable_month
#     , market_id
#     , make
#     , lag(sum(total_cost)) over (partition by market_id, make order by applicable_month asc) as prev_month_total
# from ${monthly_missed_opportunity_by_market.SQL_TABLE_NAME}
# group by applicable_month
#     , market_id
#     , make ;;
#   }

#   dimension: month {
#     type: date
#     sql: ${TABLE}.applicable_month ;;
#   }

#   dimension: market_id {
#     type: number
#     value_format_name: id
#     sql: ${TABLE}.market_id ;;
#   }

#   dimension: make {
#     type: string
#     sql: ${TABLE}.make ;;
#   }

#   dimension: primary_key {
#     primary_key: yes
#     type: string
#     sql: concat(${month}, ${market_id}, ${make}) ;;
#   }

#   dimension: prev_month_total {
#     type: number
#     value_format_name: usd_0
#     sql: ${TABLE}.prev_month_total ;;
#   }

#   measure: last_month_missed_opp {
#     type: sum
#     value_format_name: usd_0
#     sql: ${prev_month_total} ;;
#   }
# }
