view: asset_nbv_all_owners {
  derived_table: {
    sql:
    with pricing as (SELECT *
                     FROM DATA_SCIENCE.FLEET_OPT.ALL_EQUIPMENT_ROUSE_ESTIMATES AERE
                         QUALIFY ROW_NUMBER() OVER (PARTITION BY AERE.ASSET_ID ORDER BY AERE.DATE_CREATED DESC) =
                                 1),
    -- changed 11/18/24, filtering blanket extended warranty eligibility using client_cat_class E.M.
    rouse_cat_class as (SELECT equipment, client_cat_class
                    FROM data_science.fleet_opt.full_rouse fr
                    ),
    estimated_internal_valuation as (
          select dafo.asset_id
              , fev.date_month_end
              , fev.salvage_value
              , fev.period_depreciation
              , fev.estimated_valuation_number
          from fleet_optimization.gold.fact_estimated_valuation fev
          join fleet_optimization.gold.dim_assets_fleet_opt dafo
          on fev.asset_key = dafo.asset_key
          where year(fev.date_month_end) = year(current_date())
          and month(fev.date_month_end) = month(current_date())
          )

      SELECT anbv.*, eiv.estimated_valuation_number,
      aser.reasons_for_sales_eligibility_flag,
      a.RENTAL_BRANCH_ID,
      a.ODOMETER,
      p.PREDICTIONS_RETAIL,
      dafo.asset_floor_target_price as floor_price,
      dafo.asset_bench_target_price as bench_price,
      dafo.asset_online_target_price as online_price,
      dafo.asset_own_target_price as own_program_price,
      dafo.asset_current_net_book_value as net_book_value,
      coalesce(dafo.asset_current_net_book_value, eiv.estimated_valuation_number) as combined_valuation,
      dafo.asset_abs_flag as flag_for_abs_list,
      wl.flag_for_warranty_list,
      dafo.asset_own_flag,
      dafo.asset_current_oec,
      dafo.is_asset_eligible_for_sale,
      dafo.asset_equipment_class_name,
      dafo.equipment_class_id as class_id
      FROM ANALYTICS.DEBT.ASSET_NBV_ALL_OWNERS anbv
      left join ES_WAREHOUSE.PUBLIC.ASSETS a
      on anbv.ASSET_ID = a.ASSET_ID
      left join fleet_optimization.gold.v_asset_sales_eligibility_reasons aser
      on a.asset_id = aser.asset_id
      left join pricing p
      on ANBV.ASSET_ID = p.ASSET_ID
      left join estimated_internal_valuation eiv
      on eiv.asset_id = anbv.asset_id
      left join data_science.fleet_opt.full_rouse rs
      on anbv.asset_id = rs.equipment
      left join fleet_optimization.gold.dim_assets_fleet_opt dafo
      on anbv.asset_id = dafo.asset_id
      left join (select asset_id, TRUE as flag_for_warranty_list
      from data_science.fleet_opt.current_seis_warranty_eligible_assets
      ) wl on wl.asset_id = anbv.asset_id
      WHERE {% condition asset_id %} anbv.asset_id {% endcondition %}
      AND anbv.COMPANY_ID not in (420)
      ;;
  }

  dimension: estimated_internal_valuation {
    type: number
    sql: ${TABLE}."ESTIMATED_VALUATION_NUMBER" ;;
    value_format_name: usd
  }

  dimension: combined_valuation {
    type: number
    sql: ${TABLE}."COMBINED_VALUATION" ;;
    value_format_name: usd
  }

  dimension: equipment_class {
    type: string
    sql: ${TABLE}."ASSET_EQUIPMENT_CLASS_NAME" ;;
  }

  dimension: equipment_class_id {
    type: string
    sql: ${TABLE}."CLASS_ID" ;;
  }

  dimension: asset_id {
    primary_key: yes
    type: number
    value_format_name: id
    sql: ${TABLE}."ASSET_ID" ;;
  }

  dimension: asset_invoice_url {
    type: string
    sql: ${TABLE}."ASSET_INVOICE_URL" ;;
  }

  dimension: asset_type {
    type: string
    sql: ${TABLE}."ASSET_TYPE" ;;
  }

  dimension: asset_type_id {
    type: number
    sql: ${TABLE}."ASSET_TYPE_ID" ;;
  }

  dimension: company_id {
    type: number
    sql: ${TABLE}."COMPANY_ID" ;;
  }

  dimension: company_name {
    type: string
    sql: ${TABLE}."COMPANY_NAME" ;;
  }

  dimension: curr_bal {
    type: number
    sql: ${TABLE}."CURR_BAL" ;;
  }

  dimension_group: date_created {
    type: time
    timeframes: [
      raw,
      date,
      week,
      month,
      quarter,
      year
    ]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."DATE_CREATED" ;;
  }

  dimension: description {
    type: string
    sql: ${TABLE}."DESCRIPTION" ;;
  }

  dimension: finance_status {
    type: string
    sql: ${TABLE}."FINANCE_STATUS" ;;
  }

  dimension: financing_facility_type {
    type: string
    sql: ${TABLE}."FINANCING_FACILITY_TYPE" ;;
  }

  dimension_group: first_rental {
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
    sql: CAST(${TABLE}."FIRST_RENTAL" AS TIMESTAMP_NTZ) ;;
  }

  dimension: greensill_ind {
    type: string
    sql: ${TABLE}."GREENSILL_IND" ;;
  }

  dimension: hours {
    type: number
    sql: TO_NUMBER(coalesce(${TABLE}."HOURS", '0')) ;;
  }

  dimension: make {
    type: string
    sql: ${TABLE}."MAKE" ;;
  }

  dimension: market_id {
    type: number
    sql: ${TABLE}."MARKET_ID" ;;
  }

  dimension: model {
    type: string
    sql: ${TABLE}."MODEL" ;;
  }

  dimension: market_name {
    type: string
    sql: ${TABLE}."NAME" ;;
    label: "Market"
  }

  dimension: nbv {
    type: number
    sql: ${TABLE}."NBV" ;;
  }

  dimension: net_book_value {
    type: number
    sql: ${TABLE}."NET_BOOK_VALUE" ;;
    value_format_name: usd
    label: "Current Net Book Value"
  }

  dimension: oec {
    type: number
    sql: ${TABLE}."ASSET_CURRENT_OEC" ;;
    value_format_name: usd
  }

  dimension: odometer {
    type: number
    value_format_name: decimal_0
    sql: ${TABLE}."ODOMETER" ;;
  }

  dimension: orig_bal {
    type: number
    sql: ${TABLE}."ORIG_BAL" ;;
  }

  dimension: paid_in_cash_ind {
    type: number
    sql: ${TABLE}."PAID_IN_CASH_IND" ;;
  }

  dimension: payoff_amount {
    type: number
    sql: ${TABLE}."PAYOFF_AMT" ;;
  }

  dimension: pending_schedule {
    type: string
    sql: ${TABLE}."PENDING_SCHEDULE" ;;
  }

  dimension_group: purchase {
    type: time
    timeframes: [
      raw,
      date,
      week,
      month,
      quarter,
      year
    ]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."PURCHASE_DATE" ;;
  }

  dimension: rental_status {
    type: string
    sql: ${TABLE}."RENTAL_STATUS" ;;
  }

  dimension: schedule {
    type: string
    sql: ${TABLE}."SCHEDULE" ;;
  }

  dimension: serial_number {
    type: string
    sql: ${TABLE}."SERIAL_NUMBER" ;;
  }

  dimension: vin {
    type: string
    sql: ${TABLE}."VIN" ;;
  }

  dimension: serial_vin {
    type: string
    sql: coalesce(${serial_number},${vin}) ;;
  }

  dimension: year {
    type: number
    value_format_name: id
    sql: ${TABLE}."YEAR" ;;
  }

  dimension: sage_loan_id {
    type: string
    sql: ${TABLE}."SAGE_LOAN_ID" ;;
  }

  dimension: looker_price {
    type: number
    sql: ${used_equipment_sales_price_exceptions.looker_price} ;;
  }

  dimension: flag_for_abs_list {
    type: string
    sql: ${TABLE}."FLAG_FOR_ABS_LIST" ;;
  }

  dimension: submit_asset_quote_request {
    #type: string
    html: <font color="blue "><u><a href = "https://asset-retail-quote.equipmentshare.com/?assetId={{asset_id._value }}" target="_blank">Submit Quote Request</a></font></u> ;;
    sql: ${TABLE}.ASSET_ID
      ;;
  }

  dimension: rental_service_provider {
    type: string
    sql: ${TABLE}."RENTAL_BRANCH_ID" ;;
  }
  measure: asset_replacement_value {
    type: sum
    value_format_name: usd
    sql: CASE WHEN ${paid_in_cash_ind}=1      THEN (${internal_cost} * 1.26)
              WHEN ${payoff_amount} IS NULL   THEN (${internal_cost} * 1.26)
              WHEN ${nbv} >= ${payoff_amount} THEN (${internal_cost} * 1.26)
              WHEN ${nbv} < ${payoff_amount}  THEN (${internal_cost} * 1.26)
              ELSE 0 END ;;
  }

  measure: price_floor {
    type: sum
    sql: CASE WHEN ${paid_in_cash_ind}=1 THEN (${nbv} * 0.08) + ${nbv}
              WHEN ${payoff_amount} IS NULL THEN (${nbv} * 0.08) + ${nbv}
              WHEN ${nbv} >= ${payoff_amount} THEN (${nbv} * 0.08) + ${TABLE}.nbv
              WHEN ${nbv} < ${payoff_amount} THEN (${payoff_amount} * 0.08) + ${payoff_amount}
              ELSE 0 END ;;
  }

  dimension: asset_id_link_to_pictures {
    type: string
    html: <font color="blue "><u><a href ="https://equipmentshare.looker.com/dashboards/169?Asset+ID={{ value | url_encode }}"target="_blank">Pictures</a></font></u> ;;
    sql: ${asset_id};;
  }

  dimension: category {
    type:  string
    sql:  ${assets_aggregate.category} ;;
  }

  dimension: asset_sales_filter {
    type:  yesno
    sql: ${TABLE}."IS_ASSET_ELIGIBLE_FOR_SALE";;
    label:"Is Asset Sale-Eligible?"
  }

  dimension: sale_eligibility_description {
    type: string
    sql: ${TABLE}."REASONS_FOR_SALES_ELIGIBILITY_FLAG" ;;
    label: "Sale Eligibility Description"
  }

  dimension: retail_1pct_commission_range {
    label: "Floor"
    type: number
    value_format_name: usd_0
    sql: CEIL(${TABLE}."FLOOR_PRICE");;
  }

  dimension: retail_4pct_commission_range {
    label: "Bench (4% Commission)"
    type: number
    value_format_name: usd_0
    sql:  COALESCE(CEIL(${TABLE}."OWN_PROGRAM_PRICE"),CEIL(${TABLE}."BENCH_PRICE"))
              ;;
  }

  dimension: retail_5pct_commission_range {
    label: "Online (5% Commission)"
    type: number
    value_format_name: usd_0
    sql: CASE WHEN ${TABLE}."ONLINE_PRICE" - ${TABLE}."BENCH_PRICE" < 1 THEN NULL
              ELSE CEIL(${TABLE}."ONLINE_PRICE")
              END;;
  }

  dimension: own_program_price {
    label: "Own Program Price (4% Commission)"
    type:  number
    value_format_name: usd_0
    sql: CEIL(${TABLE}."OWN_PROGRAM_PRICE") ;;
  }

  measure: total_oec {
    type: sum
    sql: ${TABLE}."OEC" ;;
    value_format_name: usd
  }

  measure: predictions_retail {
    label: "Rouse Retail Prediction"
    type: sum
    value_format_name: usd
    sql: ${TABLE}."PREDICTIONS_RETAIL" ;;
  }

  dimension: own_flag {
    label: "Fleet"
    type: yesno
    sql: ${TABLE}."ASSET_OWN_FLAG" ;;
  }

  dimension: eligible_for_extended_warranty {
    label: "Warranty Eligible"
    type: yesno
    sql: CASE WHEN ${TABLE}."FLAG_FOR_WARRANTY_LIST" = TRUE
              AND ${hours} < 6000
              THEN TRUE
              ELSE FALSE
        END;;
  }

  measure: asset_replacement_value_sales_reps {
    type: sum
    sql: CASE WHEN ${looker_price} is not null THEN ${looker_price}
              WHEN ${asset_id} = 20367 THEN 64239
              WHEN ${asset_id} = 5065  THEN 40053
              WHEN ${asset_id} = 6197  THEN 45842
              WHEN ${asset_id} = 1340  THEN 73800
              WHEN ${asset_id} = 4213  THEN 43535
              WHEN ${asset_id} = 28354 THEN 25915
              WHEN ${asset_id} = 1391  THEN 73800
              WHEN ${asset_id} = 1392  THEN 73800
              WHEN ${asset_id} = 1434  THEN 53450
              WHEN ${internal_cost} = 0 THEN 0
              --Referencing the vendor to force all legacy trekker tractor units to a hard 10% markup per Mason Hunter
              WHEN ${company_purchase_orders.vendor_id} = 61019 then ${internal_cost} * 1.11

              WHEN ${make} ILIKE '%JOHN DEERE%'       and ${category} ilike '%Wheel Loader%'   then ${internal_cost} * 1.44
              WHEN ${make} ILIKE '%JOHN DEERE%'       and ${category} ilike '%Dozer%'          then ${internal_cost} * 1.44

              WHEN ${equipment_class}   ILIKE ANY(
                                              'Telehandler 16,000 -17,000 lbs, 32'' - 44'' Reach'
                                              )
              THEN ${internal_cost} * 1.55

              WHEN ${equipment_class}   ILIKE ANY(
                                              'Rough Terrain Scissor Lift, 26'' - 29'''
                                              )
              THEN ${internal_cost} * 1.50

              WHEN ${equipment_class}   ILIKE ANY(
                                              '%Backhoe Loader 90 - 99 Hp, Extendable Stick%'
                                              )
              THEN ${internal_cost} * 1.47

              WHEN ${equipment_class}   ILIKE ANY(
                                              'Electric Scissor Lift, 19'' Micro',
                                              'Electric Scissor Lift, 26'' Micro'
                                              )
              THEN ${internal_cost} * 1.45

              WHEN ${category}          ILIKE ANY(
                                              '%Compact Track Loaders%'
                                              )
              THEN ${internal_cost} * 1.44

              WHEN ${category}          ILIKE ANY(
                                              '%Vertical Mast Lifts%'
                                              )
              THEN ${internal_cost} * 1.42

              WHEN ${category}          ILIKE ANY(
                                              'Towable Boom Lifts'
                                              )
                OR ${equipment_class}   ILIKE ANY(
                                              'Telehandler 8,000 - 9,000 lbs, 40'' - 44'' Reach',
                                              'Rough Terrain Scissor Lift, 30'' - 35''',
                                              'Electric Scissor Lift, 26'' Wide%'
                                              )
              THEN ${internal_cost} * 1.40

              WHEN ${equipment_class}   ILIKE ANY(
                                              'Telehandler 2,500 - 4,500 lbs, 12'' - 14'' Reach',
                                              'Telehandler 14,000 - 15,000 lbs, 44'' - 56'' Reach'
                                              )
              THEN ${internal_cost} * 1.38

              WHEN ${equipment_class}   ILIKE ANY(
                                              'Telehandler 6,000 - 7,000 lbs, 34'' - 44'' Reach',
                                              'Telehandler 14,000 - 15,000 lbs, 44'' - 56'' Reach',
                                              'Rough Terrain Scissor Lift, 26'' - 29''%',
                                              'Rough Terrain Scissor Lift, 30'' - 35''',
                                              'Rough Terrain Scissor Lift, 30'' - 35'' Wide Deck',
                                              'Rough Terrain Scissor Lift, 50'' - 55'' Wide Deck',
                                              'Rough Terrain Scissor Lift, 60'' - 65'' Wide Deck',
                                              'Electric Articulating Boom Lift, 40'' Narrow',
                                              'Wheeled Dumper 6,000 - 7,000 Lb Payload%',
                                              '%Telescopic Boom Lift, 180'' - 185'' IC%',
                                              'Electric Scissor Lift, 19'' Narrow%',
                                              'Electric Scissor Lift, 19'' Micro with Step-up Platform',
                                              'Electric Scissor Lift, 45'' - 46''%'
                                              )
              THEN ${internal_cost} * 1.35

              WHEN ${equipment_class}   ILIKE ANY(
                                              'Telehandler 12,000 lbs, 54'' - 56'' Reach'
                                              )
              THEN ${internal_cost} * 1.33

              WHEN ${equipment_class}   ILIKE ANY(
                                              'Articulating Boom Lift, 40'' - 45'' IC',
                                              'ARTICULATING BOOM LIFT, 135'' IC%'
                                              )
              THEN ${internal_cost} * 1.32

              WHEN ${category}          ILIKE ANY(
                                              '%Wheeled Skid Loader%',
                                              'Rough Terrain Scissor Lifts'
                                              )
                OR ${equipment_class} ILIKE ANY(
                                              'Telescopic Boom Lift, 40'' IC',
                                              'Telescopic Boom Lift, 45'' - 46'' IC',
                                              'Telescopic Boom Lift, 65'' - 67'' IC',
                                              'Telescopic Boom Lift, 80'' IC',
                                              'Telescopic Boom Lift, 100%',
                                              'Telescopic Boom Lift, 120%',
                                              'Telescopic Boom Lift, 125%',
                                              'Telescopic Boom Lift, 135%',
                                              'Telescopic Boom Lift, 150%',
                                              'Telescopic Boom Lift, 180%',
                                              'Telehandler 5,000 - 5,500 lbs, 18'' - 20'' Reach%',
                                              'Telehandler, 9000 lbs, 55'' Reach',
                                              'Telehandler 10,000 lbs, 40'' - 44'' Reach',
                                              'Telehandler 10,000 lbs, 54'' - 56'' Reach',
                                              'Telehandler 12,000 lbs, 40'' - 44'' Reach',
                                              'Rotator 10,000 - 11,000 lbs',
                                              'Electric Articulating Boom Lift, 45'' Wide',
                                              'Ride-On Mini Skid Steer 800 - 1,100%',
                                              'Electric Scissor Lift, 26'' Narrow%',
                                              'Electric Scissor Lift, 32'' Narrow%',
                                              'Electric Scissor Lift, 32'' Wide%',
                                              'Electric Scissor Lift, 40'' Narrow%',
                                              'Electric Scissor Lift, 40'' Wide%',
                                              'Industrial Forklift 5,000 lbs, Dual Fuel',
                                              'Industrial Forklift 6,000 lbs, Dual Fuel',
                                              'Rough Terrain Forklift 8,000 lbs, Diesel%',
                                              '%Skip Loader 60-85%'
                                              )
              THEN ${internal_cost} * 1.30

              WHEN ${category}          ILIKE ANY(
                                              'Atrium Lifts',
                                              '%Industrial Forklift%',
                                              'Mini Excavators'
                                              )
                OR ${equipment_class}   ILIKE ANY(
                                              '%Backhoe Loader 110 - 115 Hp, Standard Stick%',
                                              '%Backhoe Loader 110 - 115 Hp, Extendable Stick%',
                                              '%Backhoe Loader 145 - 150 Hp, Extendable Stick%',
                                              'Telescopic Boom Lift, 60'' IC',
                                              'Telescopic Boom Lift, 85'' - 86'' IC',
                                              'Telescopic Boom Lift, 120'' - 125'' IC%',
                                              'High Reach Telehandler 8,500 lbs, 66'' Reach',
                                              'Telehandler 30,000 - 39,000 lbs, 32'' - 44'' Reach',
                                              'Rough Terrain Scissor Lift, 36'' - 45%',
                                              'Rough Terrain Scissor Lift, 36'' - 45'' Wide Deck',
                                              'Rough Terrain Scissor Lift, 36'' - 45'', Electric',
                                              'Rough Terrain Scissor Lift, 50'' - 55'' Wide Deck',
                                              'Articulating Boom Lift, 30'' - 35'' IC',
                                              'Articulating Boom Lift, 60'' - 65'' IC',
                                              'Articulating Boom Lift, 80'' - 85'' IC',
                                              'Articulating Boom Lift, 150'' IC%',
                                              'Hybrid Articulating Boom Lift, 60'' - 65%',
                                              'Electric Articulating Boom Lift, 30'' - 34''',
                                              'Electric Articulating Boom Lift, 60'' - 65''',
                                              '%4-Wheel Sweeper%',
                                              '%4 Wheel Sweeper%',
                                              '%Electric Scissor Lift, 13'' - 14''%',
                                              'Stacker Pallet Electric',
                                              'Wheel Loader 70 - 105 hp, 1.5 cu. yd',
                                              'Wheel Loader 165 - 175 hp, 3 cu. yd',
                                              'Wheel Loader 190 - 195hp, 3 cu. yd',
                                              'Wheel Loader 190 - 200 hp, 4 cu. yd',
                                              'Wheel Loader 230 - 255 hp, 4 cu. yd'
                                              )
              THEN ${internal_cost} * 1.25

              WHEN ${equipment_class} ILIKE ANY (
                                              'Articulating Boom Lift, 125'' IC%'
                                              )
              THEN ${internal_cost} * 1.23

              WHEN ${equipment_class} ILIKE ANY (
                                              'Ride-On Single Drum Roller, 5 - 6%',
                                              'Ride-On Single Drum Roller, 7 - 8%',
                                              'Ride-On Single Drum Roller, 10 - 12%',
                                              'Ride-On Single Drum Roller, 13 - 15%',
                                              '%Rough Terrain Forklift 6,000 lbs, Diesel%',
                                              'Rough Terrain Forklift, 11,000 lbs, Diesel%',
                                              '%Backhoe Loader 68 - 74 Hp, Standard Stick%',
                                              '%Backhoe Loader 68 - 74 Hp, Extendable Stick%',
                                              '%Backhoe Loader 90 - 99 Hp, Standard Stick%',
                                              '%Backhoe Loader 145 - 150 Hp, Standard Stick%'
                                              )
              THEN ${internal_cost} * 1.22


              WHEN ${equipment_class}   ILIKE ANY(
                                              '%Track Excavators%'
                                              )
              THEN ${internal_cost} * 1.20

              WHEN ${equipment_class} ILIKE ANY (
                                              'Walk-Behind Trench Roller, 24-34", Pad'
                                              )
              THEN ${internal_cost} * 1.18

              WHEN ${category}          ILIKE ANY(
                                              'Utility Vehicles'
                                              )
              THEN ${internal_cost} * 1.17

              WHEN ${category}          ILIKE ANY(
                                              '%Towable Light Plants%'
                                              )
              THEN ${internal_cost} * 1.15

              WHEN ${category} ilike '%forklift%'     and ${category} not ilike '%attachment%' then ${internal_cost} * 1.30

              WHEN ${make} ILIKE 'magni%' THEN ${internal_cost} * 1.33

                --ESQR Changes for additional units for sale - Cowherd 2022-04-21
              WHEN ${year} <= 2015 AND ${category} ILIKE '%Electric Scissor Lifts%'      THEN (${internal_cost} * 1.30)
              WHEN ${year} <= 2015 AND ${category} ILIKE '%Rough Terrain Scissor Lifts%' THEN (${internal_cost} * 1.35)
              WHEN ${year} <= 2015 AND ${category} ILIKE '%Telehandlers%'                THEN (${internal_cost} * 1.30)
              WHEN ${year} <= 2015 AND ${category} ILIKE '%Articulating Boom Lifts%'     THEN (${internal_cost} * 1.32)
              WHEN ${year} <= 2015 AND ${category} ILIKE '%Electric Boom Lifts%'         THEN (${internal_cost} * 1.32)
              WHEN ${year} <= 2015 AND ${category} ILIKE '%Telescopic Boom Lifts%'       THEN (${internal_cost} * 1.32)
              WHEN ${year} <= 2019 and ${equipment_class} ILIKE '%Ride-On Double Drum Roller, 1.5 ton, 36%' THEN ${internal_cost} * 1.5
                              --Per Mason Hunter 2023-09-11
              WHEN ${year} <= 2020 and ${equipment_class} ILIKE 'Ride-On Double Drum Roller, 3 ton%' THEN (${internal_cost} * 1.33)

              --For schedules on the Capital One ABL the amount owed never goes down so we always need to mark up from the NBV - Cowherd 2022-01-05
              WHEN ${schedule} ILIKE '%Capital One ABL%'            THEN (${internal_cost} * 1.25)
              ELSE (${internal_cost} * 1.22)
              END ;;
    value_format_name: decimal_0
  }

  dimension: internal_cost {
    type: number
    sql: CASE WHEN ${asset_ownership.ownership} = 'OWN'
                THEN ${nbv} * 1.05
              WHEN ${schedule} ILIKE ANY( '%Capital One ABL%',
                                          '%Paid in Cash%',
                                          'Sold and/or Removed from ABL',
                                          'Sold and Inv Paid Off'
                                        )
                THEN ${nbv}
              WHEN ${nbv} <  ${payoff_amount}           THEN ${payoff_amount}
              WHEN ${schedule} is null THEN ${nbv}
              ELSE ${nbv} END
    ;;
  }

  measure: margin_percent {
    type: number
    sql: (${asset_replacement_value_sales_reps} - ${internal_cost}) / NULLIF(${asset_replacement_value_sales_reps},0) ;;
    value_format_name: decimal_2
  }

  measure: count {
    type: count
    drill_fields: [market_name, company_name]
  }
}
