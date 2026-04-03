include: "/_standard/custom_sql/transportation_fleet_model_barcharts.view.lkml"
include: "/_standard/platform/v_markets.layer.lkml"

explore: transportation_fleet_model_barcharts {
  sql_always_where: ${v_markets.market_company_id} = 1854
  and ${v_markets.market_active};;

  join: v_markets {
    type: inner
    relationship: one_to_one
    sql_on: ${transportation_fleet_model_barcharts.market_id} = ${v_markets.market_id} ;;
  }
}
