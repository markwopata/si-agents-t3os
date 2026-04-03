view: t3_group_permissions {
  derived_table: {
    sql: SELECT
          g.GROUP_ID,
          g.NAME,
          g.SPENDING_LIMIT
      FROM "ES_WAREHOUSE"."INVENTORY"."GROUPS" g

      WHERE g.COMPANY_ID = 1854

      AND g.name LIKE '%Purchase Order%'
      AND g.date_archived is NULL
      order by g.name ASC
      ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: group_id {
    type: number
    sql: ${TABLE}."GROUP_ID" ;;
  }

  dimension: name {
    type: string
    sql: ${TABLE}."NAME" ;;
  }

  dimension: spending_limit {
    type: number
    sql: ${TABLE}."SPENDING_LIMIT" ;;
  }

  set: detail {
    fields: [group_id, name,spending_limit]
  }
}
