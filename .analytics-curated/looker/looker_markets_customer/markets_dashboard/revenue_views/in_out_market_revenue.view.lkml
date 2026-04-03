
view: in_out_market_revenue {
  derived_table: {
    sql: with liquid_filter_markets as (
          select MARKET_ID,
                 MARKET_NAME,
                 district,
                 region_name as region
          from ANALYTICS.PUBLIC.MARKET_REGION_XWALK
          where {% condition market_name %} MARKET_NAME {% endcondition %}
      ),
      market_revenue as (
          select SP_USER_ID,
                 concat(SALESPERSON,' - ',SP_USER_ID) as salesperson,
                 RENTAL_COMPANY,
                 SP_JURISDICTION,
                 SP_MARKET_ID,
                 SP_MARKET,
                 sum(RENTAL_REVENUE) as market_revenue,
                 'In Market' as market_revenue_type_flag,
                m.district,
                m.region
          from analytics.bi_ops.salesperson_line_items_current slc
          join liquid_filter_markets m on slc.RENTAL_MARKET_ID = m.MARKET_ID
          where RENTAL_MARKET_ID = SP_MARKET_ID
          group by RENTAL_MARKET,
                   RENTAL_MARKET_ID,
                   SP_USER_ID,
                   concat(SALESPERSON,' - ',SP_USER_ID),
                   SP_JURISDICTION,
                   SP_MARKET,
                   SP_MARKET_ID,
                   RENTAL_COMPANY,
                   m.district,
                   m.region
      UNION ALL
          select SP_USER_ID,
                 concat(SALESPERSON,' - ',SP_USER_ID),
                 RENTAL_COMPANY,
                 SP_JURISDICTION,
                 SP_MARKET_ID,
                 SP_MARKET,
                 sum(RENTAL_REVENUE) as market_revenue,
                 'Out of Market' as market_revenue_type_flag,
                m.district,
                m.region
          from analytics.bi_ops.salesperson_line_items_current slc
          join liquid_filter_markets m on slc.RENTAL_MARKET_ID = m.MARKET_ID
          where RENTAL_MARKET_ID <> SP_MARKET_ID
          group by RENTAL_MARKET,
                   RENTAL_MARKET_ID,
                   SP_USER_ID,
                   concat(SALESPERSON,' - ',SP_USER_ID),
                   SP_JURISDICTION,
                   SP_MARKET,
                   SP_MARKET_ID,
                   RENTAL_COMPANY,
                   m.district,
                   m.region
      )
      select *
      from market_revenue
      where market_revenue <> 0;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: sp_user_id {
    type: string
    sql: ${TABLE}."SP_USER_ID" ;;
  }

  dimension: salesperson {
    type: string
    sql: ${TABLE}."SALESPERSON" ;;
    html:
    {% if market_revenue_type_flag._value == "In Market" %}
    <font color="#0063f3 "><a href="https://equipmentshare.looker.com/dashboards/5?Sales+Rep={{rendered_value}}"target="_blank">{{rendered_value}} ➔ </a></font>
    <td>
    <span style="color: #1B1B1B;"> <b>{{market_revenue_type_flag._value}} </b></span>
    </td>
    {% else %}
    <font color="#0063f3 "><a href="https://equipmentshare.looker.com/dashboards/5?Sales+Rep={{rendered_value}}"target="_blank">{{rendered_value}} ➔ </a></font>
    <td>
    <span style="color: #8C8C8C;"> {{market_revenue_type_flag._value}} </span>
    </td>
    {% endif %};;
  }

  dimension: sp_jurisdiction {
    type: string
    sql: ${TABLE}."SP_JURISDICTION" ;;
  }

  dimension: sp_market_id {
    type: string
    sql: ${TABLE}."SP_MARKET_ID" ;;
  }

  dimension: sp_market {
    type: string
    sql: ${TABLE}."SP_MARKET" ;;
  }

  dimension: market_revenue {
    type: number
    sql: ${TABLE}."MARKET_REVENUE" ;;
    value_format_name: usd_0
  }

  dimension: market_revenue_type_flag {
    type: string
    sql: ${TABLE}."MARKET_REVENUE_TYPE_FLAG" ;;
  }

  dimension: customer {
    type: string
    sql: ${TABLE}."RENTAL_COMPANY" ;;
  }

  dimension: district {
    type: string
    sql: ${TABLE}."DISTRICT" ;;
  }

  dimension: region {
    type: string
    sql: ${TABLE}."REGION" ;;
  }

  measure: total_market_revenue {
    group_label: "Market Revenue"
    type: sum
    sql: ${market_revenue} ;;
    value_format_name: usd_0
    drill_fields: [detail*]
  }

  measure: total_market_revenue_drill_icon {
    group_label: "Market Revenue"
    label: "Rental Revenue"
    type: sum
    sql: ${market_revenue} ;;
    value_format_name: usd_0
    drill_fields: [detail*]
    html: <a href="#drillmenu" target="_self"> {{rendered_value}} <img src="https://imgur.com/ZCNurvk.png" height="15" width="15"></font></a>;;
  }

  measure: total_in_market_revenue {
    type: sum
    sql: ${market_revenue} ;;
    filters: [market_revenue_type_flag: "In Market"]
    value_format_name: usd_0
  }

  measure: total_out_of_market_revenue {
    type: sum
    sql: ${market_revenue} ;;
    filters: [market_revenue_type_flag: "Out of Market"]
    value_format_name: usd_0
  }

  measure: percent_of_revenue_in_market{
    group_label: "Revenue %"
    type: number
    sql: ${total_in_market_revenue}/nullifzero(${total_market_revenue}) ;;
    value_format_name: percent_1
  }

  measure: percent_of_revenue_out_of_market {
    group_label: "Revenue %"
    type: number
    sql: ${total_out_of_market_revenue}/nullifzero(${total_market_revenue}) ;;
    value_format_name: percent_1
  }

  filter: market_name {
    type: string
  }

  set: detail {
    fields: [
        customer,
        total_market_revenue
    ]
  }
}
