view: v_cc_audit {
  sql_table_name: "ANALYTICS"."TREASURY"."V_CC_AUDIT"
    ;;

 ###############DIMENSIONS##########################

  dimension: card_type {
    type: string
    sql:replace(${TABLE}."CARD_TYPE", '_', ' ');;
  }



  dimension: corp_field {
    type: string
    sql: ${TABLE}."CORP_FIELD" ;;
  }

  dimension: day {
    type: number
    sql: ${TABLE}."DAY" ;;
  }

  dimension: default_cost_centers_full_path {
    type: string
    sql: ${TABLE}."DEFAULT_COST_CENTERS_FULL_PATH" ;;
  }

  dimension: dept {
    type: string
    sql: case when  ${TABLE}."DEPT" is null or ${TABLE}."DEPT" = '' then 'Regional' else  ${TABLE}."DEPT" end;;
  }

  dimension: employee_name {
    type: string
    sql: ${TABLE}."EMPLOYEE_NAME" ;;
  }

  dimension: employee_number {
    type: string
    value_format: "#"
    sql: ${TABLE}."EMPLOYEE_NUMBER" ;;
  }

  dimension: employee_title {
    type: string
    sql: ${TABLE}."EMPLOYEE_TITLE" ;;
  }

  dimension: transaction_amount_dim {
    type: number
    sql: ${TABLE}."TRANSACTION_AMOUNT" ;;
  }

  dimension: transaction_id {
    type: string
    sql: ${TABLE}."TRANSACTION_ID" ;;
  }

  dimension: lob {
    type: string
    sql: ${TABLE}."LOB" ;;
  }

  dimension: mcc_code {
    type: number
    value_format: "0"
    sql: ${TABLE}."MCC_CODE" ;;
  }

  dimension: mcc_type {
    type: string
    sql: ${TABLE}."MCC_TYPE" ;;
  }

  dimension: merchant_name {
    type: string
    sql: ${TABLE}."VENDOR" ;;
  }

  dimension: month {
    type: number
    sql: ${TABLE}."MONTH" ;;
  }


  dimension: month_name {
    type: number
    sql: ${TABLE}."MONTH_NAME" ;;
  }

  dimension: quarter {
    type: number
    sql: ${TABLE}."QUARTER" ;;
  }

  dimension: region {
    type: string
    sql: ${TABLE}."REGION" ;;
  }

  dimension: region_district {
    type: string
    sql: ${TABLE}."REGION_DISTRICT" ;;
  }

  dimension: sub_dept {
    type: string
    sql: ${TABLE}."SUB_DEPT" ;;
  }

  dimension: year {
    type: number
    sql: ${TABLE}."YEAR" ;;
  }

  dimension: quarter_year {
    type: string
    sql: concat('Q',${quarter},'-',${year}) ;;
  }

  dimension: month_year {
    type: string
    sql: concat(${month_name},'-',${year}) ;;
  }

  dimension: vendor {
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

  ###############DATES##########################

  dimension: transaction_date {
    type: date
    sql: ${TABLE}."TRANSACTION_DATE" ;;
  }

  filter: date_filter {
    type: date
    suggest_dimension: transaction_date
  }

  dimension: date_start {
    type: date
    sql: DATEADD('MONTH',-1,DATE_TRUNC('MONTH', {% date_start date_filter %}))::DATE ;;
  }

  dimension: date_end {
    type: date
    sql: LAST_DAY(DATEADD('DAY',-32,DATE_TRUNC('MONTH', {% date_end date_filter %})))::DATE  ;;
  }


  dimension: is_current_period {
    type: yesno
    sql: ${transaction_date} between  {% date_start date_filter %}::date and {% date_end date_filter %}::date;;
  }

  dimension: is_prior_year {
    type: yesno
    sql: ${transaction_date} between  DATEADD('DAY',-365,{% date_start date_filter %}::date) and DATEADD('DAY',-365,{% date_end date_filter %}::date) ;;
  }

  dimension: is_prior_quarter {
    type: yesno
    sql: ${transaction_date} between DATEADD('QUARTER',-1,DATE_TRUNC('QUARTER', {% date_start date_filter %}::DATE))
         AND LAST_DAY(DATEADD('QUARTER',-1,DATE_TRUNC('QUARTER', {% date_end date_filter %}::DATE)),'QUARTER');;
  }

  dimension: is_prior_month {
    type: yesno
    sql: ${transaction_date} between DATEADD('MONTH',-1,DATE_TRUNC('MONTH', {% date_start date_filter %}::DATE))
       AND LAST_DAY(DATEADD('MONTH',-1,DATE_TRUNC('MONTH', {% date_end date_filter %}::DATE)));;
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
    sql: ${TABLE}."TRANSACTION_DATE" ;;
  }

  ###############CURRENT PERIOD MEASURES##########################

  measure: transaction_amount {
    type: sum
    value_format: "$#,##0.#0;($#,##0.#0);-"
    drill_fields: [cc_details_current*]
    link: {label: "Drill Detail" url:"{{ transaction_amount._link }}&f[v_cc_audit.is_current_period]=True" }
    sql: iff(${is_current_period},${TABLE}."TRANSACTION_AMOUNT",null) ;;
    }

  measure: average_transaction_amount {
    type: average
     value_format: "$#,##0.#0;($#,##0.#0);-"
    sql: iff(${is_current_period},${TABLE}."TRANSACTION_AMOUNT",null) ;;
  }

  measure: amount {
    type: average
    value_format: "$#,##0.#0;($#,##0.#0);-"
    sql: iff(${is_current_period},${TABLE}."TRANSACTION_AMOUNT",null) ;;
  }

  measure: median_transaction_amount {
    type: median
     value_format: "$#,##0.#0;($#,##0.#0);-"
    sql: iff(${is_current_period},${TABLE}."TRANSACTION_AMOUNT",null) ;;
  }

  measure: min_transaction_amount {
    type: min
     value_format: "$#,##0.#0;($#,##0.#0);-"
    sql: iff(${is_current_period},${TABLE}."TRANSACTION_AMOUNT",null) ;;
  }

  measure: max_transaction_amount {
    type: max
     value_format: "$#,##0.#0;($#,##0.#0);-"
    sql: iff(${is_current_period},${TABLE}."TRANSACTION_AMOUNT",null) ;;
  }

  measure: transaction_count {
    type: number
     value_format: "#,###;(#,###);-"
    sql: sum(iff(${is_current_period},1,0)) ;;
  }

###############PRIOR YEAR MEASURES##########################

#  measure: prior_year_transaction_amount {
#    type:sum
#    value_format: "$#,##0.#0;($#,##0.#0);-"
#    drill_fields: [cc_details_prior_year*]
#    link: {label: "Drill Detail" url:"{{ prior_year_transaction_amount._link }}&f[v_cc_audit.is_prior_year]=True" }
#    sql: iff(${is_prior_year},${TABLE}."TRANSACTION_AMOUNT",null) ;;
#  }

 # measure: prior_year_average_transaction_amount {
#    type: average
#    value_format: "$#,##0.#0;($#,##0.#0);-"
 #   sql: iff(${is_prior_year},${TABLE}."TRANSACTION_AMOUNT",null) ;;
#  }


 # measure: prior_year_median_transaction_amount {
#    type: median
#    value_format: "$#,##0.#0;($#,##0.#0);-"
 #   sql: iff(${is_prior_year},${TABLE}."TRANSACTION_AMOUNT",null) ;;
#  }

 # measure: prior_year_min_transaction_amount {
#    type: min
#    value_format: "$#,##0.#0;($#,##0.#0);-"
 #   sql: iff(${is_prior_year},${TABLE}."TRANSACTION_AMOUNT",null) ;;
#  }

 # measure: prior_year_max_transaction_amount {
#    type: max
#    value_format: "$#,##0.#0;($#,##0.#0);-"
#    sql: iff(${is_prior_year},${TABLE}."TRANSACTION_AMOUNT",null) ;;
 # }

#  measure: prior_year_transaction_count {
#    type: number
#    value_format: "#,###;(#,###);-"
#    sql: sum(iff(${is_prior_year},1,0)) ;;
 # }

###############PRIOR QUARTER MEASURES##########################

 # measure: prior_quarter_transaction_amount {
#    type: sum
#    value_format: "$#,##0.#0;($#,##0.#0);-"
 #   drill_fields: [cc_details_prior_quarter*]
#    link: {label: "Drill Detail" url:"{{ prior_quarter_transaction_amount._link }}&f[v_cc_audit.is_prior_quarter]=True" }
#    sql: iff(${is_prior_quarter},${TABLE}."TRANSACTION_AMOUNT",null) ;;
#  }

 # measure: prior_quarter_average_transaction_amount {
#    type: average
#    value_format: "$#,##0.#0;($#,##0.#0);-"
#    sql: iff(${is_prior_quarter},${TABLE}."TRANSACTION_AMOUNT",null) ;;
#  }


 # measure: prior_quarter_median_transaction_amount {
#    type: median
#    value_format: "$#,##0.#0;($#,##0.#0);-"
#    sql: iff(${is_prior_quarter},${TABLE}."TRANSACTION_AMOUNT",null) ;;
#  }

#  measure: prior_quarter_min_transaction_amount {
#    type: min
#    value_format: "$#,##0.#0;($#,##0.#0);-"
#    sql: iff(${is_prior_quarter},${TABLE}."TRANSACTION_AMOUNT",null) ;;
#  }

 # measure: prior_quarter_max_transaction_amount {
#    type: max
#    value_format: "$#,##0.#0;($#,##0.#0);-"
 #   sql: iff(${is_prior_quarter},${TABLE}."TRANSACTION_AMOUNT",null) ;;
#  }

 # measure: prior_quarter_transaction_count {
#    type: number
 #   value_format: "#,###;(#,###);-"
  #  sql: sum(iff(${is_prior_quarter},1,0)) ;;
  #}

###############PRIOR MONTH MEASURES##########################

  measure: prior_month_transaction_amount {
    type: sum
    value_format: "$#,##0.#0;($#,##0.#0);-"
    drill_fields: [cc_details_prior_month*]
    link: {label: "Drill Detail" url:"{{ prior_month_transaction_amount._link }}&f[v_cc_audit.is_prior_month]=True" }
    sql: iff(${is_prior_month},${TABLE}."TRANSACTION_AMOUNT",null) ;;
  }

  measure: prior_month_average_transaction_amount {
    type: average
    value_format: "$#,##0.#0;($#,##0.#0);-"
    sql: iff(${is_prior_month},${TABLE}."TRANSACTION_AMOUNT",null) ;;
  }

  measure: prior_month_amount {
    type: average
    value_format: "$#,##0.#0;($#,##0.#0);-"
    sql: iff(${is_prior_month},${TABLE}."TRANSACTION_AMOUNT",null) ;;
  }


  measure: prior_month_median_transaction_amount {
    type: median
    value_format: "$#,##0.#0;($#,##0.#0);-"
    sql: iff(${is_prior_month},${TABLE}."TRANSACTION_AMOUNT",null) ;;
  }

  measure: prior_month_min_transaction_amount {
    type: min
    value_format: "$#,##0.#0;($#,##0.#0);-"
    sql: iff(${is_prior_month},${TABLE}."TRANSACTION_AMOUNT",null) ;;
  }

  measure: prior_month_max_transaction_amount {
    type: max
    value_format: "$#,##0.#0;($#,##0.#0);-"
    sql: iff(${is_prior_month},${TABLE}."TRANSACTION_AMOUNT",null) ;;
  }

  measure: prior_month_transaction_count {
    type: number
    value_format: "#,###;(#,###);-"
    sql: sum(iff(${is_prior_month},1,0)) ;;
  }



###############DRILL DOWN FIELDS##########################

  set: cc_details_current {
    fields: [
      employee_number, employee_name, employee_title, default_cost_centers_full_path, mcc_code, mcc_type,vendor,card_type ,transaction_date,
      cc_spend_receipt_upload.additional_notes,cc_spend_receipt_upload.link_to_receipt,transaction_id,amount
    ]
  }

  #set: cc_details_prior_year {
  #  fields: [
  #    employee_number, employee_name, employee_title, default_cost_centers_full_path, mcc_code, mcc_type,vendor,card_type ,transaction_date,
  #    cc_spend_receipt_upload.additional_notes,cc_spend_receipt_upload.link_to_receipt,transaction_id,prior_year_average_transaction_amount
  #  ]
  #}

  #set: cc_details_prior_quarter {
  #  fields: [
  #    employee_number, employee_name, employee_title, default_cost_centers_full_path, mcc_code, mcc_type,vendor,card_type ,transaction_date,
  #    cc_spend_receipt_upload.additional_notes,cc_spend_receipt_upload.link_to_receipt,transaction_id,prior_quarter_average_transaction_amount
  #  ]
  #}

  set: cc_details_prior_month {
    fields: [
      employee_number, employee_name, employee_title, default_cost_centers_full_path, mcc_code, mcc_type,vendor,card_type ,transaction_date,
      cc_spend_receipt_upload.additional_notes,cc_spend_receipt_upload.link_to_receipt,transaction_id,prior_month_amount
    ]
  }



}
