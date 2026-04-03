view: market_headcount {
  derived_table: {
    sql: WITH df as( SELECT
  EMPLOYEE_TITLE,
  DEFAULT_COST_CENTERS_FULL_PATH, SUM(
CASE WHEN  (EMPLOYEE_STATUS != 'Terminated' AND EMPLOYEE_STATUS != 'Inactive' AND EMPLOYEE_STATUS != 'Not In Payroll' AND EMPLOYEE_STATUS != 'Never Started')AND EMPLOYEE_STATUS != 'Military Training Program' THEN 1
ELSE 0 END) AS Headcount
from ANALYTICS.PAYROLL.COMPANY_DIRECTORY_VAULT
WHERE  (
  TO_DATE(_ES_UPDATE_TIMESTAMP) = DATEADD(day,-1,current_date)
AND DATE_PART(HOUR, _ES_UPDATE_TIMESTAMP) >15
AND DATE_PART(HOUR, _ES_UPDATE_TIMESTAMP) <18
AND EMPLOYEE_ID NOT IN (
  select cd.EMPLOYEE_ID from ANALYTICS.PAYROLL.COMPANY_DIRECTORY cd
  WHERE EMPLOYEE_STATUS= 'Never Started'))
  GROUP BY EMPLOYEE_TITLE,
  DEFAULT_COST_CENTERS_FULL_PATH),

 df3 as( SELECT df.DEFAULT_COST_CENTERS_FULL_PATH, df2.MARKET_ID, df.EMPLOYEE_TITLE, df.HEADCOUNT from df left join
    (SELECT DEFAULT_COST_CENTERS_FULL_PATH, MAX(MARKET_ID) AS MARKET_ID from ANALYTICS.PAYROLL.COST_CENTER_TO_MARKET_ID GROUP BY DEFAULT_COST_CENTERS_FULL_PATH) df2
    on df.DEFAULT_COST_CENTERS_FULL_PATH = df2.DEFAULT_COST_CENTERS_FULL_PATH)

    SELECT JOB_FAMILY_GROUP, JOB_FAMILY, MARKET_ID, sum(HEADCOUNT) as HEADCOUNT from df3 left join
    (SELECT JOB_TITLE,JOB_FAMILY_GROUP, CASE WHEN JOB_FAMILY = 'Shop Technicians' THEN 'Field and Shop Technicians'
     WHEN JOB_FAMILY = 'Field Technicians' THEN 'Field and Shop Technicians'
     ELSE JOB_FAMILY END AS JOB_FAMILY,
     JOB_PROFILE from analytics.greenhouse.job_profiles) jp on
    df3.EMPLOYEE_TITLE=jp.JOB_TITLE
    GROUP BY  df3.MARKET_ID, jp.JOB_FAMILY_GROUP, jp.JOB_FAMILY;;
  }


 dimension: primary_key{
   primary_key: yes
  type: string
  sql:  CONCAT(${TABLE}."JOB_FAMILY",${TABLE}."MARKET_ID" ;;
 }



  dimension: job_family {
    type: string
    sql: ${TABLE}."JOB_FAMILY" ;;
  }

  dimension: market_id {
    type: string
    sql: ${TABLE}."MARKET_ID" ;;
  }

  dimension: headcount{
    type: string
    sql: ${TABLE}."HEADCOUNT" ;;
  }


}
