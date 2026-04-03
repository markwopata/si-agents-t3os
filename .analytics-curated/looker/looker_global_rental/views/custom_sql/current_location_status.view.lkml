view: current_location_status {
  derived_table: {
    sql:
    with asset_list as (
      select asset_id
      from ES_WAREHOUSE.PUBLIC.assets a
        left join ES_WAREHOUSE.PUBLIC.markets m on coalesce(a.rental_branch_id, a.inventory_branch_id) = m.market_id
              and m.company_id = '{{ _user_attributes['company_id'] }}'::numeric
      )
      , street as (
      select akv.asset_id, akv.value as street
      from ES_WAREHOUSE.PUBLIC.asset_status_key_values akv
      join asset_list al on al.asset_id = akv.asset_id
      where akv.name = 'street'
      )
      , city as (
      select akv.asset_id, akv.value as city
      from ES_WAREHOUSE.PUBLIC.asset_status_key_values akv
      join asset_list al on al.asset_id = akv.asset_id
      where akv.name = 'city'
      )
      , state as (
      select b.asset_id, st.abbreviation as state
      from (
        select akv.asset_id, akv.value as state_id
        from ES_WAREHOUSE.PUBLIC.asset_status_key_values akv
        join asset_list al on al.asset_id = akv.asset_id
        where akv.name = 'state_id') b
      left join ES_WAREHOUSE.PUBLIC.states st on b.state_id = st.state_id
      )
      , zip_code as (
      select akv.asset_id, akv.value as zip_code
      from ES_WAREHOUSE.PUBLIC.asset_status_key_values akv
      join asset_list al on al.asset_id = akv.asset_id
      where akv.name = 'zip_code'
      )
      , inventory_status as (
      select akv.asset_id, akv.value as inventory_status
      from ES_WAREHOUSE.PUBLIC.asset_status_key_values akv
      join asset_list al on al.asset_id = akv.asset_id
      where akv.name = 'asset_inventory_status'
      )
      select al.asset_id, concat_ws(', ', street, city, state) || ' ' || zip_code as current_location,
        i.inventory_status
      from asset_list al
        left join street s on al.asset_id = s.asset_id
        left join city c on al.asset_id = c.asset_id
        left join state st on al.asset_id = st.asset_id
        left join zip_code z on al.asset_id = z.asset_id
        left join inventory_status i on al.asset_id = i.asset_id
    ;;
  }
  dimension: asset_id {
    primary_key: yes
    type: number
    sql: ${TABLE}."ASSET_ID" ;;
  }

  dimension: current_location {
    type: string
    sql: ${TABLE}."CURRENT_LOCATION" ;;
  }

  dimension: inventory_status {
    type: string
    sql: ${TABLE}."INVENTORY_STATUS" ;;
  }
 }
