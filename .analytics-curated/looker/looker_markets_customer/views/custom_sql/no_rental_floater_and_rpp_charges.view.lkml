view: no_rental_floater_and_rpp_charges {
  derived_table: {
    # datagroup_trigger: Every_Two_Hours_Update
    sql: with expired_floater as (
        select
          cd.company_id,
          c.name,
          cd.valid_from,
          cd.valid_until,
          RANK() OVER(
            partition by cd.company_id order by valid_until, valid_from desc) as most_recent_document,
          case when convert_timezone('America/Chicago',valid_until) >= current_timestamp() then 1 else 0 end as expired_past_today
        from
          ES_WAREHOUSE.PUBLIC.company_documents cd
          left join ES_WAREHOUSE.PUBLIC.companies c on cd.company_id = c.company_id
        where
           cd.company_document_type_id = 1
          and cd.voided = false
         ),
         expired_floater_date as (
         select
         company_id,
         name,
         valid_from,
         valid_until,
         expired_past_today
         from
         expired_floater
        where
          most_recent_document = 1
          and expired_past_today = 0
        ),
        rpp_charge as (
         select
           c.name,
           c.company_id,
           sum(li.amount) as rpp_charged_amount,
           max(i.date_created) last_invoice_created_date
         from
            ES_WAREHOUSE.PUBLIC.orders o
            left join ES_WAREHOUSE.PUBLIC.invoices i on i.order_id = o.order_id
            left join ANALYTICS.PUBLIC.v_line_items li on li.invoice_id = i.invoice_id
            left join ES_WAREHOUSE.PUBLIC.users u on u.user_id = o.user_id
            left join ES_WAREHOUSE.PUBLIC.companies c on c.company_id = u.company_id
            left join expired_floater_date ef on ef.company_id = c.company_id
         where
            li.line_item_type_id = 9
            and i.date_created::DATE >= ef.valid_until::DATE
         group by
            c.name,
            c.company_id
         )
         select
           ef.company_id,
           ef.name,
           ef.valid_from,
           ef.valid_until,
           case when ef.expired_past_today = 0 then 'Yes' else 'No' end as expiration_date_past_today,
           rc.rpp_charged_amount,
           rc.last_invoice_created_date
         from
           expired_floater_date ef
           inner join rpp_charge rc on ef.company_id = rc.company_id
       ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: company_id {
    type: number
    sql: ${TABLE}."COMPANY_ID" ;;
    value_format_name: id
  }

  dimension: name {
    type: string
    sql: ${TABLE}."NAME" ;;
    link: {
      label: "View Customer Information Dashboard"
      url: "https://equipmentshare.looker.com/dashboards/28?Company%20Name={{ name._filterable_value | url_encode }}&Company%20ID="
    }
  }

  dimension_group: valid_from {
    type: time
    sql: ${TABLE}."VALID_FROM" ;;
  }

  dimension_group: valid_until {
    type: time
    sql: ${TABLE}."VALID_UNTIL" ;;
  }

  dimension: expiration_date_past_today {
    type: string
    sql: ${TABLE}."EXPIRATION_DATE_PAST_TODAY" ;;
  }

  dimension: rpp_charged_amount {
    type: number
    sql: ${TABLE}."RPP_CHARGED_AMOUNT" ;;
  }

  dimension_group: last_invoice_created_date {
    type: time
    sql: ${TABLE}."LAST_INVOICE_CREATED_DATE" ;;
  }

  set: detail {
    fields: [
      company_id,
      name,
      valid_from_time,
      valid_until_time,
      expiration_date_past_today,
      rpp_charged_amount,
      last_invoice_created_date_time
    ]
  }
}
