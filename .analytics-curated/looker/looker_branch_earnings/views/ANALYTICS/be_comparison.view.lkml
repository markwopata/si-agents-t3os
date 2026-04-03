view: be_comparison {
  sql_table_name: "ANALYTICS"."PUBLIC"."BE_COMPARISON"
    ;;

parameter: comparison_select {
  label: "Comparison Target"
  type: string
  # allowed_value: { value: "Salt Lake City, Utah"}
  # allowed_value: { value: "Denver, Colorado"}
}

measure: mkt_actual {
  label: "Your Actuals"
  type: sum
  value_format: "#,##0.00; (#,##0.00); -"
  sql: ${active_mkt_ttl} ;;
}

measure: mkt_revttl {
  type: sum
  value_format: "#,##0.00;(#,##0.00);-"
  sql: case when ${type} = 'Revenue' then coalesce(round(${active_mkt_ttl},2), 0) else 0 end ;;
}

measure: slc_revttl {
  type: sum
  value_format: "#,##0.00;(#,##0.00);-"
  sql: case when ${type} = 'Revenue' then coalesce(round(${slc_ttl},2), 0) else 0 end ;;
}

measure: den_revttl {
  type: sum
  value_format: "#,##0.00;(#,##0.00);-"
  sql: case when ${type} = 'Revenue' then coalesce(round(${denver_ttl},2), 0) else 0 end ;;
}

measure: tar_actual {
  label: "Comparison Actuals"
  type: sum
  value_format: "#,##0.00; (#,##0.00); -"
  sql: case when {% parameter comparison_select %} =  'Salt Lake City, Utah' then ${slc_ttl}
            when {% parameter comparison_select %} =  'Denver, Colorado' then ${denver_ttl}
            else 0
        end;;
}

  dimension: acctno {
    type: string
    sql: ${TABLE}."ACCTNO" ;;
  }

  dimension: active_mkt_ttl {
    type: number
    sql: ${TABLE}."ACTIVE_MKT_TTL" ;;
  }

  dimension: denver_ttl {
    type: number
    sql: ${TABLE}."DENVER_TTL" ;;
  }

  dimension: slc_ttl {
    type: number
    sql: ${TABLE}."SLC_TTL" ;;
  }

  dimension: dept {
    type: string
    label: "Department"
    suggestions: ["Rental", "Sales", "Delivery", "Service", "Miscellaneous"]
    order_by_field: dept_order
    sql: case when ${TABLE}."DEPT" = 'debt' then 'Bad Debt'
            when ${TABLE}."DEPT" = 'del' then 'Delivery'
            when ${TABLE}."DEPT" = 'emp' then 'Employee Benefits'
            when ${TABLE}."DEPT" = 'fac' then 'Facilities'
            when ${TABLE}."DEPT" = 'gen' then 'General Administrative'
            when ${TABLE}."DEPT" = 'interco' then 'Intercompany'
            when ${TABLE}."DEPT" = 'misc' then 'Miscellaneous'
            when ${TABLE}."DEPT" = 'over' then 'Overhead'
            when ${TABLE}."DEPT" = 'rent' then 'Rental'
            when ${TABLE}."DEPT" = 'sale' then 'Sales'
            when ${TABLE}."DEPT" = 'serv' then 'Service'
       end ;;
  }

  dimension: display {
    type: string
    label: "Date"
    sql: ${TABLE}."DISPLAY" ;;
  }

  dimension: gl_acct {
    type: string
    label: "GL Name"
    sql: ${TABLE}."GL_ACCT" ;;
  }

  dimension: gl_date {
    type: date
    datatype: date
    sql: ${TABLE}."GL_DATE" ;;
  }

  dimension: market_id {
    type: number
    label: "Market ID"
    sql: ${TABLE}."MARKET_ID" ;;
    suggest_explore: market_region_xwalk_suggestion
    suggest_dimension: market_region_xwalk_suggestion.market_id
    primary_key: yes
  }

  dimension: market_name {
    type: string
    label: "Market Name"
    sql: ${TABLE}."MARKET_NAME" ;;
    suggest_explore: market_region_xwalk_suggestion
    suggest_dimension: market_region_xwalk_suggestion.market_name
#    suggest_persist_for: "30 seconds"
  }

  dimension: type {
    type: string
    label: "Type"
    sql: ${TABLE}."TYPE" ;;
    order_by_field: bucket_order
  }


  dimension: bucket_order {
    type: number
    sql: case when ${type} = 'Rental Revenues'                    then 1
              when ${type} = 'Retail Revenues'                    then 2
              when ${type} = 'Sales Revenues'                     then 3
              when ${type} = 'Delivery Revenues'                  then 4
              when ${type} = 'Service Revenues'                   then 5
              when ${type} = 'Miscellaneous Revenues'             then 6
              when ${type} = 'Bad Debt'                           then 7
              when ${type} = 'Cost of Rental Revenues'            then 8
              when ${type} = 'Cost of Retail Revenues'            then 9
              when ${type} = 'Cost of Sales Revenues'             then 10
              when ${type} = 'Cost of Delivery Revenues'          then 11
              when ${type} = 'Cost of Service Revenues'           then 12
              when ${type} = 'Cost of Miscellaneous Revenues'     then 13
              when ${type} = 'Employee Benefits Expenses'         then 14
              when ${type} = 'Facilities Expenses'                then 15
              when ${type} = 'General Expenses'                   then 16
              when ${type} = 'Overhead Expenses'                  then 17
              when ${type} = 'Intercompany Transactions'          then 18
              end ;;
  }

  dimension: dept_order {
    type: number
    sql: case when ${dept} = 'Rental'                   then 1
              when ${dept} = 'Retail'                   then 2
              when ${dept} = 'Sales'                    then 3
              when ${dept} = 'Delivery'                 then 4
              when ${dept} = 'Service'                  then 5
              when ${dept} = 'Miscellaneous'            then 6
              when ${dept} = 'Bad Debt'                 then 7
              when ${dept} = 'Employee Benefits'        then 8
              when ${dept} = 'Facilities'               then 9
              when ${dept} = 'General Administrative'   then 10
              when ${dept} = 'Overhead'                 then 11
         end ;;
  }

}
