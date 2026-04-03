view: po_drill_details {
  derived_table: {
    sql:
  with rental_status as (
  select
  rental_id,
  case
    when (rental_billing_cycle_strategy = 'twenty_eight_day_cycle' or rental_billing_cycle_strategy is null) then
        case when r.start_date::date >= current_timestamp::date - 28 THEN dateadd(day, 28, r.start_date::date)
        else dateadd(day, TIMESTAMPDIFF('day',r.start_date::date , current_timestamp()) + (28-mod(TIMESTAMPDIFF('day',r.start_date::date , current_date()), 28))::int, r.start_date::date)
        end
    when rental_billing_cycle_strategy = 'thirty_day_cycle' then
        case when r.start_date::date >= current_timestamp::date - 30 THEN dateadd(day, 30, r.start_date::date)
        else dateadd(day, TIMESTAMPDIFF('day',r.start_date::date , current_timestamp()) + (30-mod(TIMESTAMPDIFF('day',r.start_date::date , current_date()), 30))::int, r.start_date::date) end
    when rental_billing_cycle_strategy = 'first_of_month' then
        dateadd(month, 1, date_trunc(month,current_date()))
    else
      case when r.start_date::date >= current_timestamp::date - 28 THEN dateadd(day, 28, r.start_date::date)
      else dateadd(day, TIMESTAMPDIFF('day',r.start_date::date , current_timestamp()) + (28-mod(TIMESTAMPDIFF('day',r.start_date::date , current_date()), 28))::int, r.start_date::date)
        end
  end as next_cycle_date,
  case
    when datediff(day,current_timestamp(),next_cycle_date) <= 7 AND datediff(day,current_timestamp(),next_cycle_date) >= 0 then 'Cycling This Week'
    when r.rental_status_id = 5 then 'On Rent'
    when r.rental_status_id = 4 then 'Reservation'
    else 'Off Rent'
    end as status
  from
    rentals r
    join orders o on o.order_id = r.order_id
    join purchase_orders po on po.purchase_order_id = o.purchase_order_id
    left join billing_company_preferences bcp on bcp.company_id = {{ _user_attributes['company_id'] }}::integer
    where
     po.company_id = {{ _user_attributes['company_id'] }}::integer
  )
  SELECT
      po.name as po_name,
      po.purchase_order_id,
      coalesce(po.budget_amount, 0) as budget_amount,
      coalesce(sum(vli.amount + vli.tax_amount), 0) as billed_amount,
      sum(case when line_item_type_id = 8 then coalesce(amount,0) else 0 end) as rental_only_billed_amount,
      coalesce(sum(vli.amount + vli.tax_amount), 0) - sum(case when line_item_type_id = 8 then coalesce(amount,0) else 0 end) as non_rental_billed_amount,
      i.invoice_id,
      i.invoice_no,
      i.invoice_date
  FROM
      ANALYTICS.PUBLIC.V_LINE_ITEMS vli
      JOIN invoices i on i.invoice_id = vli.invoice_id
      JOIN ES_WAREHOUSE.PUBLIC.PURCHASE_ORDERS po ON i.purchase_order_id = po.purchase_order_id
      LEFT JOIN ES_WAREHOUSE.PUBLIC.USERS u on i.ordered_by_user_id = u.user_id
      left join rentals r on vli.rental_id = r.rental_id
      left join orders o on o.order_id = r.order_id
      left join ES_WAREHOUSE.PUBLIC.USERS ou on ou.user_id = o.user_id
      left join equipment_assignments ea on r.rental_id = ea.rental_id
      left join assets a on a.asset_id = ea.asset_id
      left join rental_location_assignments rla
        on rla.rental_id = r.rental_id
        and rla.end_date is null
      left join locations l
        on l.location_id = rla.location_id
        and l.company_id = {{ _user_attributes['company_id'] }}::numeric
      left join markets m on m.market_id = o.market_id
      left join companies cm on cm.company_id = m.company_id
      left join rental_status rs on rs.rental_id = r.rental_id
  WHERE
    {% condition po_budget_information.po_filter %} po.name {% endcondition %}
    and {% condition po_budget_information.asset_filter %} a.custom_name {% endcondition %}
    and {% condition po_budget_information.class_filter %} a.asset_class {% endcondition %}
    and {% condition po_budget_information.jobsite_filter %} l.nickname {% endcondition %}
    and {% condition po_budget_information.vendor_filter %} cm.name {% endcondition %}
    and {% condition po_budget_information.rental_status_filter %} rs.status {% endcondition %}
    and {% condition po_budget_information.ordered_by_filter %} concat(ou.first_name, ' ',ou.last_name) {% endcondition %}
    and u.company_id = {{ _user_attributes['company_id'] }}::integer
    and i.billing_approved_date >= po.start_date
    and i.invoice_date::date
      between CONVERT_TIMEZONE('{{ _user_attributes['user_timezone'] }}', 'UTC', {% date_start po_budget_information.date_filter %})
          and CONVERT_TIMEZONE('{{ _user_attributes['user_timezone'] }}', 'UTC', {% date_end po_budget_information.date_filter %})
    and i.billing_approved is not null
    and po.active = TRUE
  GROUP BY
      po.name,
      po.purchase_order_id,
      i.invoice_id,
      i.invoice_no,
      i.invoice_date,
      budget_amount
    ;;
  }

  dimension: po_name {
    type: string
    label: "Purchase Order"
    sql: ${TABLE}."PO_NAME" ;;
  }

  dimension: purchase_order_id{
    type: number
    sql: ${TABLE}."PURCHASE_ORDER_ID" ;;
  }

  dimension: invoice_id {
    primary_key: yes
    type: number
    label: "Invoice ID"
    sql: ${TABLE}."INVOICE_ID" ;;
  }

  dimension: invoice_no {
    type: string
    label: "Invoice #"
    sql: ${TABLE}."INVOICE_NO" ;;
  }

  dimension: invoice_link {
    type: string
    label: "Invoice #"
    sql: ${TABLE}."INVOICE_NO"  ;;
    html: <font color="#0063f3"><u><a href="https://app.estrack.com/#/billing/{{ invoice_id._filterable_value }}" target="_blank">{{value}}</a></font></u>;;
  }

  dimension: billed_amount {
    type: number
    sql: ${TABLE}."BILLED_AMOUNT" ;;
  }

  dimension: rental_only_billed_amount {
    type: number
    sql: ${TABLE}."RENTAL_ONLY_BILLED_AMOUNT" ;;
  }

  dimension: non_rental_billed_amount {
    type: number
    sql: ${TABLE}."NON_RENTAL_BILLED_AMOUNT" ;;
  }

  dimension: budget_amount {
    type: number
    sql: ${TABLE}."BUDGET_AMOUNT" ;;
  }

  dimension: invoice_date {
    type: date
    sql: ${TABLE}."INVOICE_DATE" ;;
  }

  measure: total_spend {
    label: "Total Spend"
    type: sum
    sql: coalesce(${billed_amount}, 0) ;;
    value_format_name: usd
    drill_fields: [detail*]
  }

  measure: total_budget_amount {
    type: sum
    label: "Budget Amount"
    sql: coalesce(${budget_amount}, 0) ;;
    value_format_name: usd
  }

  measure: total_billed_amount {
    type: sum
    label: "Total Billed Amount"
    sql: ${billed_amount} ;;
    value_format_name: usd
  }

  measure: total_rental_only_billed_amount {
    type: sum
    label: "Rental Only Billed Amount"
    sql: ${rental_only_billed_amount} ;;
    value_format_name: usd
  }

  measure: total_non_rental_billed_amount {
    type: sum
    label: "Non Rental Billed Amount"
    sql: ${non_rental_billed_amount} ;;
    value_format_name: usd
  }

  set: detail {
    fields: [
      po_name,
      invoice_no,
      invoice_link,
      invoice_date,
      total_billed_amount,
      total_budget_amount]
  }

  set: po_budget_information{
    fields: [
      po_budget_information.rental_rate_filter]
  }


}
