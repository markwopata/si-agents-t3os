view: region_inventory_information {
  derived_table: {
    # datagroup_trigger: Every_Hour_Update
    sql: with status_table as (
      select
        mr.region,
        mr.region_name,
        mr.district,
        m.market_id,
        m.name as market_name,
        a.rental_branch_id,
        status.asset_inventory_status as asset_inventory_status,
        a.asset_id
      from
          ES_WAREHOUSE.PUBLIC.assets a
          left join ES_WAREHOUSE.PUBLIC.markets m on a.rental_branch_id = m.market_id
          left join ES_WAREHOUSE.PUBLIC.asset_statuses status on a.asset_id = status.asset_id
          left join market_region_xwalk mr on m.market_id = mr.market_id
      where
          a.asset_type_id = 1
          and m.company_id = 1854
          and m.is_public_rsp = true
          and a.deleted = false
          and a.available_for_rent = true
          and ((SUBSTR(TRIM(a.serial_number), 1, 3) != 'RR-' and SUBSTR(TRIM(a.serial_number), 1, 2) != 'RR') or a.serial_number is null)
        ),
      table1 as (
      select
        asset_id,
        max(purchase_history_id) as hist
      from
        ES_WAREHOUSE.PUBLIC.asset_purchase_history
      group by
        asset_id
      ),
      table2 as (
      select
        purchase_history_id as hist,
        coalesce(oec,purchase_price) as purchase_price
      from
        ES_WAREHOUSE.PUBLIC.asset_purchase_history
      ),
      purchase_table as (
      select
        asset_id,
        purchase_price
      from
        table1 t1
        join table2 t2 on t1.hist = t2.hist
      ),
      on_rent_assets as (
      select
        s.region,
        s.region_name,
        s.market_id,
        s.market_name,
        count(s.asset_id) as units_on_rent,
        sum(purchase_price) as oec_on_rent
      from
        status_table s
        left join purchase_table p on s.asset_id = p.asset_id
      where
        s.asset_inventory_status = 'On Rent'
      group by
        s.region,
        s.region_name,
        s.market_id,
        s.market_name
      ),
      total_assets as (
      select
        s.region,
        s.region_name,
        s.market_id,
        s.market_name,
        count(s.asset_id) as total_units,
        sum(purchase_price) as total_oec
      from
        status_table s
        left join purchase_table p on s.asset_id = p.asset_id
      group by
        s.region,
        s.region_name,
        s.market_id,
        s.market_name
      )
      select
        t.region,
        t.region_name,
        t.market_id,
        t.market_name,
        units_on_rent,
        oec_on_rent,
        total_units,
        total_oec
      from
        total_assets t
        left join on_rent_assets r on r.market_name = t.market_name
 ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: pkey {
    primary_key: yes
    type: string
    sql: CONCAT(${region}, ${market_id}) ;;
  }

  dimension: region {
    type: number
    sql: ${TABLE}."REGION" ;;
  }

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

  dimension: units_on_rent {
    type: number
    sql: ${TABLE}."UNITS_ON_RENT" ;;
  }

  dimension: oec_on_rent {
    type: number
    sql: ${TABLE}."OEC_ON_RENT" ;;
  }

  dimension: total_units {
    type: number
    sql: ${TABLE}."TOTAL_UNITS" ;;
  }

  dimension: total_oec {
    type: number
    sql: ${TABLE}."TOTAL_OEC" ;;
  }

  measure: unit_utilization {
    type: number
    sql: (${units_on_rent_for_region}/${total_units_for_region})*100 ;;
    value_format: "0.0\%"
    drill_fields: [market_name,unit_utilization]
  }

  measure: oec_on_rent_percentage {
    type: number
    sql: (${oec_on_rent_for_region}/${total_oec_for_region})*100 ;;
    value_format: "0.0\%"
    drill_fields: [market_name,oec_on_rent_percentage]
  }

  measure: oec_on_rent_for_region {
    type: sum
    sql: ${oec_on_rent} ;;
  }

  measure: total_oec_for_region {
    type: sum
    sql: ${total_oec} ;;
  }

  measure: units_on_rent_for_region {
    type: sum
    sql: ${units_on_rent} ;;
  }

  measure: total_units_for_region {
    type: sum
    sql: ${total_units} ;;
  }

  set: detail {
    fields: [
      region,
      region_name,
      market_id,
      market_name,
      units_on_rent,
      oec_on_rent,
      total_units,
      total_oec
    ]
  }
}
