view: job_pipeline {
  derived_table: {
    sql: with app as (SELECT * FROM ANALYTICS.GREENHOUSE.APPLICATION
             left join greenhouse.job_stage
             on application.CURRENT_STAGE_ID = job_stage.ID)


  SELECT JOB_ID, STATUS,
        COUNT_IF((NAME = 'Application Review' OR NAME = 'Review' OR NAME = 'Reviewed' OR NAME IS NULL) AND STATUS !='rejected') AS APPLICATIONS_UNDER_REVIEW,
        COUNT_IF(NAME IN ('DISC' , 'DISC Complete' , 'DISC for Regional Manager', 'Disc' ) AND STATUS !='rejected') AS DISC,
        COUNT_IF(NAME IN('Phone Interview' , 'Preliminary Phone Screen' , 'Phone Screen Pending' ) AND STATUS !='rejected' ) AS HR_PHONE_SCREEN,
        COUNT_IF(NAME IN ('Phone Interview 2' , 'Manager Review' , 'Pending Manager Review' ) AND STATUS !='rejected' ) AS MANAGER_PHONE_SCREEN,
        COUNT_IF(NAME IN ('Face to Face' ) AND STATUS !='rejected'  ) AS FACE_TO_FACE,
        COUNT_IF(NAME IN ('Offer' , 'Offer Sent' , 'Offer Accepted' ) AND STATUS !='rejected' ) AS OFFER,
        COUNT_IF( NAME IN ('Hired' ) AND STATUS !='rejected' ) AS HIRED,
        COUNT_IF( STATUS IN ('rejected')) AS REJECTED
       from app
       group by JOB_ID, STATUS;;
      }



  dimension: job_id {
    primary_key: yes
    type: string
    sql: ${TABLE}."JOB_ID" ;;
  }

  dimension: applications_under_review {
    type: number
    sql: ${TABLE}."APPLICATIONS_UNDER_REVIEW" ;;
    }

  dimension: DISC{
    type: number
    sql: ${TABLE}."DISC" ;;
  }

  dimension: hr_phone_screen {
    type: number
    sql: ${TABLE}."HR_PHONE_SCREEN" ;;
  }

  dimension: manager_phone_screen {
    type: number
    sql: ${TABLE}."MANAGER_PHONE_SCREEN" ;;
  }

  dimension: face_to_face {
    type: number
    sql: ${TABLE}."FACE_TO_FACE" ;;
  }

  dimension: offer {
    type: number
    sql: ${TABLE}."OFFER" ;;
  }

  dimension: hired {
    type: number
    sql: ${TABLE}."HIRED" ;;
  }

  dimension: rejected {
    type: number
    sql: ${TABLE}."REJECTED" ;;
  }

  dimension: status {
    type: number
    sql: ${TABLE}."STATUS" ;;
  }

  measure: applications_under_review_sum {
    type: sum
    sql: ${TABLE}."APPLICATIONS_UNDER_REVIEW" ;;
  }

  measure: DISC_sum{
    type: sum
    sql: ${TABLE}."DISC" ;;
  }

  measure: hr_phone_screen_sum {
    type: sum
    sql: ${TABLE}."HR_PHONE_SCREEN" ;;
  }

  measure: manager_phone_screen_sum {
    type: sum
    sql: ${TABLE}."MANAGER_PHONE_SCREEN" ;;
  }

  measure: face_to_face_sum {
    type: sum
    sql: ${TABLE}."FACE_TO_FACE" ;;
  }

  measure: offer_sum {
    type: sum
    sql: ${TABLE}."OFFER" ;;
  }

  measure: hired_sum {
    type: sum
    sql: ${TABLE}."HIRED" ;;
  }

  measure: rejected_sum {
    type: sum
    sql: ${TABLE}."REJECTED" ;;
  }
}
