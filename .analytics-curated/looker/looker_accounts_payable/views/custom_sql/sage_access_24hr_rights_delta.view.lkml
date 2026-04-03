view: sage_access_24hr_rights_delta {
  derived_table: {
    sql: --Detecting Changes in or creation of Rights to Users
      --PR = Previous Record (24 hours ago)
      --CR = Current Record
      --UC = Creator
      --UM = Modifier
      --R = The Role the New Rights connects to
      SELECT --CR.RECORDNO,
             R.ROLE_NAME,
             CR.POLICYNAME as "POLICY",
             PR.PRIOR_RIGHTS,
             CR.RIGHTS as "NEW_RIGHTS",
             (TO_CHAR(TO_DATE(CONVERT_TIMEZONE('UTC', 'America/Chicago', CAST(CR.WHENCREATED  AS TIMESTAMP_NTZ))), 'YYYY-MM-DD HH24:MI:SS')) AS "WHENCREATED",
             UC.CREATOR,
             (TO_CHAR(TO_DATE(CONVERT_TIMEZONE('UTC', 'America/Chicago', CAST(CR.WHENMODIFIED  AS TIMESTAMP_NTZ))), 'YYYY-MM-DD HH24:MI:SS')) AS "WHENMODIFIED",
             UM.MODIFIER

      FROM "ANALYTICS"."INTACCT"."ROLEPOLICYASSIGNMENT" CR

      LEFT JOIN (select RIGHTS AS "PRIOR_RIGHTS", RECORDNO from "ANALYTICS"."INTACCT"."ROLEPOLICYASSIGNMENT" at (offset => -60*60*24)) AS PR
      on CR.RECORDNO = PR.RECORDNO

      LEFT JOIN (SELECT DESCRIPTION as "CREATOR", RECORDNO FROM "ANALYTICS"."INTACCT"."USERINFO") as UC
      on UC.RECORDNO = CR.CREATEDBY

      LEFT JOIN (SELECT DESCRIPTION as "MODIFIER", RECORDNO FROM "ANALYTICS"."INTACCT"."USERINFO") as UM
      on UM.RECORDNO = CR.MODIFIEDBY

      LEFT JOIN (SELECT NAME as "ROLE_NAME", RECORDNO FROM "ANALYTICS"."INTACCT"."ROLES") as R
      on R.RECORDNO = CR.ROLEKEY

      where CR.RIGHTS != PR.PRIOR_RIGHTS or PR.PRIOR_RIGHTS is NULL
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

  dimension: policy {
    type: string
    sql: ${TABLE}."POLICY" ;;
  }

  dimension: prior_rights {
    type: string
    sql: ${TABLE}."PRIOR_RIGHTS" ;;
  }

  dimension: new_rights {
    type: string
    sql: ${TABLE}."NEW_RIGHTS" ;;
  }

  dimension: whencreated {
    type: string
    sql: ${TABLE}."WHENCREATED" ;;
  }

  dimension: creator {
    type: string
    sql: ${TABLE}."CREATOR" ;;
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
      role_name,
      policy,
      prior_rights,
      new_rights,
      whencreated,
      creator,
      whenmodified,
      modifier
    ]
  }
}
