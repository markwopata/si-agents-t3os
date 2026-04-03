view: assets_needing_exxon_inspection {
  derived_table: {
    sql:
select dm.market_region_name as region --hidden
    , dm.market_district as district --hidden
    , dm.market_name as market
    , r.asset_id
    , da.asset_equipment_subcategory_name as category --hidden
    , da.asset_equipment_class_name as class --hidden
    , da.asset_equipment_make as make
    , da.asset_equipment_model_name as model
    , datediff(day, greatest(r.start_date::DATE, coalesce(wo.last_exxon_inspection, '1970-01-01')), current_date) as days_since_last_exxon_inspection
from ES_WAREHOUSE.PUBLIC.RENTALS r
join ES_WAREHOUSE.PUBLIC.ORDERS o
    on r.order_id = o.order_id
left join (
        select asset_id, max(date_completed::DATE) as last_exxon_inspection
        from ES_WAREHOUSE.WORK_ORDERS.WORK_ORDERS wo
        join ES_WAREHOUSE.WORK_ORDERS.WORK_ORDER_COMPANY_TAGS woct
            on woct.work_order_id = wo.work_order_id
                and woct.company_tag_id = 22239 --Exxon 90 Day Inspection
        where wo.archived_date is null
            and wo.work_order_status_name not ilike '%Open%'
        group by 1
    ) wo
    on wo.asset_id = r.asset_id
join FLEET_OPTIMIZATION.GOLD.DIM_ASSETS_FLEET_OPT da
    on da.asset_id = r.asset_id
join FLEET_OPTIMIZATION.GOLD.DIM_MARKETS_FLEET_OPT dm
    on dm.market_key = da.asset_rental_market_key
where o.company_id in (select company_id from ES_WAREHOUSE.PUBLIC.COMPANIES c where c.name ilike '%exxon%')
    and r.rental_status_id = 5 --On Rent
    and r.asset_id is not null
    and days_since_last_exxon_inspection >= 80;;
  }
 dimension: region {
  type: string
  sql: ${TABLE}.region ;;
 }
  dimension: district {
    type: string
    sql: ${TABLE}.district ;;
  }
  dimension: market {
    type: string
    sql: ${TABLE}.market ;;
  }
  dimension: asset_id {
    type: number
    value_format_name: id
    sql: ${TABLE}.asset_id ;;
    html: <a href="https://app.estrack.com/#/assets/all/asset/{{ asset_id._value }}/service" target="new" style="color: #0063f3; text-decoration: underline;">{{ asset_id._value }}</a> ;;
  }
  dimension: category {
    type: string
    sql: ${TABLE}.category  ;;
  }
  dimension: class {
    type: string
    sql: ${TABLE}.class  ;;
  }
  dimension: make {
    type: string
    sql: ${TABLE}.make  ;;
  }
  dimension: model {
    type: string
    sql: ${TABLE}.model  ;;
  }
  dimension: days_since_last_exxon_inspection {
    type: number
    sql: ${TABLE}.days_since_last_exxon_inspection;;
  }
  measure: count {
    type: count
  }
}
