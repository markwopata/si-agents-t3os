view: regional_hierarchy_new_accounts_history_district_highlighted {

  derived_table: {
    sql:
    with new_customers_union as (
     select dcb.company_id
    , dcb.company_name
    , dates.date as new_account_date
    , COALESCE(IFF(dse.user_id = '-1', NULL, dse.user_id), dub.user_id) as sp_user_id
    , COALESCE(IFF(dse.name_current = 'Default Salesperson Record', NULL, dse.name_current),  dub.user_full_name) as sp_name
    , concat(sp_name, ' - ', sp_user_id) as salesperson
    , fccs.credit_application_type as app_type
    , dcb.company_has_orders as first_order
    , dcb.company_has_rentals as first_rental
    , case when right(xw.market_name, 9) = 'Hard Down' then true else false end as hard_down

    , caml.MARKET_ID
    , xw.market_name
    , xw.DISTRICT
    , xw.REGION_NAME as region
    , xw.MARKET_TYPE
    , xw.division_name


    from business_intelligence.gold.fact_company_customer_start fccs
    LEFT JOIN business_intelligence.gold.dim_companies_bi dcb ON dcb.company_key = fccs.company_key
    LEFT JOIN business_intelligence.gold.v_dim_dates_bi dates ON dates.date_key = fccs.first_account_date_ct_key
    LEFT JOIN business_intelligence.gold.dim_salesperson_enhanced dse ON dse.salesperson_key = fccs.salesperson_key
    LEFT JOIN business_intelligence.gold.dim_users_bi dub ON fccs.salesperson_user_key = dub.user_key
    LEFT JOIN business_intelligence.gold.bridge_user_employee bue on fccs.salesperson_user_key = bue.user_key

    JOIN ANALYTICS.GS.CREDIT_APP_MASTER_LIST caml on dcb.COMPANY_ID = caml.CUSTOMER_ID
    JOIN analytics.public.market_region_xwalk xw on caml.MARKET_ID = xw.MARKET_ID


    where ( date_trunc(month, dates.date) >= date_trunc(month, dateadd(month, -14, current_date))) and
        (xw.division_name <> 'Materials' OR xw.division_name IS NULL) and
        {% condition region_name_filter %} xw.region_name {% endcondition %}

        )

      , district_selection as (
        select
        distinct district
        from
        analytics.public.market_region_xwalk
        where
        {% condition district_name_filter %} district {% endcondition %}

        )

        , district_selection_count as (
        select
        count(district) as total_districts_selected
        from
        district_selection
        )

        , region_first_district AS (
            select min(district) as first_district, region_name
            from analytics.public.market_region_xwalk xw
            where {% condition region_name_filter %} region_name {% endcondition %}
            group by region_name
        )
        , assigned_district as (
            select
            iff(xw_district.district IS NULL, first_district, xw_district.district) as district
            from analytics.payroll.company_directory
            left join analytics.public.market_region_xwalk xw_district ON xw_district.district = split_part(DEFAULT_COST_CENTERS_FULL_PATH,'/',3)
                and {% condition region_name_filter %} xw_district.region_name {% endcondition %}
            join region_first_district rfd
            where lower(work_email) = '{{ _user_attributes['email'] }}'
            group by iff(xw_district.district IS NULL, first_district, xw_district.district)
        )

      select ncu.*,
      xw.is_open_over_12_months as is_current_months_open_greater_than_twelve,
       xw.market_type as special_locations_type,
            IFF(IFF(dsc.total_districts_selected = 1, ds.district ,ad.district) = xw.district,TRUE,FALSE) as is_selected_district
      from new_customers_union ncu
      join analytics.public.market_region_xwalk xw on ncu.market_id = xw.market_id
        cross join district_selection_count dsc
        left join district_selection ds on dsc.total_districts_selected = 1
        cross join assigned_district ad

        WHERE (xw.division_name <> 'Materials' OR xw.division_name IS NULL)
        and {% condition region_name_filter %} region_name {% endcondition %}


      ;;
  }

  filter: region_name_filter {
    type: string
  }

  filter: district_name_filter {
    type: string
  }

  dimension: is_selected_district {
    type: yesno
    sql: ${TABLE}."IS_SELECTED_DISTRICT" ;;
  }

  dimension: selected_district {
    type: string
    sql: case when ${is_selected_district} = 'Yes' then 'Highlighted' else ' ' end ;;
  }

  measure: count {
    type: count
  }

  dimension: region {
    type: string
    sql: ${TABLE}."REGION" ;;
  }

  dimension: district {
    type: string
    sql: ${TABLE}."DISTRICT" ;;
  }

  dimension: market_id {
    type: string
    sql: ${TABLE}."MARKET_ID" ;;
  }

  dimension: market {
    type: string
    sql: ${TABLE}."MARKET" ;;
  }

  dimension: market_type {
    type: string
    sql: ${TABLE}."MARKET_TYPE" ;;
  }

  dimension: hard_down {
    type: yesno
    sql: ${TABLE}."HARD_DOWN" ;;
  }

  dimension: special_locations_type {
    type: string
    sql: ${TABLE}."SPECIAL_LOCATIONS_TYPE";;
  }

  dimension: months_open_over_12 {
    type: yesno
    sql: ${TABLE}."IS_CURRENT_MONTHS_OPEN_GREATER_THAN_TWELVE" ;;
  }

  dimension: company_id {
    type: string
    label: "Customer ID"
    sql: ${TABLE}."COMPANY_ID" ;;
    primary_key: yes
  }

  dimension: company_name {
    type: string
    label: "Customer"
    sql: ${TABLE}."COMPANY_NAME" ;;
    html:
          <font color="#0063f3 "><a href="https://equipmentshare.looker.com/dashboards/28?Company+Name={{filterable_value}}&Company+ID="target="_blank">{{rendered_value}}</a></font>
          <td>
          <span style="color: #8C8C8C;"> ID: {{company_id._value}} </span>
          </td>;;
  }

  dimension_group: account_opened {
    type: time
    sql: ${TABLE}."NEW_ACCOUNT_DATE" ;;
    html: {{ rendered_value | date: "%b %d, %Y" }};;
  }

  dimension: formatted_month {
    group_label: "HTML Formatted Month"
    label: "Month"
    type: date
    sql: DATE_TRUNC(month, TO_DATE(${account_opened_date})) ;;
    html: {{ rendered_value | date: "%b %Y"  }};;
  }

  dimension: sp_user_id {
    type: string
    label: "User ID"
    sql: ${TABLE}."SP_USER_ID" ;;
  }

  dimension: salesperson {
    type: string
    sql: ${TABLE}."SALESPERSON" ;;
    html: <font color="#0063f3 "><a href="https://equipmentshare.looker.com/dashboards/5?Sales+Rep={{rendered_value}}"target="_blank">{{rendered_value}}</a></font>;;
  }

  dimension: first_rental {
    type: yesno
    sql: ${TABLE}."FIRST_RENTAL" ;;

  }

  dimension: first_order {
    type: yesno
    sql: ${TABLE}."FIRST_ORDER" ;;

  }

  dimension: app_type {
    type: string
    label: "Application Type"
    sql: ${TABLE}."APP_TYPE" ;;
  }




  measure: new_accts {
    type: count_distinct
    sql: ${company_id};;
  }


  set: customer_info {
    fields: [ company_name,
      salesperson,
      region,
      district,
      market,
      account_opened_date,
      app_type
    ]
  }
}
