include: "/views/asset_purchase_history.view.lkml"
#
# The purpose of this view is to add a floor plan deadline dimension based on logic from Cowherd.
# Need is to notify reps of units with upcoming floor plan units that are nearing period.
#
# Britt Shanklin | Built 2023-01-18
view: asset_purchase_history_extended {
  extends: [asset_purchase_history]

  dimension: floor_plan_deadline {
    type: date
    sql: CASE
              WHEN ${assets.make} like '%TAKEUCHI%' THEN DATEADD(month, 9, ${invoice_purchase_date})
              WHEN ${assets.make} like '%LINK-BELT%' THEN DATEADD(month, 6, ${invoice_purchase_date})
              WHEN ${assets.make} like '%YANMAR%' THEN DATEADD(month, 6, ${invoice_purchase_date})
              WHEN ${assets.make} like '%SANY%' THEN DATEADD(month, 12, ${invoice_purchase_date})
              WHEN ${assets.make} like '%DOOSAN%' THEN DATEADD(month, 12, ${invoice_purchase_date})
              WHEN ${assets.make} like '%EPIROC%' THEN DATEADD(month, 6, ${invoice_purchase_date})
              WHEN ${assets.make} like '%PALADIN%' THEN DATEADD(day, 120, ${invoice_purchase_date})
              WHEN ${assets.make} like '%MECALAC%' THEN DATEADD(month, 6, ${invoice_purchase_date})
              WHEN ${assets.make} like '%CHICAGO PNEUMATIC%' THEN DATEADD(month, 6, ${invoice_purchase_date})
              ELSE null
          END ;;
  }

  dimension_group: days_until_deadline {
    type: duration
    intervals: [day]
    sql_start: CURRENT_DATE() ;;
    sql_end: ${floor_plan_deadline} ;;
  }

  dimension: deadline_bucket {
    type: string
    case: {
      when: {
        sql: ${days_days_until_deadline} <= 30;;
        label: "<= 30 Days"
      }
      when: {
        sql: ${days_days_until_deadline} > 30 AND  ${days_days_until_deadline} <= 60;;
        label: "30 to 60 Days"
      }
      when: {
        sql: ${days_days_until_deadline} > 60;;
        label: "> 60 Days"
      }
      else:"Unknown"
    }
  }

  measure: count {
    type: count
    drill_fields: [asset_id, assets.custom_name, assets.name, assets.description, assets.make, assets.model, assets.serial_number, market_region_xwalk.market_name, floor_plan_deadline]
  }

  # added filtered measures to remove need for pivot in barcharts - 2023.03.22 BES
  measure: count_under_30 {
    label: "<= 30 Days"
    type: count
    filters: [deadline_bucket: "<= 30 Days"]
    drill_fields: [asset_id, assets.custom_name, assets.name,
      assets.description, assets.make, assets.model, assets.serial_number,
      market_region_xwalk.market_name, floor_plan_deadline]
  }

  measure: count_30_to_60 {
    label: "30 to 60 Days"
    type: count
    filters: [deadline_bucket: "30 to 60 Days"]
    drill_fields: [asset_id, assets.custom_name, assets.name,
      assets.description, assets.make, assets.model, assets.serial_number,
      market_region_xwalk.market_name, floor_plan_deadline]
  }

  measure: count_greater_60 {
    label: "> 60 Days"
    type: count
    filters: [deadline_bucket: "> 60 Days"]
    drill_fields: [asset_id, assets.custom_name, assets.name,
      assets.description, assets.make, assets.model, assets.serial_number,
      market_region_xwalk.market_name, floor_plan_deadline]
  }

  }
