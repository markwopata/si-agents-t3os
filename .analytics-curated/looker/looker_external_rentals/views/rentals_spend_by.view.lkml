view: rentals_spend_by {
  derived_table: {
    sql: with main_info as (
    select
      UPPER(l.nickname) as jobsite,
      sum(i.billed_amount) as billed_amount,
      I.start_date as invoice_start_date,
      I.end_date as invoice_end_date,
      RLA.start_date as rental_location_start_date,
      case when RLA.end_date is null then current_timestamp else RLA.end_date end as rental_location_end_date,
      date_part('epoch', i.end_date) - date_part('epoch',i.start_date) as invoice_seconds,
      i.invoice_id,
      i.invoice_no,
      a.asset_list,
      po.name as po_name,
      count(*) as total_line_item_count
    from
      orders o
      join rentals r on o.order_id = r.order_id
      join global_line_items li on r.rental_id = li.rental_id
      join global_invoices i on li.invoice_id = i.invoice_id
      --join es_warehouse_stage.public.global_invoices i on li.invoice_id = i.invoice_id
      join users u on o.user_id = u.user_id
      join purchase_orders po on po.purchase_order_id = i.purchase_order_id
      left join rental_location_assignments rla on r.rental_id = rla.rental_id
      left join locations l on rla.location_id = l.location_id
      left join (select li.invoice_id, listagg(a.custom_name, ', ') as asset_list from global_line_items li join assets a on li.asset_id = a.asset_id group by li.invoice_id) a on a.invoice_id = i.invoice_id
      left join equipment_classes cl on r.equipment_class_id = cl.equipment_class_id
    where
      --li.line_item_type_id = 8 and
      i.billing_approved_date between CONVERT_TIMEZONE('{{ _user_attributes['user_timezone'] }}','UTC', {% date_start date_filter %}) and CONVERT_TIMEZONE('{{ _user_attributes['user_timezone'] }}','UTC', {% date_end date_filter %})
      and u.company_id = {{ _user_attributes['company_id'] }}
      and overlaps(i.start_date,i.end_date,rla.start_date,coalesce(rla.end_date,current_timestamp))
      and i.billing_approved_date >= po.start_date
      AND {% condition jobsite_filter %} UPPER(l.nickname) {% endcondition %}
      and {% condition po_filter %} po.name {% endcondition %}
      AND {% condition class_filter %} coalesce(cl.name, 'No Class Assigned') {% endcondition %}
      --and i.invoice_id = 1019734
    group by
      l.nickname,
      i.start_date,
      i.end_date,
      rla.start_date,
      case when rla.end_date is null then current_timestamp else rla.end_date end,
      date_part('epoch', i.end_date) - date_part('epoch',i.start_date),
      i.invoice_id,
      i.invoice_no,
      a.asset_list,
      po.name
    )
    , jobsite_info as (
    select
      jobsite,
      round((billed_amount/total_line_item_count),2) as billed_amount,
      invoice_start_date,
      invoice_end_date,
      rental_location_start_date,
      rental_location_end_date,
      invoice_seconds,
      invoice_id,
      invoice_no,
      asset_list,
      po_name
    from
        main_info
    )
    , jobsite_2 as (
    select
      *,
      case when rental_location_start_date < invoice_start_date and (rental_location_end_date between invoice_start_date and invoice_end_date) then (date_part('epoch',rental_location_end_date) - date_part('epoch',invoice_start_date))
         when rental_location_start_date < invoice_start_date and rental_location_end_date > invoice_end_date then (date_part('epoch',invoice_end_date) - date_part('epoch',invoice_start_date))
         when (rental_location_start_date between invoice_start_date and invoice_end_date) and (rental_location_end_date between invoice_start_date and invoice_end_date) then (date_part('epoch',rental_location_end_date) -  date_part('epoch',rental_location_start_date))
         when (rental_location_start_date between invoice_start_date and invoice_end_date) and rental_location_end_date > invoice_end_date then (date_part('epoch',invoice_end_date) - date_part('epoch',rental_location_start_date))
         else 0 end as overlap_secs
      from
        jobsite_info
    )
    , jobsite_3 as (
    select
      jobsite,
      invoice_id,
      invoice_no,
      invoice_start_date,
      invoice_end_date,
      asset_list,
      po_name,
      max(case when invoice_seconds = 0 and overlap_secs = 0 then round(billed_amount * 1.00::numeric,2)
      else round(billed_amount * (overlap_secs/ invoice_seconds)::numeric,2) end) as billed_amount
    from
        jobsite_2
    group by
        jobsite,
      invoice_id,
      invoice_no,
      invoice_start_date,
      invoice_end_date,
      asset_list,
      po_name
    ),
    class as (
    select
    case when cl.name is null then 'No Class Assigned' else cl.name end as class,
    i.invoice_id,
    i.invoice_no,
    i.start_date as invoice_start_date,
    i.end_date as invoice_end_date,
    a.asset_list,
    cl.equipment_class_id,
    po.name as po_name,
    sum(coalesce(li.total,0)) as amount, --sum(coalesce(li.amount,0)) as amount,
    max(coalesce(li.tax,0)) as tax, --max(coalesce(li.tax_amount,0)) as tax,
    count(*) as total_line_items
    from
      orders o
      join rentals r on o.order_id = r.order_id
      join global_line_items li on r.rental_id = li.rental_id
      join global_invoices i on li.invoice_id = i.invoice_id
      --join es_warehouse_stage.public.global_invoices i on li.invoice_id = i.invoice_id
      join users u on o.user_id = u.user_id
      left join equipment_classes cl on r.equipment_class_id = cl.equipment_class_id
      left join (select li.invoice_id, a.equipment_class_id, listagg(a.custom_name, ', ') as asset_list from global_line_items li join assets_aggregate a on li.asset_id = a.asset_id group by li.invoice_id, a.equipment_class_id) a on a.invoice_id = i.invoice_id and a.equipment_class_id = cl.equipment_class_id
      join purchase_orders po on i.purchase_order_id = po.purchase_order_id
      left join rental_location_assignments rla on r.rental_id = rla.rental_id
      left join locations l on rla.location_id = l.location_id
    where u.company_id = {{ _user_attributes['company_id'] }}::integer
    and i.billing_approved_date between CONVERT_TIMEZONE('{{ _user_attributes['user_timezone'] }}','UTC', {% date_start date_filter %}) and CONVERT_TIMEZONE('{{ _user_attributes['user_timezone'] }}','UTC',{% date_end date_filter %})
    and i.billing_approved_date >= po.start_date
    AND {% condition jobsite_filter %} UPPER(l.nickname) {% endcondition %}
    and {% condition po_filter %} po.name {% endcondition %}
    AND {% condition class_filter %} coalesce(cl.name, 'No Class Assigned') {% endcondition %}
    group by
        case when cl.name is null then 'No Class Assigned' else cl.name end,
        i.invoice_id,
        i.invoice_no,
        i.start_date,
        i.end_date,
        a.asset_list,
        cl.equipment_class_id,
        po.name
    ),
    total_assets_on_invoices as (
    select
        invoice_id,
        sum(total_line_items) as total_assets_on_invoice
    from
        class
    group by
        invoice_id
    ),
    class_invoice_break as (
    select
      class,
      c.invoice_id,
      invoice_no,
      invoice_start_date,
      invoice_end_date,
      asset_list,
      po_name,
      amount,
      tax,
      total_assets_on_invoice,
      total_line_items,
      round(amount+((tax/total_assets_on_invoice)*total_line_items),2) as billed_amount
    from
        class c
        left join total_assets_on_invoices ai on c.invoice_id = ai.invoice_id
    ),
    total_invoice_amount as (
    select
        i.invoice_id,
        i.billed_amount as actual_invoice_amount
    from
        ES_WAREHOUSE.PUBLIC.GLOBAL_INVOICES i
        JOIN ES_WAREHOUSE.PUBLIC.PURCHASE_ORDERS po ON i.purchase_order_id = po.purchase_order_id
        left join ES_WAREHOUSE.PUBLIC.users u on i.ordered_by_user_id = u.user_id
    where
       billing_approved_date between CONVERT_TIMEZONE('{{ _user_attributes['user_timezone'] }}','UTC', {% date_start date_filter %}) and CONVERT_TIMEZONE('{{ _user_attributes['user_timezone'] }}','UTC',{% date_end date_filter %})
       and u.company_id = {{ _user_attributes['company_id'] }}::integer
       and i.billing_approved_date >= po.start_date
    ),
    class_invoice_sum as (
    select
        invoice_id,
        sum(billed_amount) as billed_amount
    from
        class_invoice_break cib
    group by
        invoice_id
    ),
    possible_remaining_invoice_balance as (
    select
        cis.invoice_id,
        (actual_invoice_amount - billed_amount) remaining_balance
    from
        class_invoice_sum cis
        join total_invoice_amount tia on cis.invoice_id = tia.invoice_id
    )
    , class_info as (
    select
        class,
        cib.invoice_id,
        invoice_no,
        invoice_start_date,
        invoice_end_date,
        asset_list,
        po_name,
        case when remaining_balance = 0 then billed_amount else ((remaining_balance/(total_assets_on_invoice/total_line_items))+billed_amount) end as billed_amount
    from
        class_invoice_break cib
        left join possible_remaining_invoice_balance prb on cib.invoice_id = prb.invoice_id
    ),
   po_info as (
    SELECT
        case when po.active = true then coalesce(po.name, 'No PO') else concat(coalesce(po.name, 'No PO'), ' - NA') end as po,
        i.invoice_id,
        i.invoice_no,
        i.start_date as invoice_start_date,
        i.end_date as invoice_end_date,
        a.asset_list,
        po.name as po_name,
        coalesce(i.billed_amount,0) as billed_amount
      FROM
        ES_WAREHOUSE.PUBLIC.GLOBAL_INVOICES i
        JOIN es_warehouse.public.PURCHASE_ORDERS po ON i.purchase_order_id = po.purchase_order_id
        left join es_warehouse.public.users u on i.ordered_by_user_id = u.user_id
        left join (select li.invoice_id, listagg(a.custom_name, ', ') as asset_list from global_line_items li join assets a on li.asset_id = a.asset_id group by li.invoice_id) a on a.invoice_id = i.invoice_id
      WHERE
          u.company_id = {{ _user_attributes['company_id'] }}::integer
          and i.billing_approved_date >= po.start_date
          and i.billing_approved_date between
            convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC', {% date_start date_filter %}) AND
            convert_timezone('{{ _user_attributes['user_timezone'] }}','UTC', {% date_end date_filter %})
          and po.company_id = {{ _user_attributes['company_id'] }}::integer
    ),
    budget_by_total_invoice as (
    SELECT
      i.BILLING_APPROVED_DATE::date as invoice_approved_date,
      po.name as po_name,
      po.budget_amount,
      sum(i.billed_amount) as total_billed_amount
    FROM
      ES_WAREHOUSE.PUBLIC.GLOBAL_INVOICES i
      JOIN es_warehouse.public.PURCHASE_ORDERS po ON i.purchase_order_id = po.purchase_order_id
      left join es_warehouse.public.users u on i.ordered_by_user_id = u.user_id
    WHERE
        u.company_id = {{ _user_attributes['company_id'] }}::integer
        and i.billing_approved_date >= po.start_date
    GROUP BY
        i.BILLING_APPROVED_DATE::date,
        po.name,
        po.budget_amount
    ),
    remaining_budget_by_invoice as (
    select
        invoice_approved_date,
        po_name,
        budget_amount,
        sum(total_billed_amount) over (partition by po_name order by invoice_approved_date rows between unbounded preceding and current row) as cumulative_amount,
        budget_amount - cumulative_amount as remaining_budget
    from
        budget_by_total_invoice
    union
    select
        min(po.start_date)::date as min_start_date,
        po.name as po_name,
        po.budget_amount,
        0,
        po.budget_amount as remaining_budget
    FROM
        ES_WAREHOUSE.PUBLIC.GLOBAL_INVOICES i
        JOIN ES_WAREHOUSE.PUBLIC.PURCHASE_ORDERS po ON i.purchase_order_id = po.purchase_order_id
        left join ES_WAREHOUSE.PUBLIC.users u on i.ordered_by_user_id = u.user_id
    where
        u.company_id = {{ _user_attributes['company_id'] }}::integer
    group by
        po.name,
        po.budget_amount
    )
    , invoice_info as (
    select
        invoice_approved_date,
        po_name,
        coalesce(budget_amount,0) as budget_amount,
        cumulative_amount,
        coalesce(remaining_budget,0) as remaining_budget,
        ifnull(lead(invoice_approved_date) OVER (partition by po_name order by invoice_approved_date),current_date) as next_invoice
    from
        remaining_budget_by_invoice
    ),
    generate_series as (
    select * from table(generate_series(
    '2018-01-01'::timestamp_tz,
    current_date::timestamp_tz,
    'day')
    )
    ),
    by_day_budget_info as (
    select
        series::date as generated_date,
        po_name,
        budget_amount,
        remaining_budget,
        cumulative_amount,
        case when budget_amount > 0 then ((coalesce(budget_amount,0) - coalesce(cumulative_amount,0)) / coalesce(budget_amount,0)) else 0 end as pcnt_budget_remaining
    from
        generate_series gs
        join invoice_info ii on gs.series > invoice_approved_date and gs.series <= next_invoice
    ), budget_info as (
    select
        po_name,
        budget_amount,
        pcnt_budget_remaining
    from
        by_day_budget_info
    where
        generated_date = case when {% date_end date_filter %}::date > current_date then current_date else {% date_end date_filter %}::date end
    ),
    final_jobsite_table as (
    select
        'jobsite' as type,
        jobsite as parameter,
        invoice_id,
        invoice_no,
        invoice_start_date,
        invoice_end_date,
        asset_list,
        jo.po_name,
        billed_amount,
        budget_amount,
        pcnt_budget_remaining
    from
        jobsite_3 jo
        left join budget_info bi on jo.po_name = bi.po_name
    ),
    final_class_table as (
    select
        'class' as type,
        class as parameter,
        invoice_id,
        invoice_no,
        invoice_start_date,
        invoice_end_date,
        asset_list,
        ci.po_name,
        billed_amount,
        budget_amount,
        pcnt_budget_remaining
    from
        class_info ci
        left join budget_info bi on ci.po_name = bi.po_name
    )
    ,final_po_table as (
    select
        'po' as type,
        po as parameter,
        invoice_id,
        invoice_no,
        invoice_start_date,
        invoice_end_date,
        asset_list,
        po.po_name,
        billed_amount,
        budget_amount,
        pcnt_budget_remaining
    from
        po_info po
        left join budget_info bi on po.po_name = bi.po_name
    )
        {% if spend_by._parameter_value == "'Jobsite'" %}
        select * from final_jobsite_table
        {% elsif spend_by._parameter_value == "'Purchase Order'" %}
        select * from final_po_table
        {% else %}
        select * from final_class_table
        {%  endif %}
       ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: type_ {
    type: string
    sql: ${TABLE}."TYPE" ;;
  }

  dimension: parameter {
    type: string
    sql: ${TABLE}."PARAMETER" ;;
    label: "Selection"
    group_label: "Parameter"
  }

  dimension: invoice_id {
    type: number
    sql: ${TABLE}."INVOICE_ID" ;;
    value_format_name: id
  }

  dimension: invoice_no {
    type: string
    sql: ${TABLE}."INVOICE_NO" ;;
  }

  dimension_group: invoice_start_date {
    type: time
    sql: ${TABLE}."INVOICE_START_DATE" ;;
    label: "Invoice Start"
  }

  dimension_group: invoice_end_date {
    type: time
    sql: ${TABLE}."INVOICE_END_DATE" ;;
    label: "Invoice End"
  }

  dimension: asset_list {
    type: string
    sql: ${TABLE}."ASSET_LIST" ;;
  }

  # dimension: purchase_order_id {
  #   type: number
  #   sql: ${TABLE}."PURCHASE_ORDER_ID" ;;
  #   value_format_name: id
  # }

  dimension: po_name {
    type: string
    sql: ${TABLE}."PO_NAME" ;;
  }

  dimension: billed_amount {
    type: number
    sql: ${TABLE}."BILLED_AMOUNT" ;;
    value_format_name: usd
  }

  dimension: budget_amount {
    type: number
    sql: ${TABLE}."BUDGET_AMOUNT" ;;
    value_format_name: usd
  }

  # dimension: budget_remaining {
  #   type: number
  #   sql: ${TABLE}."BUDGET_REMAINING" ;;
  #   value_format_name: usd
  # }
  # Budget remaining now pulls from the budget_remaining_by_invoice view

  dimension: pcnt_budget_remaining {
    label: "% of Budget Remaining"
    type: number
    sql: ${TABLE}."PCNT_BUDGET_REMAINING" ;;
    value_format_name: percent_0
  }

  dimension: primary_key {
    primary_key: yes
    type: string
    sql: concat(${asset_list},${type_},${invoice_start_date_raw}) ;;
  }

  filter: date_filter {
    type: date_time
  }

  filter: jobsite_filter {
    type: string
  }

  filter: class_filter {
    type: string
  }

  filter: po_filter {
    type: string
  }

  measure: total_billed_amount {
    type: sum
    sql: ${billed_amount} ;;
    value_format_name: usd
  }

  measure: total_billed_amount_po {
    type: sum
    sql: ${billed_amount} ;;
    filters: [type_: "po"]
    value_format_name: usd
  }

  measure: total_billed_amount_job {
    type: sum
    sql: ${billed_amount} ;;
    filters: [type_: "jobsite"]
    value_format_name: usd
  }

  measure: total_billed_amount_class {
    type: sum
    sql: ${billed_amount} ;;
    filters: [type_: "class"]
    value_format_name: usd
  }

  parameter: spend_by {
    type: string
    allowed_value: { value: "Jobsite"}
    allowed_value: { value: "Purchase Order"}
    allowed_value: { value: "Class"}
  }

  dimension: dynamic_spend_by_selection {
    label_from_parameter: spend_by
    sql:{% if spend_by._parameter_value == "'Jobsite'" %}
      ${parameter}
    {% elsif spend_by._parameter_value == "'Purchase Order'" %}
      ${parameter}
    {% elsif spend_by._parameter_value == "'Class'" %}
      ${parameter}
    {% else %}
      NULL
    {% endif %} ;;
    # value_format_name: percent_1
    }

    measure: max_budget_remaining {
      type: max
      # sql: ${budget_remaining} ;;
      sql: case when ${budget_remaining_by_invoice.budget_remaining} < 0 then null else ${budget_remaining_by_invoice.budget_remaining} end ;;
      value_format_name: usd_0
    }

  measure: no_budget_remaining {
    type: max
    # sql: ${budget_remaining} ;;
    sql: case when ${budget_remaining_by_invoice.budget_remaining} >= 0 then null else ${budget_remaining_by_invoice.budget_remaining}*-1 end ;;
    value_format_name: usd_0
  }

  measure: dynamic_spend_by_selection_amount {
    label_from_parameter: spend_by
    view_label: "Total Spend"
    type: number
    value_format_name: usd
    sql:{% if spend_by._parameter_value == "'Jobsite'" %}
      ${total_billed_amount_job}
    {% elsif spend_by._parameter_value == "'Purchase Order'" %}
      ${total_billed_amount_po}
    {% elsif spend_by._parameter_value == "'Class'" %}
      ${total_billed_amount_class}
    {% else %}
      NULL
    {% endif %} ;;
    drill_fields: [rental_spend_by*]
    }

  measure: budget_amount_percentage {
    type: max
    sql: ${pcnt_budget_remaining} ;;
    value_format_name: percent_0
  }

  measure: total_budget_amount {
    type: max
    sql: ${budget_amount} ;;
  }

  dimension: max_date {
    type: date
    sql: case when {% date_end date_filter %}::date > current_date then current_date else {% date_end date_filter %}::date end ;;
    html: {{ rendered_value | date: "%b %d, %Y"  }};;
    skip_drill_filter: yes
  }

  measure: dynamic_budget_amount {
    label_from_parameter: spend_by
    view_label: "Budget Amount"
    type: number
    value_format_name: usd_0
    sql:{% if spend_by._parameter_value == "'Purchase Order'" %}
      ${total_budget_amount}
    {% else %}
      NULL
    {% endif %} ;;
    html: {{rendered_value}} (Budget % Remaining: {{budget_amount_percentage._rendered_value}} as of {{max_date._rendered_value | date: "%b %d, %Y" }}  ) ;;
    # drill_fields: [detail*]
  }

  measure: dynamic_budget_percent_remaining {
    label_from_parameter: spend_by
    view_label: "Budget Remaining"
    type: number
    value_format_name: usd_0
    sql:{% if spend_by._parameter_value == "'Purchase Order'" %}
      ${max_budget_remaining}
    {% else %}
      NULL
    {% endif %} ;;
    drill_fields: [rental_spend_by*]
  }

  measure: dynamic_no_budget_remaining {
    label_from_parameter: spend_by
    view_label: "No Budget Remaining"
    type: number
    value_format_name: usd_0
    sql:{% if spend_by._parameter_value == "'Purchase Order'" %}
      ${no_budget_remaining}
    {% else %}
      NULL
    {% endif %} ;;
    drill_fields: [rental_spend_by*]
  }

  dimension: user_input_start_date {
    type: date
    sql: {% date_start date_filter %} ;;
  }

  dimension: user_input_end_date {
    type: date
    sql: {% date_end date_filter %} ;;
  }


  dimension: view_invoices_table {
    group_label: "Links to Invoice"
    label: "Invoice No"
    type: string
    sql: ${invoice_id} ;;
    # html: <font color="blue "><u><a href="https://app.estrack.com/#/rentals/invoices?status=all&start={{ user_input_start_date._value | date: "%m-%d-%Y"}}&end={{ user_input_end_date._value | date: "%m-%d-%Y"}}" target="_blank">View Invoices Summary</a></font></u> ;;
    html:
    {% if user_is_america_timezone._value == "Yes" %}
    <font color="#0063f3"><u><a href="https://app.estrack.com/#/billing/{{invoice_id._value}}" target="_blank">{{invoice_no._value}}</a></font></u>
    {% else %}
    {{invoice_no._value}}
    {% endif %}
    ;;
  }

  dimension: user_is_america_timezone {
    type: yesno
    sql: substr('{{ _user_attributes['user_timezone'] }}',0,7) = 'America' ;;
  }

  set: rental_spend_by {
    fields: [parameter, view_invoices_table, invoice_start_date_date, invoice_end_date_date, asset_list, budget_remaining_by_invoice.po_name, budget_amount, budget_remaining_by_invoice.budget_remaining, budget_remaining_by_invoice.pcnt_budget_remaining, total_billed_amount]
  }

  set: detail {
    fields: [
      type_,
      parameter,
      invoice_no,
      invoice_start_date_time,
      invoice_end_date_time,
      asset_list,
      po_name,
      billed_amount,
      budget_amount,
      pcnt_budget_remaining
    ]
  }
}
