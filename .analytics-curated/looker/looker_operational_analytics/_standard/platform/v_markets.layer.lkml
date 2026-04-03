include: "/_base/platform/gold/v_markets.view.lkml"

view: +v_markets {
  label: "V Markets"

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
