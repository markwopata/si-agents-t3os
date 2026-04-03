include: "/views/markets.view.lkml"

view: markets_public_rsps {

  extends: [markets]

  dimension: name {
    type: string
    suggest_explore: markets_public_rsps_suggest
    suggest_dimension: markets_public_rsps_suggest.name
    sql:  ${TABLE}.name ;;
  }

}

view: markets_public_rsps_suggest {

  dimension: name {
    type: string
    sql:  ${TABLE}.name ;;
  }

  derived_table: {
    sql: SELECT DISTINCT name FROM markets where is_public_rsp = true ;;
  }

}

explore: markets_public_rsps_suggest {}
