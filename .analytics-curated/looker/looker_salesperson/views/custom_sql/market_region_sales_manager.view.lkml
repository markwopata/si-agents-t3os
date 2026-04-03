view: market_region_sales_manager {
  derived_table: {
    # datagroup_trigger: Every_Two_Hours_Update
    sql: with total_rev as(
      select
      salesperson_user_id
      ,concat(first_name,' ',last_name) as salesperson
      ,district
      ,region
      --,concat(region, '-', district) as region_district
      ,region_name
      ,mrs.market_id
      ,m.name as market_name
      ,sum(amount::NUMERIC(20,2) ) as total_rev
      from market_region_salesperson mrs
      left join ES_WAREHOUSE.public.markets m
        on mrs.market_id=m.market_id
       group by
       salesperson_user_id
      ,concat(first_name,' ',last_name)
      ,district
      ,region
      --,concat(region, '-', district)
      ,region_name
      ,mrs.market_id
      ,m.name
      order by salesperson_user_id
      )
      ,rep_rank as(
      select
      salesperson_user_id
      ,salesperson
      ,district
      ,region
      --,region_district
      ,region_name
      ,market_id
      ,market_name
      ,ROW_NUMBER() OVER (PARTITION BY salesperson_user_id ORDER BY total_rev DESC) AS rn
      from total_rev ah
      )
      select
      rr.*
      , rr.market_name = si.home_market_dated as is_current_home
      from
      rep_rank rr
      left join analytics.bi_ops.salesperson_info si on rr.salesperson_user_id = si.user_id and
            si.employee_status_present = 'Active' and
            si.record_ineffective_date IS NULL and
            lower(si.employee_title_dated) = 'territory account manager'
      --where rn=1
       QUALIFY ROW_NUMBER() OVER(partition by salesperson_user_id ORDER BY is_current_home DESC, rn) = 1 -- to tie active TAMs to their current home market if they
       ;;
  }

  measure: count {
    type: count
    drill_fields: [region_name, salesperson]
  }

  dimension: salesperson_user_id {
    type: number
    sql: ${TABLE}."SALESPERSON_USER_ID" ;;
  }

  dimension: salesperson {
    type: string
    sql: ${TABLE}."SALESPERSON" ;;
  }

  dimension: district {
    type: string
    sql: ${TABLE}."DISTRICT" ;;
  }

  dimension: region {
    type: number
    sql: ${TABLE}."REGION" ;;
  }

  # dimension: region_district {
  #   type: string
  #   sql: ${TABLE}."REGION_DISTRICT" ;;
  # }

  dimension: region_name {
    type: string
    sql: ${TABLE}."REGION_NAME" ;;
  }

  dimension: market_id {
    type: number
    sql: ${TABLE}."MARKET_ID" ;;
  }

  dimension: market_name {
    type: string
    sql: ${TABLE}."MARKET_NAME" ;;
  }

  dimension: rn {
    type: number
    sql: ${TABLE}."RN" ;;
  }

  dimension: Full_Name_with_ID{
    type:  string
    sql: concat(${salesperson},' - ',${salesperson_user_id}) ;;
  }

  dimension: Salesperson_District_Region_Market_Access {
    type: yesno
    sql:
          ${market_region_salesperson.district} in ({{ _user_attributes['district'] }}) OR ${market_region_salesperson.region_name} in ({{ _user_attributes['region'] }}) OR ${market_region_salesperson.market_id} in ({{ _user_attributes['market_id'] }}) ;;
  }

  set: detail {
    fields: [
      salesperson_user_id,
      salesperson,
      district,
      region,
      region_name,
      market_id,
      market_name,
      rn
    ]
  }
}
