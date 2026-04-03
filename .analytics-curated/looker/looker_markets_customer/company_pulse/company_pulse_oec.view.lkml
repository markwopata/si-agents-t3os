
view: company_pulse_oec {
  derived_table: {
    sql: with region_selection as (
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

          , markets_aor_oec AS (
          SELECT
            date,
            market_id,
            sum(assets_on_rent) as assets_on_rent,
            sum(oec_on_rent) as oec_on_rent
          from
            analytics.bi_ops.market_oec_aor_historical
          where
            date >= dateadd(day,-90,current_date)
          group by
            date,
            market_id
          UNION
          SELECT
              date,
              market_id,
              sum(assets_on_rent) as assets_on_rent,
              sum(oec_on_rent) as oec_on_rent
          from
            analytics.bi_ops.market_oec_aor_current
          group by
            date,
            market_id
          )

          SELECT
              mao.date,
              mao.market_id,
              xw.market_name,
              xw.market_type,
              case when right(xw.market_name, 9) = 'Hard Down' then true else false end as hard_down,
              xw.district,
              xw.region_name,
              IFF(
              IFF(rsc.total_regions_selected = 1, rs.region ,ar.region)
              = xw.region_name,TRUE,FALSE) as is_selected_region,
              mao.assets_on_rent as assets_on_rent,
              mao.oec_on_rent as oec_on_rent,
              vmt.IS_CURRENT_MONTHS_OPEN_GREATER_THAN_TWELVE
          FROM
              markets_aor_oec mao
              join analytics.public.market_region_xwalk xw on mao.market_id = xw.market_id
              left join (
                          select market_id, is_current_months_open_greater_than_twelve
                          from analytics.public.v_market_t3_analytics
                          group by market_id, is_current_months_open_greater_than_twelve) vmt on vmt.market_id = mao.market_id
              cross join region_selection_count rsc
              left join region_selection rs on rsc.total_regions_selected = 1
              cross join assigned_region ar
;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: date {
    type: date
    sql: ${TABLE}."DATE" ;;
  }

  dimension_group: date_group {
    type: time
    sql: ${TABLE}."DATE" ;;
  }

  dimension: market_id {
    type: number
    sql: ${TABLE}."MARKET_ID" ;;
  }

  dimension: market_name {
    type: string
    sql: ${TABLE}."MARKET_NAME" ;;
  }

  dimension: market_type {
    type: string
    sql: ${TABLE}."MARKET_TYPE" ;;
  }

  dimension: hard_down {
    type: yesno
    sql: ${TABLE}."HARD_DOWN" ;;
  }

  dimension: district {
    type: string
    sql: ${TABLE}."DISTRICT" ;;
  }

  dimension: region_name {
    type: string
    sql: ${TABLE}."REGION_NAME" ;;
  }

  dimension: is_selected_region {
    type: yesno
    sql: ${TABLE}."IS_SELECTED_REGION" ;;
  }

  dimension: is_current_months_open_greater_than_twelve {
    type: yesno
    sql: ${TABLE}."IS_CURRENT_MONTHS_OPEN_GREATER_THAN_TWELVE" ;;
  }

  dimension: selected_region_name {
    type: string
    sql: case when ${is_selected_region} = 'Yes' then 'Highlighted' else ' ' end ;;
  }

  filter: region_name_filter {
    type: string
  }

  dimension: assets_on_rent {
    type: number
    sql: ${TABLE}."ASSETS_ON_RENT" ;;
  }

  measure: assets_on_rent_sum {
    type: sum
    sql: ${assets_on_rent} ;;
  }

  dimension: oec_on_rent {
    type: number
    sql: ${TABLE}."OEC_ON_RENT" ;;
    value_format_name: usd_0
  }



  measure: total_oec {
    type: sum
    sql: ${oec_on_rent} ;;
    value_format_name: usd_0
  }



  dimension: formatted_date {
    group_label: "HTML Formatted Date"
    label: "Date"
    type: date
    sql: ${date} ;;
    html: {{ rendered_value | date: "%b %d, %Y"  }};;
  }

  set: detail {
    fields: [
      date,
      market_id,
      market_name,
      market_type,
      hard_down,
      district,
      region_name,
      is_selected_region,
      assets_on_rent,
      oec_on_rent,
      is_current_months_open_greater_than_twelve
    ]
  }
}
