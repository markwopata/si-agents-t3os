# The purpose of this view is to pull out logic specific to rebate calculations from the primary
# v_line_items view using refinement structure.

include: "/views/ANALYTICS/v_line_items.view.lkml"

view: +v_line_items {
  #drill_fields: [rebates_per_market]#rebate_amount_per_customer.rebate_percent_achieved, rental_charges_eligible_for_rebate]
#    view_label: "V_Line_Items with Customer Rebates"


  dimension: cheapest_period_hour_count {
    type:  number
    sql:COALESCE(IFF(charindex('cheapest_period_hour_count":', ${v_line_items.extended_data}) = 0,0, try_cast(SUBSTRING(
           ${v_line_items.extended_data},
           charindex('cheapest_period_hour_count":', ${v_line_items.extended_data}) + len('cheapest_period_hour_count":'),
           charindex(',', SUBSTRING(${v_line_items.extended_data},charindex('cheapest_period_hour_count":', ${v_line_items.extended_data}) + len('cheapest_period_hour_count":')+1, len(${v_line_items.extended_data})))) as number)),0);;
  }


  dimension: cheapest_period_day_count {
    type:  number
    sql:COALESCE(IFF(charindex('cheapest_period_day_count":', ${v_line_items.extended_data}) = 0,0, try_cast(SUBSTRING(
           ${v_line_items.extended_data},
           charindex('cheapest_period_day_count":', ${v_line_items.extended_data}) + len('cheapest_period_day_count":'),
           charindex(',', SUBSTRING(${v_line_items.extended_data},charindex('cheapest_period_day_count":', ${v_line_items.extended_data}) + len('cheapest_period_day_count":')+1, len(${v_line_items.extended_data})))) as number)),0);;
  }


  dimension: cheapest_period_week_count {
    type:  number
    sql:COALESCE(IFF(charindex('cheapest_period_week_count":', ${v_line_items.extended_data}) = 0,0, try_cast(SUBSTRING(
           ${v_line_items.extended_data},
           charindex('cheapest_period_week_count":', ${v_line_items.extended_data}) + len('cheapest_period_week_count":'),
           charindex(',', SUBSTRING(${v_line_items.extended_data},charindex('cheapest_period_week_count":', ${v_line_items.extended_data}) + len('cheapest_period_week_count":')+1, len(${v_line_items.extended_data})))) as number)),0);;
  }

  dimension: cheapest_period_four_week_count {
    type:  number
    sql:COALESCE(IFF(charindex('cheapest_period_four_week_count":', ${v_line_items.extended_data}) = 0,0, try_cast(SUBSTRING(
           ${v_line_items.extended_data},
           charindex('cheapest_period_four_week_count":', ${v_line_items.extended_data}) + len('cheapest_period_four_week_count":'),
           charindex(',', SUBSTRING(${v_line_items.extended_data},charindex('cheapest_period_four_week_count":', ${v_line_items.extended_data}) + len('cheapest_period_four_week_count":')+1, len(${v_line_items.extended_data})))) as number)),0);;
  }

  dimension: cheapest_period_month_count {
    type:  number
    sql:COALESCE(IFF(charindex('cheapest_period_month_count":', ${v_line_items.extended_data}) = 0,0, try_cast(SUBSTRING(
           ${v_line_items.extended_data},
           charindex('cheapest_period_month_count":', ${v_line_items.extended_data}) + len('cheapest_period_month_count":'),
           charindex(',', SUBSTRING(${v_line_items.extended_data},charindex('cheapest_period_month_count":', ${v_line_items.extended_data}) + len('cheapest_period_month_count":')+1, len(${v_line_items.extended_data})))) as number)),0);;
  }

  dimension: cheapest_period_cycle_count {
    type:  number
    sql:COALESCE(IFF(charindex('cheapest_period_cycle_max_count":', ${v_line_items.extended_data}) = 0,0, try_cast(SUBSTRING(
           ${v_line_items.extended_data},
           charindex('cheapest_period_cycle_max_count":', ${v_line_items.extended_data}) + len('cheapest_period_cycle_max_count":'),
           charindex(',', SUBSTRING(${v_line_items.extended_data},charindex('cheapest_period_cycle_max_count":', ${v_line_items.extended_data}) + len('cheapest_period_cycle_max_count":')+1, len(${v_line_items.extended_data})))) as number)),0);;
  }

  dimension: prorated_flag {
    type:  yesno
    sql:case when ${billing_company_preferences.four_week_billing_date} is null then false else true end;;
}

    dimension: billing_type {
      type:  string
      sql:
      CASE WHEN COALESCE(IFF(charindex('price_per_month":', ${v_line_items.extended_data}) = 0,0, try_cast(SUBSTRING(
           ${v_line_items.extended_data},
           charindex('price_per_month":', ${v_line_items.extended_data}) + len('price_per_month":'),
           charindex(',', SUBSTRING(${v_line_items.extended_data},charindex('price_per_month":', ${v_line_items.extended_data}) + len('price_per_month":')+1, len(${v_line_items.extended_data})))) as number)),0) >0 then 'monthly' else 'four_week' end;;
      }


  dimension: expected_total {
    type: number
    sql:
    NULLIF(
      CASE
        -- no customer-specific rates → no expected total
        WHEN ${customer_rebates.customer_specific_rates} = 'no' THEN NULL

      -- customer-specific = yes but no prices at all → no expected total
      WHEN ${customer_rebates.customer_specific_rates} = 'yes'
      AND ${line_items_with_customer_rates.price_per_month} IS NULL
      AND ${line_items_with_customer_rates.price_per_week}  IS NULL
      AND ${line_items_with_customer_rates.price_per_day}   IS NULL
      AND ${line_items_with_customer_rates.price_per_hour}  IS NULL
      THEN NULL

      -- single cycle
      WHEN ${cheapest_period_cycle_count} = 1 THEN
      CASE
      -- be careful here: prorated_flag is likely 'Yes'/'No' not true/false
      WHEN ${prorated_flag} = 'No'
      THEN ${line_items_with_customer_rates.price_per_month}
      ELSE
      (${line_items_with_customer_rates.price_per_month} / 28) *
      DATEDIFF(
      day,
      ${invoices_rebates.start_date},
      ${invoices_rebates.end_date}
      )
      END

      -- daily billing
      WHEN ${rentals.daily_billing_flag} = 'Yes' THEN
      (${line_items_with_customer_rates.price_per_month} / 28) *
      DATEDIFF(
      day,
      ${invoices_rebates.start_date},
      ${invoices_rebates.end_date}
      )

      -- long monthly cycles after 2024-11-13
      WHEN ${billing_type} = 'monthly'
      AND DATEDIFF(
      day,
      ${invoices_rebates.start_date},
      ${invoices_rebates.end_date}
      ) > 28
      AND ${orders.date_created_date} >= '2024-11-13'
      THEN
      (${line_items_with_customer_rates.price_per_month} / 28) *
      DATEDIFF(
      day,
      ${invoices_rebates.start_date},
      ${invoices_rebates.end_date}
      )

      -- standard cheapest-period breakdown
      ELSE
      ${cheapest_period_hour_count}        * ${line_items_with_customer_rates.price_per_hour} +
      ${cheapest_period_day_count}         * ${line_items_with_customer_rates.price_per_day} +
      ${cheapest_period_week_count}        * ${line_items_with_customer_rates.price_per_week} +
      ${cheapest_period_four_week_count}   * ${line_items_with_customer_rates.price_per_month} +
      ${cheapest_period_month_count}       * ${line_items_with_customer_rates.price_per_month}
      END,
      0
      )
      ;;
  }

  # dimension: expected_total {
  #   type:  number
  #   sql: CASE WHEN (CASE WHEN ${customer_rebates.customer_specific_rates} = 'no' then null
  #   WHEN ${customer_rebates.customer_specific_rates} = 'yes' and ${line_items_with_customer_rates.price_per_month} is null and ${line_items_with_customer_rates.price_per_week} is null and ${line_items_with_customer_rates.price_per_day} is null and ${line_items_with_customer_rates.price_per_hour} is null then null
  #   WHEN ${cheapest_period_cycle_count} = 1 then case when ${prorated_flag} = false then ${line_items_with_customer_rates.price_per_month} else (${line_items_with_customer_rates.price_per_month}/28)* datediff(day, ${invoices_rebates.start_date}, ${invoices_rebates.end_date}) end
  #   WHEN ${rentals.daily_billing_flag} = 'Yes' then (${line_items_with_customer_rates.price_per_month} / 28) * datediff(day, ${invoices_rebates.start_date}, ${invoices_rebates.end_date})
  #   WHEN ${billing_type} = 'monthly' and datediff(day, ${invoices_rebates.start_date}, ${invoices_rebates.end_date}) > 28 and ${orders.date_created_date} >= '2024-11-13' then (${line_items_with_customer_rates.price_per_month} / 28) * datediff(day, ${invoices_rebates.start_date}, ${invoices_rebates.end_date})
  #   ELSE ${cheapest_period_hour_count}*${line_items_with_customer_rates.price_per_hour} + ${cheapest_period_day_count}*${line_items_with_customer_rates.price_per_day}
  #   + ${cheapest_period_week_count}*${line_items_with_customer_rates.price_per_week} + ${cheapest_period_four_week_count}*${line_items_with_customer_rates.price_per_month} + ${cheapest_period_month_count}*${line_items_with_customer_rates.price_per_month} end) = 0 then null else


  #   (CASE WHEN ${customer_rebates.customer_specific_rates} = 'no' then null
  #   WHEN ${customer_rebates.customer_specific_rates} = 'yes' and ${line_items_with_customer_rates.price_per_month} is null and ${line_items_with_customer_rates.price_per_week} is null and ${line_items_with_customer_rates.price_per_day} is null and ${line_items_with_customer_rates.price_per_hour} is null then null
  #   WHEN ${cheapest_period_cycle_count} = 1 then case when ${prorated_flag} = false then ${line_items_with_customer_rates.price_per_month} else (${line_items_with_customer_rates.price_per_month}/28)* datediff(day, ${invoices_rebates.start_date}, ${invoices_rebates.end_date}) end
  #   WHEN ${rentals.daily_billing_flag} = 'Yes' then (${line_items_with_customer_rates.price_per_month} / 28) * datediff(day, ${invoices_rebates.start_date}, ${invoices_rebates.end_date})
  #   WHEN ${billing_type} = 'monthly' and datediff(day, ${invoices_rebates.start_date}, ${invoices_rebates.end_date}) > 28 and ${orders.date_created_date} >= '2024-11-13' then (${line_items_with_customer_rates.price_per_month} / 28) * datediff(day, ${invoices_rebates.start_date}, ${invoices_rebates.end_date})
  #   ELSE ${cheapest_period_hour_count}*${line_items_with_customer_rates.price_per_hour} + ${cheapest_period_day_count}*${line_items_with_customer_rates.price_per_day}
  #   + ${cheapest_period_week_count}*${line_items_with_customer_rates.price_per_week} + ${cheapest_period_four_week_count}*${line_items_with_customer_rates.price_per_month} + ${cheapest_period_month_count}*${line_items_with_customer_rates.price_per_month} end)
  #   END;;
  # }

  dimension: revenue_diff_yes_no{
    type:  string
    sql: CASE WHEN ABS(${v_line_items.amount}) - ${expected_total} >= 0 THEN 'yes' WHEN ${expected_total} is null then 'yes' else 'no' END;;
  }


  dimension: is_valid_rate {
    type:  string
    sql: CASE WHEN ${customer_rebates.customer_specific_rates} = 'yes' THEN (CASE WHEN ABS(${v_line_items.amount}) - ${expected_total} >= 0 THEN 'yes' WHEN ${expected_total} is null then 'yes' else 'no' END) ELSE 'yes' END;;
    html:

    {% if value == 'no' %}

      <p style="color: black; background-color: rgb(179, 47, 55); font-size:100%; text-align:center">{{ rendered_value }}</p>

      {% else %}

      <p style="color: black; font-size:100%; text-align:center">{{ rendered_value }}</p>

      {% endif %}
      ;;}

  dimension: is_rebate_eligible {
    type:  string
    sql: CASE WHEN ${invoices_rebates.customer_rebate_pay_period_cutoff} = 'Yes' AND ${is_valid_rate} = 'yes' THEN 'yes' ELSE 'no' END;;
    html:

    {% if value == 'no' %}

      <p style="color: black; background-color: rgb(179, 47, 55); font-size:100%; text-align:center">{{ rendered_value }}</p>

      {% else %}

      <p style="color: black; font-size:100%; text-align:center">{{ rendered_value }}</p>

      {% endif %}
      ;;}

  # dimension: rental_charges_eligible_for_rebate {
  #   type:  number
  #   sql: CASE WHEN ${is_rebate_eligible} = 'yes' THEN ${v_line_items.amount} ELSE 0 END;;
  # }

  # measure: total_rental_charges_eligible_for_rebate {
  #   type:  sum
  #   sql: COALESCE(${rental_charges_eligible_for_rebate},0)::number;;
  #   # value_format_name: usd
  # }


  measure: rental_charges_eligible_for_rebate{
    type: sum
    sql: coalesce(${v_line_items.amount},0) ;;
    value_format_name: usd
    filters: [is_rebate_eligible: "yes"]
  }

  measure: rental_charges {
    type: sum
    sql: ${amount} ;;
    value_format: "$#,##0.00"
  }

  measure: rebate_amount {
    type:  number
    sql:  ${rebate_amount_per_customer.rebate_percent_achieved} * ${rental_charges_eligible_for_rebate};;
    value_format: "$#,##0.00"
    }

  # measure: total_rental_charges {
  #   type:  sum
  #   sql: coalesce(${v_line_items.amount}, 0) ;;
  #   value_format_name: usd
  # }
}
