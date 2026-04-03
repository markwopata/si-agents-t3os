view: rent_rev_act_tar {
  derived_table: {
    sql: with actual_cte as (
          select
              try_to_number(BEDS.MKT_ID)                          mkt_id,
              REGION_NAME                                         rgn_name,
              REGION                                              mkt_rgn,
              REGION_DISTRICT                                     mkt_dist,
              MKT_NAME,
              date_trunc(month, GL_DATE::date)                    gl_mo,
              'Actual'                                            class,
              sum(AMT)                                            rent_rev
          from ANALYTICS.PUBLIC.BRANCH_EARNINGS_DDS_SNAP BEDS
          join ANALYTICS.PUBLIC.MARKET_REGION_XWALK XW
              on BEDS.MKT_ID = XW.MARKET_ID::varchar
          where BEDS.ACCTNO in ('FAAA', 'TAIR','5000')
              and mkt_id not in (7522, 10744)
              and gl_mo between dateadd(month, -5,
                            (select TRUNC::date from ANALYTICS.GS.PLEXI_PERIODS
                            where DISPLAY = {% parameter report_period %})) and
                            (select TRUNC::date from ANALYTICS.GS.PLEXI_PERIODS
                            where DISPLAY = {% parameter report_period %})
          group by mkt_id, rgn_name, mkt_rgn, mkt_dist, MKT_NAME, gl_mo, class
          order by mkt_id, gl_mo
      ),
      forecast_cte as (
          select
              iff(XW.MARKET_ID=15967,33163,XW.MARKET_ID)          mkt_id,
              REGION_NAME                                         rgn_name,
              REGION                                              mkt_rgn,
              REGION_DISTRICT                                     mkt_dist,
              xw.MARKET_NAME                                      mkt_name,
              G.MONTH::date                                       gl_mo,
              'Target'                                            class,
              round(FORECAST, 2)                                  rent_rev
          from ANALYTICS.PUBLIC.MARKET_REGION_XWALK XW
          join ANALYTICS.GS.MKT_GOALS_2021 G
              on XW.MARKET_ID::varchar = G.MARKET_ID
          where mkt_id > 0
              and mkt_id not in ('7522', '10744')
          order by mkt_id, gl_mo
      ),
      union_cte as (
          select * from actual_cte

          union all

          select * from forecast_cte
          where gl_mo between
              dateadd(month, 1,
                  (select TRUNC::date
                  from ANALYTICS.GS.PLEXI_PERIODS
                  where DISPLAY = {% parameter report_period %}))
              and dateadd(month, 6,
                  (select TRUNC::date
                  from ANALYTICS.GS.PLEXI_PERIODS
                  where DISPLAY = {% parameter report_period %}))
      )
      select
          U.mkt_id,
          U.rgn_name,
          U.mkt_rgn,
          U.mkt_dist,
          U.mkt_name,
          U.gl_mo,
          U.class,
          U.rent_rev,
          iff(F.rent_rev=0,0,U.rent_rev / F.rent_rev)  achv
      from union_cte U
      left join forecast_cte F
          on U.mkt_id = F.mkt_id
          and U.gl_mo = F.gl_mo
          and F.gl_mo = ( select TRUNC::date
                          from ANALYTICS.GS.PLEXI_PERIODS
                          where DISPLAY = {% parameter report_period %} )
       ;;
  }

  parameter:  report_period {
    label: "Period"
    type: string
    full_suggestions: yes
    suggest_explore: plexi_periods
    suggest_dimension: plexi_periods.display
  }

  measure: count {
    type: count
    drill_fields: []
  }

  measure: rev {
    label: "Rent Revenue"
    type: sum
    value_format: "#,##0;(#,##0);-"
    sql: ${rent_rev} ;;
    html: {% if rent_rev_act_tar.class._value == 'Target' %}
          <i>{{rendered_value}}</i>
          {% elsif rent_rev_act_tar.achv2._value >= 1.0 %}
          <p style="color: black; background-color: #00A572">{{ rendered_value }}</p>
          {% elsif rent_rev_act_tar.achv2._value >= 0.9 %}
          <p style="color: black; background-color: #FFD300">{{ rendered_value }}</p>
          {% elsif rent_rev_act_tar.achv2._value < 0 %}
          {{rendered_value}}
          {% else %}
          <p style="color: white; background-color: #B32F37">{{ rendered_value }}</p>
          {% endif %};;
  }

  measure: achv2 {
    type: sum
    label: "Actual to Budget"
    sql: coalesce(${achv}, -1) ;;
  }

  dimension: mkt_id {
    type: number
    label: "Market ID"
    sql: ${TABLE}."MKT_ID" ;;
    primary_key: yes
  }

  dimension: mkt_name {
    type: string
    label: "Market Name"
    sql: ${TABLE}."MKT_NAME" ;;
  }

  dimension: mkt_rgn {
    type: string
    label: "Region"
    sql: ${TABLE}."MKT_RGN" ;;
  }

  dimension: mkt_ist {
    type: string
    label: "District"
    sql: ${TABLE}."MKT_DIST" ;;
  }

  dimension: gl_mo {
    type: date
    label: "Date"
    convert_tz: no
    sql: ${TABLE}."GL_MO" ;;
  }

  dimension: month {
    type: string
    label: "Month"
    sql: to_varchar(${TABLE}."GL_MO", 'MMMM YYYY') ;;
    order_by_field: gl_mo
  }

  dimension: class {
    type: string
    label: "Class"
    sql: ${TABLE}."CLASS" ;;
  }

  dimension: rent_rev {
    type: number
    label: "Rent Revenue"
    sql: ${TABLE}."RENT_REV" ;;
  }

  dimension: achv {
    type: number
    hidden: yes
    sql: ${TABLE}."ACHV" ;;
  }

  dimension: trunc {
    type: string
    sql: (select trunc from ${plexi_periods.SQL_TABLE_NAME} where display = {% parameter report_period %}) ;;
  }
  dimension: months_open {
    type: string
    sql: datediff(months, ${revmodel_market_rollout_conservative.branch_earnings_start_month_date}, ${trunc})+1 ;;
  }

  dimension: greater_twelve_months_open {
    label: "Markets Greater Than 12 Months Open?"
    type: yesno
    sql: ${months_open} > 12;;
  }

  dimension: period_published {
    label: "Plexi Period Published"
    type: string
    sql: (select period_published from ${plexi_periods.SQL_TABLE_NAME} where display = {% parameter report_period %}) ;;
  }

  set: detail {
    fields: []
  }
}
