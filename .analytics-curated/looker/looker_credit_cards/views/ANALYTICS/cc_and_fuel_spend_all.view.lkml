view: cc_and_fuel_spend_all {
  derived_table: {
    sql:
      SELECT *
      FROM "PUBLIC"."CC_AND_FUEL_SPEND_ALL"
      WHERE corporate_account_name <> 'EQS EMPLOYEE REWARDS'
    ;;
  }

  dimension_group: transaction_date {
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
    sql: CAST(${TABLE}."TRANSACTION_DATE" AS TIMESTAMP_NTZ) ;;
  }

  # measure: receipt_cutoff {
  #   type: string
  #   sql: (${transaction_date_time} - interval '14 days') ;;
  # }

  dimension: employee_number {
    type: number
    sql: ${TABLE}."EMPLOYEE_NUMBER"::INT ;;
    value_format_name: id
  }

  dimension: first_name {
    type: string
    sql: ${TABLE}."FIRST_NAME"::TEXT ;;
  }

  dimension: last_name {
    type: string
    sql: ${TABLE}."LAST_NAME"::TEXT ;;
  }

  dimension: full_name {
    type: string
    sql: ${TABLE}."FULL_NAME"::TEXT ;;
  }

  dimension: status {
    type: string
    sql: ${TABLE}."STATUS"::TEXT ;;
  }

  dimension: most_recent_status {
    type: string
    sql: ${TABLE}."MOST_RECENT_STATUS"::TEXT ;;
  }

  measure: status_clean {
    type: string
    sql: CASE WHEN MAX(TRIM(UPPER(${most_recent_status})) )like '%OPEN%' OR MAX(TRIM(UPPER(${most_recent_status}))) like '%ACTIVE%' THEN 'OPEN' ELSE 'CLOSED' END ;;
  }

  dimension: transaction_amount {
    type: number
    sql: ${TABLE}."TRANSACTION_AMOUNT"::NUMERIC(10,2) ;;
  }

  dimension: merchant_name {
    type: string
    sql: ${TABLE}."MERCHANT_NAME"::TEXT ;;
  }

  dimension: transaction_id {
    type: string
    sql: ${TABLE}."TRANSACTION_ID"::TEXT ;;
  }

  dimension: mcc_code {
    type: string
    sql: ${TABLE}."MCC_CODE"::TEXT ;;
  }

  dimension: mcc {
    type: string
    sql: ${TABLE}."MCC"::TEXT ;;
  }

  dimension: card_type {
    type: string
    sql: ${TABLE}."CARD_TYPE"::TEXT ;;
  }

  measure: total_spend {
    type: sum
    sql: ${transaction_amount} ;;
    drill_fields: [ merchant_name, full_name,employee_number,card_type,transaction_date_date,transaction_id, mcc, transaction_amount ,cc_spend_receipt_upload.additional_notes, cc_spend_receipt_upload.link_to_receipt]
  }

  measure: total_spend_amex {
    type: sum
    sql: ${transaction_amount} ;;
    filters: [card_type: "amex"]
    drill_fields: [ merchant_name, full_name,card_type,transaction_date_date,transaction_id, mcc, transaction_amount ,cc_spend_receipt_upload.additional_notes, cc_spend_receipt_upload.link_to_receipt]
  }

  measure: total_spend_central_bank {
    type: sum
    sql: ${transaction_amount} ;;
    filters: [card_type: "central_bank"]
    drill_fields: [ merchant_name, full_name,card_type,transaction_date_date,transaction_id, mcc, transaction_amount ,cc_spend_receipt_upload.additional_notes, cc_spend_receipt_upload.link_to_receipt]
  }

  measure: total_spend_fuel_card {
    type: sum
    sql: ${transaction_amount} ;;
    filters: [card_type: "fuel_card"]
    drill_fields: [ merchant_name, full_name,card_type,transaction_date_date,transaction_id, mcc, transaction_amount ,cc_spend_receipt_upload.additional_notes, cc_spend_receipt_upload.link_to_receipt]
  }

  measure: avg_spend {
    type: average
    sql: ${transaction_amount} ;;
    drill_fields: [ merchant_name, full_name,card_type,transaction_date_date,transaction_id, mcc, transaction_amount ,cc_spend_receipt_upload.additional_notes, cc_spend_receipt_upload.link_to_receipt]
  }

  dimension: inapproptiate_ind {
    type: yesno
    sql: ${mcc_code} in ('5813','5993','5921','3731','5912','5815','5818','4899') OR (UPPER(${merchant_name}) like '%BAR %' AND UPPER(${merchant_name}) not like '%ELECTRIC%')
          OR (UPPER(${merchant_name}) like '%BREW%'AND UPPER(${merchant_name}) not like '%OIL%') OR UPPER(${merchant_name}) like '%CIGAR%'
          OR UPPER(${merchant_name}) like '%TAVERN%' OR UPPER(${merchant_name}) like '%SALOON%' OR UPPER(${merchant_name}) like '%TAP %'
          OR UPPER(${merchant_name}) like '%PUB %' OR UPPER(${merchant_name}) like '%GOLF%' OR UPPER(${merchant_name}) like '%BEER%' OR UPPER(${merchant_name}) like '%LIQUOR%' OR UPPER(${merchant_name}) like '%RELAXATION%'
           OR UPPER(${merchant_name}) like '% SPA %';;
  }

  dimension: doctor_visits {
    type: yesno
    sql: ${mcc_code} in ('8099') OR ${mcc} like '%HEALTH%'
    or ${mcc} like '%DOCTOR%'
    or upper(${merchant_name}) like '%URGENT CARE%'
    or upper(${merchant_name}) like '%HOSPITAL %'
    or upper(${merchant_name}) like '%EMERGENCY%'
    or upper(${merchant_name}) like '%MEDICAL%'
    or (upper(${merchant_name}) like '%DOCTOR%' and upper(${merchant_name}) not like '%GLASS DOCTOR%'  and upper(${merchant_name}) not like '%LOCKDOCTOR%');;
  }

  dimension: media_ind {
    type: yesno
    sql: ${mcc_code} in ('5815','5818','4899');;
  }

  dimension: equipment_ind {
    type: yesno
    sql: ${mcc_code} in ('7394','7519','5599') ;;
  }

  dimension: fleet_spend_ind {
    type: yesno
    sql: ${mcc_code} in ('7538','7534','7531','5533','5532','5521','5511') ;;
  }

  dimension: boots_ind {
    type: yesno
    sql: ${mcc_code} in ('5661');;
  }

  dimension: cigarette_ind {
    type: yesno
    sql: ${mcc_code} in ('5541','5542') AND ${transaction_amount} < 10;;
  }

  dimension: fleet_maintenance_ind {
    type: yesno
    sql: ${mcc_code} in ('5172','5511','5532','5533','5541','5542','7699','7542','7549','7538','5561','5571','5599','7531','7534','7535');;
  }

  dimension: large_tx_ind {
    type: yesno
    sql: ${transaction_amount} >= 1000;;
  }

  dimension: receipt_received_ind {
    type: yesno
    sql: ${cc_spend_receipt_upload.link_to_receipt} is not null  ;;
  }

  measure: count {
    type: count
    drill_fields: [full_name,card_type, merchant_name,transaction_date_date,transaction_id,transaction_amount]
  }

  dimension: cardholder_first_name_truncated {
    type: string
    sql: CASE WHEN UPPER(TRIM(${first_name})) = 'JOSHUA' THEN 'JOSH' ELSE UPPER(TRIM(${first_name})) END ;;
  }

  dimension: cardholder_full_name_truncated {
    type: string
    sql: concat(${cardholder_first_name_truncated},' ',${last_name}) ;;
  }

  dimension: row_number {
    primary_key: yes
    ##hidden: yes
    type: number
    sql: ${TABLE}."ROW_NUMBER" ;;
  }


  dimension: is_month_to_date {
    type: yesno
    sql:--extract(month from ${transaction_date_raw})  = extract(month from current_timestamp)
        --and extract(year from ${transaction_date_raw}) = extract(year from current_timestamp)
        date_trunc('month',${transaction_date_date}::DATE)::DATE=date_trunc('month',current_timestamp)::DATE;;
  }

  measure: month_to_date_spending {
    type: sum
    sql: ${transaction_amount} ;;
    value_format: "$#,##0"
    filters: {
      field: is_month_to_date
      value: "yes"
    }
    drill_fields: [full_name,card_type, merchant_name, transaction_date_date,transaction_id, mcc, transaction_amount,cc_spend_receipt_upload.additional_notes, cc_spend_receipt_upload.link_to_receipt ]
  }

  measure: last_mtd_spending {
    type: sum
    sql: ${transaction_amount};;
    value_format: "$#,##0"
    filters: {
      field: dated_last_year_month
      value: "yes"
    }
    drill_fields: [full_name,card_type, merchant_name, transaction_date_date,transaction_id, mcc, transaction_amount,cc_spend_receipt_upload.additional_notes,cc_spend_receipt_upload.link_to_receipt ]
  }

  measure: month_to_date_tx_count {
    type: count
    filters: {
      field: is_month_to_date
      value: "yes"
    }
    drill_fields: [full_name,card_type, merchant_name, transaction_date_date,transaction_id, mcc, transaction_amount, cc_spend_receipt_upload.link_to_receipt ]
  }

  measure: last_mtd_tx_count {
    type: count
    filters: {
      field: dated_last_year_month
      value: "yes"
    }
    drill_fields: [full_name,card_type, merchant_name, transaction_date_date,transaction_id, mcc, transaction_amount,cc_spend_receipt_upload.additional_notes,cc_spend_receipt_upload.link_to_receipt ]
  }


  measure: month_to_date_receipts_received {
    type: count
    filters: {
      field: is_month_to_date
      value: "yes"
    }
    filters: {
      field: receipt_received_ind
      value: "yes"
    }
    filters: {
      field: transaction_amount
      value: ">0"
    }
    drill_fields: [full_name,card_type, merchant_name, transaction_date_date,transaction_id, mcc, transaction_amount,cc_spend_receipt_upload.additional_notes, cc_spend_receipt_upload.link_to_receipt ]
  }

  measure: last_month_receipts_received {
    type: count
    filters: {
      field: dated_last_month
      value: "yes"
    }
    filters: {
      field: receipt_received_ind
      value: "yes"
    }
    filters: {
      field: transaction_amount
      value: ">0"
    }
    drill_fields: [full_name,card_type, merchant_name, transaction_date_date,transaction_id, mcc, transaction_amount,cc_spend_receipt_upload.additional_notes,cc_spend_receipt_upload.link_to_receipt ]
  }

  dimension: receipt_submit_start_date {
    type: yesno
    sql:  ${transaction_date_date}::DATE>= '2023-04-01';;
  }

  dimension: transaction_72_hr_lag {
    type: yesno
    sql:  current_timestamp::DATE > (${transaction_date_date}::DATE + interval '95 hours' + interval '59 minutes')::DATE;;
  }


  measure: total_receipts_not_received {
    type: count
    filters: {
      field: receipt_submit_start_date
      value: "yes"
    }
    # filters: {
    #   field: transaction_72_hr_lag
    #   value: "yes"
    # }
    filters: {
      field: receipt_received_ind
      value: "no"
    }
    filters: {
      field: transaction_amount
      value: ">3"
    }
    drill_fields: [employee_number,full_name,card_type, merchant_name, transaction_date_date,transaction_id, mcc, transaction_amount,cc_spend_receipt_upload.additional_notes, cc_spend_receipt_upload.link_to_receipt ]
  }


  dimension: cardholder_link_to_individual_dashboard {
    type: string
    sql: ${full_name} ;;

    link: {
      label: "View Individual Credit Cards Dashboard"
      url: "https://equipmentshare.looker.com/dashboards/135?Cardholder={{ full_name._filterable_value | url_encode }}"
    }
  }

  measure: month_to_date_receipts_not_received {
    type: count
    filters: {
      field: is_month_to_date
      value: "yes"
    }
    filters: {
      field: receipt_received_ind
      value: "no"
    }
    filters: {
      field: transaction_amount
      value: ">3"
    }
    # filters: {
    #   field: transaction_72_hr_lag
    #   value: "yes"
    # }
    drill_fields: [full_name,card_type, merchant_name, transaction_date_date,transaction_id, mcc, transaction_amount,cc_spend_receipt_upload.additional_notes, cc_spend_receipt_upload.link_to_receipt ]
  }

  measure: last_month_receipts_not_received {
    type: count
    filters: {
      field: dated_last_month
      value: "yes"
    }
    filters: {
      field: receipt_received_ind
      value: "no"
    }
    filters: {
      field: transaction_amount
      value: ">3"
    }
    # filters: {
    #   field: transaction_72_hr_lag
    #   value: "yes"
    # }
    drill_fields: [full_name,card_type, merchant_name, transaction_date_date,transaction_id, mcc, transaction_amount,cc_spend_receipt_upload.additional_notes,cc_spend_receipt_upload.link_to_receipt ]
  }

  measure: two_months_ago_receipts_not_received {
    type: count
    filters: {
      field: dated_two_months_ago
      value: "yes"
    }
    filters: {
      field: receipt_received_ind
      value: "no"
    }
    filters: {
      field: transaction_amount
      value: ">0"
    }
    drill_fields: [full_name,card_type, merchant_name, transaction_date_date,transaction_id, mcc, transaction_amount,cc_spend_receipt_upload.additional_notes,cc_spend_receipt_upload.link_to_receipt ]
  }

  dimension:  dated_last_year_month{
    type: yesno
    sql: date_part(day,${transaction_date_date}::DATE) <= date_part(day,(date_trunc('day', current_date)))
          and date_part(month,${transaction_date_date}::DATE)  = date_part(month,(date_trunc('month', current_date- interval '1 month')))
          and date_part(year,${transaction_date_date}::DATE) = date_part(year,(date_trunc('year', current_date - interval '1 month')))  ;;
  }

  dimension:  dated_last_month{
    type: yesno
    sql: date_part(month , ${transaction_date_date}::DATE)  = date_part(month , (date_trunc('month', current_timestamp - interval '1 month')))
      and date_part(year , ${transaction_date_date}::DATE) = date_part(year , (date_trunc('year',current_timestamp - interval '1 month'))) ;;
  }

  dimension:  dated_two_months_ago{
    type: yesno
    sql: date_part(month , ${transaction_date_date}::DATE)  = date_part(month , (date_trunc('month', current_timestamp - interval '2 months')))
      and date_part(year , ${transaction_date_date}::DATE) = date_part(year , (date_trunc('year',current_timestamp - interval '2 months'))) ;;
  }

  dimension: submit_spend_receipt {
    type: string
    html: <font color="blue "><u><a href ="https://docs.google.com/forms/d/e/1FAIpQLSfpAR6MGq9OrnnwL9dJz8qZIelo-0gL_W-Guagp9xwoAykUVQ/viewform?usp=pp_url&entry.1164859533={{  _user_attributes['name'] }}&entry.837344666=Credit+Card&entry.130892990={{  _user_attributes['email'] }}"target="_blank">Submit Credit Card Receipt</a></font></u> ;;
    sql: ${transaction_id} ;;
  }

  dimension: submit_spend_receipt_autofill {
    type: string
    html: <font color="blue "><u><a href ="https://docs.google.com/forms/d/e/1FAIpQLSfpAR6MGq9OrnnwL9dJz8qZIelo-0gL_W-Guagp9xwoAykUVQ/viewform?usp=pp_url&entry.1164859533={{  _user_attributes['name'] }}&entry.837344666=Credit+Card&entry.1077598267={{ cc_and_fuel_spend_all.transaction_amount._value }}&entry.1579787528={{cc_and_fuel_spend_all.transaction_date_date._value}}&entry.130892990={{  _user_attributes['email'] }}"target="_blank">Submit Credit Card Receipt</a></font></u> ;;
    sql: ${transaction_id} ;;
  }

  measure: days_since_transaction {
    type: number
    sql: current_timestamp::DATE - ${transaction_date_date}::DATE ;;
  }

  dimension: car_rental_vendor {
    type: string
    sql: case when ${merchant_name} like 'BUDGET%' then 'BUDGET'
              when ${merchant_name} like 'ENTERPRISE%' then 'ENTERPRISE'
              when ${merchant_name} like 'HERTZ%' then 'HERTZ'
              when ${merchant_name} like 'NATIONAL CAR%' then 'NATIONAL CAR'
              when ${merchant_name} like '%PAYLESS%' then 'PAYLESS'
              when ${merchant_name} like 'THRIFTY%' then 'THRIFTY'
              else ${merchant_name} end
    ;;
  }
  dimension: charge_category {
    type: string
    sql: case when (${mcc_code} >= '3000' AND ${mcc_code} <= '3350') OR ${mcc_code} = '4511' then 'Airlines & Air Carriers'
              when (${mcc_code} >= '3351' AND ${mcc_code} <= '3500') OR ${mcc_code} = '7512' then 'Car Rental Agencies'
              when (${mcc_code} >= '3501' AND ${mcc_code} <= '3999') OR ${mcc_code} = '7011' then 'Lodging, Hotels, Motels, Resorts'
              when ${mcc_code} >= '5812' AND ${mcc_code} <= '5814' then 'Restaurants'
              when ${mcc_code}  = '5541' then 'Service Stations (with or without Ancillary Services)'
              when ${mcc_code}  = '5542' then 'Fuel Dispenser Automated'
              else 'Other' end
    ;;
  }
  dimension: merchant_name_clean {
    type: string
    sql: CASE --Airlines
       WHEN ${merchant_name} like 'ALASKA%' THEN 'ALASKA'
       WHEN ${merchant_name} like 'AMERICAN%' THEN 'AMERICAN'
       WHEN ${merchant_name} like 'FRONTIER%' THEN 'FRONTIER'
       WHEN ${merchant_name} like 'JETBLUE%' THEN 'JETBLUE'
       WHEN ${merchant_name} like 'SOUTHWES%' THEN 'SOUTHWEST'
       WHEN ${merchant_name} like 'SPIRIT%' THEN 'SPIRIT'
       WHEN ${merchant_name} like 'UNITED%' OR ${merchant_name} like 'UA%' THEN 'UNITED'
       --Gas Stations
       WHEN ${merchant_name} like '7-ELEVEN%' THEN '7-ELEVEN'
       WHEN ${merchant_name} like '76 %' THEN '76'
       WHEN ${merchant_name} like 'ALLSUP%' THEN 'ALLSUPS'
       WHEN ${merchant_name} like 'ALON DK%' THEN 'ALON DK'
       WHEN ${merchant_name} like 'AMOCO%' THEN 'AMOCO'
       WHEN ${merchant_name} like 'ARCO%' THEN 'ARCO'
       WHEN ${merchant_name} like 'BIG RED%' THEN 'BIG RED'
       WHEN ${merchant_name} like 'BP%' THEN 'BP'
       WHEN ${merchant_name} like 'BROOKSHIRE BROS%' THEN 'BROOKSHIRE BROS'
       WHEN ${merchant_name} like 'BREAK TIME%' THEN 'BREAK TIME'
       WHEN ${merchant_name} like 'BUC-EE%' THEN 'BUC-EE''S'
       WHEN ${merchant_name} like 'CASEYS%' THEN 'CASEY''S GENERAL STORE'
       WHEN ${merchant_name} like 'CEFCO%' THEN 'CEFCO'
       WHEN ${merchant_name} like 'CENEX%' THEN 'CENEX'
       WHEN ${merchant_name} like '%CHEVRON%' THEN 'CHEVRON'
       WHEN ${merchant_name} like '%CIRCLE K%' THEN 'CIRCLE K'
       WHEN ${merchant_name} like '%CITGO%' THEN 'CITGO'
       WHEN ${merchant_name} like 'CONOCO%' THEN 'CONOCO'
       WHEN ${merchant_name} like 'DIAMOND%' THEN 'DIAMOND'
       WHEN ${merchant_name} like 'DILLONS%' THEN 'DILLONS FUEL'
       WHEN ${merchant_name} like 'E%Z%MART%' THEN 'E-Z MART'
       WHEN ${merchant_name} like 'EMPIRE%' THEN 'EMPIRE'
       WHEN ${merchant_name} like 'ENMARKET%' THEN 'ENMARKET'
       WHEN ${merchant_name} like 'EXXON%' THEN 'EXXON'
       WHEN ${merchant_name} like 'FLYING J%' THEN 'FLYING J'
       WHEN ${merchant_name} like 'FRED M FUEL%' THEN 'FRED M FUEL'
       WHEN ${merchant_name} like 'FRED%FOOD%' THEN 'FRED''S FOODMART'
       WHEN ${merchant_name} like 'GATE%' THEN 'GATE PETROLEUM'
       WHEN ${merchant_name} like 'GULF OIL%' THEN 'GULF OIL'
       WHEN ${merchant_name} like 'H-E-B%' THEN 'H-E-B GAS'
       WHEN ${merchant_name} like 'HY-VEE%' THEN 'HY-VEE GAS'
       WHEN ${merchant_name} like 'KROGER%' THEN 'KROGER FUEL'
       WHEN ${merchant_name} like 'KUM%GO%' THEN 'KUM & GO'
       WHEN ${merchant_name} like 'KWIK SHOP%' THEN 'KWIK SHOP'
       WHEN ${merchant_name} like '%KWIK STOP%' THEN 'KWIK STOP'
       WHEN ${merchant_name} like 'KWIK STAR%' THEN 'KWIK STAR'
       WHEN ${merchant_name} like 'KWIK TRIP%' THEN 'KWIK TRIP'
       WHEN ${merchant_name} like 'LOAF N JUG%' THEN 'LOAF N JUG'
       WHEN ${merchant_name} like 'LOVE%S%' THEN 'LOVE''S'
       WHEN ${merchant_name} like 'MAPCO%' THEN 'MAPCO'
       WHEN ${merchant_name} like 'MARATHON%' THEN 'MARATHON'
       WHEN ${merchant_name} like 'MAVERIK%' THEN 'MAVERIK'
       WHEN ${merchant_name} like 'MEIJER%' THEN 'MEIJER'
       WHEN ${merchant_name} like 'MURPHY %' THEN 'MURPHY'
       WHEN ${merchant_name} like 'PARKERS%' THEN 'PARKERS'
       WHEN ${merchant_name} like 'PETRO%' THEN 'PETRO'
       WHEN ${merchant_name} like 'PHILLIPS 66%' OR ${merchant_name} like 'Phillips 66%' THEN 'PHILLIPS 66'
       WHEN ${merchant_name} like 'PIC QUIK%' THEN 'PIC QUIK'
       WHEN ${merchant_name} like 'PILOT%' THEN 'PILOT'
       WHEN ${merchant_name} like 'QT%' OR ${merchant_name} like 'QUIKTRIP%' THEN 'QUIKTRIP'
       WHEN ${merchant_name} like 'RACETRAC%' THEN 'RACETRAC'
       WHEN ${merchant_name} like 'RACEWAY%' THEN 'RACEWAY'
       WHEN ${merchant_name} like 'ROAD RANGER%' THEN 'ROAD RANGER'
       WHEN ${merchant_name} like 'ROYAL FARMS%' THEN 'ROYAL FARMS'
       WHEN ${merchant_name} like 'SAFEWAY%' THEN 'SAFEWAY FUEL'
       WHEN ${merchant_name} like '%SAMS%CLUB%' THEN 'SAMS CLUB'
       WHEN ${merchant_name} like 'SHEETZ%' THEN 'SHEETZ'
       WHEN ${merchant_name} like 'SHELL%' THEN 'SHELL OIL'
       WHEN ${merchant_name} like 'SOUTHERN TIRE%' THEN 'SOUTHERN TIRE MART'
       WHEN ${merchant_name} like 'SPEEDWAY%' THEN 'SPEEDWAY'
       WHEN ${merchant_name} like 'SPEEDY STOP%' THEN 'SPEEDY STOP'
       WHEN ${merchant_name} like 'SPINX%' THEN 'SPINX'
       WHEN ${merchant_name} like 'STINKER%' THEN 'STINKER'
       WHEN ${merchant_name} like 'STRIPES%' THEN 'STRIPES'
       WHEN ${merchant_name} like 'SUNOCO%' THEN 'SUNOCO'
       WHEN ${merchant_name} like 'TA%' THEN 'TA'
       WHEN ${merchant_name} like 'TEXACO%' THEN 'TEXACO'
       WHEN ${merchant_name} like 'THORNTONS%' THEN 'THORNTONS'
       WHEN ${merchant_name} like '%VALERO%' THEN 'VALERO'
       WHEN ${merchant_name} like '%WALMART%' OR ${merchant_name} like 'WM SUPER%' THEN 'WALMART'
       WHEN ${merchant_name} like 'WAWA%' THEN 'WAWA'
       WHEN ${merchant_name} like 'YESWAY%' THEN 'YESWAY'

       --Hotels
       WHEN ${merchant_name} like 'HOLIDAY%' OR ${merchant_name} like '%HOLIDAY%' THEN 'HOLIDAY INN'
       WHEN ${merchant_name} like '%LA QUINTA%' THEN 'LA QUINTA INNS'
       WHEN ${merchant_name} like '%MARRIOTT%' OR ${merchant_name} like 'MARRIOTT%' OR ${merchant_name} like '$MARRIOTT' THEN 'MARRIOTT'
       WHEN ${merchant_name} like 'AVID%' THEN 'AVID HOTEL'
       WHEN ${merchant_name} like 'AIRBNB%' THEN 'AIRBNB'
       WHEN ${merchant_name} like 'ALOFT%' THEN 'ALOFT'
       WHEN ${merchant_name} like 'BEST WESTERN%' THEN 'BEST WESTERN'
       WHEN ${merchant_name} like 'CANDLEWOOD%' THEN 'CANDLEWOOD SUITES'
       WHEN ${merchant_name} like 'CAMBRIA%' THEN 'CAMBRIA HOTEL'
       WHEN ${merchant_name} like 'COMFORT INN%' THEN 'COMFORT INN'
       WHEN ${merchant_name} like 'COMFORT SUITES%' THEN 'COMFORT SUITES'
       WHEN ${merchant_name} like 'COUNTRY INN%' THEN 'COUNTRY INN & SUITES'
       WHEN ${merchant_name} like 'COURTYARD%' THEN 'MARRIOTT'
       WHEN ${merchant_name} like 'CROWNE PLAZA%' THEN 'CROWN PLAZA'
       WHEN ${merchant_name} like 'DAYS INN%' THEN 'DAYS INN'
       WHEN ${merchant_name} like 'DELTA%' THEN 'DELTA HOTELS'
       WHEN ${merchant_name} like 'DOUBLETREE%' THEN 'DOUBLETREE'
       WHEN ${merchant_name} like 'DRURY%' THEN 'DRURY INN'
       WHEN ${merchant_name} like 'FAIRFIELD%' THEN 'MARRIOTT'
       WHEN ${merchant_name} like 'EMBASSY SUITES%' OR ${merchant_name} like 'EMBASSY STES%'  THEN 'EMBASSY SUITES'
       WHEN ${merchant_name} like 'HAMPTON%' OR ${merchant_name} like 'Hampton%' THEN 'HAMPTON INN'
       WHEN ${merchant_name} like 'HILTON%' OR ${merchant_name} like 'Hilton%' OR ${merchant_name} like '%HILTON%' THEN 'HILTON'
       WHEN ${merchant_name} like 'HOME 2%' OR ${merchant_name} like 'HOME2%' OR ${merchant_name} like 'HOMES TO%' OR ${merchant_name} like 'HOMEWOOD%' OR ${merchant_name} like 'Homewood%' THEN 'HILTON'
       WHEN ${merchant_name} like 'HYATT%' THEN 'HYATT'
       WHEN ${merchant_name} like 'RESIDENCE INN%' THEN 'RESIDENCE INN'
       WHEN ${merchant_name} like 'SHERATON%' THEN 'SHERATON'
       WHEN ${merchant_name} like 'SPRINGHILL%' OR ${merchant_name} like 'SHS%' THEN 'SPRINGHILL SUITES'
       WHEN ${merchant_name} like 'STAYBRIDGE%' THEN 'STAYBRIDGE SUITES'
       WHEN ${merchant_name} like 'SUPER 8%' THEN 'SUPER 8'
       WHEN ${merchant_name} like 'TRU %' THEN 'HILTON'
       WHEN ${merchant_name} like '%TRUMP%' THEN 'TRUMP'
       WHEN ${merchant_name} like 'TOWNE PLACE%' OR ${merchant_name} like 'TOWNEPLACE%' OR ${merchant_name} like 'TPS%' THEN 'TOWNE PLACE SUITES'
       WHEN ${merchant_name} like 'WESTIN%' OR ${merchant_name} like 'THE WESTIN%' THEN 'WESTIN'
       WHEN ${merchant_name} like 'WYNDHAM%' THEN 'WYNDHAM'
       --Rental Car
       WHEN ${merchant_name} like 'BUDGET%' then 'BUDGET'
       WHEN ${merchant_name} like 'ENTERPRISE%' then 'ENTERPRISE'
       WHEN ${merchant_name} like 'HERTZ%' then 'HERTZ'
       WHEN ${merchant_name} like 'NATIONAL CAR%' then 'NATIONAL CAR'
       WHEN ${merchant_name} like '%PAYLESS%' then 'PAYLESS'
       WHEN ${merchant_name} like 'THRIFTY%' then 'THRIFTY'
       --Restaurants
       WHEN ${merchant_name} like '%TORCHYS%' THEN 'TORCHYS TACOS'
       WHEN ${merchant_name} like '%BRAUMS%' THEN 'BRAUMS'
       WHEN ${merchant_name} like '54TH%' THEN '54TH STREET BAR & GRILL'
       WHEN ${merchant_name} like '%5GUYS%' THEN '5GUYS'
       WHEN ${merchant_name} like '%HOULIHAN%' THEN 'HOULIHANS'
       WHEN ${merchant_name} like 'APPLEBEE%' THEN 'APPLEBEES'
       WHEN ${merchant_name} like 'ARBYS%' OR ${merchant_name} like 'ARBY''S%' THEN 'ARBY''S'
       WHEN ${merchant_name} like 'BOJANGLES%' THEN 'BOJANGLES'
       WHEN ${merchant_name} like 'BONE DAD%' THEN 'BONE DADDY'
       WHEN ${merchant_name} like 'BONEFISH%' THEN 'BONEFISH GRILL'
       WHEN ${merchant_name} like 'BUFFALO WILD WINGS%' OR ${merchant_name} like 'BWW%' THEN 'BUFFALO WILD WINGS'
       WHEN ${merchant_name} like '%BURGER KING%' THEN 'BURGER KING'
       WHEN ${merchant_name} like 'CARLS JR%' THEN 'CARLS JR'
       WHEN ${merchant_name} like 'CARRABBAS%' THEN 'CARRABAS ITALIAN GRILL'
       WHEN ${merchant_name} like '%CHICK-FIL-A%' THEN 'CHICK-FIL-A'
       WHEN ${merchant_name} like '%CHILI''S%' THEN 'CHILI''s'
       WHEN ${merchant_name} like '%CHIPOTLE%' THEN 'CHIPOTLE'
       WHEN ${merchant_name} like 'CHURCH S %' OR ${merchant_name} like 'CHURCHS %' OR ${merchant_name} like 'CHURCH''S %' THEN 'CHURCH''S CHICKEN'
       WHEN ${merchant_name} like '%CRACKER BAR%' THEN 'CRACKER BARREL'
       WHEN ${merchant_name} like '%CULVERS%' THEN 'CULVERS'
       WHEN ${merchant_name} like '%DAIRY QUEEN%' THEN 'DAIRY QUEEN'
       WHEN ${merchant_name} like '%DAVE & BUSTER%' THEN 'DAVE & BUSTER''S'
       WHEN ${merchant_name} like '%DOORDASH%' THEN 'DOORDASH'
       WHEN ${merchant_name} like 'MCDONALD%' THEN 'MCDONALD''S'
       WHEN ${merchant_name} like 'SONIC%' THEN 'SONIC'
       WHEN ${merchant_name} like 'STARBUCKS%' OR ${merchant_name} like 'SBUX%' THEN 'STARBUCKS'
       WHEN ${merchant_name} like '%DOMINO''S%' THEN 'DOMINO''S'
       WHEN ${merchant_name} like 'Subway%' OR ${merchant_name} like 'SUBWAY%' THEN 'SUBWAY'
       WHEN ${merchant_name} like 'TACO BELL%' THEN 'TACO BELL'
       WHEN ${merchant_name} like 'TEXAS ROAD%' THEN 'TEXAS ROADHOUSE'
       WHEN ${merchant_name} like 'TOPGOLF%' OR ${merchant_name} like 'TOP GOLF%' THEN 'TOPGOLF'
       WHEN ${merchant_name} like 'TWIN PEAKS%' OR ${merchant_name} like 'Twin Peaks%' THEN 'TWIN PEAKS'
       WHEN ${merchant_name} like 'WAFFLE HOUSE%' THEN 'WAFFLE HOUSE'
       WHEN ${merchant_name} like 'WENDYS%' OR ${merchant_name} like 'WENDY''S%'   THEN 'WENDYS'
       WHEN ${merchant_name} like 'WHATABURGER%' THEN 'WHATABURGER'
       WHEN ${merchant_name} like 'WILD WING CAFE%' THEN 'WILD WING CAFE'
       WHEN ${merchant_name} like 'WINGSTOP%' THEN 'WINGSTOP'
       WHEN ${merchant_name} like 'YARD HOUSE%' THEN 'YARD HOUSE'
       WHEN ${merchant_name} like '%ZAXBY%' THEN 'ZAXBY''S'
else ${merchant_name} END
    ;;
  }

  dimension: action_code {
    type: string
    sql: ' ' ;;
  }

  dimension: reason_code {
    type: string
    sql: ' ' ;;
  }
}
