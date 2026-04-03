
view: items {
  sql_table_name: procurement.public__silver.items  ;;


  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: item_id {
    type: string
    sql: ${TABLE}."ITEM_ID" ;;
  }

  dimension: buyable {
    type: yesno
    sql: ${TABLE}."BUYABLE" ;;
  }

  dimension: company_id {
    type: string
    sql: ${TABLE}."COMPANY_ID" ;;
  }

  dimension: created_by_id {
    type: string
    sql: ${TABLE}."CREATED_BY_ID" ;;
  }

  dimension_group: date_archived {
    type: time
    sql: ${TABLE}."DATE_ARCHIVED" ;;
  }

  dimension_group: date_created {
    type: time
    sql: ${TABLE}."DATE_CREATED" ;;
  }

  dimension_group: date_updated {
    type: time
    sql: ${TABLE}."DATE_UPDATED" ;;
  }

  dimension: duplicate_of_id {
    type: string
    sql: ${TABLE}."DUPLICATE_OF_ID" ;;
  }

  dimension: item_type {
    type: string
    sql: ${TABLE}."ITEM_TYPE" ;;
  }

  dimension: modified_by_id {
    type: string
    sql: ${TABLE}."MODIFIED_BY_ID" ;;
  }

  dimension: preferred_vendor_id {
    type: string
    sql: ${TABLE}."PREFERRED_VENDOR_ID" ;;
  }

  dimension: sellable {
    type: yesno
    sql: ${TABLE}."SELLABLE" ;;
  }

  dimension: item_service {
    type: string
    sql:  case
            when ${item_type} = 'INVENTORY'
            then 'A1301 - Equipment Parts Inventory'
            when ${item_type} = 'NON_INVENTORY'
            then ${non_inventory_items.name}
        end ;;
  }

  dimension_group: _items_effective_start_utc_datetime {
    type: time
    sql: ${TABLE}."_ITEMS_EFFECTIVE_START_UTC_DATETIME" ;;
  }

  dimension_group: _items_effective_delete_utc_datetime {
    type: time
    sql: ${TABLE}."_ITEMS_EFFECTIVE_DELETE_UTC_DATETIME" ;;
  }

  set: detail {
    fields: [
        item_id,
  buyable,
  company_id,
  created_by_id,
  date_archived_time,
  date_created_time,
  date_updated_time,
  duplicate_of_id,
  item_type,
  modified_by_id,
  preferred_vendor_id,
  sellable,
  _items_effective_start_utc_datetime_time,
  _items_effective_delete_utc_datetime_time
    ]
  }
}
