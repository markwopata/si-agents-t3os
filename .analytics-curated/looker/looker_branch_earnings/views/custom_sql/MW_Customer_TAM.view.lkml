view: mw_customer_tam {
  derived_table: {
    sql:
      with top_tam as (select concat(ld.CUSTOMER_NAME, ' - ', ld.COMPANY_ID) as customer_name,
        ld.customer_name as raw_name,
        ld.COMPANY_ID,
        l.STREET_1,
        l.CITY,
        s.name                                          as state,
        l.ZIP_CODE as zip,
        concat(u.FIRST_NAME, ' ', u.LAST_NAME)          as primary_salesperson,
        sum(ld.amount)                                  as revenue
      from analytics.intacct_models.int_admin_invoice_and_credit_line_detail ld
            left join ES_COMPANIES ec
                      on ld.COMPANY_ID = ec.COMPANY_ID
            left join es_warehouse.public.COMPANIES c
                      on ld.COMPANY_ID = c.COMPANY_ID
            left join es_warehouse.public.NET_TERMS nt
                      on c.NET_TERMS_ID = nt.NET_TERMS_ID
            left join es_warehouse.public.LOCATIONS l
                      on c.BILLING_LOCATION_ID = l.LOCATION_ID
            left join ES_WAREHOUSE.PUBLIC.STATES s
                      on l.STATE_ID = s.STATE_ID
            left join es_warehouse.public.users u
                      on ld.PRIMARY_SALESPERSON_ID = u.USER_ID
            left join analytics.payroll.COMPANY_DIRECTORY cd
                      on to_varchar(u.EMPLOYEE_ID) = to_varchar(cd.EMPLOYEE_ID)
            join analytics.public.market_region_xwalk mrx
                      on ld.market_id = mrx.market_id
      where ec.COMPANY_ID is null
        and nt.NAME <> 'Cash on Delivery'
        and s.name in ('New Mexico', 'Colorado', 'Idaho', 'Arizona', 'Wyoming', 'Montana', 'Nevada', 'Utah')
        and ld.LINE_ITEM_TYPE_ID in (6, 8, 43, 44, 108, 109)
        and ld.BILLING_APPROVED_DATE >= {% parameter billing_approved_date_filter %}
        and {% if billing_approved_date_max_filter._is_filtered %}
              ld.billing_approved_date <= {% parameter billing_approved_date_max_filter %}
          {% else %}
            1=1
          {% endif %}
        and cd.EMPLOYEE_TITLE = 'Territory Account Manager'
        and mrx.region_name = 'Mountain West'
      group by all
      QUALIFY ROW_NUMBER() OVER (PARTITION BY ld.Company_ID
                                ORDER BY sum(ld.amount) DESC) = 1
      order by customer_name, revenue desc),

      second_tam as (select ld.customer_name,
      ld.COMPANY_ID,
      l.STREET_1,
      l.CITY,
      s.name                                          as state,
      l.ZIP_CODE as zip,
      concat(u.FIRST_NAME, ' ', u.LAST_NAME)          as primary_salesperson,
      sum(ld.amount)                                  as revenue
      from analytics.intacct_models.int_admin_invoice_and_credit_line_detail ld
      left join ES_COMPANIES ec
      on ld.COMPANY_ID = ec.COMPANY_ID
      left join es_warehouse.public.COMPANIES c
      on ld.COMPANY_ID = c.COMPANY_ID
      left join es_warehouse.public.NET_TERMS nt
      on c.NET_TERMS_ID = nt.NET_TERMS_ID
      left join es_warehouse.public.LOCATIONS l
      on c.BILLING_LOCATION_ID = l.LOCATION_ID
      left join ES_WAREHOUSE.PUBLIC.STATES s
      on l.STATE_ID = s.STATE_ID
      left join es_warehouse.public.users u
      on ld.PRIMARY_SALESPERSON_ID = u.USER_ID
      left join analytics.payroll.COMPANY_DIRECTORY cd
      on to_varchar(u.EMPLOYEE_ID) = to_varchar(cd.EMPLOYEE_ID)
      join analytics.public.market_region_xwalk mrx
      on ld.market_id = mrx.market_id
      where ec.COMPANY_ID is null
      and nt.NAME <> 'Cash on Delivery'
      and s.name in ('New Mexico', 'Colorado', 'Idaho', 'Arizona', 'Wyoming', 'Montana', 'Nevada', 'Utah')
      and ld.LINE_ITEM_TYPE_ID in (6, 8, 43, 44, 108, 109)
      and ld.BILLING_APPROVED_DATE >= {% parameter billing_approved_date_filter %} -- Liquid filter applied here
      and ld.BILLING_APPROVED_DATE <= {% parameter billing_approved_date_max_filter %}
      and cd.EMPLOYEE_TITLE = 'Territory Account Manager'
      and mrx.region_name = 'Mountain West'
      group by all
      QUALIFY ROW_NUMBER() OVER (PARTITION BY ld.Company_ID
      ORDER BY sum(ld.amount) DESC) = 2
      order by customer_name, revenue desc)

      select tt.*, st.primary_salesperson as second_tam, st.revenue as second_rev
      from top_tam tt
      left join second_tam st
      on tt.company_id = st.company_id
      WHERE
      ( -- This outer parenthesis group is for the salesperson filter logic
      {% if salesperson_name_filter._is_filtered %} -- Check if the salesperson filter has been used
      (
      tt.primary_salesperson = {% parameter salesperson_name_filter %}  -- Syntax UPDATED
      OR
      (st.primary_salesperson IS NOT NULL AND st.primary_salesperson = {% parameter salesperson_name_filter %} ) -- Syntax UPDATED
      )
      {% else %}
      1=1 -- If no salesperson filter is applied, this condition is always true
      {% endif %}
      )
      order by customer_name desc

      ;;
  }

  parameter: billing_approved_date_filter {
    label: "Billing Approved On or After Date"
    type: date
    default_value: "2024-01-01"
  }
  parameter: billing_approved_date_max_filter {
    label: "Billing Approved On or Before Date"
    type: date
  }

  parameter: salesperson_name_filter {
    label: "Salesperson Name (TAM 1 or TAM 2)"
    type: string
    suggest_dimension: primary_salesperson
  }

  dimension: customer_name {
    label: "Customer Name"
    type: string
    sql: ${TABLE}."CUSTOMER_NAME" ;;
    link: {
      label: "Customer Dashboard"
      url: "@{db_company_detail}?Company+Name={{mw_customer_tam.raw_name._filterable_value}}"
    }
    link: {
      label: "Rentals by Customer"
      url: "@{db_customer_dashboard}?Customer={{mw_customer_tam.raw_name._filterable_value | url_encode}}"
    }
    link: {
      label: "Customer Rebates"
      url: "@{db_customer_rebates_dashboard}?Customer+Name={{mw_customer_tam.raw_name._filterable_value | url_encode}}&Current+Rebates=Yes&Rebate+End+Period+Date=after+0+minutes+ago&Parent+Customer+Name="
    }
  }

  dimension: raw_name {
    label: "Name"
    type: string
    sql: ${TABLE}."RAW_NAME" ;;
  }

  dimension: Company_ID {
    label: "Company ID"
    type: number
    sql: ${TABLE}."COMPANY_ID" ;;
  }

  dimension: street_1 {
    label: "Street"
    type: string
    sql: ${TABLE}."STREET_1" ;;
  }

  dimension: City {
    label: "City"
    type: string
    sql: ${TABLE}."CITY" ;;
  }

  dimension: state {
    label: "State"
    type: string
    sql: ${TABLE}."STATE" ;;
  }

  dimension: ZIP {
    label: "ZIP Code"
    type: string
    sql: ${TABLE}."ZIP" ;;
  }

  dimension: primary_salesperson {
    label: "TAM 1"
    type: string
    sql: ${TABLE}."PRIMARY_SALESPERSON" ;;
  }

  measure: rental_revenue {
    label: "TAM 1 Rental Revenue"
    type: sum
    sql: ${TABLE}."REVENUE" ;;
    value_format_name: usd_0 # Example formatting
  }

  dimension: second_salesperson {
    label: "TAM 2"
    type: string
    sql: ${TABLE}."SECOND_TAM" ;;
  }

  measure: second_rental_revenue {
    label: "TAM 2 Rental Revenue"
    type: sum
    sql: ${TABLE}."SECOND_REV" ;;
    value_format_name: usd_0 # Example formatting
  }
}
