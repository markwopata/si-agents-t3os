view: be_main {
  derived_table: {
    sql: with intacct_plexi_cte as (
          select to_number(iff(JE.DEPARTMENT = '15967', '33163', JE.DEPARTMENT)) as market_id,
                 m.MARKET_NAME                                            as mkt_name,
                 datediff(month, RO.MARKET_START_MONTH,
                 date_from_parts({% parameter report_year %},{% parameter report_month %},1))
                                                                           as market_age,
                 M.REGION_NAME                                             as rgn_name,
                 B."GROUP"                                                 as bucket,
                 JE.ACCOUNTNO                                              as acctno,
                 date_part(month, to_date(JE.ENTRY_DATE))                  as mth,
                 date_part(year, to_date(JE.ENTRY_DATE))                   as yr,
                 round(sum(JE.TRX_AMOUNT::float * JE.TR_TYPE::float * -1),2)
                                                                           as amount
          from ANALYTICS.PUBLIC.GLENTRY                                       JE
                 join ANALYTICS.GS.PLEXI_BUCKET_MAPPING                       B
                           on JE.ACCOUNTNO = B.SAGE_GL
                 join ANALYTICS.GS.REVMODEL_MARKET_ROLLOUT_CONSERVATIVE       RO
                           on iff(JE.DEPARTMENT = '15967', '33163', JE.DEPARTMENT) = to_varchar(RO.MARKET_ID)
                 left join ANALYTICS.PUBLIC.MARKET_REGION_XWALK               M
                           on iff(JE.DEPARTMENT = '15967', '33163', JE.DEPARTMENT) = to_varchar(M.MARKET_ID)
          where JE.LOCATION = 'E1'            -- Only entries in entity E1 (EquipmentShare)
          and JE.STATE = 'Posted'             -- Only entries posted to the GL
          and bucket is not null                -- Ignore entries that don't belong in a Plexi group
          and JE.DEPARTMENT regexp '^[0-9]+$' -- Only allow numeric location codes
          {% if report_month._parameter_value == "''" %}
          and mth = {% parameter report_month %}
          {% endif %}
          {% if report_year._parameter_value == "''" %}
          and yr = {% parameter report_year %}
          {% endif %}
          and market_age > 0
          group by JE.DEPARTMENT, mkt_name, rgn_name, market_age, bucket, acctno, mth, yr
          order by rgn_name, market_id, mth desc, yr, bucket
      )

      -- Pivot to final output - bucketed P&L as row per market/month
      select  market_id,
      mkt_name,
      market_age,
      rgn_name,
      mth,
      yr,
      sum("'REVrent'")        rentrev,
      sum("'REVsale'")        salerev,
      sum("'REVdel'")         delrev,
      sum("'REVserv'")        servrev,
      sum("'REVmisc'")        miscrev,

      sum("'EXPdebt'")        debtexp,
      sum("'EXPrent'")        rentexp,
      sum("'EXPsale'")        saleexp,
      sum("'EXPdel'")         delexp,
      sum("'EXPserv'")        servexp,
      sum("'EXPmisc'")        miscexp,
      sum("'EXPemp'")         empexp,
      sum("'EXPfac'")         facexp,
      sum("'EXPgen'")         genexp,
      sum("'EXPover'")        overexp,

      sum("'interco'")        intercomp

      from intacct_plexi_cte

      pivot(sum(amount)
      for bucket in ('REVrent', 'REVsale', 'REVdel', 'REVserv', 'REVmisc', 'EXPdebt',
      'EXPrent', 'EXPsale', 'EXPdel', 'EXPserv', 'EXPmisc', 'EXPemp', 'EXPfac',
      'EXPgen', 'EXPover', 'interco'))
      group by market_id, mkt_name, rgn_name, market_age, mth, yr
      order by market_id, yr desc, mth
      ;;
  }

  parameter: report_month {
    label: "Month"
    type: number
    default_value: "9"
    allowed_value: {
      label: "January"
      value: "1"
    }
    allowed_value: {
      label: "February"
      value: "2"
    }
    allowed_value: {
      label: "March"
      value: "3"
    }
    allowed_value: {
      label: "April"
      value: "4"
    }
    allowed_value: {
      label: "May"
      value: "5"
    }
    allowed_value: {
      label: "June"
      value: "6"
    }
    allowed_value: {
      label: "July"
      value: "7"
    }
    allowed_value: {
      label: "August"
      value: "8"
    }
    allowed_value: {
      label: "September"
      value: "9"
    }
    allowed_value: {
      label: "October"
      value: "10"
    }
    allowed_value: {
      label: "November"
      value: "11"
    }
    allowed_value: {
      label: "December"
      value: "12"
    }
  }

  parameter: report_year {
    label: "Year"
    type: number
    default_value: "2020"
  }

  measure: count {
    type: count
  }

  measure: ttl_rent_rev {
    label: "Rental Revenue"
    type: sum
    value_format: "#,##0.00;(#,##0.00);-"
    link: {
      label: "Detail View"
      url: "https://equipmentshare.looker.com/looks/152?f[be_transaction_listing.mkt_name]={{ mkt_name._filterable_value | url_encode }}&f[be_transaction_listing.report_month]={{ _filters['be_main.report_month'] | url_encode }}&f[be_transaction_listing.report_year]={{ _filters['be_main.report_year'] | url_encode }}&f[be_transaction_listing.bucket_select]={{ 'REVrent' | url_encode }}&toggle=det"
    }
    sql: ${rental_rev} ;;
  }

  measure: ttl_sales_rev {
    label: "Sales Revenue"
    type: sum
    value_format: "#,##0.00;(#,##0.00);-"
    link: {
      label: "Detail View"
      url: "https://equipmentshare.looker.com/looks/152?f[be_transaction_listing.mkt_name]={{ mkt_name._filterable_value | url_encode }}&f[be_transaction_listing.report_month]={{ _filters['be_main.report_month'] | url_encode }}&f[be_transaction_listing.report_year]={{ _filters['be_main.report_year'] | url_encode }}&f[be_transaction_listing.bucket_select]={{ 'REVsale' | url_encode }}&toggle=det"
    }
    sql: ${sales_rev} ;;
  }

  measure: ttl_delivery_rev {
    label: "Delivery Revenue"
    type: sum
    value_format: "#,##0.00;(#,##0.00);-"
    link: {
      label: "Detail View"
      url: "https://equipmentshare.looker.com/looks/152?f[be_transaction_listing.mkt_name]={{ mkt_name._filterable_value | url_encode }}&f[be_transaction_listing.report_month]={{ _filters['be_main.report_month'] | url_encode }}&f[be_transaction_listing.report_year]={{ _filters['be_main.report_year'] | url_encode }}&f[be_transaction_listing.bucket_select]={{ 'REVdel' | url_encode }}&toggle=det"
    }
    sql: ${delivery_rev} ;;
  }

  measure: ttl_service_rev {
    label: "Service Revenue"
    type: sum
    value_format: "#,##0.00;(#,##0.00);-"
    link: {
      label: "Detail View"
      url: "https://equipmentshare.looker.com/looks/152?f[be_transaction_listing.mkt_name]={{ mkt_name._filterable_value | url_encode }}&f[be_transaction_listing.report_month]={{ _filters['be_main.report_month'] | url_encode }}&f[be_transaction_listing.report_year]={{ _filters['be_main.report_year'] | url_encode }}&f[be_transaction_listing.bucket_select]={{ 'REVserv' | url_encode }}&toggle=det"
    }
    sql: ${service_rev} ;;
  }

  measure: ttl_misc_rev {
    label: "Misc Revenue"
    type: sum
    value_format: "#,##0.00;(#,##0.00);-"
    link: {
      label: "Detail View"
      url: "https://equipmentshare.looker.com/looks/152?f[be_transaction_listing.mkt_name]={{ mkt_name._filterable_value | url_encode }}&f[be_transaction_listing.report_month]={{ _filters['be_main.report_month'] | url_encode }}&f[be_transaction_listing.report_year]={{ _filters['be_main.report_year'] | url_encode }}&f[be_transaction_listing.bucket_select]={{ 'REVmisc' | url_encode }}&toggle=det"
    }
    sql: ${misc_rev} ;;
  }

  measure: ttl_debt_exp {
    label: "Bad Debt"
    type: sum
    value_format: "#,##0.00;(#,##0.00);-"
    link: {
      label: "Detail View"
      url: "https://equipmentshare.looker.com/looks/152?f[be_transaction_listing.mkt_name]={{ mkt_name._filterable_value | url_encode }}&f[be_transaction_listing.report_month]={{ _filters['be_main.report_month'] | url_encode }}&f[be_transaction_listing.report_year]={{ _filters['be_main.report_year'] | url_encode }}&f[be_transaction_listing.bucket_select]={{ 'EXPdebt' | url_encode }}&toggle=det"
    }
    sql: ${bad_debt} ;;
  }

  measure: ttl_rent_exp {
    label: "Rental Expense"
    type: sum
    value_format: "#,##0.00;(#,##0.00);-"
    link: {
      label: "Detail View"
      url: "https://equipmentshare.looker.com/looks/152?f[be_transaction_listing.mkt_name]={{ mkt_name._filterable_value | url_encode }}&f[be_transaction_listing.report_month]={{ _filters['be_main.report_month'] | url_encode }}&f[be_transaction_listing.report_year]={{ _filters['be_main.report_year'] | url_encode }}&f[be_transaction_listing.bucket_select]={{ 'EXPrent' | url_encode }}&toggle=det"
    }
    sql: ${rental_exp} ;;
  }

  measure: ttl_sales_exp {
    label: "Sales Expense"
    type: sum
    value_format: "#,##0.00;(#,##0.00);-"
    link: {
      label: "Detail View"
      url: "https://equipmentshare.looker.com/looks/152?f[be_transaction_listing.mkt_name]={{ mkt_name._filterable_value | url_encode }}&f[be_transaction_listing.report_month]={{ _filters['be_main.report_month'] | url_encode }}&f[be_transaction_listing.report_year]={{ _filters['be_main.report_year'] | url_encode }}&f[be_transaction_listing.bucket_select]={{ 'EXPsale' | url_encode }}&toggle=det"
    }
    sql: ${sales_exp} ;;
  }

  measure: ttl_delivery_exp {
    label: "Delivery Expense"
    type: sum
    value_format: "#,##0.00;(#,##0.00);-"
    link: {
      label: "Detail View"
      url: "https://equipmentshare.looker.com/looks/152?f[be_transaction_listing.mkt_name]={{ mkt_name._filterable_value | url_encode }}&f[be_transaction_listing.report_month]={{ _filters['be_main.report_month'] | url_encode }}&f[be_transaction_listing.report_year]={{ _filters['be_main.report_year'] | url_encode }}&f[be_transaction_listing.bucket_select]={{ 'EXPdel' | url_encode }}&toggle=det"
    }
    sql: ${delivery_exp} ;;
  }

  measure: ttl_service_exp {
    label: "Service Expense"
    type: sum
    value_format: "#,##0.00;(#,##0.00);-"
    link: {
      label: "Detail View"
      url: "https://equipmentshare.looker.com/looks/152?f[be_transaction_listing.mkt_name]={{ mkt_name._filterable_value | url_encode }}&f[be_transaction_listing.report_month]={{ _filters['be_main.report_month'] | url_encode }}&f[be_transaction_listing.report_year]={{ _filters['be_main.report_year'] | url_encode }}&f[be_transaction_listing.bucket_select]={{ 'EXPserv' | url_encode }}&toggle=det"
    }
    sql: ${service_exp} ;;
  }

  measure: ttl_misc_exp {
    label: "Misc Expense"
    type: sum
    value_format: "#,##0.00;(#,##0.00);-"
    link: {
      label: "Detail View"
      url: "https://equipmentshare.looker.com/looks/152?f[be_transaction_listing.mkt_name]={{ mkt_name._filterable_value | url_encode }}&f[be_transaction_listing.report_month]={{ _filters['be_main.report_month'] | url_encode }}&f[be_transaction_listing.report_year]={{ _filters['be_main.report_year'] | url_encode }}&f[be_transaction_listing.bucket_select]={{ 'EXPmisc' | url_encode }}&toggle=det"
    }
    sql: ${misc_exp} ;;
  }

  measure: ttl_employee_exp {
    label: "Employee Benefits Expense"
    type: sum
    value_format: "#,##0.00;(#,##0.00);-"
    link: {
      label: "Detail View"
      url: "https://equipmentshare.looker.com/looks/152?f[be_transaction_listing.mkt_name]={{ mkt_name._filterable_value | url_encode }}&f[be_transaction_listing.report_month]={{ _filters['be_main.report_month'] | url_encode }}&f[be_transaction_listing.report_year]={{ _filters['be_main.report_year'] | url_encode }}&f[be_transaction_listing.bucket_select]={{ 'EXPemp' | url_encode }}&toggle=det"
    }
    sql: ${employees_exp} ;;
  }

  measure: ttl_facility_exp {
    label: "Facilities Expense"
    type: sum
    value_format: "#,##0.00;(#,##0.00);-"
    link: {
      label: "Detail View"
      url: "https://equipmentshare.looker.com/looks/152?f[be_transaction_listing.mkt_name]={{ mkt_name._filterable_value | url_encode }}&f[be_transaction_listing.report_month]={{ _filters['be_main.report_month'] | url_encode }}&f[be_transaction_listing.report_year]={{ _filters['be_main.report_year'] | url_encode }}&f[be_transaction_listing.bucket_select]={{ 'EXPfac' | url_encode }}&toggle=det"
    }
    sql: ${facility_exp} ;;
  }

  measure: ttl_general_exp {
    label: "General Expense"
    type: sum
    value_format: "#,##0.00;(#,##0.00);-"
    link: {
      label: "Detail View"
      url: "https://equipmentshare.looker.com/looks/152?f[be_transaction_listing.mkt_name]={{ mkt_name._filterable_value | url_encode }}&f[be_transaction_listing.report_month]={{ _filters['be_main.report_month'] | url_encode }}&f[be_transaction_listing.report_year]={{ _filters['be_main.report_year'] | url_encode }}&f[be_transaction_listing.bucket_select]={{ 'EXPgen' | url_encode }}&toggle=det"
    }
    sql: ${general_exp} ;;
  }

  measure: ttl_overhead_exp {
    label: "Overhead Expense"
    type: sum
    value_format: "#,##0.00;(#,##0.00);-"
    link: {
      label: "Detail View"
      url: "https://equipmentshare.looker.com/looks/152?f[be_transaction_listing.mkt_name]={{ mkt_name._filterable_value | url_encode }}&f[be_transaction_listing.report_month]={{ _filters['be_main.report_month'] | url_encode }}&f[be_transaction_listing.report_year]={{ _filters['be_main.report_year'] | url_encode }}&f[be_transaction_listing.bucket_select]={{ 'EXPover' | url_encode }}&toggle=det"
    }
    sql: ${overhead_exp} ;;
  }

  measure: ttl_interco {
    label: "Intercompany Transactions"
    type: sum
    value_format: "#,##0.00;(#,##0.00);-"
    link: {
      label: "Detail View"
      url: "https://equipmentshare.looker.com/looks/152?f[be_transaction_listing.mkt_name]={{ mkt_name._filterable_value | url_encode }}&f[be_transaction_listing.report_month]={{ _filters['be_main.report_month'] | url_encode }}&f[be_transaction_listing.report_year]={{ _filters['be_main.report_year'] | url_encode }}&f[be_transaction_listing.bucket_select]={{ 'interco' | url_encode }}&toggle=det"
    }
    sql: ${interco} ;;
  }

  measure: ttl_rev {
    label: "Total Revenues"
    type: number
    value_format: "#,##0.00;(#,##0.00);-"
    sql: ${ttl_rent_rev}+${ttl_sales_rev}+${ttl_delivery_rev}+${ttl_service_rev}+${ttl_misc_rev} ;;
  }

  measure: ttl_exp {
    label: "Total Expenses"
    type: number
    value_format: "#,##0.00;(#,##0.00);-"
    sql: ${ttl_debt_exp}+${ttl_rent_exp}+${ttl_sales_exp}+${ttl_delivery_exp}+${ttl_service_exp}+${ttl_misc_exp}+${ttl_employee_exp}+
      ${ttl_facility_exp}+${ttl_general_exp}+${ttl_overhead_exp} ;;
  }

  measure: net_income {
    label: "Net Income"
    type: number
    value_format: "#,##0.00;(#,##0.00);-"
    link: {
      label: "Detail View"
      url: "https://equipmentshare.looker.com/looks/157?f[be_transaction_listing.mkt_name]={{ mkt_name._filterable_value | url_encode }}&f[plexi_periods.display]={{ _filters['plexi_periods.display'] | url_encode }}&toggle=det"
    }
    sql: ${ttl_rev}+${ttl_exp}+${ttl_interco} ;;
  }

  dimension: market_id {
    type: string
    primary_key: yes
    sql: ${TABLE}."MARKET_ID" ;;
    suggest_explore: market_region_xwalk
    suggest_dimension: market_region_xwalk.market_id
    link: {
      label: "Detail View"
      url: "https://equipmentshare.looker.com/looks/158?f[oldquery_3mom.mkt_name]={{ mkt_name._filterable_value | url_encode }}&f[oldquery_3mom.report_month]={{ _filters['be_main.report_month'] | url_encode }}&f[oldquery_3mom.report_year]={{ _filters['be_main.report_year'] | url_encode }}&toggle=det"
    }
  }

  dimension: mkt_name {
    type: string
    sql: ${TABLE}."MKT_NAME" ;;
    suggest_explore: market_region_xwalk
    suggest_dimension: market_region_xwalk.market_name
    link: {
      label: "Detail View"
      url: "https://equipmentshare.looker.com/looks/158?f[oldquery_3mom.mkt_name]={{ mkt_name._filterable_value | url_encode }}&f[oldquery_3mom.report_month]={{ _filters['be_main.report_month'] | url_encode }}&f[oldquery_3mom.report_year]={{ _filters['be_main.report_year'] | url_encode }}&toggle=det"
    }
  }

  dimension: market_age {
    type: number
    sql: ${TABLE}."MARKET_AGE" ;;
  }

  dimension: rgn_name {
    type: string
    sql: ${TABLE}."RGN_NAME" ;;
  }

  dimension: month {
    type: string
    case: {
      when: {
        sql: ${TABLE}."MTH" = 1 ;;
        label: "January"
      }
      when: {
        sql: ${TABLE}."MTH" = 2 ;;
        label: "February"
      }
      when: {
        sql: ${TABLE}."MTH" = 3 ;;
        label: "March"
      }
      when: {
        sql: ${TABLE}."MTH" = 4 ;;
        label: "April"
      }
      when: {
        sql: ${TABLE}."MTH" = 5 ;;
        label: "May"
      }
      when: {
        sql: ${TABLE}."MTH" = 6 ;;
        label: "June"
      }
      when: {
        sql: ${TABLE}."MTH" = 7 ;;
        label: "July"
      }
      when: {
        sql: ${TABLE}."MTH" = 8 ;;
        label: "August"
      }
      when: {
        sql: ${TABLE}."MTH" = 9 ;;
        label: "September"
      }
      when: {
        sql: ${TABLE}."MTH" = 10 ;;
        label: "October"
      }
      when: {
        sql: ${TABLE}."MTH" = 11 ;;
        label: "November"
      }
      when: {
        sql: ${TABLE}."MTH" = 12 ;;
        label: "December"
      }
    }
  }

  dimension: mth {
    type: number
    sql: ${TABLE}."MTH" ;;
  }

  dimension: year {
    type: number
    sql: ${TABLE}."YR" ;;
  }

  dimension: rental_rev {
    type: number
    sql: ${TABLE}.rentrev ;;
  }

  dimension: sales_rev {
    type: number
    sql: ${TABLE}.salerev ;;
  }

  dimension: delivery_rev {
    type: number
    sql: ${TABLE}.delrev ;;
  }

  dimension: service_rev {
    type: number
    sql: ${TABLE}.servrev ;;
  }

  dimension: misc_rev {
    type: number
    sql: ${TABLE}.miscrev ;;
  }

  dimension: bad_debt {
    type: number
    sql: ${TABLE}.debtexp ;;
  }

  dimension: rental_exp {
    type: number
    sql: ${TABLE}.rentexp ;;
  }

  dimension: sales_exp {
    type: number
    sql: ${TABLE}.saleexp ;;
  }

  dimension: delivery_exp {
    type: number
    sql: ${TABLE}.delexp ;;
  }

  dimension: service_exp {
    type: number
    sql: ${TABLE}.servexp ;;
  }

  dimension: misc_exp {
    type: number
    sql: ${TABLE}.miscexp ;;
  }

  dimension: employees_exp {
    type: number
    sql: ${TABLE}.empexp ;;
  }

  dimension: facility_exp {
    type: number
    sql: ${TABLE}.facexp ;;
  }

  dimension: general_exp {
    type: number
    sql: ${TABLE}.genexp ;;
  }

  dimension: overhead_exp {
    type: number
    sql: ${TABLE}.overexp ;;
  }

  dimension: interco {
    type: number
    sql: ${TABLE}.intercomp ;;
  }

  set: detail {
    fields: [
      market_id,
      mkt_name,
      market_age,
      rgn_name,
      month,
      year,
      rental_rev,
      sales_rev,
      delivery_rev,
      service_rev,
      misc_rev,
      bad_debt,
      rental_exp,
      sales_exp,
      delivery_exp,
      service_exp,
      misc_exp,
      employees_exp,
      facility_exp,
      general_exp,
      overhead_exp
    ]
  }
}
