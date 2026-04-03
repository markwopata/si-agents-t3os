view: docebo_courses {
  # # You can specify the table name if it's different from the view name:
  sql_table_name:"ANALYTICS"."DOCEBO"."COURSES";;
    #
    # # Define your dimensions and measures here, like this:
    dimension: course_id {
      primary_key: yes
      label: "Course ID"
      type: number
      sql: ${TABLE}."ID_COURSE";;
    }

    dimension: course_uid {
      type: string
      sql: ${TABLE}."UIDCOURSE" ;;
    }

    dimension: name {
      type:  string
      sql:  ${TABLE}."NAME" ;;
    }

    dimension: description {
      type: string
      sql:  ${TABLE}."DESCRIPTION" ;;
    }

    dimension: course_type {
      label: "Type"
      type: string
      sql:  ${TABLE}."COURSE_TYPE" ;;
    }

    dimension: category {
      type:  string
      sql:  ${TABLE}.'CATEGORY' ;;
    }

    dimension: course_begin {
      type: date
      sql: ${TABLE}."START_DATE" ;;
      html: {{ rendered_value | date: "%b %d, %Y"  }};;
    }

    dimension: course_end {
      type: date
      sql: ${TABLE}."END_DATE" ;;
      html: {{ rendered_value | date: "%b %d, %Y"  }};;
    }
   }
