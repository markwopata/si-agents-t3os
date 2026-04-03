view: countless_order_and_invoice_detail {
derived_table: {
  sql: with wac_prep as ( -- suppressing overridden wac snapshots based on date_applied values
    select *
    from ANALYTICS.INTACCT_MODELS.STG_ES_WAREHOUSE_INVENTORY__WEIGHTED_AVERAGE_COST_SNAPSHOTS wacs
    qualify row_number() over (
        partition by wacs.inventory_location_id, wacs.product_id, date_applied
        order by wacs.date_created desc)
                = 1
    order by product_id, INVENTORY_LOCATION_ID, date_applied desc)

   , wac_history as (select *
                          , lead(DATE_APPLIED, 1) over (
        partition by PRODUCT_ID, INVENTORY_LOCATION_ID
        order by DATE_APPLIED asc) as date_end
                     from wac_prep),
part_margin as (
select li.BRANCH_ID,
       li.PART_ID,
       li.LINE_ITEM_ID,
       li.AMOUNT,
       wacs.WEIGHTED_AVERAGE_COST,
       avg(wac_history.WEIGHTED_AVERAGE_COST) as cw_wac
from ANALYTICS.INTACCT_MODELS.STG_ES_WAREHOUSE_PUBLIC__LINE_ITEMS li
         left join ANALYTICS.INTACCT_MODELS.STG_ES_WAREHOUSE_INVENTORY__INVENTORY_LOCATIONS il
                   on li.BRANCH_ID = il.MARKET_ID
                       and il.IS_DEFAULT_STORE = true
         left join ANALYTICS.INTACCT_MODELS.STG_ES_WAREHOUSE_INVENTORY__WEIGHTED_AVERAGE_COST_SNAPSHOTS wacs -- join on part id and date
                   on li.PART_ID = wacs.PRODUCT_ID
                       and li.DATE_CREATED::date = wacs.DATE_APPLIED::date
                       and il.STORE_ID = wacs.INVENTORY_LOCATION_ID
         left join wac_history on li.part_id = wac_history.product_id
    and li.date_created::date between wac_history.date_applied::date and coalesce(date_end::date, '9999-12-31')
group by li.PART_ID, li.AMOUNT, wacs.WEIGHTED_AVERAGE_COST, li.BRANCH_ID, li.LINE_ITEM_ID),
discrete_customer_list as (
    select MARKET_ID,
           MARKET_NAME,
           COMPANY_ID,
           CUSTOMER_NAME,
           min(BILLING_APPROVED_DATE) as earliest_invoice_date
    from ANALYTICS.INTACCT_MODELS.int_admin_invoice_and_credit_line_detail ic
    group by CUSTOMER_NAME, MARKET_NAME, COMPANY_ID, MARKET_ID
)

select o.MARKET_ID,
       icld.MARKET_NAME,
       o.ORDER_ID,
       o.DATE_CREATED as order_date_created,
       o.ORDER_STATUS_ID,
       os.NAME as order_status_name,
       o.USER_ID as order_user_id,
       o.URL_ADMIN as order_admin_url,
       icld.INVOICE_ID,
       icld.INVOICE_NUMBER,
       icld.CREDIT_NOTE_ID,
       icld.CREDIT_NOTE_NUMBER,
       icld.GL_DATE,
       icld.IS_BILLING_APPROVED,
       icld.IS_DELETED as invoice_is_deleted,
       icld.COMPANY_ID,
       icld.CUSTOMER_NAME,
       dcl.earliest_invoice_date,
       icld.INVOICE_MEMO,
       icld.CREDIT_NOTE_ID,
       icld.CREDIT_NOTE_NUMBER,
       icld.CREDIT_NOTE_DATE,
       icld.CREDIT_NOTE_STATUS_ID,
       icld.CREDIT_NOTE_STATUS_NAME,
       icld.CREDIT_NOTE_MEMO,
       icld.LINE_ITEM_ID,
       icld.LINE_ITEM_TYPE_ID,
       icld.LINE_ITEM_TYPE_NAME,
       icld.AMOUNT as invoice_line_amount,
       icld.LINE_ITEM_DESCRIPTION,
       icld.PRIMARY_SALESPERSON_ID,
       u.FULL_NAME as salesperson_name,
       i.CREATED_BY_USER_ID as invoice_created_by_user_id,
       u2.FULL_NAME as invoice_created_by_name,
       icld.URL_INVOICE_ADMIN,
       icld.URL_CREDIT_NOTE_ADMIN,
       icld.SHIP_TO_NICKNAME,
       li.NUMBER_OF_UNITS,
       li.PRICE_PER_UNIT,
       li.AMOUNT as line_item_amount,
       li.PART_ID,
       li.PART_NUMBER,
       coalesce(pm.WEIGHTED_AVERAGE_COST,pm.cw_wac) as weighted_average_cost,
       coalesce(pm.WEIGHTED_AVERAGE_COST,pm.cw_wac) * NUMBER_OF_UNITS as total_part_cost

from ANALYTICS.INTACCT_MODELS.STG_ES_WAREHOUSE_PUBLIC__ORDERS o
left join ANALYTICS.INTACCT_MODELS.STG_ES_WAREHOUSE_PUBLIC__INVOICES i
on o.ORDER_ID = i.ORDER_ID
left join ANALYTICS.INTACCT_MODELS.int_admin_invoice_and_credit_line_detail icld
on i.INVOICE_ID = icld.INVOICE_ID
left join ANALYTICS.INTACCT_MODELS.STG_ES_WAREHOUSE_PUBLIC__LINE_ITEMS li
on icld.LINE_ITEM_ID = li.LINE_ITEM_ID
left join ANALYTICS.INTACCT_MODELS.STG_ES_WAREHOUSE_PUBLIC__USERS u
on icld.PRIMARY_SALESPERSON_ID = u.USER_ID
left join ANALYTICS.INTACCT_MODELS.STG_ES_WAREHOUSE_PUBLIC__USERS u2
on i.CREATED_BY_USER_ID = u2.USER_ID
left join ANALYTICS.INTACCT_MODELS.STG_ES_WAREHOUSE_PUBLIC__ORDER_STATUSES os
on o.ORDER_STATUS_ID = os.ORDER_STATUS_ID
left join part_margin pm
on li.LINE_ITEM_ID = pm.LINE_ITEM_ID
left join discrete_customer_list dcl
on icld.MARKET_ID = dcl.MARKET_ID
and icld.COMPANY_ID = dcl.COMPANY_ID
where li.line_item_type_id in ('29','49');;
}

    filter: reporting_period {
      type: date
      description: "Single dashboard date control for both Bookings (order_date_created) and Revenue (gl_date)."
    }


    # ========== Dimensions ==========
    dimension: market_id {
      type: string
      sql: ${TABLE}.market_id ;;
    }

    dimension: market_name {
      type: string
      sql: ${TABLE}.market_name ;;
    }

    dimension: order_id {
      type: string
      sql: ${TABLE}.order_id ;;
    }

    dimension_group: order_date_created {
      type: time
      timeframes: [date, week, month, quarter, year, raw]
      sql: ${TABLE}.order_date_created ;;
    }

  dimension: is_booked_not_billed {
    type: string
    sql:
    CASE
      WHEN ${order_date_created_date} >= {% date_start gl_date_month %}
       AND ${order_date_created_date} < {% date_end gl_date_month %}
       AND (
         ${gl_date_date} IS NULL
         OR ${gl_date_date} >= {% date_end gl_date_month %}
       )
      THEN 'Yes'
      ELSE 'No'
    END ;;
  }


    dimension: order_status_id {
      type: number
      sql: ${TABLE}.order_status_id ;;
    }

    dimension: order_status_name {
      type: string
      sql: ${TABLE}.order_status_name ;;
    }
## Hiding below in favor of the active booking_flag until further advice from Matt Dunn
    dimension: booking_flag {
      label: "Is Booking Flag"
      type: string
      sql: case when ${order_status_id} <= 4
                then 'Yes'
                else 'No'
                end;;
    }

    # dimension: is_booking {
    #   type: yesno
    #   sql: ${invoice_number} IS NULL ;;
    # }

    dimension: order_user_id {
      type: string
      sql: ${TABLE}.order_user_id ;;
    }

    dimension: order_admin_url {
      type: string
      sql: ${TABLE}.order_admin_url ;;
    }

    dimension: invoice_id {
      type: string
      sql: ${TABLE}.invoice_id ;;
    }

    dimension: invoice_number {
      type: string
      sql: ${TABLE}.invoice_number ;;
    }

    dimension_group: gl_date {
      type: time
      timeframes: [date, week, month, quarter, year, raw]
      sql: ${TABLE}.gl_date ;;
    }

    dimension: is_billing_approved {
      type: yesno
      sql: ${TABLE}.is_billing_approved ;;
    }

    dimension: invoice_is_deleted {
      type: yesno
      sql: ${TABLE}.invoice_is_deleted ;;
    }

    dimension: company_id {
      type: string
      sql: ${TABLE}.company_id ;;
    }

    dimension: customer_name {
      type: string
      sql: ${TABLE}.customer_name ;;
    }

    dimension_group: earliest_invoice_date {
      label: "Earliest Invoice Date"
      type: time
      timeframes: [date, week, month, quarter, year, raw]
      sql: ${TABLE}.earliest_invoice_date ;;
    }

    dimension: invoice_memo {
      type: string
      sql: ${TABLE}.invoice_memo ;;
    }

    dimension: credit_note_id {
      type: string
      sql: ${TABLE}.credit_note_id ;;
    }

    dimension: credit_note_number {
      type: string
      sql: ${TABLE}.credit_note_number ;;
    }

    dimension_group: credit_note_date {
      type: time
      timeframes: [date, week, month, quarter, year, raw]
      sql: ${TABLE}.credit_note_date ;;
    }

    dimension: credit_note_status_id {
      type: number
      sql: ${TABLE}.credit_note_status_id ;;
    }

    dimension: credit_note_status_name {
      type: string
      sql: ${TABLE}.credit_note_status_name ;;
    }

    dimension: credit_note_memo {
      type: string
      sql: ${TABLE}.credit_note_memo ;;
    }

    dimension: line_item_id {
      type: string
      primary_key: yes
      sql: ${TABLE}.line_item_id ;;
    }

    dimension: line_item_type_id {
      type: number
      sql: ${TABLE}.line_item_type_id ;;
    }

    dimension: line_item_type_name {
      type: string
      sql: ${TABLE}.line_item_type_name ;;
    }

    dimension: line_item_description {
      type: string
      sql: ${TABLE}.line_item_description ;;
    }

    dimension: invoice_line_amount {
      label: "Invoice Line Amount"
      type: number
      value_format_name: decimal_2
      sql: ${TABLE}.invoice_line_amount ;;
    }

    dimension: line_item_amount {
      label: "Line Item Amount"
      type: number
      value_format_name: decimal_2
      sql: ${TABLE}.line_item_amount ;;
    }

    dimension: primary_salesperson_id {
      type: string
      sql: ${TABLE}.primary_salesperson_id ;;
    }

    dimension: salesperson_name {
      type: string
      sql: ${TABLE}.salesperson_name ;;
    }

    dimension: invoice_created_by_user_id {
      label: "Inside Employee ID"
      type: number
      sql: ${TABLE}.invoice_created_by_user_id;;
    }

    dimension: invoice_created_by_name {
      label: "Inside Employee Name"
      type: string
      sql: ${TABLE}.invoice_created_by_name ;;
    }

    dimension: url_invoice_admin {
      type: string
      sql: ${TABLE}.url_invoice_admin ;;
      link: {
        label: "Open Invoice"
        url: "${url_invoice_admin}"
      }
      group_label: "Links"
    }

    dimension: url_credit_note_admin {
      type: string
      sql: ${TABLE}.url_credit_note_admin ;;
    }

    dimension: ship_to_nickname {
      type: string
      sql: ${TABLE}.ship_to_nickname ;;
    }

    dimension: number_of_units {
      type: number
      value_format_name: decimal_2
      sql: ${TABLE}.number_of_units ;;
    }

    dimension: price_per_unit {
      type: number
      value_format_name: decimal_2
      sql: ${TABLE}.price_per_unit ;;
    }

    dimension: part_id {
      type: string
      sql: ${TABLE}.part_id ;;
    }

    dimension: part_number {
      type: string
      sql: ${TABLE}.part_number ;;
    }

    dimension: weighted_average_cost {
      label: "Weighted Avg Cost (Unit)"
      type: number
      value_format_name: decimal_4
      sql: ${TABLE}.weighted_average_cost ;;
      group_label: "Cost"
    }

    dimension: total_part_cost {
      type: number
      sql: ${TABLE}.total_part_cost ;;
    }

    # ========== Measures ==========
    measure: count {
      type: count
    }

    measure: orders {
      type: count_distinct
      sql: ${order_id} ;;
    }

    measure: invoices {
      type: count_distinct
      sql: ${invoice_id} ;;
    }

    measure: line_items {
      type: count_distinct
      sql: ${line_item_id} ;;
    }

    measure: total_units {
      type: sum
      sql: ${number_of_units} ;;
      value_format_name: decimal_2
    }

    measure: avg_price_per_unit {
      type: average
      sql: ${price_per_unit} ;;
      value_format_name: decimal_2
    }

    measure: total_cost {
      label: "Total Cost (WAC)"
      type: sum
      sql: ${total_part_cost} ;;
      value_format_name: usd
    }

    measure: total_revenue {
      label: "Total Revenue"
      type: sum
      sql: ${invoice_line_amount} ;;
      value_format_name: usd
      drill_fields: [order_id, invoice_id, line_item_id, part_number, market_name]
    }

  measure: total_revenue_reporting_period {
    label: "Total Revenue Booking Date Adjusted"
    description: "We need total revenue in a tile that is filtered on order date created instead of gl date but I need the gl date revenue for a proper book to bill ratio."
    type: sum
    # sql: ${invoice_line_amount} ;;
    sql:
    CASE
    WHEN ${gl_date_date} >= {% date_start reporting_period %}
    AND ${gl_date_date} <  {% date_end   reporting_period %}
    THEN ${invoice_line_amount}
    ELSE 0
    END ;;
    value_format_name: usd
    drill_fields: [order_id, invoice_id, line_item_id, part_number, market_name]
  }

    measure: avg_unit_cost {
      label: "Avg Unit WAC"
      type: average
      sql: ${weighted_average_cost} ;;
      value_format_name: decimal_4
    }

    measure: weighted_average_cost_agg {
      label: "Part Weighted Average Cost"
      type: sum
      sql: ${weighted_average_cost} ;;
      value_format_name: decimal_2
    }

    measure: gross_margin {
      type: number
      sql: ${total_revenue} - ${total_cost} ;;
      value_format_name: usd
    }

    measure: margin_pct {
      type: number
      value_format_name: percent_2
      sql:
      CASE WHEN ${total_revenue} = 0 THEN NULL
           ELSE ${gross_margin} / NULLIF(${total_revenue}, 0)
      END ;;
    }

    # Row-level flag
    dimension: is_booked_in_reporting_period {
      type: yesno
      sql:
      ${order_date_created_date} >= {% date_start reporting_period %}
      AND ${order_date_created_date} <  {% date_end   reporting_period %} ;;
      }

    measure: bookings_total_amount {
      label: "Total Booking Amount"
      type: sum
      sql:
      CASE
        WHEN ${order_date_created_date} >= {% date_start reporting_period %}
         AND ${order_date_created_date} <  {% date_end   reporting_period %}
        THEN ${invoice_line_amount}
        ELSE 0
      END ;;
      value_format_name: usd
    }


    measure: booking_line_count {
      label: "Total Lines Booked"
      type: count_distinct
      sql: ${line_item_id} ;;
      filters: [booking_flag: "Yes"]
    }

    measure: book_to_bill {
      label: "Total Book to Bill"
      type: number
      value_format_name: percent_2
      sql: COALESCE(${bookings_total_amount} / NULLIF(${total_revenue_reporting_period}, 0), 0) ;;
    }

    measure: average_booking_amount_per_line {
      label: "Average Booking Amount per Line"
      type: number
      sql: ${bookings_total_amount}/${booking_line_count} ;;
    }

  measure: active_customers {
    type: count_distinct
    sql: ${company_id} ;;
  }

  measure: new_customers {
    type: count_distinct
    sql:
    CASE
      -- This checks if the customer's first invoice date
      -- is within the date range of your report's filter.
      WHEN ${TABLE}.earliest_invoice_date >= {% date_start reporting_period %}
       AND ${TABLE}.earliest_invoice_date < {% date_end reporting_period %}
      THEN ${company_id}
      ELSE NULL
    END ;;
  }

# Flag: first invoice date is in the reporting period
  dimension: is_new_customer_in_reporting_period {
    type: yesno
    sql:
    ${earliest_invoice_date_date} >= {% date_start reporting_period %}
    AND ${earliest_invoice_date_date} <  {% date_end   reporting_period %} ;;
  }

# Display fields for listing
  dimension: new_customer_company_id_in_reporting_period {
    label: "Company ID (New in Reporting Period)"
    type: string
    sql: CASE WHEN ${is_new_customer_in_reporting_period} THEN ${company_id} ELSE NULL END ;;
  }

  dimension: new_customer_name_in_reporting_period {
    label: "Customer (New in Reporting Period)"
    type: string
    sql: CASE WHEN ${is_new_customer_in_reporting_period} THEN ${customer_name} ELSE NULL END ;;
  }



}
