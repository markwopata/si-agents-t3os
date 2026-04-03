view: national_accounts_ancillary_revenue {
  derived_table: {
    sql:
          with national_accounts as (
              SELECT
                bcp.company_id,
                c.name as company,
                pcr.parent_company_name,
                COALESCE(CASE WHEN position(' ',coalesce(cd.nickname,cd.first_name)) = 0
                               THEN concat(coalesce(cd.nickname,cd.first_name), ' ', cd.last_name)
                               ELSE concat(coalesce(cd.nickname,concat(cd.first_name, ' ',cd.last_name))) END,
                         'Unassigned') as assigned_nam,
                cd.work_email as nam_email
              FROM es_warehouse.public.billing_company_preferences bcp
              JOIN es_warehouse.public.companies c ON bcp.company_id = c.company_id
              LEFT JOIN analytics.bi_ops.v_parent_company_relationships pcr ON c.company_id = pcr.company_id
              LEFT JOIN analytics.commission.nam_company_assignments nca ON nca.company_id = c.company_id
              LEFT JOIN es_warehouse.public.users u on u.user_id = nca.nam_user_id
              LEFT JOIN analytics.payroll.company_directory cd ON lower(u.EMAIL_ADDRESS) = lower(cd.WORK_EMAIL)
              WHERE bcp.PREFS:national_account = TRUE
                AND current_timestamp() BETWEEN nca.effective_start_date AND nca.effective_end_date
            )

          select
          li.gl_billing_approved_date as billing_approved_date,
          i.SALESPERSON_USER_ID,
          CASE WHEN position(' ',coalesce(cd.nickname,cd.first_name)) = 0
             THEN concat(coalesce(cd.nickname,cd.first_name), ' ', cd.last_name)
             ELSE concat(coalesce(cd.nickname,concat(cd.first_name, ' ',cd.last_name))) END as salesperson,
          u.email_address as sp_email,
          c.company_id,
          c.name as company,
          na.parent_company_name,
          na.assigned_nam,
          coalesce(li.branch_id,o.market_id) as market_id,
          mrx.market_name as market,
          COALESCE(bs.name, 'No Class Listed') AS business_segment_name,
          case
            when li.line_item_type_id in (24, 50, 80, 81, 110, 111) then 'Retail'
            when li.line_item_type_id in (11, 12, 25, 29, 49) then 'Parts'
            when li.line_item_type_id in (13, 20, 26) then 'Service'
            when li.line_item_type_id in (44) then 'Bulk'
            when li.line_item_type_id in (5) then 'Delivery'
            when li.line_item_type_id in (28, 2, 7, 21, 98, 99, 100, 101, 9) then 'Other'
            else 'Undefined'
          end as revenue_type,
          sum(amount) as revenue
          from analytics.public.v_line_items li
          join es_warehouse.public.invoices i on i.invoice_id = li.invoice_id
          join es_warehouse.public.orders o on o.order_id = i.order_id
          left join es_warehouse.public.users as customer_user on o.USER_ID = customer_user.USER_ID
          left join es_warehouse.public.companies c on customer_user.COMPANY_ID = c.COMPANY_ID
          LEFT JOIN national_accounts na ON c.company_id = na.company_id
          join analytics.public.market_region_xwalk mrx on mrx.market_id = coalesce(li.branch_id,o.market_id)
          left join es_warehouse.public.users u on i.SALESPERSON_USER_ID = u.USER_ID
          left join analytics.payroll.company_directory cd on lower(u.email_address) = lower(cd.work_email)
          LEFT JOIN es_warehouse.public.rentals r ON r.rental_id = li.rental_id
          LEFT JOIN es_warehouse.public.assets a on a.asset_id = r.asset_id
          LEFT JOIN es_warehouse.public.equipment_classes ec ON ec.equipment_class_id = a.equipment_class_id
          LEFT JOIN ES_WAREHOUSE.PUBLIC.BUSINESS_SEGMENTS bs ON bs.business_segment_id = ec.business_segment_id
          where c.company_id not in (1854, 1855, 8151, 155)
            and amount <> 0
            /*
            AND i.salesperson_user_id IN (SELECT user_id
                                          FROM analytics.commission.employee_commission_info
                                          WHERE commission_type_id = 6)
            */
            AND c.company_id IN (SELECT company_id
                                 FROM es_warehouse.public.billing_company_preferences
                                 WHERE PREFS:national_account = TRUE)
            AND (({{ _user_attributes['job_role'] }} = 'nam' AND na.nam_email = '{{ _user_attributes['email'] }}')
                -- Hardcode for Jessica to only see Tyler Levin's accounts
                OR ('{{ _user_attributes['email'] }}' = 'jessica.howard@equipmentshare.com' AND lower(na.nam_email) = 'tyler.levins@equipmentshare.com')
                OR ('{{ _user_attributes['email'] }}' <> 'jessica.howard@equipmentshare.com' AND {{ _user_attributes['job_role'] }} <> 'nam'))
          group by
            li.gl_billing_approved_date,
            i.SALESPERSON_USER_ID,
            salesperson,
            u.email_address,
            c.company_id,
            c.name,
            na.parent_company_name,
            na.assigned_nam,
            coalesce(li.branch_id,o.market_id),
            mrx.market_name,
            business_segment_name,
            revenue_type;;
  }

  dimension_group: billing_approved_date {
    type: time
    sql: ${TABLE}."BILLING_APPROVED_DATE" ;;
  }

  dimension: sp_user_id {
    type: number
    sql: ${TABLE}."SALESPERSON_USER_ID" ;;
  }

  dimension: sp_name {
    type: string
    sql: ${TABLE}."SALESPERSON" ;;
  }

  dimension: company_id {
    type: number
    sql: ${TABLE}."COMPANY_ID" ;;
  }

  dimension: company {
    type: string
    sql: ${TABLE}."COMPANY" ;;
  }

  dimension: parent_company {
    type: string
    sql: ${TABLE}."PARENT_COMPANY_NAME";;
  }

  dimension: assigned_nam {
    type: string
    sql: ${TABLE}."ASSIGNED_NAM" ;;
  }

  dimension: market_id {
    type: number
    sql: ${TABLE}."MARKET_ID" ;;
  }

  dimension: market_name {
    type: string
    sql: ${TABLE}."MARKET_NAME" ;;
  }

  dimension: business_segment {
    type: string
    sql: ${TABLE}."BUSINESS_SEGMENT_NAME" ;;
  }

  dimension: revenue_type {
    type: string
    sql: ${TABLE}."REVENUE_TYPE" ;;
  }

  dimension: revenue {
    type: number
    sql: ${TABLE}."REVENUE" ;;
  }

  measure: revenue_sum {
    type: sum
    sql: ${TABLE}."REVENUE" ;;
    value_format_name: usd_0
  }

  measure: service_revenue {
    type: sum
    sql: ${revenue} ;;
    filters: [revenue_type: "Service"]
    value_format_name: usd_0
  }

  measure: retail_revenue {
    type: sum
    sql: ${revenue} ;;
    filters: [revenue_type: "Retail"]
    value_format_name: usd_0
  }

  measure: parts_revenue {
    type: sum
    sql: ${revenue} ;;
    filters: [revenue_type: "Parts"]
    value_format_name: usd_0
  }

  measure: other_revenue {
    type: sum
    sql: ${revenue} ;;
    filters: [revenue_type: "Other"]
    value_format_name: usd_0
  }

  measure: delivery_revenue {
    type: sum
    sql: ${revenue} ;;
    filters: [revenue_type: "Delivery"]
    value_format_name: usd_0
  }

  measure: bulk_revenue {
    type: sum
    sql: ${revenue} ;;
    filters: [revenue_type: "Bulk"]
    value_format_name: usd_0
  }
}
