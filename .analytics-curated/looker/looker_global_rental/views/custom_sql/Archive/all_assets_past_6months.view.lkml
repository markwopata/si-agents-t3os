view: all_assets_past_6months {
  derived_table: {
    sql:
        select distinct
          first_value(a.asset_id) over (partition by a.asset_id order by sai.date_start) as asset_id,
          coalesce(a.asset_class, 'No Asset Class') as asset_class,
          a.company_id as asset_owner_id
        from  ES_WAREHOUSE.PUBLIC.assets a
            join ES_WAREHOUSE.SCD.scd_asset_inventory sai on sai.asset_id = a.asset_id
            join ES_WAREHOUSE.PUBLIC.markets m on coalesce(a.rental_branch_id, a.inventory_branch_id) = m.market_id
        where m.company_id = {{ _user_attributes['company_id'] }}
            and ES_WAREHOUSE.PUBLIC.overlaps(sai.date_start, sai.date_end, convert_timezone('{{ _user_attributes['user_timezone'] }}', current_timestamp)::date - interval '6 months', convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC', current_timestamp)::date + interval '1 day')
        ;;
  }

    dimension: asset_id {
      primary_key: yes
      type: number
      sql: ${TABLE}."ASSET_ID" ;;
      value_format_name: id
    }

    dimension: asset_class {
      type: string
      sql: ${TABLE}."ASSET_CLASS" ;;
    }

    dimension: date_start {
      type: date_time
      sql: ${TABLE}."DATE_START" ;;
    }

    dimension: date_end {
      type: date_time
      sql: ${TABLE}."DATE_END" ;;
    }

    dimension: asset_owner_id {
      type: number
      sql: ${TABLE}."ASSET_OWNER_ID" ;;
      value_format_name: id
    }

  }