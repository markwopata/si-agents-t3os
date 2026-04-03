connection: "es_snowflake_analytics"

include: "/Dashboards/rate_achievement/views/*.lkml"                # include all views in the views/ folder in this project
# include: "/**/*.view.lkml"                 # include all views in this project
# include: "my_dashboard.dashboard.lookml"   # include a LookML dashboard called my_dashboard

view: +new_rate_achievement_test {


  dimension: current_commission_amount {
    label: "Current Commission Details"
    html:
    <span style="color: #000000; text-align: left;">Billing Approved Date: {{billing_approved_date._rendered_value}}</span>
    <br />
    <span style="color: #000000; text-align: left;">Rates: {{rates_as_of_billing_approved_date._rendered_value}}</span>
    <br />
    <span style="color: #000000; text-align: left;">Commission Rate: {{current_commission_percentage._rendered_value}}</span>
    <br />
    <span style="color: #000000; text-align: left;">Commission Amount: {{current_commission_amount._rendered_value}}</span>
  ;;
  }

  dimension: current_commission_percentage {
    label: "Current Commission"
    html:
    <span style="color: #000000; text-align: left;">Invoiced Rates: {{invoiced_rates._rendered_value}}</span>
    <br />
    <span style="color: #000000; text-align: left;">Commission Rate: {{best_commission_percentage._rendered_value}}</span>
    <br />
    <span style="color: #000000; text-align: left;">Commission Amount: {{best_commission_amount._rendered_value}}</span>
  ;;
  }

  dimension: quote_order_commission_amount {
    label: "Quote Order Date Commission Details"
    html:
    <span style="color: #000000; text-align: left;">Quote Date: {{quote_created_date._rendered_value}}</span>
    <br />
    <span style="color: #000000; text-align: left;">Order Date: {{order_created_date._rendered_value}}</span>
    <br />
    <span style="color: #000000; text-align: left;">Order Date Anniversary: {{moving_original_rate_date._rendered_value}}</span>
    <br />
    <span style="color: #000000; text-align: left;">Rate Lock Date: {{rate_lock_date._rendered_value}}</span>
    <br />
    <span style="color: #000000; text-align: left;">Rates: {{rates_as_of_rate_lookup_date._rendered_value}}</span>
    <br />
    <span style="color: #000000; text-align: left;">Commission Rate: {{quote_order_commission_percentage._rendered_value}}</span>
    <br />
    <span style="color: #000000; text-align: left;">Commission Amount: {{quote_order_commission_amount._rendered_value}}</span>
  ;;
  }


  dimension: crr_created_date_commission_amount {
    label: "Customer Rental Rates Commission Details"
    html:
    <span style="color: #000000; text-align: left;">Created Date: {{customer_rental_rate_created_date._rendered_value}}</span>
    <br />
    <span style="color: #000000; text-align: left;">End Date: {{customer_rental_rate_end_date._rendered_value}}</span>
    <br />
    <span style="color: #000000; text-align: left;">Rates: {{rates_as_of_crr_created_date._rendered_value}}</span>
    <br />
    <span style="color: #000000; text-align: left;">Commission Rate: {{crr_created_date_commission_percentage._rendered_value}}</span>
    <br />
    <span style="color: #000000; text-align: left;">Commission Amount: {{crr_created_date_commission_amount._rendered_value}}</span>
  ;;
  }

  dimension: best_commission_amount {
    label: "Best Commission Details"
    html:
    <span style="color: #000000; text-align: left;">Source: {{best_commission_rate_source._rendered_value}}</span>
    <br />
    <span style="color: #000000; text-align: left;">Date: {{best_commission_rate_date._rendered_value}}</span>
    <br />
    <span style="color: #000000; text-align: left;">Rates: {{best_commission_rates._rendered_value}}</span>
    <br />
    <span style="color: #000000; text-align: left;">Commission Rate: {{best_commission_percentage._rendered_value}}</span>
    <br />
    <span style="color: #000000; text-align: left;">Commission Amount: {{best_commission_amount._rendered_value}}</span>
  ;;
  }

  dimension: next_best_commission_amount {
    label: "Next Best Commission Details"
    html:
    <span style="color: #000000; text-align: left;">Source: {{next_best_commission_rate_source._rendered_value}}</span>
    <br />
    <span style="color: #000000; text-align: left;">Date: {{next_best_commission_date._rendered_value}}</span>
    <br />
    <span style="color: #000000; text-align: left;">Rates: {{next_best_commission_rates._rendered_value}}</span>
    <br />
    <span style="color: #000000; text-align: left;">Commission Rate: {{next_best_commission_percentage._rendered_value}}</span>
    <br />
    <span style="color: #000000; text-align: left;">Commission Amount: {{next_best_commission_amount._rendered_value}}</span>
  ;;
  }


  dimension: next_crr_commission_amount {
    label: "Next Customer Rental Rates Commission Details"
    html:
    <span style="color: #000000; text-align: left;">Commission Rate: {{next_crr_commission_percentage._rendered_value}}</span>
    <br />
    <span style="color: #000000; text-align: left;">Commission Amount: {{next_crr_commission_amount._rendered_value}}</span>
  ;;
  }


  dimension: next_rate_lock_date_commission_amount {
    label: "Next Quote Order Commission Details"
    html:
    <span style="color: #000000; text-align: left;">Next Order Date Anniversary: {{next_moving_original_rate_date._rendered_value}}</span>
    <br />
    <span style="color: #000000; text-align: left;">Rate Lock Date: {{next_rate_lock_date._rendered_value}}</span>
    <br />
    <span style="color: #000000; text-align: left;">Rates: {{rates_as_of_next_rate_lock_date._rendered_value}}</span>
    <br />
    <span style="color: #000000; text-align: left;">Commission Rate: {{next_rate_lock_date_commission_percentage._rendered_value}}</span>
    <br />
    <span style="color: #000000; text-align: left;">Commission Amount: {{next_rate_lock_date_commission_amount._rendered_value}}</span>
  ;;
  }


  dimension: next_period_floor_rates {
    label: "Next Rate Achievement Period Commission"
    html:
    <span style="color: #000000; text-align: left;">Floor Rates {{next_period_floor_rates._rendered_value}}</span>
    <br />
    <span style="color: #000000; text-align: left;">Bench Rates: {{next_period_bench_rates._rendered_value}}</span>
    <br />
    <span style="color: #000000; text-align: left;">Book Rates: {{next_period_book_rates._rendered_value}}</span>
    <br />
    <span style="color: #000000; text-align: left;">Commission Rate: {{next_rate_lock_date_commission_percentage._rendered_value}}</span>
    <br />
    <span style="color: #000000; text-align: left;">Commission Amount: {{next_rate_lock_date_commission_amount._rendered_value}}</span>
  ;;
  }

  # dimension: next_rate_lock_date_commission_amount {
  #   label: "Next Quote Order Commission Details"
  #   html:
  #   <span style="color: #000000; text-align: left;">Source: {{next_ccr_commission_rate_source._rendered_value}}</span>
  #   <br />
  #   <span style="color: #000000; text-align: left;">Commission Rate: {{next_ccr_commission_percentage._rendered_value}}</span>
  #   <br />
  #   <span style="color: #000000; text-align: left;">Commission Amount: {{next_ccr_commission_amount._rendered_value}}</span>
  # ;;
  # }



  # dimension: quote_order_date_commissions {
  #   type:  string
  #   sql:  ${rates_as_of_rate_lookup_date} || '\n' || ${quote_order_commission_percentage} || '\n' || ${quote_order_commission_amount} ;;
  # }

  # dimension: crr_created_date_commissions {
  #   type:  string
  #   sql:  ${rates_as_of_crr_created_date} || '\n' || ${crr_created_date_commission_percentage} || '\n' || ${crr_created_date_commission_amount} ;;
  # }
  dimension: salesperson_email_address_access {
    type: yesno
    hidden: yes
    sql: ${TABLE}."SALESPERSON_EMAIL_ADDRESS" in ('{{ _user_attributes['email'] | replace: "'", "\\'"}}') ;;
  }

}


