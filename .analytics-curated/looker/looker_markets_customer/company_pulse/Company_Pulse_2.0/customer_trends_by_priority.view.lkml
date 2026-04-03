view: customer_trends_by_priority {
  derived_table: {
    sql:

      select * from analytics.bi_ops.customer_trends_by_priority
      ;;
  }



  filter: region_name_filter_mapping {
    type: string
  }

  filter: district_filter_mapping {
    type: string
  }

  filter: market_name_filter_mapping {
    type: string
  }


  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: market_id {
    type: string
    sql: ${TABLE}."MARKET_ID" ;;
  }

  dimension: company {
    type: string
    sql: ${TABLE}."COMPANY" ;;
  }

  dimension: company_id {
    type: string
    sql: ${TABLE}."COMPANY_ID" ;;
  }

  dimension: company_with_id {
    type:  string
    sql: concat(${company_name}, ' - ', ${company_id}) ;;
  }

  dimension: company_name {
    type: string
    sql: ${TABLE}."COMPANY" ;;
    link: {
      label: "View Customer Information Dashboard"
      url: "https://equipmentshare.looker.com/dashboards/28?Company%20Name={{ company_name._filterable_value | url_encode }}&Company%20ID="
    }
  }

  dimension: company_name_formatted {
    type: string
    sql: ${TABLE}."COMPANY" ;;
    html:
    <font color="#0063f3 "><a href="https://equipmentshare.looker.com/dashboards/28?Company+Name={{filterable_value | url_encode}}&Company+ID="target="_blank"> {{rendered_value}} ➔ </a></font>
    <td>
    <span style="color: #8C8C8C;"> ID: {{company_id._value}} </span>
    </td>;;
  }

  dimension: overall_trend {
    type: string
    sql: ${TABLE}."OVERALL_TREND" ;;
    html:
    {% if overall_trend._value == "Growth" %}
      <span style="background-color:#DCFCE7; padding:2px 4px; border-radius:3px;"><strong>{{rendered_value}}</strong></span>
    {% elsif overall_trend._value == "Declining" %}
          <span style="background-color:#ffcccc; padding:2px 4px; border-radius:3px;"><strong>{{rendered_value}}</strong></span>
    {% elsif overall_trend._value == "New" %}
      <span style="background-color:#ffffcc; padding:2px 4px; border-radius:3px;"><strong>{{rendered_value}}</strong></span>
    {% else %}
          <strong>{{rendered_value}}</strong>
    {% endif %};;
  }

  dimension: rentals_trend_direction {
    type: string
    sql: ${TABLE}."RENTALS_TREND_DIRECTION" ;;
  }

  dimension: rentals_trend_band {
    type: string
    sql: ${TABLE}."RENTALS_TREND_BAND" ;;
  }

  dimension: seasonal_trend_performance {
    type: string
    sql: ${TABLE}."SEASONAL_TREND_PERFORMANCE" ;;
    html:
    {% if value == "Outperforming Season" %}
      <span style="background-color:#DCFCE7; padding:2px 4px; border-radius:3px;"><strong>{{rendered_value}}</strong></span>
    {% elsif value == "Underperforming Season" %}
     <span style="background-color:#ffcccc; padding:2px 4px; border-radius:3px;"><strong>{{rendered_value}}</strong></span>
     {% elsif value == "New" %}
      <span style="background-color:#ffffcc; padding:2px 4px; border-radius:3px;"><strong>{{rendered_value}}</strong></span>
    {% else %}
      <span style="color:grey">Expected</span>
    {% endif %};;
  }

  dimension: oec_trend_direction {
    type: string
    sql: ${TABLE}."OEC_TREND_DIRECTION" ;;
  }

  dimension: oec_trend_band {
    type: string
    sql: ${TABLE}."OEC_TREND_BAND" ;;
  }

  dimension: current_rentals {
    type: number
    sql: ${TABLE}."CURRENT_RENTALS" ;;
  }

  measure: current_rentals_sum {
    type: sum
    sql: ${current_rentals} ;;
  }

  dimension: current_oec_on_rent {
    type: number
    sql: ${TABLE}."CURRENT_OEC_ON_RENT" ;;
    value_format_name: usd_0
  }

  measure: current_oec_on_rent_sum {
    type: sum
    sql: ${current_oec_on_rent} ;;
    value_format_name: usd_0
  }

  dimension: rentals_7_d_ago {
    type: number
    sql: ${TABLE}."RENTALS_7D_AGO" ;;
  }

  dimension: oec_7_d_ago {
    type: number
    sql: ${TABLE}."OEC_7D_AGO" ;;
    value_format_name: usd_0
  }

  dimension: rentals_14_d_ago {
    type: number
    sql: ${TABLE}."RENTALS_14D_AGO" ;;
  }

  dimension: oec_14_d_ago {
    type: number
    sql: ${TABLE}."OEC_14D_AGO" ;;
    value_format_name: usd_0

  }

  dimension: rentals_30_d_ago {
    type: number
    sql: ${TABLE}."RENTALS_30D_AGO" ;;
  }

  dimension: oec_30_d_ago {
    type: number
    sql: ${TABLE}."OEC_30D_AGO" ;;
    value_format_name: usd_0

  }

  dimension: priority_rank_in_market {
    type: number
    sql: ${TABLE}."PRIORITY_RANK_IN_MARKET" ;;
  }

  dimension: credit_app_status {
    type: string
    sql: ${TABLE}."APP_STATUS" ;;
  }

  dimension: years_since_first_completed_order {
    type: number
    sql: ${TABLE}."YEARS_SINCE_FIRST_COMPLETED_ORDER" ;;
  }

  dimension: years_since_first_market_order {
    type: number
    sql: ${TABLE}."YEARS_SINCE_FIRST_MARKET_ORDER" ;;
  }

  set: detail {
    fields: [
      market_id,
      company,
      overall_trend,
      rentals_trend_direction,
      rentals_trend_band,
      oec_trend_direction,
      oec_trend_band,
      current_rentals,
      current_oec_on_rent,
      rentals_7_d_ago,
      oec_7_d_ago,
      rentals_14_d_ago,
      oec_14_d_ago,
      rentals_30_d_ago,
      oec_30_d_ago,
      priority_rank_in_market
    ]
  }

}
