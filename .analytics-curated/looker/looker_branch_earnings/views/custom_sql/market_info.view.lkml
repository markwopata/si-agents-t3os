# Primary use: Give Kinzie and team access to see parent/child markets, start dates, and first invoice data.

view: market_info {
  # Or, you could make this view a derived table, like this:
  derived_table: {
    sql: select m.child_market_id,
               m.child_market_name,
               m.market_id,
               m.market_name,
               m.state,
               m.abbreviation,
               m.region,
               m.region_name,
               m.area_code,
               m.district,
               m.region_district,
               m._id_dist,
               m.market_type_id,
               m.market_type,
               m.is_dealership,
               m.date_updated,
               m.branch_earnings_start_month,
               m.market_start_month,
               m.general_manager_employee_id,
               m.general_manager_name,
               m.general_manager_title,
               m.general_manager_url_greenhouse,
               m.general_manager_disc_code,
               m.general_manager_environment_style,
               m.general_manager_url_disc,
               min(i.billing_approved_date) first_invoice_date
        from analytics.branch_earnings.market m
                 left join es_warehouse.public.invoices i
                           on m.market_id = i.ship_from:branch_id
                 left join analytics.public.es_companies ec
                           on i.company_id = ec.company_id
        where (i.invoice_id is null or ec.company_id is null)
        group by all
      ;;
  }

  # Define your dimensions and measures here, like this:
  dimension: child_market_id {
    type: number
    value_format_name: id
    sql: ${TABLE}.child_market_id ;;
  }

  dimension: child_market_name {
    type: string
    sql: ${TABLE}.child_market_name ;;
  }

  dimension: market_id {
    type: number
    value_format_name: id
    sql: ${TABLE}.market_id ;;
  }

  dimension: market_name {
    type: string
    sql: ${TABLE}.market_name ;;
  }

  dimension: state {
    type: string
    sql: ${TABLE}.state ;;
  }

  dimension: abbreviation {
    type: string
    sql: ${TABLE}.abbreviation ;;
  }

  dimension: region {
    type: number
    value_format_name: id
    sql: ${TABLE}.region ;;
  }

  dimension: region_name {
    type: string
    sql: ${TABLE}.region_name ;;
  }

  dimension: area_code {
    type: string
    sql: ${TABLE}.area_code ;;
  }

  dimension: district {
    type: string
    sql: ${TABLE}.district ;;
  }

  dimension: region_district {
    type: string
    sql: ${TABLE}.region_district ;;
  }

  dimension: id_dist {
    type: number
    value_format_name: id
    sql: ${TABLE}._id_dist ;;
  }

  dimension: market_type_id {
    type: number
    value_format_name: id
    sql: ${TABLE}.market_type_id ;;
  }

  dimension: market_type {
    type: string
    sql: ${TABLE}.market_type ;;
  }

  dimension: is_dealership {
    type: yesno
    sql: ${TABLE}.is_dealership ;;
  }

  dimension: date_updated {
    type: date
    sql: ${TABLE}.date_updated ;;
  }

  dimension: branch_earnings_start_month {
    type: date
    sql: ${TABLE}.branch_earnings_start_month ;;
  }

  dimension: market_start_month {
    type: date
    sql: ${TABLE}.market_start_month ;;
  }

  dimension: general_manager_employee_id {
    type: number
    value_format_name: id
    sql: ${TABLE}.general_manager_employee_id ;;
  }

  dimension: general_manager_name {
    type: string
    sql: ${TABLE}.general_manager_name ;;
  }

  dimension: general_manager_title {
    type: string
    sql: ${TABLE}.general_manager_title ;;
  }

  dimension: general_manager_url_greenhouse {
    type: string
    sql: ${TABLE}.general_manager_url_greenhouse ;;
  }

  dimension: general_manager_disc_code {
    type: string
    sql: ${TABLE}.general_manager_disc_code ;;
  }

  dimension: general_manager_environment_style {
    type: string
    sql: ${TABLE}.general_manager_environment_style ;;
  }

  dimension: general_manager_url_disc {
    type: string
    sql: ${TABLE}.general_manager_url_disc ;;
  }

  dimension: first_invoice_date {
    type: date
    sql: ${TABLE}.first_invoice_date ;;
  }

}
