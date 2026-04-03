view: sage_access_24hr_group_delta {
  derived_table: {
    sql: --Detecting creation and changes made to User Groups.
      --PR = Previous Record (24 hours ago)
      --CR = Current Record
      --UC = Creator
      --UM = Modifier
      SELECT --CR.RECORDNO,
             PR.PRIOR_NAME,
             CR.NAME as "NEW_NAME",
             (TO_CHAR(TO_DATE(CONVERT_TIMEZONE('UTC', 'America/Chicago', CAST(CR.WHENCREATED  AS TIMESTAMP_NTZ))), 'YYYY-MM-DD HH24:MI:SS')) AS "WHENCREATED",
             UC.CREATOR,
             (TO_CHAR(TO_DATE(CONVERT_TIMEZONE('UTC', 'America/Chicago', CAST(CR.WHENMODIFIED  AS TIMESTAMP_NTZ))), 'YYYY-MM-DD HH24:MI:SS')) AS "WHENMODIFIED",
             UM.MODIFIER

      from "ANALYTICS"."INTACCT"."USERGROUP" as CR

      LEFT JOIN (select NAME AS "PRIOR_NAME", RECORDNO from "ANALYTICS"."INTACCT"."USERGROUP" at (offset => -60*60*24)) AS PR
      on CR.RECORDNO = PR.RECORDNO

      LEFT JOIN (SELECT DESCRIPTION as "CREATOR", RECORDNO FROM "ANALYTICS"."INTACCT"."USERINFO") as UC
      on UC.RECORDNO = CR.CREATEDBY

      LEFT JOIN (SELECT DESCRIPTION as "MODIFIER", RECORDNO FROM "ANALYTICS"."INTACCT"."USERINFO") as UM
      on UM.RECORDNO = CR.MODIFIEDBY

      where CR.NAME != PR.PRIOR_NAME or PR.PRIOR_NAME is NULL
      ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: prior_name {
    type: string
    sql: ${TABLE}."PRIOR_NAME" ;;
  }

  dimension: new_name {
    type: string
    sql: ${TABLE}."NEW_NAME" ;;
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
      prior_name,
      new_name,
      whencreated,
      creator,
      whenmodified,
      modifier
    ]
  }
}
