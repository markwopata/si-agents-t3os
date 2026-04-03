view: collector_cust_flags {
  sql_table_name: "PUBLIC"."COLLECTOR_CUST_FLAGS"
    ;;

  dimension: customer_id {
    type: string
    sql: ${TABLE}."CUSTOMER_ID" ;;
  }

  dimension: customer_name {
    type: string
    sql: ${TABLE}."CUSTOMER_NAME" ;;
  }

  dimension: dnc {
    type: string
    sql: ${TABLE}."DNC" ;;
  }

  dimension: legal {
    type: string
    sql: case when ${TABLE}."SENT_TO_LEGAL_MONTH" is not null
      and ${TABLE}."RETURNED_FROM_LEGAL_MONTH" is null
      then 'LEGAL'
      else 'Not Legal'
      end ;;
  }

  dimension_group: SENT_TO_LEGAL_MONTH {
    type: time
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: CAST(${TABLE}."SENT_TO_LEGAL_MONTH" AS TIMESTAMP_NTZ) ;;
  }

  dimension_group: RETURNED_FROM_LEGAL_MONTH {
    type: time
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: CAST(${TABLE}."RETURNED_FROM_LEGAL_MONTH" AS TIMESTAMP_NTZ) ;;
  }

# Removed when Paul Mason had the OIL sheet deleted. He's putting OIL stuff in the Exceptions sheet now. -Jack G
  # dimension: oil {
  #   type: string
  #   sql: ${TABLE}."OIL" ;;
  # }

  measure: count {
    type: count
    drill_fields: [customer_name]
  }
# Removing this because Paul Mason removed the Do Not Call sheet. -Jack G 5/26/22
  # dimension: do_not_call_flag {
  #   type: string
  #   sql: case when ${dnc} = 'DO NOT CALL' THEN 'DO NOT CALL' ELSE ' ' END ;;
  #   #This dimension lives to show a blank space on the AR customer dashboard and not a null sign
  # }

  dimension: legal_flag {
    type: string
    sql: case when ${legal} = 'LEGAL' THEN 'LEGAL' ELSE ' ' END ;;
    #This dimension lives to show a blank space on the AR customer dashboard and not a null sign
  }

# Removed when Paul Mason had the OIL sheet deleted. He's putting OIL stuff in the Exceptions sheet now. -Jack G
  # dimension: oil_flag {
  #   type: string
  #   sql: case when ${oil} = 'OIL' THEN 'OIL' ELSE ' ' END ;;
  #   #This dimension lives to show a blank space on the AR customer dashboard and not a null sign
  # }

  dimension: dnc_bit {
    type: yesno
    sql:${dnc} = 'DO NOT CALL' ;;
    #This dimension lives for the filters on the AR Dashboard
  }

  dimension: legal_bit {
    type: yesno
    sql:${legal} = 'LEGAL' ;;
    #This dimension lives for the filters on the AR Dashboard
  }

  dimension: legal_not_legal_string{
    type: string
    sql: CASE WHEN ${legal} is null THEN 'Not Legal' ELSE ${legal} END  ;;
  }

# Removed when Paul Mason had the OIL sheet deleted. He's putting OIL stuff in the Exceptions sheet now. -Jack G
  # dimension: oil_bit {
  #   type: yesno
  #   sql: (${oil} = 'OIL' AND ${dnc} = ' ' AND ${legal} = ' ')
  #       OR (${oil} = 'OIL' AND ${dnc} = 'DO NOT CALL' AND ${legal} = ' ')
  #       OR (${oil} = 'OIL' AND ${dnc} = ' ' AND ${legal} = 'LEGAL')
  #       OR (${oil} = 'OIL' AND ${dnc} = 'DO NOT CALL' AND ${legal} = 'LEGAL')  ;;
  #   #This dimension lives for the filters on the AR Dashboard
  #   }

# Removing OIL from this case statment. Check github for the exact changes. -Jack G
# Removed Do Not Call logic because Paul Mason deleted the Do Not Call sheet. -Jack G 5/26/22
    dimension: Customer_flag {
      type: string
      sql: IFF(${legal} = 'LEGAL', 'LEGAL', null);;
    }
}
