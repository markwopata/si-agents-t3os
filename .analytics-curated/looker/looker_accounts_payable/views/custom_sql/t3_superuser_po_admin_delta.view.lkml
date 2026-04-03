view: t3_superuser_po_admin_delta {
  derived_table: {
    sql: --Need to know when someone is added to the Superuser and recieved purchase order admin groups
      --ug = User Groups
      --g = Current Groups
      --pg = Previous Groups
      --u = Users
      SELECT concat(u.first_name,' ',u.last_name) as user_name,
             ug.GROUP_ID,
             g.CUR_GROUPNAME,
             (TO_CHAR(TO_DATE(CONVERT_TIMEZONE('UTC', 'America/Chicago', CAST(ug.DATE_CREATED  AS TIMESTAMP_NTZ))), 'YYYY-MM-DD')) AS "WHENCREATED"

      FROM "ES_WAREHOUSE"."INVENTORY"."USER_GROUPS" ug

      LEFT JOIN (SELECT GROUP_ID as "CUR_GROUP", NAME as "CUR_GROUPNAME" FROM "ES_WAREHOUSE"."INVENTORY"."GROUPS") as g ON g.CUR_GROUP = ug.GROUP_ID

      LEFT JOIN (select GROUP_ID as "PREV_GROUP", USER_ID from "ES_WAREHOUSE"."INVENTORY"."USER_GROUPS" at (offset => -60*60*24)) AS pg
      on pg.PREV_GROUP = ug.GROUP_ID and pg.USER_ID = ug.USER_ID

      left join ES_WAREHOUSE.PUBLIC.users u on u.user_id = ug.user_id


      WHERE pg.PREV_GROUP is NULL and g.CUR_GROUPNAME = 'SuperUser' or pg.PREV_GROUP is NULL and g.CUR_GROUPNAME = 'Received Purchase Order Admin'
      ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: user_name {
    type: string
    sql: ${TABLE}."USER_NAME" ;;
  }

  dimension: group_id {
    type: number
    sql: ${TABLE}."GROUP_ID" ;;
  }

  dimension: cur_groupname {
    type: string
    sql: ${TABLE}."CUR_GROUPNAME" ;;
  }

  dimension: whencreated {
    type: string
    sql: ${TABLE}."WHENCREATED" ;;
  }

  set: detail {
    fields: [user_name, group_id, cur_groupname, whencreated]
  }
}
