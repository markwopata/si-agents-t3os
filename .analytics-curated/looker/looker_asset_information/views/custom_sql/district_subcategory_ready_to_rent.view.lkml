view: district_subcategory_ready_to_rent {
  derived_table: {
    sql:
select m.market_district as district
    , iff(a.asset_equipment_subcategory_name <> 'Unrecognized Equipment Subcategory Name', a.asset_equipment_subcategory_name, a.asset_equipment_class_name) as subcategory_or_class
    , sum(iff(a.asset_inventory_status = 'Ready To Rent', 1, 0)) as assets_in_ready_to_rent_status
    , iff(assets_in_ready_to_rent_status <> 0, TRUE, FALSE) assets_available_to_rent
from FLEET_OPTIMIZATION.GOLD.DIM_ASSETS_FLEET_OPT a
join FLEET_OPTIMIZATION.GOLD.DIM_MARKETS_FLEET_OPT m
    on m.market_key = iff(asset_rental_market_id <> -1, asset_rental_market_key, asset_inventory_market_key)
group by 1,2 ;;
  }
 dimension: district {
   type: string
   sql: ${TABLE}.district ;;
 }

  dimension: subcategory_or_class {
    type: string
    sql: ${TABLE}.subcategory_or_class ;;
  }

  dimension: assets_in_ready_to_rent_status {
    type: number
    sql: ${TABLE}.assets_in_ready_to_rent_status ;;
  }

  dimension: district_class_available_to_rent {
    type: yesno
    sql: coalesce(${TABLE}.assets_available_to_rent, FALSE) ;;
  }
}
