include: "/views/ANALYTICS/v_line_items.view"
view: fuel_revenue {
  extends: [v_line_items]

dimension: incorrect_onsite_fueling_reasons {
  type: string
  sql:
      case
      when
      ${fuel_revenue.line_item_type_id} in (98,99,100,101 ,102 ,103,104,105,139)
      AND (
        ${fuel_revenue.description} ilike 'onsite' OR
        ${fuel_revenue.description} ilike 'on-site')
      THEN 'Onsite Fueling Charged to Other Fuel Line Items'

      when
      ${fuel_revenue.line_item_type_id} in (129,130,131,132,138)
      AND ${fuel_revenue.description} not ilike 'tax'
      AND ${fuel_revenue.number_of_units} = 1
      AND ${fuel_revenue.amount} > 360
      THEN 'Onsite Fueling with Incorrect Rate Input'

      when
      ${fuel_revenue.line_item_type_id} in (129,130,131,132,138)
      AND ${fuel_revenue.number_of_units} = 1
      AND ${fuel_revenue.amount} <= 360
      AND ${fuel_revenue.amount} > 50
      THEN 'Onsite Fueling Delivery Fees Charged to Incorrect Line Item'

      when
      ${fuel_revenue.line_item_type_id} in (129,130,131,132,138,98,99,100,101,102,103,104,105,142)
      AND ${incorrect_onsite_fueling_reporting.invoice_id} IS NOT NULL
      THEN 'Invoices with Onsite Fuel Delivery Fees and Onsite Fueling Charged to Other Fuel Line Items'

      ELSE NULL
      END
      ;;
}


  parameter: region_granularity {
    type: string
    default_value: "Region"
    allowed_value: {
      label: "Region"
      value: "Region"
    }
    allowed_value: {
      label: "District"
      value: "District"
    }
    allowed_value: {
      label: "Market"
      value: "Market"
    }
  }

  dimension: region_granularity_selection {
    type: string
    sql:
    CASE
      WHEN {% parameter region_granularity %} = 'Region' THEN ${market_region_xwalk.region_name}
      WHEN {% parameter region_granularity %} = 'District' THEN ${market_region_xwalk.district}
      WHEN {% parameter region_granularity %} = 'Market' THEN ${market_region_xwalk.market_name}
    END ;;
  }

}
