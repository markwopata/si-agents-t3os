view: current_own_program_assets {
  derived_table: {
    sql: select asset_id
    , payout_program_name
from ES_WAREHOUSE.PUBLIC.V_PAYOUT_PROGRAMS
where CURRENT_TIMESTAMP >= START_DATE
    AND CURRENT_TIMESTAMP < COALESCE(END_DATE, '2099-12-31') ;;
  }

  dimension: asset_id {
    type: number
    primary_key: yes
    value_format_name: id
    sql: ${TABLE}.asset_id ;;
  }

  dimension: payout_program_name {
    type: string
    sql: ${TABLE}.payout_program_name ;;
  }
}
