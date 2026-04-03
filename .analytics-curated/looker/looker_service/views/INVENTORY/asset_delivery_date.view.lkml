view: asset_delivery_date {
  sql_table_name: "ANALYTICS"."PARTS_INVENTORY"."ASSET_DELIVERY_DATE";;

dimension: asset_id {
  type: number
  value_format_name: id
  primary_key: yes
  sql: ${TABLE}.asset_id ;;
}

dimension: delivery_date {
  type: date
  sql: ${TABLE}.delivery_date ;;
}

dimension: missing_delivery_date {
  type: yesno
  sql: iff(${TABLE}.delivery_date is null, true, false) ;;
}
}
