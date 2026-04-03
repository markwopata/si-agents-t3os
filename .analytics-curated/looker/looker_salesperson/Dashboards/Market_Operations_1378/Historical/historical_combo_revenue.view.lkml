
view: historical_combo_revenue {
 sql_table_name: analytics.bi_ops.historical_revenue_by_type ;;

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension_group: billing_approved_date {
    type: time
    sql: ${TABLE}."BILLING_APPROVED_DATE" ;;
  }

  dimension: rental_region {
    group_label: "Order/Rental Details"
    type: string
    sql: ${TABLE}."RENTAL_REGION" ;;
  }

  dimension: rental_district {
    group_label: "Order/Rental Details"
    type: string
    sql: ${TABLE}."RENTAL_DISTRICT" ;;
  }

  dimension: mtd {
    group_label: "Time Flag"
    type: yesno
    sql: CASE WHEN date_trunc(month,TO_DATE(${billing_approved_date_date})) = date_trunc(month, current_date()) THEN TRUE ELSE FALSE END ;;
  }

  dimension: past_mtd {
    group_label: "Time Flag"
    type: yesno
    sql: CASE WHEN TO_DATE(${billing_approved_date_date}) >= DATEADD(month, '-1',DATE_FROM_PARTS(year(CONVERT_TIMEZONE('UTC', 'America/Chicago', CURRENT_TIMESTAMP())::DATE),month(CONVERT_TIMEZONE('UTC', 'America/Chicago', CURRENT_TIMESTAMP())::DATE),1)) and TO_DATE(${billing_approved_date_date}) <= DATEADD(month, '-1',CONVERT_TIMEZONE('UTC', 'America/Chicago', CURRENT_TIMESTAMP())::DATE) THEN TRUE ELSE FALSE END ;;
  }

  dimension: rental_market_id {
    group_label: "Order/Rental Details"
    type: number
    sql: ${TABLE}."RENTAL_MARKET_ID" ;;
  }

  dimension: rental_market {
    group_label: "Order/Rental Details"
    type: string
    sql: ${TABLE}."RENTAL_MARKET" ;;
  }

  dimension: rental_company_id {
    group_label: "Order/Rental Details"
    type: number
    sql: ${TABLE}."RENTAL_COMPANY_ID" ;;
  }

  dimension: rental_company {
    group_label: "Order/Rental Details"
    type: string
    sql: ${TABLE}."RENTAL_COMPANY" ;;
  }

  dimension: secondary_rep_count {
    group_label: "Order/Rental Details"
    type: number
    sql: ${TABLE}."SECONDARY_REP_COUNT" ;;
  }

  dimension: salesperson_type_id {
    group_label: "Sales Person Info"
    type: number
    sql: ${TABLE}."SALESPERSON_TYPE_ID" ;;
  }

  dimension: total_associated_ancillary_prim {
    group_label: "Revenue Info"
    type: number
    sql: COALESCE(${TABLE}."ASSOCIATED_ANCILLARY_PRIMARY",0) ------------------------------------------------------------------------------------------------------------------------
    ;;
  }

  measure: associated_ancillary_prim {
    group_label: "Revenue Info"
    label: "Associated Ancillary (Primary)"
    type:  sum
    sql:  ${total_associated_ancillary_prim} ;;
    value_format_name: usd_0
  }


  measure: current_month_as_ancillary_prim{
    group_label: "Revenue Info"
    label: "MTD Associated Ancillary (Primary)"
    type: sum
    sql: CASE WHEN ${mtd} THEN ${total_associated_ancillary_prim} ELSE NULL END ;;
    value_format_name: usd_0
    drill_fields: [ancillary_revenue_company_drill*]
  }

  measure: past_mtd_as_ancillary_prim{
    group_label: "Revenue Info"
    label: "Last MTD Associated Ancillary (Primary)"
    type: sum
    sql: CASE WHEN ${past_mtd} THEN ${total_associated_ancillary_prim} ELSE NULL END ;;
    value_format_name: usd_0
  }


  measure: mtd_change_as_ancillary_arrows_prim {
    group_label: "Fixed Timeframes Change"
    type: number
    sql: ${current_month_as_ancillary_prim} - ${past_mtd_as_ancillary_prim};;
    value_format_name: usd_0
    html:
      {% if value > 0 %}
        <font color="#00CB86">
        <strong>&#9650;&nbsp;{{rendered_value}}</strong></font> <!-- Up Triangle with space -->
    {% elsif value == 0 %}
        <font color="#808080">
        <strong>{{rendered_value}}</strong></font>
    {% elsif value < 0 %}
        <font color="#DA344D">
        <strong>&#9660;&nbsp;{{rendered_value}}</strong></font> <!-- Down Triangle with space -->
    {% else %}
        <font color="#808080">
        <strong>{{rendered_value}}</strong></font>
    {% endif %}
       ;;
  }

  dimension: total_commission_ancillary_prim {
    group_label: "Revenue Info"
    type: number
    sql: COALESCE(${TABLE}."COMMISSION_ANCILLARY_PRIMARY",0) ;;
  }

  measure: commission_ancillary_prim {
    group_label: "Revenue Info"
    label: "Commission Ancillary (Primary)"
    type:  sum
    sql:  ${total_commission_ancillary_prim} ;;
    value_format_name: usd_0
  }

  measure: current_month_com_ancillary_prim{
    group_label: "Revenue Info"
    label: "MTD Commission Ancillary (Primary)"
    type: sum
    sql: CASE WHEN ${mtd} THEN ${total_commission_ancillary_prim} ELSE NULL END ;;
    value_format_name: usd_0
    drill_fields: [ancillary_revenue_company_drill*]
  }


  measure: past_mtd_com_ancillary_prim{
    group_label: "Revenue Info"
    label: "Last MTD Commission Ancillary (Primary)"
    type: sum
    sql: CASE WHEN ${past_mtd} THEN ${total_commission_ancillary_prim} ELSE NULL END ;;
    value_format_name: usd_0
  }

  measure: mtd_change_com_ancillary_arrows_prim {
    group_label: "Fixed Timeframes Change"
    type: number
    sql: ${current_month_com_ancillary_prim} - ${past_mtd_com_ancillary_prim} ;;
    value_format_name: usd_0
    html:
      {% if value > 0 %}
        <font color="#00CB86">
        <strong>&#9650;&nbsp;{{rendered_value}}</strong></font> <!-- Up Triangle with space -->
    {% elsif value == 0 %}
        <font color="#808080">
        <strong>{{rendered_value}}</strong></font>
    {% elsif value < 0 %}
        <font color="#DA344D">
        <strong>&#9660;&nbsp;{{rendered_value}}</strong></font> <!-- Down Triangle with space -->
    {% else %}
        <font color="#808080">
        <strong>{{rendered_value}}</strong></font>
    {% endif %}
       ;;
  }


  dimension: total_associated_ancillary_sec {
    group_label: "Revenue Info"
    type: number
    sql: COALESCE(${TABLE}."ASSOCIATED_ANCILLARY_SECONDARY",0) ;;
  }

  measure: associated_ancillary_sec {
    group_label: "Revenue Info"
    label: "Associated Ancillary (Secondary)"
    type:  sum
    sql:  ${total_associated_ancillary_sec} ;;
    value_format_name: usd_0
  }


  measure: current_month_as_ancillary_sec{
    group_label: "Revenue Info"
    label: "MTD Associated Ancillary (Secondary)"
    type: sum
    sql: CASE WHEN ${mtd} THEN ${total_associated_ancillary_sec} ELSE NULL END ;;
    value_format_name: usd_0
    drill_fields: [ancillary_revenue_company_drill*]
  }

  measure: past_mtd_as_ancillary_sec{
    group_label: "Revenue Info"
    label: "Last MTD Associated Ancillary (Secondary)"
    type: sum
    sql: CASE WHEN ${past_mtd} THEN ${total_associated_ancillary_sec} ELSE NULL END ;;
    value_format_name: usd_0
  }

  dimension: total_commission_ancillary_sec {
    group_label: "Revenue Info"
    type: number
    sql: COALESCE(${TABLE}."COMMISSION_ANCILLARY_SECONDARY",0) ;;
  }

  measure: commission_ancillary_sec {
    group_label: "Revenue Info"
    label: "Commission Ancillary (Secondary)"
    type:  sum
    sql:  ${total_commission_ancillary_sec} ;;
    value_format_name: usd_0
  }


  measure: current_month_com_ancillary_sec{
    group_label: "Revenue Info"
    label: "MTD Commission Ancillary (Secondary)"
    type: sum
    sql: CASE WHEN ${mtd} THEN ${total_commission_ancillary_sec} ELSE NULL END ;;
    value_format_name: usd_0
    drill_fields: [ancillary_revenue_company_drill*]
  }

  measure: past_mtd_com_ancillary_sec{
    group_label: "Revenue Info"
    label: "Last MTD Commission Ancillary (Secondary)"
    type: sum
    sql: CASE WHEN ${past_mtd} THEN ${total_commission_ancillary_sec} ELSE NULL END ;;
    value_format_name: usd_0
  }


  measure: mtd_change_com_ancillary_arrows_sec {
    group_label: "Fixed Timeframes Change"
    type: number
    sql: ${current_month_com_ancillary_sec} - ${past_mtd_com_ancillary_sec};;
    value_format_name: usd_0
    html:
      {% if value > 0 %}
        <font color="#00CB86">
        <strong>&#9650;&nbsp;{{rendered_value}}</strong></font> <!-- Up Triangle with space -->
    {% elsif value == 0 %}
        <font color="#808080">
        <strong>{{rendered_value}}</strong></font>
    {% elsif value < 0 %}
        <font color="#DA344D">
        <strong>&#9660;&nbsp;{{rendered_value}}</strong></font> <!-- Down Triangle with space -->
    {% else %}
        <font color="#808080">
        <strong>{{rendered_value}}</strong></font>
    {% endif %}
       ;;
  }






  dimension: total_associated_onsite_fuel_prim {
    group_label: "Revenue Info"
    type: number
    sql: COALESCE(${TABLE}."ASSOCIATED_ONSITE_FUEL_PRIMARY",0) ;;
  }

  measure: associated_onsite_fuel_prim {
    group_label: "Revenue Info"
    label: "Associated Onsite Fuel (Primary)"
    type:  sum
    sql:  ${total_associated_onsite_fuel_prim} ;;
    value_format_name: usd_0
  }

  measure: current_month_as_onsite_fuel_prim{
    group_label: "Revenue Info"
    label: "MTD Associated Onsite Fuel (Primary)"
    type: sum
    sql: CASE WHEN ${mtd} THEN ${total_associated_onsite_fuel_prim} ELSE NULL END ;;
    value_format_name: usd_0
    drill_fields: [ancillary_revenue_company_drill*]
  }

  measure: past_mtd_as_onsite_fuel_prim{
    group_label: "Revenue Info"
    label: "Last MTD Associated Onsite Fuel (Primary)"
    type: sum
    sql: CASE WHEN ${past_mtd} THEN ${total_associated_onsite_fuel_prim} ELSE NULL END ;;
    value_format_name: usd_0
  }

  measure: mtd_change_as_onsite_fuel_arrows_prim {
    group_label: "Fixed Timeframes Change"
    type: number
    sql: ${current_month_as_onsite_fuel_prim} - ${past_mtd_as_onsite_fuel_prim};;
    value_format_name: usd_0
    html:
      {% if value > 0 %}
        <font color="#00CB86">
        <strong>&#9650;&nbsp;{{rendered_value}}</strong></font> <!-- Up Triangle with space -->
    {% elsif value == 0 %}
        <font color="#808080">
        <strong>{{rendered_value}}</strong></font>
    {% elsif value < 0 %}
        <font color="#DA344D">
        <strong>&#9660;&nbsp;{{rendered_value}}</strong></font> <!-- Down Triangle with space -->
    {% else %}
        <font color="#808080">
        <strong>{{rendered_value}}</strong></font>
    {% endif %}
       ;;
  }

  dimension: total_commission_onsite_fuel_prim {
    group_label: "Revenue Info"
    type: number
    sql: COALESCE(${TABLE}."COMMISSION_ONSITE_FUEL_PRIMARY",0) ;;
  }

  measure: commission_onsite_fuel_prim {
    group_label: "Revenue Info"
    label: "Commission Onsite Fuel (Primary)"
    type:  sum
    sql:  ${total_commission_onsite_fuel_prim} ;;
    value_format_name: usd_0
  }

  measure: current_month_com_onsite_fuel_prim{
    group_label: "Revenue Info"
    label: "MTD Commission Onsite Fuel (Primary)"
    type: sum
    sql: CASE WHEN ${mtd} THEN ${total_commission_onsite_fuel_prim} ELSE NULL END ;;
    value_format_name: usd_0
    drill_fields: [ancillary_revenue_company_drill*]
  }


  measure: past_mtd_com_onsite_fuel_prim{
    group_label: "Revenue Info"
    label: "Last MTD Commission Onsite Fuel (Primary)"
    type: sum
    sql: CASE WHEN ${past_mtd} THEN ${total_commission_onsite_fuel_prim} ELSE NULL END ;;
    value_format_name: usd_0
  }

  measure: mtd_change_com_onsite_fuel_arrows_prim {
    group_label: "Fixed Timeframes Change"
    type: number
    sql: ${current_month_com_onsite_fuel_prim} - ${past_mtd_com_onsite_fuel_prim};;
    value_format_name: usd_0
    html:
      {% if value > 0 %}
        <font color="#00CB86">
        <strong>&#9650;&nbsp;{{rendered_value}}</strong></font> <!-- Up Triangle with space -->
    {% elsif value == 0 %}
        <font color="#808080">
        <strong>{{rendered_value}}</strong></font>
    {% elsif value < 0 %}
        <font color="#DA344D">
        <strong>&#9660;&nbsp;{{rendered_value}}</strong></font> <!-- Down Triangle with space -->
    {% else %}
        <font color="#808080">
        <strong>{{rendered_value}}</strong></font>
    {% endif %}
       ;;
  }

  dimension: total_associated_onsite_fuel_sec {
    group_label: "Revenue Info"
    type: number
    sql: COALESCE(${TABLE}."ASSOCIATED_ONSITE_FUEL_SECONDARY",0) ;;
  }

  measure: associated_onsite_fuel_sec {
    group_label: "Revenue Info"
    label: "Associated Onsite Fuel (Secondary)"
    type:  sum
    sql:  ${total_associated_onsite_fuel_sec} ;;
    value_format_name: usd_0
  }


  measure: current_month_as_onsite_fuel_sec{
    group_label: "Revenue Info"
    label: "MTD Associated Onsite Fuel (Secondary)"
    type: sum
    sql: CASE WHEN ${mtd} THEN ${total_associated_onsite_fuel_sec} ELSE NULL END ;;
    value_format_name: usd_0
    drill_fields: [ancillary_revenue_company_drill*]
  }

  measure: past_mtd_as_onsite_fuel_sec{
    group_label: "Revenue Info"
    label: "Last MTD Associated Onsite Fuel (Secondary)"
    type: sum
    sql: CASE WHEN ${past_mtd} THEN ${total_associated_onsite_fuel_sec} ELSE NULL END ;;
    value_format_name: usd_0
  }

  dimension: total_commission_onsite_fuel_sec {
    group_label: "Revenue Info"
    type: number
    sql: COALESCE(${TABLE}."COMMISSION_ONSITE_FUEL_SECONDARY",0) ;;
  }

  measure: commission_onsite_fuel_sec {
    group_label: "Revenue Info"
    label: "Commission Onsite Fuel (Secondary)"
    type:  sum
    sql:  ${total_commission_onsite_fuel_sec} ;;
    value_format_name: usd_0
  }


  measure: current_month_com_onsite_fuel_sec{
    group_label: "Revenue Info"
    label: "MTD Commission Onsite Fuel (Secondary)"
    type: sum
    sql: CASE WHEN ${mtd} THEN ${total_commission_onsite_fuel_sec} ELSE NULL END ;;
    value_format_name: usd_0
    drill_fields: [ancillary_revenue_company_drill*]
  }

  measure: past_mtd_com_onsite_fuel_sec{
    group_label: "Revenue Info"
    label: "Last MTD Commission Onsite Fuel (Secondary)"
    type: sum
    sql: CASE WHEN ${past_mtd} THEN ${total_commission_onsite_fuel_sec} ELSE NULL END ;;
    value_format_name: usd_0
  }


  measure: mtd_change_com_onsite_fuel_arrows_sec {
    group_label: "Fixed Timeframes Change"
    type: number
    sql: ${current_month_com_onsite_fuel_sec} - ${past_mtd_com_onsite_fuel_sec};;
    value_format_name: usd_0
    html:
      {% if value > 0 %}
        <font color="#00CB86">
        <strong>&#9650;&nbsp;{{rendered_value}}</strong></font> <!-- Up Triangle with space -->
    {% elsif value == 0 %}
        <font color="#808080">
        <strong>{{rendered_value}}</strong></font>
    {% elsif value < 0 %}
        <font color="#DA344D">
        <strong>&#9660;&nbsp;{{rendered_value}}</strong></font> <!-- Down Triangle with space -->
    {% else %}
        <font color="#808080">
        <strong>{{rendered_value}}</strong></font>
    {% endif %}
       ;;
  }





















  dimension: total_associated_rental_prim {
    group_label: "Revenue Info"
    type: number
    sql: COALESCE(${TABLE}."ASSOCIATED_RENTAL_PRIMARY",0) ;;
  }

  measure: associated_rental_prim {
    group_label: "Revenue Info"
    label: "Associated Rental (Primary)"
    description: "Total rental revenue from orders where salesperson is listed as the primary salesperson."
    type:  sum
    sql:  ${total_associated_rental_prim} ;;
    value_format_name: usd_0
  }

  measure: current_month_as_rental_prim{
    group_label: "Revenue Info"
    label: "MTD Associated Rental (Primary)"
    type: sum
    sql: CASE WHEN ${mtd} THEN ${total_associated_rental_prim} ELSE NULL END ;;
    value_format_name: usd_0
    drill_fields: [rental_revenue_company_drill*]
  }

  measure: past_mtd_as_rental_prim{
    label: "Last MTD Associated Rental (Primary)"
    group_label: "Revenue Info"
    type: sum
    sql: CASE WHEN ${past_mtd} THEN ${total_associated_rental_prim} ELSE NULL END ;;
    value_format_name: usd_0
  }

  measure: mtd_change_as_rental_arrows_prim {
    group_label: "Fixed Timeframes Change"
    type: number
    sql: ${current_month_as_rental_prim} - ${past_mtd_as_rental_prim};;
    value_format_name: usd_0
    html:
      {% if value > 0 %}
        <font color="#00CB86">
        <strong>&#9650;&nbsp;{{rendered_value}}</strong></font> <!-- Up Triangle with space -->
    {% elsif value == 0 %}
        <font color="#808080">
        <strong>{{rendered_value}}</strong></font>
    {% elsif value < 0 %}
        <font color="#DA344D">
        <strong>&#9660;&nbsp;{{rendered_value}}</strong></font> <!-- Down Triangle with space -->
    {% else %}
        <font color="#808080">
        <strong>{{rendered_value}}</strong></font>
    {% endif %}
       ;;
  }







  measure: in_market_as_rental_prim {
    group_label: "Revenue Info"
    label: "In Market Associated Rental (Primary)"
    type:  sum
    sql:  CASE WHEN ${in_or_out} = 'In Market' THEN ${total_associated_rental_prim} ELSE NULL END ;;
    value_format: "[>=1000000]$0.00,,\"M\";[>=1000]$0.00,\"K\";$0"
  }

  measure: mtd_in_market_as_rental_prim {
    group_label: "Revenue Info"
    label: "MTD In Market Rental Revenue"
    type:  sum
    sql:  CASE WHEN ${in_or_out} = 'In Market' AND ${mtd} THEN ${total_associated_rental_prim} ELSE NULL END ;;
    value_format_name: usd_0
  }

  measure: in_market_prct {
    group_label: "Revenue Info"
    label: "In Market Prct for Associated Rental (Primary)"
    type: number
    sql: div0null(${in_market_as_rental_prim}, ${associated_rental_prim})  ;;
    value_format_name: percent_1
  }

  measure: out_market_as_rental_prim {
    group_label: "Revenue Info"
    label: "Out of Market Associated Rental (Primary)"
    type:  sum
    sql:  CASE WHEN ${in_or_out} = 'Out of Market' THEN ${total_associated_rental_prim} ELSE NULL END ;;
    value_format_name: usd_0
  }

  measure: mtd_out_market_rental_rev {
    group_label: "Revenue Info"
    label: "MTD Out of Market Rental Revenue"
    type:  sum
    sql:  CASE WHEN ${in_or_out} = 'Out of Market' AND ${mtd} THEN ${total_associated_rental_prim} ELSE NULL END ;;
    value_format_name: usd_0
  }












  dimension: total_commission_rental_prim {
    group_label: "Revenue Info"
    type: number
    sql: COALESCE(${TABLE}."COMMISSION_RENTAL_PRIMARY",0) ;;
  }

  measure: commission_rental_prim {
    group_label: "Revenue Info"
    label: "Commission Rental (Primary)"
    type:  sum
    sql:  ${total_commission_rental_prim} ;;
    value_format_name: usd_0
  }

  measure: current_month_com_rental_prim{
    group_label: "Revenue Info"
    label: "MTD Commission Rental (Primary)"
    type: sum
    sql: CASE WHEN ${mtd} THEN ${total_commission_rental_prim} ELSE NULL END ;;
    value_format_name: usd_0
    drill_fields: [ancillary_revenue_company_drill*]
  }


  measure: past_mtd_com_rental_prim{
    group_label: "Revenue Info"
    label: "Last MTD Commission Rental (Primary)"
    type: sum
    sql: CASE WHEN ${past_mtd} THEN ${total_commission_rental_prim} ELSE NULL END ;;
    value_format_name: usd_0
  }

  measure: mtd_change_com_rental_arrows_prim {
    group_label: "Fixed Timeframes Change"
    type: number
    sql: ${current_month_com_rental_prim} - ${past_mtd_com_rental_prim};;
    value_format_name: usd_0
    html:
      {% if value > 0 %}
        <font color="#00CB86">
        <strong>&#9650;&nbsp;{{rendered_value}}</strong></font> <!-- Up Triangle with space -->
    {% elsif value == 0 %}
        <font color="#808080">
        <strong>{{rendered_value}}</strong></font>
    {% elsif value < 0 %}
        <font color="#DA344D">
        <strong>&#9660;&nbsp;{{rendered_value}}</strong></font> <!-- Down Triangle with space -->
    {% else %}
        <font color="#808080">
        <strong>{{rendered_value}}</strong></font>
    {% endif %}
       ;;
  }

  dimension: total_associated_rental_sec {
    group_label: "Revenue Info"
    type: number
    sql: COALESCE(${TABLE}."ASSOCIATED_RENTAL_SECONDARY",0) ;;
  }

  measure: associated_rental_sec {
    group_label: "Revenue Info"
    label: "Associated Rental (Secondary)"
    type:  sum
    sql:  ${total_associated_rental_sec} ;;
    value_format_name: usd_0
  }


  measure: current_month_as_rental_sec{
    group_label: "Revenue Info"
    label: "MTD Associated Rental (Secondary)"
    type: sum
    sql: CASE WHEN ${mtd} THEN ${total_associated_rental_sec} ELSE NULL END ;;
    value_format_name: usd_0
    drill_fields: [ancillary_revenue_company_drill*]
  }

  measure: past_mtd_as_rental_sec{
    group_label: "Revenue Info"
    label: "Last MTD Associated Rental (Secondary)"
    type: sum
    sql: CASE WHEN ${past_mtd} THEN ${total_associated_rental_sec} ELSE NULL END ;;
    value_format_name: usd_0
  }

  dimension: total_commission_rental_sec {
    group_label: "Revenue Info"
    type: number
    sql: COALESCE(${TABLE}."COMMISSION_RENTAL_SECONDARY",0) ;;
  }

  measure: commission_rental_sec {
    group_label: "Revenue Info"
    label: "Commission Rental (Secondary)"
    type:  sum
    sql:  ${total_commission_rental_sec} ;;
    value_format_name: usd_0
  }


  measure: current_month_com_rental_sec{
    group_label: "Revenue Info"
    label: "MTD Commission Rental (Secondary)"
    type: sum
    sql: CASE WHEN ${mtd} THEN ${total_commission_rental_sec} ELSE NULL END ;;
    value_format_name: usd_0
    drill_fields: [ancillary_revenue_company_drill*]
  }

  measure: past_mtd_com_rental_sec{
    group_label: "Revenue Info"
    label: "Last MTD Commission Rental (Secondary)"
    type: sum
    sql: CASE WHEN ${past_mtd} THEN ${total_commission_rental_sec} ELSE NULL END ;;
    value_format_name: usd_0
  }


  measure: mtd_change_com_rental_arrows_sec {
    group_label: "Fixed Timeframes Change"
    type: number
    sql: ${current_month_com_rental_sec} - ${past_mtd_com_rental_sec};;
    value_format_name: usd_0
    html:
      {% if value > 0 %}
        <font color="#00CB86">
        <strong>&#9650;&nbsp;{{rendered_value}}</strong></font> <!-- Up Triangle with space -->
    {% elsif value == 0 %}
        <font color="#808080">
        <strong>{{rendered_value}}</strong></font>
    {% elsif value < 0 %}
        <font color="#DA344D">
        <strong>&#9660;&nbsp;{{rendered_value}}</strong></font> <!-- Down Triangle with space -->
    {% else %}
        <font color="#808080">
        <strong>{{rendered_value}}</strong></font>
    {% endif %}
       ;;
  }





  dimension: sp_user_id {
    group_label: "Sales Person Info"
    type: string
    sql: ${TABLE}."SP_USER_ID" ;;
  }

  dimension: sp_email {
    group_label: "Sales Person Info"
    type: string
    sql: ${TABLE}."SP_EMAIL" ;;
  }

  dimension: sp_name {
    group_label: "Sales Person Info"
    type: string
    sql: ${TABLE}."SP_NAME" ;;
  }

  dimension: sp_jurisdiction_dated {
    group_label: "Sales Person Info"
    type: string
    sql: ${TABLE}."SP_JURISDICTION_DATED" ;;
  }

  dimension: sp_region_dated {
    group_label: "Sales Person Info"
    type: string
    sql: ${TABLE}."SP_REGION_DATED" ;;
  }

  dimension: sp_district_dated {
    group_label: "Sales Person Info"
    type: string
    sql: ${TABLE}."SP_DISTRICT_DATED" ;;
  }

  dimension: sp_market_id_dated {
    group_label: "Sales Person Info"
    type: number
    sql: ${TABLE}."SP_MARKET_ID_DATED" ;;
  }

  dimension: sp_market_dated {
    group_label: "Sales Person Info"
    type: string
    sql: ${TABLE}."SP_MARKET_DATED" ;;
  }

  dimension: in_or_out {
    group_label: "Revenue Info"
    type: string
    sql: ${TABLE}."IN_OR_OUT" ;;
  }

  dimension: sp_current_home_id {
    group_label: "Sales Person Current Info"
    type: number
    sql: ${TABLE}."SP_CURRENT_HOME_ID" ;;
  }

  dimension: sp_current_home {
    group_label: "Sales Person Current Info"
    type: string
    sql: ${TABLE}."SP_CURRENT_HOME" ;;
  }

  dimension: rep {
    group_label: "Sales Person Current Info"
    type:  string
    sql:  concat(${sp_name}, ' - ', ${sp_current_home}) ;;
  }

  dimension: direct_manager_user_id_present {
    group_label: "Sales Person Current Info"
    type: number
    sql: ${TABLE}."DIRECT_MANAGER_USER_ID_PRESENT" ;;
  }

  dimension: direct_manager_name_present {
    group_label: "Sales Person Current Info"
    type: string
    sql: ${TABLE}."DIRECT_MANAGER_NAME_PRESENT" ;;
  }

  dimension: current_status {
    group_label: "Sales Person Current Info"
    type: string
    sql: ${TABLE}."CURRENT_STATUS" ;;
  }

  dimension: first_date_as_tam {
    group_label: "Sales Person Info"
    type: date
    sql: ${TABLE}."FIRST_DATE_AS_TAM" ;;
  }

  dimension: new_sp_flag_current {
    group_label: "Sales Person Current Info"
    type: string
    sql: ${TABLE}."NEW_SP_FLAG_CURRENT" ;;
  }

  set: all_revenue_company_drill {
    fields: [
      billing_approved_date_month,
      rental_company,
      associated_rental_prim,
      associated_ancillary_prim,
      commission_ancillary_prim
    ]
  }
  set: rental_revenue_company_drill {
    fields: [
        billing_approved_date_month,
        rental_company,
        associated_rental_prim

    ]
  }

  set: secondary_revenue_company_drill {
    fields: [
        billing_approved_date_month,
        rental_company

    ]
  }

  set: ancillary_revenue_company_drill {
    fields: [
        billing_approved_date_month,
        rental_company,
        associated_ancillary_prim,
        commission_ancillary_prim
    ]
  }

  set: fuel_revenue_company_drill {
    fields: [
      billing_approved_date_month,
      rental_company
    ]
  }

  set: detail {
    fields: [
        billing_approved_date_month,
  rental_region,
  rental_district,
  rental_market_id,
  rental_market,
  rental_company_id,
  rental_company,
  secondary_rep_count,
  salesperson_type_id,


  sp_user_id,
  sp_email,
  sp_name,
  sp_jurisdiction_dated,
  sp_region_dated,
  sp_district_dated,
  sp_market_id_dated,
  sp_market_dated,
  in_or_out,
  sp_current_home_id,
  sp_current_home,
  direct_manager_user_id_present,
  direct_manager_name_present,
  current_status,
  first_date_as_tam,
  new_sp_flag_current
    ]
  }
}