view: +rentals_without_customer_rental_rates {
  dimension: salesperson_email_address_access {
    type: yesno
    hidden: yes
    sql: ${TABLE}."SALESPERSON_EMAIL_ADDRESS" in ('{{ _user_attributes['email'] | replace: "'", "\\'"}}') ;;
  }
  }



# # Select the views that should be a part of this model,
# # and define the joins that connect them together.
#
explore: new_rate_acheivement {
  sql_always_where: ${new_rate_acheivement.salesperson_email_address_access}
  or 'developer' = {{ _user_attributes['department'] }}
  or 'admin' = {{ _user_attributes['department'] }}
  or 'god view'= {{ _user_attributes['department'] }}
  OR TRIM('{{ _user_attributes['email'] | replace: "'", "\\'"}}')  = 'jabbok@equipmentshare.com';;
  from: new_rate_achievement_test
}

# Commented out due to low usage on 2026-03-26
# explore: rentals_without_customer_rental_rates {
#   sql_always_where: ${rentals_without_customer_rental_rates.salesperson_email_address_access}
#       or 'developer' = {{ _user_attributes['department'] }}
#       or 'admin' = {{ _user_attributes['department'] }}
#       or 'god view'= {{ _user_attributes['department'] }}
#       OR TRIM('{{ _user_attributes['email'] | replace: "'", "\\'"}}')  = 'jabbok@equipmentshare.com';;
#   from: rentals_without_customer_rental_rates
# }
