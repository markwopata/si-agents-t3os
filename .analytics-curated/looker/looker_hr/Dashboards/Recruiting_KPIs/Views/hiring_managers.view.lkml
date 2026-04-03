view: hiring_managers {
  derived_table: {
    sql: WITH hm as (SELECT JOB_ID, ROLE, CONCAT(FIRST_NAME,' ',LAST_NAME) AS NAME FROM ANALYTICS.GREENHOUSE.HIRING_TEAM hf
left join ANALYTICS.GREENHOUSE.USER uf on
hf.USER_ID = uf.ID
WHERE ROLE = 'hiring_managers')

SELECT JOB_ID,
       LISTAGG(NAME, ', ') WITHIN GROUP(ORDER BY NAME) AS HIRING_MANAGERS
FROM hm
GROUP BY JOB_ID;;
  }


  dimension: job_id {
    type: number
    sql: ${TABLE}."JOB_ID" ;;
  }

  dimension: hiring_managers {
    type: string
    sql: ${TABLE}."HIRING_MANAGERS" ;;
  }


}
