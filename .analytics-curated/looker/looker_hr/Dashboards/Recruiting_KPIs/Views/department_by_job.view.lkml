view: department_by_job{
  derived_table: {
    sql:WITH o1 as (SELECT JOB_ID, DEPARTMENT_ID
FROM (SELECT *, ROW_NUMBER () OVER (PARTITION BY JOB_ID ORDER BY _FIVETRAN_SYNCED DESC) AS rn FROM ANALYTICS.GREENHOUSE.JOB_DEPARTMENT)
where rn = 1),

o2 as (SELECT * from o1 LEFT JOIN
 (SELECT * FROM ANALYTICS.GREENHOUSE.DEPARTMENT) jo2
ON o1.DEPARTMENT_ID = jo2.ID)

SELECT * from o2 left join
 (SELECT * FROM ANALYTICS.GREENHOUSE.DEPARTMENT_DIVISION_XWALK) di
ON o2.NAME = di.DEPARTMENT left join
(SELECT ID, NAME AS DEPARTMENT_JOB_NAME from ANALYTICS.GREENHOUSE.JOB) jo
on o2.JOB_ID = jo.ID;;
  }


  dimension: job_id {
    primary_key: yes
    type: number
    sql: ${TABLE}."JOB_ID" ;;
  }

  dimension: department_id {
    type: string
    sql: ${TABLE}."DEPARTMENT_ID" ;;
  }

  dimension: department_name {
    type: string
    sql: ${TABLE}."NAME" ;;
  }

  dimension: department {
    type: string
    sql: ${TABLE}."DEPARTMENT" ;;
  }


  dimension: division {
    type: string
    sql: CASE
    WHEN ${TABLE}."DIVISION"='Management' AND CONTAINS(${TABLE}."DEPARTMENT_JOB_NAME", 'General Manager') THEN 'Rental'
    WHEN ${TABLE}."DIVISION"='Management' AND CONTAINS(${TABLE}."DEPARTMENT_JOB_NAME", 'District Operations Manager') THEN 'Rental'
    WHEN ${TABLE}."DIVISION"='Management' AND CONTAINS(${TABLE}."DEPARTMENT_JOB_NAME", 'Regional Sales Manager') THEN 'Rental'
    WHEN ${TABLE}."DIVISION"='Management' AND CONTAINS(${TABLE}."DEPARTMENT_JOB_NAME", 'Sales Manager') THEN 'Rental'
    WHEN ${TABLE}."DIVISION"='Management' AND CONTAINS(${TABLE}."DEPARTMENT_JOB_NAME", 'District Manager') THEN 'Rental'
    ELSE ${TABLE}."DIVISION" END ;;
  }

  dimension: division_2 {
    type: string
    sql: CASE
          WHEN CONTAINS(${TABLE}."DEPARTMENT_JOB_NAME", 'Sales') THEN 'Sales'
          WHEN CONTAINS(${TABLE}."DEPARTMENT", 'Sales') THEN 'Sales'
          WHEN ${TABLE}."DIVISION"='Corp'  THEN 'Corporate'
          WHEN ${TABLE}."DIVISION"='Management'  THEN 'Ops'
          WHEN ${TABLE}."DIVISION"='Manufacturing'  THEN 'Ops'
          WHEN ${TABLE}."DIVISION"='Materials'  THEN 'Ops'
          WHEN ${TABLE}."DIVISION"='Rental'  THEN 'Ops'
          WHEN ${TABLE}."DIVISION"='T3'  THEN 'Corporate'
          ELSE ${TABLE}."DIVISION" END ;;
  }

  dimension: department_job_name {
    type: string
    sql: ${TABLE}."DEPARTMENT_JOB_NAME" ;;
  }

  dimension: unicorn_departments_jobs {
    type: string
    sql: CASE WHEN ${TABLE}."DEPARTMENT_JOB_NAME" = 'General Manager' OR ${TABLE}."DEPARTMENT_JOB_NAME" = 'General Manager - Advanced Solutions' THEN 'General Managers'
          WHEN CONTAINS(${TABLE}."DEPARTMENT_JOB_NAME",'District Sales Manager') THEN 'District Sales Managers'
          WHEN CONTAINS(${TABLE}."DEPARTMENT",'Business Analytics') THEN 'Business Analytics'
          WHEN (CONTAINS(${TABLE}."DEPARTMENT",'Accounting') OR CONTAINS(${TABLE}."DEPARTMENT",'Finance')) THEN 'Accounting/Finance'
          WHEN CONTAINS(${TABLE}."DEPARTMENT_JOB_NAME",'Construction Project Manager') THEN 'Construction Project Managers'
          WHEN CONTAINS(${TABLE}."DEPARTMENT_JOB_NAME",'Territory Account Manager') THEN 'Territory Account Managers'
          ELSE 'Other' END;;
  }

}
