view: sage_access_24hr_group_member_delta {
  derived_table: {
    sql: --Detect a new user being added to a group.
      --UG = Group Members
      --CG = Current Group
      --PG = Group Mmebers 24 hours ago
      --U = User affected
      --UM = Modifier
      SELECT U.USER,
             UG.USERKEY,
             CG.GROUP_NAME,
             UG.WHENMODIFIED,
             UM.MODIFIER

      FROM "ANALYTICS"."INTACCT"."MEMBERUSERGROUP" as UG

      LEFT JOIN (SELECT RECORDNO, NAME as "GROUP_NAME"  FROM "ANALYTICS"."INTACCT"."USERGROUP") AS CG
      on CG.RECORDNO = UG.USERGROUPKEY

      LEFT JOIN (select USERGROUPKEY, RECORDNO, USERKEY  from "ANALYTICS"."INTACCT"."MEMBERUSERGROUP" at (offset => -60*60*24)) AS PG
      on PG.RECORDNO = UG.RECORDNO and PG.USERGROUPKEY = UG.USERGROUPKEY and PG.USERKEY = UG.USERKEY

      LEFT JOIN (SELECT DESCRIPTION as "USER", RECORDNO FROM "ANALYTICS"."INTACCT"."USERINFO") as U
      on U.RECORDNO = UG.USERKEY

      LEFT JOIN (SELECT DESCRIPTION as "MODIFIER", RECORDNO FROM "ANALYTICS"."INTACCT"."USERINFO") as UM
      on UM.RECORDNO = UG.MODIFIEDBY

      where U.RECORDNO is not NULL and PG.USERGROUPKEY is  NULL
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

  dimension: userkey {
    type: number
    sql: ${TABLE}."USERKEY" ;;
  }

  dimension: group_name {
    type: string
    sql: ${TABLE}."GROUP_NAME" ;;
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
    fields: [user, userkey, group_name, whenmodified_time, modifier]
  }
}
