
view: regional_actively_renting_customers {
  derived_table: {
    sql:
     with daily_oec_aor_by_market_90 AS (
      SELECT * FROM analytics.bi_ops.historical_arc where date >= dateadd(month, '-14', current_date())
      UNION
      SELECT * FROM analytics.bi_ops.current_arc
      )
      , region_selection as (
          select
            distinct region_name as region
          from
            analytics.public.market_region_xwalk
          where
            {% condition region_name_filter %} region_name {% endcondition %}
            --region_name IN ('Midwest', 'Mountain West')
        )

        , region_selection_count as (
          select
            count(region) as total_regions_selected
          from
            region_selection
        )

        , assigned_region as (
          select
            IFF(split_part(DEFAULT_COST_CENTERS_FULL_PATH,'/',2) = 'Corp', 'Midwest',
            IFF(split_part(DEFAULT_COST_CENTERS_FULL_PATH,'/',2) = 'R2 Mountain West', 'Mountain West',
                IFF(
                    split_part(split_part(DEFAULT_COST_CENTERS_FULL_PATH,'/',2), ' ',2) = ''
                    ,'Midwest'
                    ,split_part(split_part(DEFAULT_COST_CENTERS_FULL_PATH,'/',2), ' ',2)
                    )
                )
              ) as region
          from
            analytics.payroll.company_directory
          where
            lower(work_email) = '{{ _user_attributes['email'] }}'
          )
    SELECT
      doa.*,
      vmt.is_current_months_open_greater_than_twelve,
      vmt.district as current_district,
      vmt.region_name as current_region_name,
      case when right(vmt.market_name, 9) = 'Hard Down' then true else false end as hard_down,

      IFF( IFF(total_regions_selected = 1,rs.region,ar.region) = xw.region_name,TRUE,FALSE) as is_selected_region

    FROM daily_oec_aor_by_market_90 doa
    join analytics.public.market_region_xwalk xw on doa.market_id = xw.market_id
    left join (select market_id, market_name, state, district, region, region_name, is_current_months_open_greater_than_twelve from analytics.public.v_market_t3_analytics group by market_id, market_name, state, district, region, region_name, is_current_months_open_greater_than_twelve) vmt
            on vmt.market_id = doa.market_id
    cross join region_selection_count rsc
    left join region_selection rs on rsc.total_regions_selected = 1
    cross join assigned_region ar
    ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  filter: region_name_filter {
    type: string
  }

  dimension: is_selected_region {
    type: yesno
    sql: ${TABLE}."IS_SELECTED_REGION";;
  }

  dimension: selected_region_name {
    type: string
    sql: case when ${is_selected_region} = 'Yes' then 'Highlighted' else ' ' end;;
  }


  dimension: date {
    type: date
    sql: ${TABLE}."DATE" ;;
  }

  dimension_group: flexidate {
    type: time
    sql: ${TABLE}."DATE" ;;
  }


  dimension: rental_day_formatted {
    group_label: "HTML Formatted Day"
    label: "Date"
    type: date
    sql: ${date} ;;
    html: {{ rendered_value | date: "%b %d, %Y"  }};;
  }


  dimension: format_month {
    group_label: "HTML Formatted Month"
    label: "Month"
    type: date
    sql: DATE_TRUNC(month, TO_DATE(${flexidate_date})) ;;
    html: {{ rendered_value | date: "%b %Y"  }};;
  }

  dimension: market_id {
    type: string
    sql: ${TABLE}."MARKET_ID" ;;
  }

  dimension: months_open_over_12 {
    type: yesno
    sql: ${TABLE}."IS_CURRENT_MONTHS_OPEN_GREATER_THAN_TWELVE" ;;
  }

  dimension: market_name {
    type: string
    sql: ${TABLE}."MARKET_NAME" ;;
  }

  dimension: district {
    type: string
    sql: ${TABLE}."DISTRICT" ;;
  }

  dimension: current_district {
    type: string
    sql: ${TABLE}."CURRENT_DISTRICT" ;;
  }

  dimension: region {
    type: string
    sql: ${TABLE}."REGION" ;;
  }

  dimension: region_name {
    type: string
    sql: ${TABLE}."REGION_NAME" ;;
  }

  dimension: current_region_name {
    type: string
    sql: ${TABLE}."CURRENT_REGION_NAME" ;;
  }

  dimension: hard_down {
    type: yesno
    sql: ${TABLE}."HARD_DOWN" ;;
  }

  dimension: market_type {
    type: string
    sql: ${TABLE}."MARKET_TYPE" ;;
  }

  dimension: assets_on_rent {
    type: number
    sql: ${TABLE}."ASSETS_ON_RENT" ;;
  }

  measure: assets_on_rent_sum {
    group_label: "AOR Agg"
    label: "Assets On Rent"
    type: sum
    sql: ${assets_on_rent}  ;;
  }

  measure: assets_on_rent_sum_formatted {
    label: "Assets On Rent"
    description: "Making a second assets on rent sum to use for the drill down on the actively renting customers tile on the markets dashboard"
    type: sum
    sql: ${assets_on_rent}  ;;
  }

  dimension: company_id {
    type: number
    sql: ${TABLE}."COMPANY_ID" ;;
  }

  measure: company_count{
    type: count_distinct
    sql: ${company_id} ;;

  }

  measure: arc_selected {
    label: "Company Count (Selected)"
    type: count_distinct
    sql: ${company_id} ;;
    filters: [is_selected_region: "YES"]

  }

  measure: arc_unselected {
    label: "Company Count (Unselected)"
    type: count_distinct
    sql: ${company_id} ;;
    filters: [is_selected_region: "NO"]

  }

  dimension: company_name {
    type: string
    sql: ${TABLE}."COMPANY_NAME" ;;
  }

  dimension: customer_name_formatted {
    label: "Customer"
    type: string
    sql: ${TABLE}."COMPANY_NAME" ;;
    html: <font color="0063f3 "><a href="https://equipmentshare.looker.com/dashboards/28?Company+Name={{filterable_value}}&Company+ID="target="_blank">{{rendered_value}}</a></font>
          <td>
          <span style="color: #8C8C8C;"> ID: {{company_id._value}} </span>
          </td>;;
  }

  dimension: oec_on_rent {
    type: number
    sql: ${TABLE}."OEC_ON_RENT" ;;
    value_format_name: usd
  }

  measure: oec_on_rent_sum {
    group_label: "OEC Agg"
    label: "OEC On Rent"
    type: sum
    sql:  ${oec_on_rent} ;;
    value_format_name: usd
  }

  dimension: one_flag {
    type: number
    sql: ${TABLE}."ONE_FLAG" ;;
  }

  dimension: current_day_flag {
    type: string
    sql: case when ${date} = dateadd(day, '-1', convert_timezone('America/Chicago',current_timestamp)::date) then 1 else 0 end ;;
  }

  # dimension: test {
  #   type: string
  #   sql: dateadd(day, '-1', convert_timezone('America/Chicago',current_date)::date) ;;
  # }

  # dimension: test_2 {
  #   type: string
  #   sql: dateadd(day, '-1', convert_timezone('America/Chicago',current_timestamp)::date) ;;
  # }


  measure: actively_renting_customers {
    type: count_distinct
    sql: ${company_id} ;;
    filters: [current_day_flag: "1"]
    drill_fields: [customer_name_formatted, assets_on_rent_sum_formatted]
  }

  measure: actively_renting_customers_total {
    type: count_distinct
    sql: ${company_id} ;;
  }

  set: company_count_drill{
    fields:[customer_name_formatted, assets_on_rent_sum,oec_on_rent_sum
      ]
  }

  set: detail {
    fields: [
        date,
  market_id,
  market_name,
  district,
  region,
  region_name,
  market_type,
  assets_on_rent,
  company_id,
  company_name,
  oec_on_rent,
  one_flag
    ]
  }
}
