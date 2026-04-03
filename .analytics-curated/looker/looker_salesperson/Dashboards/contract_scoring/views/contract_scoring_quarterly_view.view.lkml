  view: contract_scoring_quarterly_view {
    sql_table_name: RATE_ACHIEVEMENT.CONTRACT_SCORING_QUARTERLY_AGG ;;


#Moves derived table to snowflake

      dimension: pkey {
        type: string
        primary_key: yes
        hidden: yes
        sql: CONCAT(${TABLE}.parent_company_name,${TABLE}.invoice_date)  ;;
      }

      dimension: parent_company_name {
        type: string
        sql: ${TABLE}.PARENT_COMPANY_NAME ;;
      }


 #      dimension: company_name{
#        type: string
#         sql: ${TABLE}.COMPANY_NAME ;;
#       }

#       dimension: invoice_year{
 #       type: string
  #       sql: ${TABLE}."INVOICE_YEAR" ;;
   #    }

#       dimension: invoice_quarter{
 #        type: string
  #       sql: ${TABLE}."INVOICE_QUARTER" ;;
   #    }

      dimension: invoice_date_raw {

        type: date
        sql: ${TABLE}.INVOICE_DATE ;;


      }
      dimension_group: invoice_date {
        type: time
        timeframes: [
          quarter,
          year
        ]
        sql: CAST(${TABLE}.INVOICE_DATE AS TIMESTAMP_NTZ) ;;
      }


      dimension: rental_revenue{
        type: number
        value_format_name: usd
        sql: ${TABLE}.RENTAL_REVENUE_SUM ;;
      }


      dimension: gross_profit_margin{
        type:  number
        value_format_name: usd
        sql:  ${TABLE}.GROSS_PROFIT_MARGIN_SUM ;;
      }

      dimension: gross_profit_margin_pct{
        type:  number
        sql:  ${TABLE}.GROSS_PROFIT_MARGIN_PCT_SUM ;;
      }


      dimension: ancillary_pct_of_rental_revenue{
        type:  number
        sql:  ${TABLE}.ancillary_pct_of_revenue ;;
      }

      measure: rental_revenue_sum {
        type:  sum
        value_format_name: usd
        sql:  ${TABLE}.RENTAL_REVENUE_SUM ;;
      }


      measure: gross_profit_margin_sum{
        type:  sum
        value_format_name: usd
        sql:  ${TABLE}.GROSS_PROFIT_MARGIN_SUM ;;
      }

      # measure: gross_profit_margin_pct_avg{
      #   type:  average
      #   sql:  ${TABLE}."GROSS_PROFIT_MARGIN_PCT" ;;
      # }

      measure: gross_profit_margin_pct_sum {
        type: number
        sql: CASE
          WHEN ${rental_revenue_sum} != 0 THEN ${gross_profit_margin_sum} / ${rental_revenue_sum}
          ELSE 0
        END ;;
        value_format: "0.00%" # Formats the result as a percentage
      }


      measure: total_ancillary_revenue {
        type: sum
        sql: ${TABLE}.TOTAL_ANCILLARY ;;
      }

      measure: retail_parts_sales_revenue {
        type: sum
        sql: ${TABLE}.RETAIL_PART_SALES ;;
      }

      measure: environmental_fees_revenue {
        type: sum
        sql: ${TABLE}.ENVIRONMENTAL_FEES_REVENUE ;;
      }

      measure: pnd_revenue {
        type: sum
        sql: ${TABLE}.PND_REVENUE ;;
      }

      measure: fuel_revenue {
        type: sum
        sql: ${TABLE}.FUEL_REVENUE ;;
      }

      measure: service_revenue {
        type: sum
        sql: ${TABLE}.SERVICE_REVENUE ;;
      }

      measure: ancillary_pct_of_rental_revenue_sum{
        type: number
        sql: CASE
          WHEN ${rental_revenue_sum} != 0 THEN ${total_ancillary_revenue} / ${rental_revenue_sum}
          ELSE 0
        END ;;
        value_format: "0.00%" # Formats the result as a percentage
      }


      # dimension:  key {
      #   primary_key: yes
      #   type: number
      #   hidden:  yes
      #   sql:  ${TABLE}."KEY" ;;
      # }


    }
