view: market_region_xwalk {
  sql_table_name: "ANALYTICS"."PUBLIC"."MARKET_REGION_XWALK"
    ;;

  dimension: abbreviation {
    type: string
    sql: ${TABLE}."ABBREVIATION" ;;
  }

  dimension: area_code {
    type: string
    sql: ${TABLE}."AREA_CODE" ;;
  }

  dimension: district {
    type: string
    sql: ${TABLE}."DISTRICT" ;;
  }

  dimension: market_id {
    type: number
    sql: ${TABLE}."MARKET_ID" ;;
  }

  dimension: market_name {
    type: string
    sql: ${TABLE}."MARKET_NAME" ;;
  }

  dimension: market_name_link {
    label: "Market Link"
    type: string
    sql: ${TABLE}."MARKET_NAME" ;;
    html: <a style="color:blue; text-decoration:underline" href="https://equipmentshare.looker.com/dashboards/2485?Invoice%20Date=30%20day&Sale%20Type=&amp;&Retail%20Territory=&amp;&Asset%20Make=&amp;&Equipment%20Category=&amp;&Asset%20Model=&Equipment%20Class=&amp;&Market%20Name={{ market_name._filterable_value | url_encode }}&amp;&Exclude%20Trade-In%20Value%20from%20Revenue%3F=No&amp;&District=&amp;&Dealership%20Sale=Yes&amp;&Region%20Name=&amp;&Salesperson%20Name="
       target="_blank">{{ value }}</a>  ;;
  }

  dimension: market_type {
    type: string
    sql: ${TABLE}."MARKET_TYPE" ;;
  }

  dimension: region {
    type: number
    sql: ${TABLE}."REGION" ;;
  }

  dimension: region_name {
    type: string
    sql: ${TABLE}."REGION_NAME" ;;
  }

  dimension: state {
    type: string
    sql: ${TABLE}."STATE" ;;
  }

  measure: count {
    type: count
    drill_fields: [region_name, market_name]
  }

  dimension: city {
    type: string
    sql: SPLIT_PART(${market_name},',',1) ;;
  }

  dimension: district_text {
    type: string
    sql: ${TABLE}."DISTRICT" ::text ;;
  }

  dimension: region_district {
    type: string
    sql: ${TABLE}."REGION_DISTRICT"::text ;;
  }


  dimension: market_id_string {
    type: string
    sql: ${market_id}::text;;
  }

  dimension: is_dealership {
    type: string
    sql: ${TABLE}."IS_DEALERSHIP" ;;
  }

  dimension: retail_territory {
    type: string
    sql:
        CASE
          when ${market_id} = 40698 then 'CPE'
          when ${market_id} = 61102 then 'CPE'
          when ${market_id} = 61105 then 'CPE'
          when ${market_id} = 61108 then 'CPE'
          when ${market_id} = 85323 then 'CPE'
          when ${market_id} = 85717 then 'CPE'
          when ${market_id} = 115668 then 'CPE'
          when ${market_id} = 8606 then 'ES Central'
          when ${market_id} = 15966 then 'ES Central'
          when ${market_id} = 40688 then 'ES Central'
          when ${market_id} = 103038 then 'ES Central'
          when ${market_id} = 10313 then 'ES East'
          when ${market_id} = 11007 then 'ES East'
          when ${market_id} = 11812 then 'ES East'
          when ${market_id} = 13576 then 'ES East'
          when ${market_id} = 18703 then 'ES East'
          when ${market_id} = 18704 then 'ES East'
          when ${market_id} = 36770 then 'ES East'
          when ${market_id} = 47381 then 'ES East'
          when ${market_id} = 106316 then 'ES East'
          when ${market_id} = 7672 then 'ES West'
          when ${market_id} = 10550 then 'ES West'
          when ${market_id} = 15962 then 'ES West'
          when ${market_id} = 15970 then 'ES West'
          when ${market_id} = 15975 then 'ES West'
          when ${market_id} = 35347 then 'ES West'
          when ${market_id} = 36754 then 'ES West'
          when ${market_id} = 36756 then 'ES West'
          when ${market_id} = 36758 then 'ES West'
          when ${market_id} = 124703 then 'ES West'
          when ${market_id} = 36759 then 'Landmark'
          when ${market_id} = 85605 then 'Landmark'
          when ${market_id} = 85606 then 'Landmark'
          when ${market_id} = 85607 then 'Landmark'
          when ${market_id} = 85608 then 'Landmark'
          when ${market_id} = 131098 then 'Landmark'
          when ${market_id} = 1 then 'VLP'
          when ${market_id} = 13574 then 'VLP'
          when ${market_id} = 15977 then 'VLP'
          when ${market_id} = 23626 then 'VLP'
          when ${market_id} = 23627 then 'VLP'
          when ${market_id} = 55495 then 'VLP'
          when ${market_id} = 86328 then 'VLP'
          ELSE 'Other'
        END ;;
  }

  dimension: retail_territory_link {
      type: string
      sql: ${retail_territory} ;;
      html: <a style="color:blue; text-decoration:underline" href="https://equipmentshare.looker.com/dashboards/2484?Invoice%20Date=30%20day&amp;&Sale%20Type=&amp;&Retail%20Territory={{ retail_territory._filterable_value | url_encode }}&amp;&Asset%20Make=&Equipment%20Category=&amp;&Asset%20Model=&amp;&Equipment%20Class=&amp;&Quote%20Date%20Range=30%20day&amp;&Market%20Name=" target="_blank">{{value}}</a> ;;
    }

  dimension: District_Region_Market_Access {
    type: yesno
    sql: ${district} in ({{ _user_attributes['district'] }}) OR ${region_name} in ({{ _user_attributes['region'] }}) OR ${market_id} in ({{ _user_attributes['market_id'] }}) ;;
  }

  dimension: is_open_over_12_months {
    label: "Market open over 12 months?"
    type: yesno
    sql: ${TABLE}."IS_OPEN_OVER_12_MONTHS" ;;
  }

  measure: sales_rep_market_distinct_count {
    type: count_distinct
    sql: ${market_id} ;;
    description: "Used to toggle final market name on salesperson dashboard"
  }

  measure: market_count {
    type: count_distinct
    sql: ${market_id} ;;
  }

parameter: geo_granularity {
  description: "Group data at varying levels of geographic granularity"
  allowed_value: {
    label: "Retail Territory"
    value: "retail_territory"
  }
  allowed_value: {
    label: "Region"
    value: "region_name"
  }
  allowed_value: {
    label: "District"
    value: "region_district"
  }

  allowed_value: {
    label: "Market"
    value: "market_name"
  }
}

dimension: grouping {
  type: string
  label: "Geographic Grouping"
  sql: case
        when {% parameter geo_granularity %} = 'retail_territory' then ${retail_territory}
        when {% parameter geo_granularity %} = 'region_name' then ${region_name}
        when {% parameter geo_granularity %} = 'region_district' then ${region_district}
        when {% parameter geo_granularity %} = 'market_name' then ${market_name}
       end;;
 }


  dimension: parent_market_id {
    type: string
    sql: ${TABLE}."PARENT_MARKET_ID" ;;
  }

  dimension: parent_market_name {
    type: string
    sql: ${TABLE}."PARENT_MARKET_NAME" ;;
  }

  dimension: branch_earnings_start_month {
    type: date
    sql: ${TABLE}."BRANCH_EARNINGS_START_MONTH" ;;
  }

  dimension: current_months_open {
    type: number
    sql: ${TABLE}."CURRENT_MONTHS_OPEN" ;;
  }

  dimension: _id_dist {
    type: string
    sql: ${TABLE}."_ID_DIST" ;;
  }

  dimension: market_type_id {
    type: string
    sql: ${TABLE}."MARKET_TYPE_ID" ;;
  }

  dimension: division_id {
    type: string
    sql: ${TABLE}."DIVISION_ID" ;;
  }

  dimension: division_name {
    type: string
    sql: ${TABLE}."DIVISION_NAME" ;;
  }

  dimension_group: date_updated {
    type: time
    sql: ${TABLE}."DATE_UPDATED" ;;
  }
}
