view: msa {
  derived_table: {
    sql: SELECT substring(proj_cap.P_ZIP_CODE,0,5) AS project_zip_code,
CASE WHEN msa.msa IS NULL THEN proj_cap.P_CITY_NAME||', '||proj_cap.P_STATE_ID ELSE msa.msa END AS msa
FROM INBOUND.DODGE_CONSTRUCTION_VIEW.FF_OUT_REP_PROJECT_CAPSULE AS proj_cap
LEFT JOIN ANALYTICS."PUBLIC".MSA AS msa
ON substring(proj_cap.P_ZIP_CODE,0,5) = msa.zip_code
                               ;;
  }



  dimension: project_zip_code {
    type: string
    sql: ${TABLE}.project_zip_code ;;
  }

  dimension: msa {
    type: string
    sql: ${TABLE}.msa ;;
  }


  }
