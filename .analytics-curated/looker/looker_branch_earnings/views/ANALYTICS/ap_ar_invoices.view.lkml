view: ap_ar_invoices {
  derived_table: {
    sql:
    with ap_invoices as (select ap.invoice_date,
                                ap.invoice_number,
                                ap.amount,
                                ap.account_number,
                                ap.account_name,
                                ap.vendor_id                      as business_id, --naming convention to use for AR and AP when customer and vendors will show in same column.
                                ap.vendor_name                    as business_name,
                                ap.department_id,
                                ap.department_name,
                                ap.invoice_state,
                                ap.line_description,
                                ap.url_concur                     as invoice_url,
                                ap.line_description ilike '%tax%' as tax_line,
                                s.name                            as state,
                                s.abbreviation                    as state_abbreviation,
                                ap.URL_INVOICE                    as sage_url,
                                'AP'                              as invoice_type
                         from analytics.intacct_models.AP_DETAIL ap
                                  left join es_warehouse.public.markets m on m.market_id::varchar = ap.department_id
                                  left join es_warehouse.public.locations l on m.location_id = l.location_id
                                  left join es_warehouse.public.states s on s.state_id = l.state_id
                         where invoice_date >= '2023-01-01' and invoice_date <= '2030-01-01'
                                  ),


      ar_invoices as (select ar.invoice_date,
      ar.invoice_number,
      ar.amount,
      ar.account_number,
      ar.account_name,
      ar.customer_id                    as business_id,
      ar.customer_name                  as business_name,
      ar.department_id,
      ar.department_name,
      ar.invoice_state,
      ar.line_description,
      ar.url_admin                      as invoice_url,
      ar.line_description ilike '%tax%' as tax_line,
      s.name                            as state,
      s.abbreviation                    as state_abbreviation,
      ar.URL_INVOICE                    as sage_url,
      'AR'                              as invoice_type
      from analytics.intacct_models.AR_DETAIL ar
      left join es_warehouse.public.markets m on m.market_id::varchar = ar.department_id
      left join es_warehouse.public.locations l on m.location_id = l.location_id
      left join es_warehouse.public.states s on s.state_id = l.state_id
      where invoice_date >= '2023-01-01' and invoice_date <= '2030-01-01'
      )

      select *
      from ap_invoices
      union all
      select *
      from ar_invoices
      ;;
  }

  # Primary key
  dimension: invoice_number {
    primary_key: yes
    type: string
    sql: ${TABLE}.invoice_number ;;
  }

  dimension: invoice_date {
    type: date
    sql: ${TABLE}.invoice_date ;;
  }

  dimension: amount {
    type: number
    sql: ${TABLE}.amount ;;
  }

  dimension: account_number {
    type: string
    sql: ${TABLE}.account_number ;;
  }

  dimension: account_name {
    type: string
    sql: ${TABLE}.account_name ;;
  }

  dimension: business_id {
    type: string
    sql: ${TABLE}.business_id ;;
  }

  dimension: business_name {
    type: string
    sql: ${TABLE}.business_name ;;
  }

  dimension: department_id {
    type: string
    sql: ${TABLE}.department_id ;;
  }

  dimension: department_name {
    type: string
    sql: ${TABLE}.department_name ;;
  }

  dimension: invoice_state {
    type: string
    sql: ${TABLE}.invoice_state ;;
  }

  dimension: line_description {
    type: string
    sql: ${TABLE}.line_description ;;
  }

  dimension: invoice_url {
    type: string
    sql: ${TABLE}.invoice_url ;;
    link: {
      label: "{{ value }}"
      url: "{{ value }}"
    }
  }

  dimension: state {
    type: string
    sql: ${TABLE}.state ;;
  }

  dimension: state_abbreviation {
    type: string
    sql: ${TABLE}.state_abbreviation ;;
  }

  dimension: tax_line {
    type: yesno
    sql: ${TABLE}.tax_line ;;
  }

  dimension: sage_url {
    type: string
    sql: ${TABLE}.sage_url ;;
    link: {
      label: "{{ value }}"
      url: "{{ value }}"
    }
  }

  dimension: invoice_type {
    type: string
    sql: ${TABLE}.invoice_type ;;
  }
}
