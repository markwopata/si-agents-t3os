view: market_region_salesperson_rank_amount {
  derived_table: {
    # datagroup_trigger: 6AM_update
    sql: with salesperson_rank as (
        select
          salesperson_user_id,
          first_name,
          last_name,
          market_id,
          district,
          region,
          region_name,
          RANK() OVER(
                  partition by salesperson_user_id order by amount desc) as AmountRank
        from
          market_region_salesperson as mrs
        )
        select
          salesperson_user_id,
          first_name,
          last_name,
          market_id,
          district,
          region,
          region_name
        from
          salesperson_rank
        where
          AmountRank = 1
       ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: salesperson_user_id {
    type: number
    sql: ${TABLE}."SALESPERSON_USER_ID" ;;
  }

  dimension: first_name {
    type: string
    sql: ${TABLE}."FIRST_NAME" ;;
  }

  dimension: last_name {
    type: string
    sql: ${TABLE}."LAST_NAME" ;;
  }

  dimension: market_id {
    type: number
    sql: ${TABLE}."MARKET_ID" ;;
  }

  dimension: district {
    type: number
    sql: ${TABLE}."DISTRICT" ;;
  }

  dimension: region {
    type: number
    sql: ${TABLE}."REGION" ;;
  }

  dimension: region_name {
    type: string
    sql: ${TABLE}."REGION_NAME" ;;
  }

  dimension: Full_Name_with_ID{
    type:  string
    sql: concat(${first_name},' ',${last_name},' - ',${salesperson_user_id}) ;;
  }

  dimension: Salesperson_District_Region_Market_Access {
    type: yesno
    sql:
    ${market_region_salesperson_rank_amount.district} in ({{ _user_attributes['district'] }}) OR ${market_region_salesperson_rank_amount.region_name} in ({{ _user_attributes['region'] }}) OR ${market_region_salesperson_rank_amount.market_id} in ({{ _user_attributes['market_id'] }}) ;;
  }

  set: detail {
    fields: [
      salesperson_user_id,
      first_name,
      last_name,
      market_id,
      district,
      region,
      region_name
    ]
  }
}
