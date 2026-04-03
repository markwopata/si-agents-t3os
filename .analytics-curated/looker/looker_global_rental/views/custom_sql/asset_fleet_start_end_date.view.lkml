view: asset_fleet_start_end_date {
    derived_table: {
      sql:
      select distinct sar.asset_id,
          first_value(date_start) over (partition by asset_id order by date_start asc) as fleet_start,
          last_value(date_end) over (partition by asset_id order by date_start asc) as fleet_end
      from ES_WAREHOUSE.SCD.scd_asset_rsp sar
          join ES_WAREHOUSE.PUBLIC.markets m on sar.rental_branch_id = m.market_id
      where m.company_id = {{ _user_attributes['company_id'] }}
;;
    }

  dimension: asset_id {
    primary_key: yes
    type: number
    sql: ${TABLE}."ASSET_ID";;
    value_format_name: id
  }

  dimension: fleet_start {
    type: date
    sql: ${TABLE}."FLEET_START";;
  }

  dimension: fleet_end {
    type: date
    sql: ${TABLE}."FLEET_END";;
  }
  }
