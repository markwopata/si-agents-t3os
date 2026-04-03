view: asset_retail_tool_sales_reps {
  sql_table_name: "DEBT"."ASSET_RETAIL_TOOL_SALES_REPS"
  ;;

  dimension: asset_id {
    primary_key: yes
    type: number
    sql: ${TABLE}.ASSET_ID ;;
  }

  dimension: asset_invoice_url {
    type: string
    sql: ${TABLE}.ASSET_INVOICE_URL ;;
  }

  dimension: serial_number {
    type: string
    sql: ${TABLE}.SERIAL_NUMBER ;;
  }

  dimension: vin {
    type: string
    sql: ${TABLE}.VIN ;;
  }

  dimension: asset_type_id {
    type: string
    sql: ${TABLE}.ASSET_TYPE_ID ;;
  }

  dimension: asset_type {
    type: string
    sql: ${TABLE}.ASSET_TYPE ;;
  }

  dimension: company_id {
    type: number
    sql: ${TABLE}.COMPANY_ID ;;
  }

  dimension: company_name {
    type: string
    sql: ${TABLE}.COMPANY_NAME ;;
  }

  dimension: hours {
    type: number
    sql: ROUND(${TABLE}.HOURS,0) ;;
  }

  dimension: market_id {
    type: number
    sql: ${TABLE}.MARKET_ID ;;
  }

  dimension: market_name {
    type: string
    sql: ${TABLE}.NAME ;;
  }

  dimension: make {
    type: string
    sql: ${TABLE}.MAKE ;;
  }

  dimension: model_name {
    type: string
    sql: ${TABLE}.MODEL ;;
  }

  dimension: equipment_class {
    type: string
    sql: ${TABLE}.ASSET_CLASS ;;
  }

  dimension: description {
    type: string
    sql: ${TABLE}.DESCRIPTION ;;
  }

  dimension: greensill_ind {
    type: string
    sql: ${TABLE}.GREENSILL_IND ;;
  }

  dimension: rental_status {
    type: string
    sql: ${TABLE}.RENTAL_STATUS ;;
  }

  dimension: finance_status {
    type: string
    sql: ${TABLE}.FINANCE_STATUS ;;
  }

  dimension: year {
    type: number
    sql: ${TABLE}.YEAR ;;
  }

  dimension: oec{
    type: number
    sql: ${TABLE}.OEC ;;
  }

  dimension: schedule {
    type: string
    sql: ${TABLE}.SCHEDULE ;;
  }

  dimension: rpo_status {
    type: string
    sql: ${TABLE}.RPO_STATUS ;;
  }

  dimension: orig_bal{
    type: number
    sql: ${TABLE}.ORIG_BAL ;;
  }

  dimension: curr_bal{
    type: number
    sql: ${TABLE}.CURR_BAL ;;
  }

  dimension_group: first_rental {
    type: time
    timeframes: [date, week, month, year]
    sql: ${TABLE}.FIRST_RENTAL ;;
  }

  dimension: payoff_amount{
    type: number
    sql: ${TABLE}.PAYOFF_AMT ;;
    value_format_name: decimal_0
  }

  dimension: nbv{
    type: number
    sql: ${TABLE}.NBV ;;
    value_format_name: decimal_0
  }

  dimension: paid_in_cash_ind{
    type: yesno
    sql: ${TABLE}.PAID_IN_CASH_IND ;;
  }

  measure: asset_replacement_value {
    type: sum
    sql: CASE WHEN ${asset_id} = 20367 THEN 64239
              WHEN ${asset_id} = 5065 THEN 40053
              WHEN ${asset_id} = 6197 THEN 45842
              WHEN ${asset_id} = 1340 THEN 73800
              WHEN ${asset_id} = 4213 THEN 43535
              WHEN ${asset_id} = 28354 THEN 25915
              WHEN ${asset_id} = 1391 THEN 73800
              WHEN ${asset_id} = 1392 THEN 73800
              WHEN ${asset_id} = 1434 THEN 53450
              WHEN ${greensill_ind} = 'greensill' THEN (${nbv} * 1.22)
              WHEN TRIM(UPPER(${make})) LIKE '%JOHN DEERE%' AND TRIM(UPPER(${model_name})) LIKE '%650K%' AND (${nbv} * 1.33) > 142000 THEN (${nbv} * 1.33)
              WHEN TRIM(UPPER(${make})) LIKE '%JOHN DEERE%' AND TRIM(UPPER(${model_name})) LIKE '%650K%' AND (${nbv} * 1.33) <= 142000 THEN 142000
              WHEN TRIM(UPPER(${make})) LIKE '%SANY%' AND TRIM(UPPER(${model_name})) LIKE '%SY500%' THEN (${nbv} * 1.35)
              WHEN TRIM(UPPER(${make})) LIKE '%SANY%' AND TRIM(UPPER(${model_name})) LIKE '%SY50%' THEN (${nbv} * 1.40)
              WHEN TRIM(UPPER(${make})) LIKE '%SANY%' AND TRIM(UPPER(${model_name})) LIKE '%SY35%' THEN (${nbv} * 1.40)
              WHEN TRIM(UPPER(${make})) LIKE '%SANY%' AND TRIM(UPPER(${model_name})) LIKE '%SY135%' THEN (${nbv} * 1.35)
              WHEN TRIM(UPPER(${make})) LIKE '%SANY%' AND TRIM(UPPER(${model_name})) LIKE '%SY95%' THEN (${nbv} * 1.35)
              WHEN TRIM(UPPER(${make})) LIKE '%SANY%' AND TRIM(UPPER(${model_name})) LIKE '%SY215%' THEN (${nbv} * 1.35)
              WHEN TRIM(UPPER(${make})) LIKE '%SANY%' AND TRIM(UPPER(${equipment_class})) LIKE '%Excavator%' THEN (${nbv} * 1.35)
              WHEN TRIM(UPPER(${equipment_class})) LIKE '%Telescopic Boom Lift, 120%' THEN (${nbv} * 1.30)
              WHEN TRIM(UPPER(${equipment_class})) LIKE '%Telescopic Boom Lift, 100%' THEN (${nbv} * 1.30)
              WHEN TRIM(UPPER(${equipment_class})) LIKE '%Telescopic Boom Lift, 125%' THEN (${nbv} * 1.30)
              WHEN TRIM(UPPER(${equipment_class})) LIKE '%Telescopic Boom Lift, 150%' THEN (${nbv} * 1.30)
              WHEN TRIM(UPPER(${equipment_class})) LIKE '%Telescopic Boom Lift, 135%' THEN (${nbv} * 1.30)
              WHEN TRIM(UPPER(${equipment_class})) LIKE '%Telescopic Boom Lift, 180%' THEN (${nbv} * 1.30)
              WHEN TRIM(UPPER(${equipment_class})) LIKE '%Backhoe Loader%' THEN (${nbv} * 1.30)
              WHEN TRIM(UPPER(${equipment_class})) LIKE '%Wheel Loader%' THEN (${nbv} * 1.30)
              WHEN TRIM(UPPER(${equipment_class})) LIKE '%Track Dozer%' THEN (${nbv} * 1.30)
              WHEN ${asset_type_id} = 2 THEN (${nbv} * 1.26)
              WHEN ${paid_in_cash_ind}=1 THEN (${nbv} * 1.22)
              WHEN ${payoff_amount} IS NULL THEN (${nbv} * 1.22)
              WHEN ${nbv} >= ${payoff_amount} THEN (${nbv} * 1.22)
              WHEN ${nbv} < ${payoff_amount} THEN (${payoff_amount} * 1.22)
              ELSE 0 END ;;
    value_format_name: decimal_0
  }

  measure: price_floor {
    type: sum
    sql: CASE WHEN ${greensill_ind} = 'greensill' THEN (${nbv} * 0.08)
              WHEN ${paid_in_cash_ind}=1 THEN (${nbv} * 0.08) + ${nbv}
              WHEN ${payoff_amount} IS NULL THEN (${nbv} * 0.08) + ${nbv}
              WHEN ${nbv} >= ${payoff_amount} THEN (${nbv} * 0.08) + ${nbv}
              WHEN ${nbv} < ${payoff_amount} THEN (${payoff_amount} * 0.08) + ${payoff_amount}
              ELSE 0 END ;;
    value_format_name: decimal_0
  }

  dimension: date_created{
    type: date
    sql: ${TABLE}.DATE_CREATED ;;
  }

  dimension: purchase_date{
    type: date
    sql: ${TABLE}.PURCHASE_DATE ;;
  }

  dimension: submit_asset_quote_request {
    #type: string
    html: <font color="blue "><u><a href = "https://docs.google.com/forms/d/e/1FAIpQLSdgAqkc3BbMwanMrlzOmJIW-LbYidsovmga49jQFMd-JeBqqw/viewform?usp=pp_url&entry.48880894={{  _user_attributes['email'] }}&entry.986112423={{market_name._value}}&entry.632031412={{asset_id._value }}&entry.1717427395={{serial_number._value }}&entry.1389071533={{equipment_class._value}}&entry.502486490={{model_name._value}}&entry.2118721629={{make._value}}&entry.408981061={{year._value}}&entry.1380918136={{hours._value}}&entry.94737192={{asset_replacement_value._rendered_value}}" target="_blank">Submit Quote Request</a></font></u> ;;
    sql: ${TABLE}.ASSET_ID
      ;;
    #sql: (select ${TABLE}.user_id from users where ${TABLE}.email_address = '{{ _user_attributes['email'] }}')
    #users.passing_user_id_from_logged_in_looker_user._value
  }

  dimension: submit_asset_quote_request_button {
    type: string
    sql: 'View Used Assets For Sale'  ;;

    link: {
      label: "View Used Assets For Sale"
      url: "https://equipmentshare.looker.com/looks/87?toggle=det"
    }
  }

  dimension: asset_id_link_to_asset_dashboard {
    type: number
    sql: ${asset_id} ;;

    link: {
      label: "View Asset Details Dashboard"
      url: "https://equipmentshare.looker.com/dashboards/169?Asset+ID={{ value | url_encode }}"
    }
  }

  dimension: asset_id_link_to_pictures {
    type: string
    html: <font color="blue "><u><a href ="https://equipmentshare.looker.com/dashboards/169?Asset+ID={{ value | url_encode }}"target="_blank">Pictures</a></font></u> ;;
    sql: ${asset_id};;
  }
}
