view: tool_trailer_user_based_matching {
  derived_table: {
    sql: select
    TTPR1.TOOL_TRAILER_PART_RENTAL_ID as CHECK_OUT_TOOL_TRAILER_PART_RENTAL_ID
  , TTPR1.PART_ID as CHECK_OUT_PART_ID
  , PT.DESCRIPTION as CHECK_OUT_DESCRIPTION
  , TTPR1.USER_ID as CHECK_OUT_USER_ID
  , concat(U.FIRST_NAME, ' ', U.LAST_NAME) as CHECK_OUT_USER
  , TTPR1.START_END_DATE as CHECK_OUT_START_END_DATE
  , TTPR1.MODIFIED_BY_USER as CHECK_OUT_MODIFIED_BY_USER
  , TTPR1.BRANCH_ID as CHECK_OUT_BRANCH_ID
  , TTPR1.NOTE as CHECK_OUT_NOTE
  , TTPR2.TOOL_TRAILER_PART_RENTAL_ID as CHECK_IN_TOOL_TRAILER_PART_RENTAL_ID
  , TTPR2.PART_ID as CHECK_IN_PART_ID
  , PT2.DESCRIPTION as CHECK_IN_DESCRIPTION
  , TTPR2.USER_ID as CHECK_IN_USER_ID
  , concat(U2.FIRST_NAME, ' ', U2.LAST_NAME) as CHECK_IN_USER
  , TTPR2.START_END_DATE as CHECK_IN_START_END_DATE
  , TTPR2.CREATED_BY_USER as CHECK_IN_CREATED_BY_USER
  , TTPR2.BRANCH_ID as CHECK_IN_BRANCH_ID
  , TTPR2.NOTE as CHECK_IN_NOTE
  from ANALYTICS.TOOLS_TRAILER.USER_PART_CHECK_IN UPCI
           left join TOOLS_TRAILER.PUBLIC.TOOL_TRAILER_PART_RENTAL TTPR1
           on UPCI.CHECK_OUT_ID = TTPR1.TOOL_TRAILER_PART_RENTAL_ID
           left join TOOLS_TRAILER.PUBLIC.TOOL_TRAILER_PART_RENTAL TTPR2
           on UPCI.CHECK_IN_ID = TTPR2.TOOL_TRAILER_PART_RENTAL_ID
           left join ES_WAREHOUSE.PUBLIC.USERS U
           on TTPR1.USER_ID = U.USER_ID
           left join ES_WAREHOUSE.PUBLIC.USERS U2
           on TTPR2.USER_ID = U2.USER_ID
           left join ES_WAREHOUSE.INVENTORY.PARTS P
           on TTPR1.PART_ID = P.PART_ID
           left join ES_WAREHOUSE.INVENTORY.PART_TYPES PT
           on P.PART_TYPE_ID = PT.PART_TYPE_ID
           left join ES_WAREHOUSE.INVENTORY.PARTS P2
           on TTPR2.PART_ID = P2.PART_ID
           left join ES_WAREHOUSE.INVENTORY.PART_TYPES PT2
           on P2.PART_TYPE_ID = PT2.PART_TYPE_ID
 ;;
  }

  dimension: CHECK_OUT_TOOL_TRAILER_PART_RENTAL_ID {
    type: number
    sql: ${TABLE}."CHECK_OUT_TOOL_TRAILER_PART_RENTAL_ID" ;;
  }

  dimension: CHECK_OUT_PART_ID {
    type: number
    sql: ${TABLE}."CHECK_OUT_PART_ID" ;;
  }

  dimension: CHECK_OUT_DESCRIPTION {
    type: string
    sql: ${TABLE}."CHECK_OUT_DESCRIPTION" ;;
  }

  dimension: CHECK_OUT_USER_ID {
    type: number
    sql: ${TABLE}."CHECK_OUT_USER_ID" ;;
  }

  dimension: CHECK_OUT_USER {
    type: string
    sql: ${TABLE}."CHECK_OUT_USER" ;;
  }

  dimension: CHECK_OUT_START_END_DATE {
    type: date
    sql: ${TABLE}."CHECK_OUT_START_END_DATE" ;;
  }

  dimension: CHECK_OUT_MODIFIED_BY_USER {
    type: string
    sql: ${TABLE}."CHECK_OUT_MODIFIED_BY_USER" ;;
  }

  dimension: CHECK_OUT_BRANCH_ID {
    type: number
    sql: ${TABLE}."CHECK_OUT_BRANCH_ID" ;;
  }

  dimension: CHECK_OUT_NOTE {
    type: string
    sql: ${TABLE}."CHECK_OUT_NOTE" ;;
  }

  dimension: CHECK_IN_TOOL_TRAILER_PART_RENTAL_ID {
    type: number
    sql: ${TABLE}."CHECK_IN_TOOL_TRAILER_PART_RENTAL_ID" ;;
  }

  dimension: CHECK_IN_PART_ID {
    type: number
    sql: ${TABLE}."CHECK_IN_PART_ID" ;;
  }

  dimension: CHECK_IN_DESCRIPTION {
    type: string
    sql: ${TABLE}."CHECK_IN_DESCRIPTION" ;;
  }

  dimension: CHECK_IN_USER_ID {
    type: number
    sql: ${TABLE}."CHECK_IN_USER_ID" ;;
  }

  dimension: CHECK_IN_USER {
    type: string
    sql: ${TABLE}."CHECK_IN_USER" ;;
  }

  dimension: CHECK_IN_START_END_DATE {
    type: date
    sql: ${TABLE}."CHECK_IN_START_END_DATE" ;;
  }

  dimension: CHECK_IN_CREATED_BY_USER {
    type: string
    sql: ${TABLE}."CHECK_IN_CREATED_BY_USER" ;;
  }

  dimension: CHECK_IN_BRANCH_ID {
    type: number
    sql: ${TABLE}."CHECK_IN_BRANCH_ID" ;;
  }

  dimension: CHECK_IN_NOTE {
    type: string
    sql: ${TABLE}."CHECK_IN_NOTE" ;;
  }



}
