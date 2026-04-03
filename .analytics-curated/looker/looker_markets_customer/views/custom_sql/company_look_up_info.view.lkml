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
                sum(li.amount) as total_spend,
                max(i.start_date::DATE) as latest_invoice_date
              FROM
                ES_WAREHOUSE.PUBLIC.orders o
                join ES_WAREHOUSE.PUBLIC.users u on o.user_id = u.user_id
                join ES_WAREHOUSE.PUBLIC.companies c on u.company_id = c.company_id
                join ES_WAREHOUSE.PUBLIC.users u2 on o.salesperson_user_id = u2.user_id
                join ES_WAREHOUSE.PUBLIC.invoices i on o.order_id = i.order_id
                join ANALYTICS.PUBLIC.v_line_items li on i.invoice_id = li.invoice_id
              WHERE
                li.gl_date_created > (current_date - INTERVAL '12 months')
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
        s.name as state_name,
        l.city,
        l.STREET_1,
        l.STREET_2,
        s.abbreviation,
                cr.sales_rep_rank_one,
                cr.sales_rep_rank_two,
                cr.sales_rep_rank_three,
        c.has_msa
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
    sql: TRIM(REPLACE(${TABLE}."NAME",CHAR(9), '')) ;;
    html:
   <font color="blue "><u><a href = "https://equipmentshare.looker.com/dashboards/28?Company%20Name={{ name._filterable_value | url_encode }}&Company%20ID={{ company_id._filterable_value | url_encode }}" target="_blank">{{ name._filterable_value }}</a></font></u> ;;
  }

  dimension: company_id {
    type: number
    sql: ${TABLE}."COMPANY_ID" ;;
  }

  dimension: street_address {
    type: string
    sql:  CASE
              WHEN ${TABLE}."STREET_1" IS NULL THEN 'No address on file'
              ELSE coalesce( ${TABLE}."STREET_1", '')
                   || coalesce( ${TABLE}."STREET_2", '')
                   || ', ' || coalesce( ${TABLE}."CITY", '')
                   || ', ' || coalesce( ${state}, '')
          END ;;
  }

  dimension: state {
    type: string
    sql: ${TABLE}."STATE_NAME" ;;
  }

  dimension: city {
    type: string
    sql: ${TABLE}."CITY" ;;
  }

  dimension: abbreviation {
    label: "State"
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

  dimension: has_msa {
    type: yesno
    sql: ${TABLE}."HAS_MSA" ;;
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

  dimension: navbar_crm {
    html: <p align="center">
      <a href="https://equipmentshare.looker.com/dashboards/232" >
      <img border="0" alt="altText" src="https://img.icons8.com/pastel-glyph/64/000000/warehouse.png"
      height="55" width="60">
      </a>
      </p>
      <p align="center"> <i>
      <font size = "2">
      PROSPECTS & EXISTING CUSTOMERS
      </f>
      </i></p>
      <p align="center">
      <a href="https://equipmentshare.looker.com/dashboards/226" >
      <img border="0" alt="altText" src="https://cdn2.iconfinder.com/data/icons/gconstruct/2118/gconstruct1-18.png"
      height="55" width="60">
      </a>
      </p>
      <p align="center"> <i>
      <font size = "2">
      DODGE PROJECTS
      </f>
      </i></p>
      <p align="center">
      <a href="https://staging-ba.equipmentshare.com/crm/create_prospect" >
      <img border="0" alt="altText" src="https://img.icons8.com/ios/50/000000/keypad.png"
      height="55" width="60">
      </a>
      </p>
      <p align="center"> <i>
      <font size = "2">
      CREATE PROSPECT
      </f>
      </i></p>
      <p align="center">
      <a href="https://equipmentshare.looker.com/dashboards/206" >
      <img border="0" alt="altText" src="https://img.icons8.com/carbon-copy/100/000000/purchase-order.png"
      height="55" width="60">
      </a>
      </p>
      <p align="center"> <i>
      <font size = "2">
      VIEW PROSPECTS
      </f>
      </i></p>
      <p align="center">
      <a href="https://equipmentshare.looker.com/dashboards/229" >
      <img border="0" alt="altText" src="https://img.icons8.com/material-two-tone/24/000000/wireless-cloud-access.png"
      height="55" width="60">
      </a>
      </p>
      <p align="center"> <i>
      <font size = "2">
      PROSPECT ACTIONS
      </f>
      </i></p>
      <p align="center">
      <a href="https://equipmentshare.looker.com/dashboards/229" >
      <img border="0" alt="altText" src="https://img.icons8.com/wired/64/000000/purchase-order.png"
      height="55" width="60">
      </a>
      </p>
      <p align="center"> <i>
      <font size = "2">
      EXISTING CUSTOMER LOOKUP
      </f>
      </i></p>
      <p align="center">
      <a href="https://equipmentshare.looker.com/dashboards/273" >
      <img border="0" alt="altText" src="https://img.icons8.com/carbon-copy/100/000000/calendar.png"
      height="55" width="60">
      </a>
      </p>
      <p align="center"> <i>
      <font size = "2">
      EXISTING CUSTOMER ACTIONS
      </f>
      </i></p>
      <p align="center">
      <a href="https://equipmentshare.looker.com/dashboards/234" >
      <img border="0" alt="altText" src="https://img.icons8.com/windows/32/000000/help.png"
      height="55" width="60">
      </a>
      </p>
      <p align="center"> <i>
      <font size = "2">
      HELP
      </f>
      </i></p>
      ;;
    sql: ${TABLE}."COMPANY_ID" ;;
  }
}
