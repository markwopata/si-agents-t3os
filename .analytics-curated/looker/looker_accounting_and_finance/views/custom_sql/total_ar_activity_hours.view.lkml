view: total_ar_activity_hours {
  derived_table: {
    sql: SELECT
        MT.user_id,
        U.EMAIL_ADDRESS,
        MT.date::date as date,
        SUM(MT.hours) AS hours
      FROM ANALYTICS.TREASURY.AR_MANUAL_TIMES AS MT
      LEFT JOIN ES_WAREHOUSE.PUBLIC.USERS AS U ON MT.USER_ID = U.USER_ID
      WHERE U.COMPANY_ID IN (1854,1855)
      GROUP BY ALL
      ;;
  }

  dimension: key {
    primary_key: yes
    type: string
    sql: ${user_id} || '-' || ${date} ;;
  }

  dimension: user_id {
    type: number
    value_format_name: id
    sql: ${TABLE}."USER_ID" ;;
  }

  dimension: email_address {
    type: string
    sql: ${TABLE}."EMAIL_ADDRESS" ;;
  }

  dimension: date {
    type: date
    sql: ${TABLE}."DATE" ;;
  }

  measure: hours {
    value_format_name: decimal_2
    type: sum
    sql: ${TABLE}."HOURS" ;;
  }

  dimension: row_level_hours {
    type: number
    sql: ${TABLE}.hours ;;
  }

  dimension: is_user  {
    type: yesno
    sql: (${email_address} = '{{ _user_attributes['email'] }}') OR
         ('{{ _user_attributes['email'] }}' in (
        'ryan.stevens@equipmentshare.com',
        'paul.logue@equipmentshare.com',
        'lisa.evans@equipmentshare.com',
        'mark.wopata@equipmentshare.com',
        'jabbok@equipmentshare.com',
        'angie.wallace@equipmentshare.com',
        'jenny.sperry@equipmentshare.com',
        'kris@equipmentshare.com'
       )) ;;
  }


  }
