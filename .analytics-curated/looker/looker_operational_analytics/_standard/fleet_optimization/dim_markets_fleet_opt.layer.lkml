include: "/_base/fleet_optimization/dim_markets_fleet_opt.view.lkml"

view: +dim_markets_fleet_opt {
  label: "Markets"

  dimension: dynamic_axis {
    type: string
    sql: {% if market_name._in_query %}
           ${market_name}
         {% elsif market_district._in_query %}
           ${market_name}
         {% elsif market_region_name._in_query %}
           ${market_district}
         {% else %}
           ${market_region_name}
         {% endif %} ;;
  }

  }
