view: fleet_qbr_purchasing_goals {
    derived_table: {
      sql:
      Select
      equipment_class_id,
      equipment_class,
      category,
      sub_category,
      purchase_goal_oec,
      purchase_goal_overall_units,
      purchase_goal_units_per_month
      from data_science_stage.fleet_testing.purchasing_goals_by_category
        ;;
    }

    dimension: equipment_class_id {
      type:  string
      description: "one row per class/cat/subcat"
      primary_key: yes
      hidden: no
      sql:${TABLE}."EQUIPMENT_CLASS_ID";;
    }

  dimension: class {
    type: string
    description: "class associated with the asset purchased."
    sql: ${TABLE}."EQUIPMENT_CLASS" ;;
  }

    dimension: category {
      type: string
      description: "category associated with the asset purchased."
      sql: ${TABLE}."CATEGORY" ;;
    }

    dimension: subcategory {
      type: string
      description: "subcategory associated with the asset purchased."
      sql: ${TABLE}."SUB_CATEGORY" ;;
    }

    measure: oec_goal {
      type: sum
      description: "purchasing goal of calculated OEC for CY purchases"
      value_format: "$#,##0"
      sql: ${TABLE}."PURCHASE_GOAL_OEC" ;;
    }

    measure: overall_units_goal {
      type: sum
      description: "purchasing goal in units for CY purchases"
      value_format: "#,##0"
      sql: ${TABLE}."PURCHASE_GOAL_OVERALL_UNITS" ;;
    }

    measure: units_per_month_goal {
      type: sum
      description: "purchasing goal in units per month (assuming 5 remaining months) for CY purchases"
      value_format: "#,##0"
      sql: ${TABLE}."PURCHASE_GOAL_UNITS_PER_MONTH" ;;
    }
  }
