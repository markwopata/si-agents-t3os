view: cod_outstanding_action_items {
  derived_table: {
    sql:
    with current_inside_collections as (
        select *

        from analytics.bi_ops.collectors_inside_collections
        qualify row_number() over(partition by company_id order by assignment_timestamp desc) = 1
    ),

    legal_flag as (select company_id, true as legal_flag
    from current_inside_collections ic
    join analytics.bi_ops.collectors c on ic.collector_id = c.collector_id
    where c.entity = 'Legal')

    select
            mrx.region_name,
            mrx.district,
            mrx.market_name,
            i.invoice_date,
            c.name as company_name,
            concat(u.first_name, ' ', u.last_name) as full_name,
            i.invoice_no,
            i.invoice_id,
            coalesce(lf.legal_flag, false) legal_flag,
            c.do_not_rent,
            sum(i.owed_amount) as amount
        from es_warehouse.public.orders o
        left join es_warehouse.public.invoices i
        on o.order_id = i.order_id
        left join analytics.public.market_region_xwalk mrx
        on o.market_id = mrx.market_id
        left join es_warehouse.public.companies c
        on o.company_id = c.company_id
      --  left join es_warehouse.public.net_terms n
      --  on c.net_terms_id = n.net_terms_id
        left join es_warehouse.public.order_salespersons os
        on o.order_id = os.order_id
        left join es_warehouse.public.users u
        on os.user_id = u.user_id
        left join legal_flag lf
        on o.company_id = lf.company_id
        where c.net_terms_id = 1 --n.name = 'Cash on Delivery'
        and os.salesperson_type_id = 1
        and i.invoice_id in (
            select
                distinct(i.invoice_id)
            from es_warehouse.public.invoices i
            left join es_warehouse.public.line_items l
            on i.invoice_id = l.invoice_id
            where paid = 'No'
            and billing_approved = 'Yes'
          --  and i.invoice_date::date < dateadd(days, -30, current_date)
           and i.invoice_date::date < current_date
            and l.line_item_type_id in (6, 8, 108, 109)
        )
        group by 1,2,3,4,5,6,7,8,9,10
      ;;
  }

  measure: count {
    type: count
  }
  dimension: do_not_rent {
    type: yesno
    sql: ${TABLE}."DO_NOT_RENT" ;;
  }

  dimension: market {
    type: string
    sql: ${TABLE}."MARKET_NAME" ;;
  }

  dimension: region {
    type: string
    sql: ${TABLE}."REGION_NAME" ;;
  }

  dimension: district {
    type: string
    sql: ${TABLE}."DISTRICT" ;;
  }

  dimension: company_name {
    type: string
    sql: ${TABLE}."COMPANY_NAME" ;;
  }

  dimension: full_name {
    type: string
    sql: ${TABLE}."FULL_NAME" ;;
  }

  dimension: invoice_no {
    type: string
    sql: ${TABLE}."INVOICE_NO" ;;
  }

  dimension: invoice_no_link {
    label: "Invoice No"
    type: string
    sql: ${invoice_no} ;;
    html: <a href="https://admin.equipmentshare.com/#/home/transactions/invoices/{{invoice_id._value}}--invoice id" style="color:#0063f3;" target="_blank">{{rendered_value}} ➔</a> ;;
  }

  dimension: invoice_id {
    type: string
    sql: ${TABLE}."INVOICE_ID" ;;
  }

  dimension: invoice_total_amount {
    type: string
    sql: ${TABLE}."AMOUNT" ;;
    value_format_name: usd_0
  }

  dimension: invoice_date {
    type: date
    sql: ${TABLE}."INVOICE_DATE" ;;
    html: {{ rendered_value | date: "%b %d, %Y" }};;
  }

  dimension: legal_flag {
    type: yesno
    sql: ${TABLE}."LEGAL_FLAG" ;;
  }

  # dimension: invoice_link {
  #   type: string
  #   sql: ${request_id} ;;
  #   html: <a href="https://api.equipmentshare.com/skunkworks/invoices/request-image/{{ rendered_value }}/?redirect=1" style="color: blue;" target="_blank">Invoice PDF</a> ;;
  # }

  # dimension: invoice_number {
  #   type: string
  #   sql: ${TABLE}."INVOICE_NUMBER" ;;
  #   html: <a href="https://api.equipmentshare.com/skunkworks/invoices/request-image/{{ request_id._value }}/?redirect=1" style="color: blue;" target="_blank">{{ value }}</a> ;;
  # }

}
