view: master_markets_cip_tracking {
  derived_table: {
    sql:
with markets as(
SELECT
        mm.group_title as project_type,
        mm.grouping_name as launch_phase,
        mm.market_id,
        mm.branch_name,
        mm.region_district,
        mm.construction_district,
        mm.launch_phase as sub_phase,
        mm.target_construction_completion_date,
        mm.division,
        mm.transaction_type AS lease_type,
        mm.possession_date,
        mm.cpm_project_completion_date,
        mm.address,
        concat('https://equipmentshare.monday.com/boards/5444327901/pulses/',mm.item_id) as monday_link
      FROM analytics.intacct_models.int_master_markets_single_market mm
      WHERE mm.grouping_name != 'Dead Deals'
 order by 2)

, projects as(
select ba.market_id
     , ba.project_code
     , sum(ba.budget_amount) as budget_amount
     , sum(ba.actual_amount) as actual_amount
     , sum(ba.budget_delta) as delta
 from analytics.intacct_models.int_cip_budget_v_actual_summary ba
  group by 1,2)

select m.market_id
     , m.branch_name as market_name
     , m.address
     , m.monday_link
     , p.project_code as project
     , m.project_type
     , m.division
     , m.region_district
     , m.construction_district
     , m.launch_phase
     , m.sub_phase
     , m.target_construction_completion_date
     , m.possession_date
     , m.cpm_project_completion_date as actual_completion_date
     , datediff(day,m.possession_date,nvl(m.cpm_project_completion_date,current_date)) as days_from_posession_to_completion
     , m.lease_type
     , p.budget_amount
     , p.actual_amount
     , p.delta
 from markets m
  join projects p on m.market_id = p.market_id
 order by m.branch_name, p.project_code
;;
  }

  dimension: market_id {
    type:  number
    sql:  ${TABLE}.market_id ;;
    drill_fields: [project,budget_amount,actual_amount,delta]
  }

  dimension: market_name {
    type:  string
    sql:  ${TABLE}.market_name ;;
    drill_fields: [project,budget_amount,actual_amount,delta]
  }

  dimension: address {
    type:  string
    sql:  ${TABLE}.address ;;
    drill_fields: [project,budget_amount,actual_amount,delta]
  }

  dimension: item_id {
    type:  string
    sql:  ${TABLE}.item_id ;;
    drill_fields: [project,budget_amount,actual_amount,delta]
  }

  dimension: monday_link {
    type: string
    sql: ${TABLE}.monday_link ;;
    html: <a href='{{ value }}' target='_blank' style='color: #1a0dab;'>{{ value }}</a>;;
    drill_fields: [project,budget_amount,actual_amount,delta]
  }

  dimension: project {
    type:  string
    sql:  ${TABLE}.project ;;
  }

  dimension: project_type {
    type:  string
    sql:  ${TABLE}.project_type ;;
    drill_fields: [project,budget_amount,actual_amount,delta]
  }

  dimension: division {
    type:  string
    sql:  ${TABLE}.division ;;
    drill_fields: [project,budget_amount,actual_amount,delta]
  }

  dimension: region_district {
    type:  string
    sql:  ${TABLE}.region_district ;;
    drill_fields: [project,budget_amount,actual_amount,delta]
  }

  dimension: construction_district {
    type:  string
    sql:  ${TABLE}.construction_district ;;
    drill_fields: [project,budget_amount,actual_amount,delta]
  }

  dimension: launch_phase {
    type:  string
    sql:  ${TABLE}.launch_phase ;;
    drill_fields: [project,budget_amount,actual_amount,delta]
  }

  dimension: sub_phase {
    type:  string
    sql:  ${TABLE}.sub_phase ;;
    drill_fields: [project,budget_amount,actual_amount,delta]
  }

  dimension: target_construction_completion_date {
    type:  date
    sql:  ${TABLE}.target_construction_completion_date ;;
    drill_fields: [project,budget_amount,actual_amount,delta]
  }

  dimension: possession_date {
    type:  date
    sql:  ${TABLE}.possession_date ;;
    drill_fields: [project,budget_amount,actual_amount,delta]
  }

  dimension: actual_completion_date {
    type:  date
    sql:  ${TABLE}.actual_completion_date ;;
    drill_fields: [project,budget_amount,actual_amount,delta]
  }

  dimension: days_from_posession_to_completion {
    type:  number
    sql:  ${TABLE}.days_from_posession_to_completion ;;
    drill_fields: [project,budget_amount,actual_amount,delta]
  }

  dimension: lease_type {
    type:  string
    sql:  ${TABLE}.lease_type ;;
    drill_fields: [project,budget_amount,actual_amount,delta]
  }

  measure: budget_amount {
    type: sum
    sql: ${TABLE}.budget_amount ;;
    value_format: "$#,##0.00;($#,##0.00)"
  }

  measure: actual_amount {
    type: sum
    sql: ${TABLE}.actual_amount ;;
    value_format: "$#,##0.00;($#,##0.00)"
  }

  measure: delta {
    type: sum
    sql: ${TABLE}.delta ;;
    value_format: "$#,##0.00;($#,##0.00)"
  }
}
