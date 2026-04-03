view: sage_access_24hr_policy_delta {
  derived_table: {
    sql: --Detecting changes to Policies or the creation of new Policies.
      --PR = Previous Record (24 hours ago)
      --CR = Current Record
      --UC = Creator
      --UM = Modifier
      --role = The Role the Policy connects to
      SELECT
      //       CR.RECORDNO,
             R.ROLE_NAME,
             PR.PRIOR_POLICY,
             CR.POLICYNAME as "NEW_POLICY",
             PR.RIGHTS AS "OLD_RIGHTS",
             CR.RIGHTS as "NEW_RIGHTS",
             CR.WHENCREATED,
             UC.CREATOR,
             CR.WHENMODIFIED,
             UM.MODIFIER

      FROM "ANALYTICS"."INTACCT"."ROLEPOLICYASSIGNMENT" CR

      LEFT JOIN (select POLICYNAME AS "PRIOR_POLICY", RIGHTS, RECORDNO from "ANALYTICS"."INTACCT"."ROLEPOLICYASSIGNMENT" at (offset => -60*60*24)) AS PR
      on CR.RECORDNO = PR.RECORDNO

      LEFT JOIN (SELECT DESCRIPTION as "CREATOR", RECORDNO FROM "ANALYTICS"."INTACCT"."USERINFO") as UC
      on UC.RECORDNO = CR.CREATEDBY

      LEFT JOIN (SELECT DESCRIPTION as "MODIFIER", RECORDNO FROM "ANALYTICS"."INTACCT"."USERINFO") as UM
      on UM.RECORDNO = CR.MODIFIEDBY

      LEFT JOIN (SELECT NAME as "ROLE_NAME", RECORDNO FROM "ANALYTICS"."INTACCT"."ROLES") as R
      on R.RECORDNO = CR.ROLEKEY

      where CR.POLICYNAME != PR.PRIOR_POLICY or PR.PRIOR_POLICY is NULL
      ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: role_name {
    type: string
    sql: ${TABLE}."ROLE_NAME" ;;
  }

  dimension: prior_policy {
    type: string
    sql: ${TABLE}."PRIOR_POLICY" ;;
  }

  dimension: new_policy {
    type: string
    sql: ${TABLE}."NEW_POLICY" ;;
  }

  dimension: old_rights {
    type: string
    sql: ${TABLE}."OLD_RIGHTS" ;;
  }

  dimension: new_rights {
    type: string
    sql: ${TABLE}."NEW_RIGHTS" ;;
  }

  dimension_group: whencreated {
    type: time
    sql: ${TABLE}."WHENCREATED" ;;
  }

  dimension: creator {
    type: string
    sql: ${TABLE}."CREATOR" ;;
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
      role_name,
      prior_policy,
      new_policy,
      old_rights,
      new_rights,
      whencreated_time,
      creator,
      whenmodified_time,
      modifier
    ]
  }
}
