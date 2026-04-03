view: docebo_user_status {

  derived_table: {
    sql: WITH has_overdue as (select DISTINCT USER_USERID from ANALYTICS.DOCEBO.ENROLLMENT_HISTORY
                            where COALESCE(ENROLLMENT_DATE_EXPIRE_VALIDITY, COURSE_DATE_END) < CURRENT_DATE() and ENROLLMENT_STATUS!= 'Completed'),
            has_no_overdue as (select DISTINCT USER_USERID from ANALYTICS.DOCEBO.ENROLLMENT_HISTORY
                            where USER_USERID NOT IN (select DISTINCT USER_USERID from ANALYTICS.DOCEBO.ENROLLMENT_HISTORY
                            where COALESCE(ENROLLMENT_DATE_EXPIRE_VALIDITY, COURSE_DATE_END) < CURRENT_DATE() and ENROLLMENT_STATUS!= 'Completed'))
      select USER_USERID, 'Yes' as has_overdue_courses from has_overdue
      UNION ALL
      select USER_USERID, 'No' as has_overdue_courses from has_no_overdue
      order by USER_USERID
      ;;
    }


   dimension: user_id {
     type: string
     sql: ${TABLE}."USER_USERID";;
   }

  dimension: has_overdue {
    type: string
    sql: ${TABLE}."HAS_OVERDUE_COURSES" ;;
  }

  measure: user_count {
    type: count_distinct
    sql: ${user_id} ;;
  }

}
