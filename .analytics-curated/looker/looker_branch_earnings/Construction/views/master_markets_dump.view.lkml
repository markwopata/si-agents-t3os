view: master_markets_dump {
  derived_table: {
    sql:
SELECT
        mm.group_title as project_type,
        mm.grouping_name,
        mm.market_id,
        mm.branch_name,
        mm.region_district,
        mm.launch_phase,
        mm.target_construction_completion_date,
        mm.division,
        mm.transaction_type AS lease_type,
        mm.possession_date,
        mm.address,
        concat('https://equipmentshare.monday.com/boards/5444327901/pulses/',mm.item_id) as monday_link
      FROM analytics.monday.master_markets_board mm
      WHERE mm.grouping_name != 'Dead Deals'
;;
  }

  dimension: project_type {
    type: string
    sql: ${TABLE}.project_type ;;
  }

  dimension: grouping_name {
    type: string
    sql: ${TABLE}.grouping_name ;;
  }

  dimension: market_id {
    type: string
    sql: ${TABLE}.market_id ;;
  }

  dimension: branch_name {
    type: string
    sql: ${TABLE}.branch_name ;;
  }

  dimension: region_district {
    type: string
    sql: ${TABLE}.region_district ;;
  }

  dimension: launch_phase {
    type: string
    sql: ${TABLE}.launch_phase ;;
  }

  dimension: target_construction_completion_date {
    type: date
    sql: ${TABLE}.target_construction_completion_date ;;
  }

  dimension: division {
    type: string
    sql: ${TABLE}.division ;;
  }

  dimension: lease_type {
    type: string
    sql: ${TABLE}.lease_type ;;
  }

  dimension: possession_date {
    type: date
    sql: ${TABLE}.possession_date ;;
  }

  dimension: address {
    type: string
    sql: ${TABLE}.address ;;
  }

  dimension: monday_link {
    type: string
    sql: ${TABLE}.monday_link ;;
  }

}
