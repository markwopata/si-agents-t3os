view: markets_and_gms {
  derived_table: {
    sql: SELECT
          MKT.MARKET_ID AS "Market_ID",
          MKT.NAME AS "Market_Name",
          CAST(CONVERT_TIMEZONE('America/Chicago',MKT.DATE_CREATED) AS DATE) AS "Date_Created",
          LOC.STREET_1 AS "Address_Line_1",
          LOC.STREET_2 AS "Address_Line_2",
          LOC.CITY AS "City",
          ST.ABBREVIATION AS "State_Abbreviation",
          ST.NAME AS "State_Name",
          LOC.ZIP_CODE AS "Zip",
          LOC.ZIP_CODE_EXTENDED AS "Plus 4",
          CASE WHEN MKT.ACTIVE THEN 'Yes' ELSE 'No' END AS "Is_Active",
          GM.GM AS "General_Manager",
          GM.EMAIL AS "GM_Email",
          GM.PHONE AS "GM_Phone",
          GM.GM_SUPERVISOR AS "GM_Supervisor",
          CASE WHEN INTLOC.DEPARTMENTID IS NULL THEN 'No' ELSE 'Yes' END AS "In_Intacct",
          INTLOC.DEPARTMENTID AS "In_Intacct_As_ID",
          INTLOC.TITLE AS "In_Intacct_As_Name",
          CASE WHEN CONC_BRANCH.BRANCH_ID IS NULL THEN 'No' ELSE 'Yes' END                           AS "In_Concur",
          CASE WHEN COALESCE(INTLOC.DEPARTMENTID,'-') = coalesce(CONC_BRANCH.BRANCH_ID, '-') THEN '-' ELSE 'Create in Concur' END AS "Flag"
      FROM
          "ES_WAREHOUSE"."PUBLIC"."MARKETS" MKT
          LEFT JOIN "ES_WAREHOUSE"."PUBLIC"."LOCATIONS" LOC ON MKT.LOCATION_ID = LOC.LOCATION_ID
          LEFT JOIN "ES_WAREHOUSE"."PUBLIC"."STATES" ST ON LOC.STATE_ID = ST.STATE_ID
          LEFT JOIN "ES_WAREHOUSE"."PUBLIC"."BRANCH_ERP_REFS" ERP ON MKT.MARKET_ID = ERP.BRANCH_ID
          LEFT JOIN "ANALYTICS"."INTACCT"."DEPARTMENT" INTLOC ON ERP.INTACCT_DEPARTMENT_ID = INTLOC.DEPARTMENTID
          LEFT JOIN (SELECT DISTINCT
                         CB.BRANCH_ID,
                         CB.BRANCH_NAME
                     FROM
                         ANALYTICS.CONCUR.CONCUR_BRANCHES CB
                     WHERE
                         CB.BRANCH_ID NOT IN ('-', 'nan')
                     ORDER BY
                         CB.BRANCH_ID) CONC_BRANCH ON INTLOC.DEPARTMENTID = CONC_BRANCH.BRANCH_ID
          LEFT JOIN (SELECT
                          GM.MARKET_ID AS "MKTID",
                          CONCAT(GM.FIRST_NAME,' ',GM.LAST_NAME) AS "GM",
                          GM.WORK_EMAIL AS "EMAIL",
                          GM.WORK_PHONE AS "PHONE",
                          GM.DIRECT_MANAGER_NAME AS "GM_SUPERVISOR"
                      FROM
                          "ANALYTICS"."PAYROLL"."COMPANY_DIRECTORY" GM
                          JOIN (SELECT
                                    EMP.MARKET_ID,
                                    MIN(EMPLOYEE_ID) AS "GM_ID"
                                FROM
                                    "ANALYTICS"."PAYROLL"."COMPANY_DIRECTORY" EMP
                                WHERE
                                    EMP.EMPLOYEE_STATUS = 'Active'
                                    AND EMP.EMPLOYEE_TITLE = 'General Manager'
                                GROUP BY
                                    EMP.MARKET_ID) GM1 ON GM.EMPLOYEE_ID = GM1.GM_ID) GM ON MKT.MARKET_ID = GM.MKTID
      WHERE
          MKT.COMPANY_ID = 1854
      ORDER BY
          MKT.MARKET_ID
       ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: market_id {
    type: number
    sql: ${TABLE}."Market_ID" ;;
  }

  dimension: market_name {
    type: string
    sql: ${TABLE}."Market_Name" ;;
  }

  dimension: date_created {
    type: date
    sql: ${TABLE}."Date_Created" ;;
  }

  dimension: address_line_1 {
    type: string
    sql: ${TABLE}."Address_Line_1" ;;
  }

  dimension: address_line_2 {
    type: string
    sql: ${TABLE}."Address_Line_2" ;;
  }

  dimension: city {
    type: string
    sql: ${TABLE}."City" ;;
  }

  dimension: state_abbreviation {
    type: string
    sql: ${TABLE}."State_Abbreviation" ;;
  }

  dimension: state_name {
    type: string
    sql: ${TABLE}."State_Name" ;;
  }

  dimension: zip {
    type: number
    sql: ${TABLE}."Zip" ;;
  }

  dimension: plus_4 {
    type: number
    label: "Plus 4"
    sql: ${TABLE}."Plus 4" ;;
  }

  dimension: is_active {
    type: string
    sql: ${TABLE}."Is_Active" ;;
  }

  dimension: general_manager {
    type: string
    sql: ${TABLE}."General_Manager" ;;
  }

  dimension: gm_email {
    type: string
    sql: ${TABLE}."GM_Email" ;;
  }

  dimension: gm_phone {
    type: string
    sql: ${TABLE}."GM_Phone" ;;
  }

  dimension: gm_supervisor {
    type: string
    sql: ${TABLE}."GM_Supervisor" ;;
  }

  dimension: in_intacct {
    type: string
    sql: ${TABLE}."In_Intacct" ;;
  }

  dimension: in_intacct_as_id {
    type: string
    sql: ${TABLE}."In_Intacct_As_ID" ;;
  }

  dimension: in_intacct_as_name {
    type: string
    sql: ${TABLE}."In_Intacct_As_Name" ;;
  }

  dimension: in_concur {
    type: string
    sql: ${TABLE}."In_Concur" ;;
  }

  dimension: flag {
    type: string
    sql: ${TABLE}."Flag" ;;
  }

  set: detail {
    fields: [
      market_id,
      market_name,
      date_created,
      address_line_1,
      address_line_2,
      city,
      state_abbreviation,
      state_name,
      zip,
      plus_4,
      is_active,
      general_manager,
      gm_email,
      gm_phone,
      gm_supervisor,
      in_intacct,
      in_intacct_as_id,
      in_intacct_as_name,
      in_concur,
      flag
    ]
  }
}
