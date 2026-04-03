view: fleet_qbr_ideal_make_for_class {
  derived_table: {
    sql:
        Select
        asset.equipment_class_id,
        asset.equipment_class,
        asset.category,
        asset.is_ideal_make_flag,
        asset.invoice_date,
        asset.promised_this_year_flag,
        asset.calculated_oec
        from data_science_stage.fleet_testing.asset_purchases_for_qbr asset
        inner join data_science_stage.fleet_testing.ideal_make_of_class ideal
        on ideal.equipment_class_id = asset.equipment_class_id
          ;;
  }

  dimension: equipment_class_with_ideal {
    type:  number
    description: "class for which there exists an ideal make"
    primary_key: yes
    hidden: yes
    sql:${TABLE}."EQUIPMENT_CLASS_ID";;
  }

  dimension: equipment_class {
    type: string
    sql: ${TABLE}."EQUIPMENT_CLASS" ;;
  }

  dimension: ideal_make_flag {
    type: string
    sql: ${TABLE}."IS_IDEAL_MAKE_FLAG" ;;
  }

  dimension: invoice {
    type: date
    sql: ${TABLE}."INVOICE_DATE" ;;
  }

  dimension: promised_this_year {
    type: string
    sql: ${TABLE}."PROMISED_THIS_YEAR_FLAG" ;;
  }

  dimension: category {
    type: string
    sql: ${TABLE}."CATEGORY" ;;
  }

  measure: calculated_oec {
    type: sum
    description: "total cost + freight"
    value_format: "$#,##0"
    sql: ${TABLE}."CALCULATED_OEC" ;;
  }

}
