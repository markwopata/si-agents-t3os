view: asset_warranties {
  derived_table: {
    sql:
select w.asset_id
    , listagg(distinct war.description, ' / ') as warranties
    , listagg(distinct wi.description, ' / ') as warranty_items
from ES_WAREHOUSE.PUBLIC.ASSET_WARRANTY_XREF w
join ES_WAREHOUSE.PUBLIC.WARRANTIES war
    on war.warranty_id = w.warranty_id
left join ES_WAREHOUSE.PUBLIC.WARRANTY_ITEMS wi
    on wi.warranty_id = w.warranty_id
where wi.DATE_DELETED is null
    and war.date_deleted is null
    and w.date_deleted is null
group by w.asset_id;;
  }

dimension: asset_id {
  type: number
  value_format_name: id
  sql: ${TABLE}.asset_id ;;
}

dimension: warranties {
  type: string
  sql: ${TABLE}.warranties ;;
}

  dimension: warranty_items {
    type: string
    sql: ${TABLE}.warranty_items ;;
  }
}
