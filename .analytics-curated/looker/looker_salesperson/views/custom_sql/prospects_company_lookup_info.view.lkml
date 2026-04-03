view: company_look_up_info {
  derived_table: {
    # datagroup_trigger: Every_Hour_Update
    sql: with invoices_info as (
              SELECT
                u.company_id,
                c.name,
                o.salesperson_user_id,
                u2.first_name,
                u2.last_name,
                sum(i.line_item_amount) as total_spend,
                max(i.start_date::DATE) as latest_invoice_date
              FROM
                ES_WAREHOUSE.PUBLIC.orders o
                join ES_WAREHOUSE.PUBLIC.users u on o.user_id = u.user_id
                join ES_WAREHOUSE.PUBLIC.companies c on u.company_id = c.company_id
                join ES_WAREHOUSE.PUBLIC.users u2 on o.salesperson_user_id = u2.user_id
                join ES_WAREHOUSE.PUBLIC.invoices i on o.order_id = i.order_id
              WHERE
                i.invoice_date > (current_date - INTERVAL '12 months')
                AND u.company_id is not null
                AND o.salesperson_user_id is not null
              GROUP BY
                u.company_id,
                c.name,
                o.salesperson_user_id,
                u.company_id,
                u2.first_name,
                u2.last_name
              ),
              rank_last_invoice as (
              select
                *,
                row_number ()
                over (
                partition by
                  company_id
                order by
                  latest_invoice_date desc
                ) rank_number
              from
                invoices_info
              where
                total_spend > 0
              order by
                company_id
              ),
              sales_rep_rank_one as (
              select
                company_id,
                case when rank_number = 1 then concat(first_name,' ',last_name) end as sales_rep_rank_one
              from
                rank_last_invoice
              where
                rank_number = 1
              ),
              sales_rep_rank_two as (
              select
                company_id,
                case when rank_number = 2 then concat(first_name,' ',last_name) end as sales_rep_rank_two
              from
                rank_last_invoice
              where
                rank_number = 2
              ),
              sales_rep_rank_three as (
              select
                company_id,
                case when rank_number = 3 then concat(first_name,' ',last_name) end as sales_rep_rank_three
              from
                rank_last_invoice
              where
                rank_number = 3
              ),
              company_sales_rep_ranking as (
              select
                ro.company_id,
                sales_rep_rank_one,
                sales_rep_rank_two,
                sales_rep_rank_three
              from
                sales_rep_rank_one ro
                left join sales_rep_rank_two rw on ro.company_id = rw.company_id
                left join sales_rep_rank_three rt on ro.company_id = rt.company_id
              )
              select
        c.name,
        c.company_id,
        concat(l.street_1,' ',l.street_2) as street_address,
        l.city,
        s.abbreviation,
                cr.sales_rep_rank_one,
                cr.sales_rep_rank_two,
                cr.sales_rep_rank_three
      from
        ES_WAREHOUSE.PUBLIC.companies c
        left join ES_WAREHOUSE.PUBLIC.locations l on c.billing_location_id = l.location_id
        left join ES_WAREHOUSE.PUBLIC.states s on s.state_id = l.state_id
        left join company_sales_rep_ranking cr on cr.company_id = c.company_id
      where
        c.timezone not like '%Auckland%'
 ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: name {
    type: string
    sql: TRIM(${TABLE}."NAME") ;;
    link: {
      label: "View Customer Information Dashboard"
      url: "https://equipmentshare.looker.com/dashboards/28?Company%20Name={{ name._filterable_value | url_encode }}&Company%20ID="
    }
  }

  dimension: company_id {
    type: number
    sql: ${TABLE}."COMPANY_ID" ;;
  }

  dimension: street_address {
    type: string
    sql: ${TABLE}."STREET_ADDRESS" ;;
  }

  dimension: city {
    type: string
    sql: ${TABLE}."CITY" ;;
  }

  dimension: abbreviation {
    type: string
    sql: ${TABLE}."ABBREVIATION" ;;
  }

  dimension: sales_rep_rank_one {
    type: string
    sql: ${TABLE}."SALES_REP_RANK_ONE" ;;
  }

  dimension: sales_rep_rank_two {
    type: string
    sql: ${TABLE}."SALES_REP_RANK_TWO" ;;
  }

  dimension: sales_rep_rank_three {
    type: string
    sql: ${TABLE}."SALES_REP_RANK_THREE" ;;
  }

  dimension: city_state {
    type: string
    sql: concat(${city},', ',${abbreviation}) ;;
  }

  set: detail {
    fields: [
      name,
      company_id,
      street_address,
      city,
      abbreviation,
      sales_rep_rank_one,
      sales_rep_rank_two,
      sales_rep_rank_three
    ]
  }

  dimension: create_note {
    type: string
    html:
    <font color="blue "><u><a href = "https://staging-ba.equipmentshare.com/crm/existing_customer_note?Company%20ID={{ company_id._value | url_encode }}&Company%20Name={{ name._value | url_encode }}" target="_blank">Create Note</a></font></u>;;
    sql: ${TABLE}.company_id  ;;}

  dimension: quote_templates {
    type: string
    html:
    <font color="blue "><u><a href = "https://staging-ba.equipmentshare.com/crm/existing_customer_quote_templates?Company%20ID={{ company_id._value | url_encode }}&Company%20Name={{ name._value | url_encode }}" target="_blank">Create Quote</a></font></u>;;
    sql: ${TABLE}.company_id  ;;}

  dimension:view_notes {
    type: string
    html:
    <font color="blue "><u><a href = "https://equipmentshare.looker.com/dashboards/235?Company%20ID={{ company_id._value | url_encode }}&Company%20Name={{ name._value | url_encode }}" target="_blank">View Notes</a></font></u>;;
    sql: ${TABLE}.company_id  ;;}



}
