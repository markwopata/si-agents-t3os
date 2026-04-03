view: transportation_assets {
  derived_table: {
    sql:  select
            a.asset_id,
            coalesce(a.service_branch_id,a.inventory_branch_id) as market_id,
            iff(sum(case
              when (a.asset_type_id = 1 and upper(asi.maintenance_group_interval_name) like '%90 DAY%') then 1
              else '0' end) > 0,'RENTED','OWNED') as owned_or_rented,
            iff(sum(case
              when a.asset_type_id in (2,3) then 1
              when (a.asset_type_id = 1 and upper(asi.maintenance_group_interval_name) like '%DOT%') then 1
              when a.asset_class in ('Delivery Trailer'
                                    , 'Delivery Trucks'
                                    , 'Dual Axle Dump Truck, 10 - 12 Yd'
                                    , 'Office Trailer, 8%20%'
                                    , 'Service Truck'
                                    , 'Single Axle Dump Truck, 3/4 Yd - Diesel'
                                    , 'Single Axle Dump Truck, 5/6 Yd - Diesel'
                                    , 'Water Truck 2,000 - 2,500 Gal - Diesel'
                                    , 'Water Truck 4,000 - 4,500 Gal  - Diesel') then 1
              else '0' end) > 0 and a.company_id in (select company_id from analytics.public.es_companies where owned = true),'YES','NO')
              as transportation_asset,
              ifnull(
                nullif(
                  listagg(
                    iff(asi.maintenance_group_interval_name ilike any ('%BIT %','%DOT %','%90 Day%','%Crane%','%In-House%','%Annual%','%Yearey%','%50,000%'),null,maintenance_group_interval_name)
                    ,', ')
                  ,'')
                ,'None')
              as pms
          from es_warehouse.public.assets as a
          left join es_warehouse.public.asset_service_intervals as asi
            on asi.asset_id = a.asset_id
          group by a.asset_id, a.company_id, a.service_branch_id, a.inventory_branch_id;;
  }

  dimension: asset_id {
    type: number
    sql: ${TABLE}."ASSET_ID" ;;
    html: <font color="blue "><u><a href="https://app.estrack.com/#/assets/all/asset/{{ asset_id }}/history?" target="_blank">{{rendered_value}}</a></font></u> ;;
    value_format: "0"
  }

  dimension: market_id {
    type: number
    sql: ${TABLE}."MARKET_ID" ;;
    value_format: "0"
  }

  dimension: transportation_asset {
    type: string
    sql: ${TABLE}."TRANSPORTATION_ASSET" ;;
  }

  dimension: owned_or_rented {
    type: string
    sql: ${TABLE}."OWNED_OR_RENTED" ;;
  }

  dimension: pms {
    type: string
    sql: ${TABLE}."PMS" ;;
  }
}
