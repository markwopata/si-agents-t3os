view: sage_access_24hr_user_roles_delta {
  derived_table: {
    sql: --Detects individual users gaining access to RoleKeys outside of groups.
      --Detecting the Change or Creation of new roles within User Groups
      --PR = Previous Record (24 hours ago)
      --CR = Current Record
      --U = User
      --UM = Modifier
      SELECT U.USER,
             PR.ROLEKEY as "PREV_ROLEKEY",
             PR.ROLENAME as "PREV_ROLENAME",
             CR.ROLEKEY as "NEW_ROLEKEY",
             CR.ROLENAME as "NEW_ROLENAME",
             CR.WHENMODIFIED,
             UM.MODIFIER

      FROM "ANALYTICS"."INTACCT"."ROLEASSIGNMENT" CR

      LEFT JOIN (select ROLEKEY, USER_GROUP_KEY, WHENMODIFIED, RECORDNO, ROLENAME from "ANALYTICS"."INTACCT"."ROLEASSIGNMENT" at (offset => -60*60*24)) AS PR
      on PR.USER_GROUP_KEY = CR.USER_GROUP_KEY and PR.RECORDNO = CR.RECORDNO

      LEFT JOIN (SELECT DESCRIPTION as "USER", RECORDNO FROM "ANALYTICS"."INTACCT"."USERINFO") as U
      on U.RECORDNO = CR.USER_GROUP_KEY

      LEFT JOIN (SELECT DESCRIPTION as "MODIFIER", RECORDNO FROM "ANALYTICS"."INTACCT"."USERINFO") as UM
      on UM.RECORDNO = CR.MODIFIEDBY

      WHERE CR.TYPE = 'U' and PR.ROLEKEY != CR.ROLEKEY or CR.TYPE = 'U' and PR.ROLEKEY is NULL
      ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: user {
    type: string
    sql: ${TABLE}."USER" ;;
  }

  dimension: prev_rolekey {
    type: number
    sql: ${TABLE}."PREV_ROLEKEY" ;;
  }

  dimension: prev_rolename {
    type: string
    sql: ${TABLE}."PREV_ROLENAME" ;;
  }

  dimension: new_rolekey {
    type: number
    sql: ${TABLE}."NEW_ROLEKEY" ;;
  }

  dimension: new_rolename {
    type: string
    sql: ${TABLE}."NEW_ROLENAME" ;;
  }

  dimension_group: whenmodified {
    type: time
    sql: ${TABLE}."WHENMODIFIED" ;;
  }

  dimension: modifier {
    type: string
    sql: ${TABLE}."MODIFIER" ;;
  }

  set: detail {
    fields: [
      user,
      prev_rolekey,
      prev_rolename,
      new_rolekey,
      new_rolename,
      whenmodified_time,
      modifier
    ]
  }
}
