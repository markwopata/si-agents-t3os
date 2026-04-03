view: sage_access_24hr_group_role_delta {
  derived_table: {
    sql: --Detecting the Change or Creation of new roles within User Groups
      --PR = Previous Record (24 hours ago)
      --CR = Current Record
      --G = Group
      SELECT G.GROUP_NAME,
             --G.RECORDNO,
             PR.ROLEKEY as "PREV_ROLEKEY",
             CR.ROLEKEY as "NEW_ROLEKEY",
             CR.ROLENAME as "NEW_ROLENAME",
             CR.USER_GROUP_KEY,
             (TO_CHAR(TO_DATE(CONVERT_TIMEZONE('UTC', 'America/Chicago', CAST(CR.WHENMODIFIED  AS TIMESTAMP_NTZ))), 'YYYY-MM-DD HH24:MI:SS')) AS "WHENMODIFIED",
             UM.MODIFIER

      FROM "ANALYTICS"."INTACCT"."ROLEASSIGNMENT" CR

      LEFT JOIN (SELECT NAME as "GROUP_NAME",RECORDNO  FROM "ANALYTICS"."INTACCT"."USERGROUP") as G
      on G.RECORDNO = CR.USER_GROUP_KEY

      LEFT JOIN (select ROLEKEY, USER_GROUP_KEY, WHENMODIFIED, WHENCREATED, RECORDNO from "ANALYTICS"."INTACCT"."ROLEASSIGNMENT" at (offset => -60*60*24)) AS PR
      on PR.USER_GROUP_KEY = CR.USER_GROUP_KEY and PR.RECORDNO = CR.RECORDNO

      LEFT JOIN (SELECT DESCRIPTION as "MODIFIER", RECORDNO FROM "ANALYTICS"."INTACCT"."USERINFO") as UM
      on UM.RECORDNO = CR.MODIFIEDBY

      WHERE CR.TYPE = 'G' and PR.ROLEKEY != CR.ROLEKEY or CR.TYPE = 'G' and PR.ROLEKEY is NULL
      ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: group_name {
    type: string
    sql: ${TABLE}."GROUP_NAME" ;;
  }

  dimension: prev_rolekey {
    type: number
    sql: ${TABLE}."PREV_ROLEKEY" ;;
  }

  dimension: new_rolekey {
    type: number
    sql: ${TABLE}."NEW_ROLEKEY" ;;
  }

  dimension: new_rolename {
    type: string
    sql: ${TABLE}."NEW_ROLENAME" ;;
  }

  dimension: user_group_key {
    type: number
    sql: ${TABLE}."USER_GROUP_KEY" ;;
  }

  dimension: whenmodified {
    type: string
    sql: ${TABLE}."WHENMODIFIED" ;;
  }

  dimension: modifier {
    type: string
    sql: ${TABLE}."MODIFIER" ;;
  }

  set: detail {
    fields: [
      group_name,
      prev_rolekey,
      new_rolekey,
      new_rolename,
      user_group_key,
      whenmodified,
      modifier
    ]
  }
}
