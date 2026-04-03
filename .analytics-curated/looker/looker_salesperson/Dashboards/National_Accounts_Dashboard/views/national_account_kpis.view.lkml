view: national_account_kpis {
  derived_table: {
    sql:
        WITH date_series AS (
          SELECT
              DATEADD(
                  day,
                  '-' || ROW_NUMBER() OVER (ORDER BY NULL),
                  DATEADD(day, '+1', CONVERT_TIMEZONE('UTC', 'America/Chicago', CURRENT_TIMESTAMP())::DATE)
              ) AS date
          FROM TABLE (GENERATOR(rowcount => (365 * 2)))
        )
        , aor_oec AS (
          SELECT
              ds.date
              , o.market_id
              --, mrx.market_name
              , c.company_id
              --, c.name as company
              --, pcr.parent_company_name
              --, COALESCE(bs.name, 'No Class Listed') AS business_segment_name
              --, COALESCE(os.user_id, o.salesperson_user_id) AS salesperson_user_id
              --, CASE WHEN position(' ',coalesce(cd.nickname,cd.first_name)) = 0
              --     THEN concat(coalesce(cd.nickname,cd.first_name), ' ', cd.last_name)
              --     ELSE concat(coalesce(cd.nickname,concat(cd.first_name, ' ',cd.last_name))) END as salesperson_full_name
              --, spu.email_address as sp_email
              , COUNT(DISTINCT  ea.asset_id) AS assets_on_rent
              , SUM(CASE WHEN  r.rental_status_id in (9,5,3,7,4,6) THEN COALESCE(aa.oec, 0) ELSE 0 end) AS OEC_on_rent
          FROM date_series ds
          LEFT JOIN es_warehouse.public.equipment_assignments ea ON ea.start_date <= ds.date
                                                              and COALESCE(ea.end_date, (CONVERT_TIMEZONE('UTC', 'America/Chicago', CURRENT_TIMESTAMP())::DATE)) >= ds.date
          LEFT JOIN es_warehouse.public.rentals r ON r.rental_id = ea.rental_id
          LEFT JOIN es_warehouse.public.orders o ON r.order_id = o.order_id
          --LEFT JOIN analytics.public.market_region_xwalk mrx on mrx.market_id = o.market_id
          LEFT JOIN es_warehouse.public.users u ON u.user_id = o.user_id
          LEFT JOIN es_warehouse.public.companies c ON c.company_id = u.company_id
          --LEFT JOIN analytics.bi_ops.v_parent_company_relationships pcr ON c.company_id = pcr.company_id
          LEFT JOIN es_warehouse.public.assets_aggregate aa ON aa.asset_id = ea.asset_id
          --LEFT JOIN es_warehouse.public.order_salespersons os ON os.order_id = o.order_id
          --left join ES_WAREHOUSE.PUBLIC.USERS spu on COALESCE(os.user_id, o.salesperson_user_id) = spu.USER_ID
          --LEFT JOIN analytics.payroll.company_directory cd ON lower(spu.email_address) = lower(cd.work_email)
          --LEFT JOIN es_warehouse.public.assets a on a.asset_id = r.asset_id
          --LEFT JOIN es_warehouse.public.equipment_classes ec ON ec.equipment_class_id = a.equipment_class_id
          --LEFT JOIN ES_WAREHOUSE.PUBLIC.BUSINESS_SEGMENTS bs ON bs.business_segment_id = ec.business_segment_id
          WHERE c.company_id not in (1854,1855,8151,155) AND r.deleted = false AND o.deleted = false
          /*
            AND COALESCE(os.user_id, o.salesperson_user_id) IN (SELECT user_id
                                                                FROM analytics.commission.employee_commission_info
                                                                WHERE commission_type_id = 6)
          */
            AND c.company_id IN (SELECT company_id
                                 FROM es_warehouse.public.billing_company_preferences
                                 WHERE PREFS:national_account = TRUE)
            AND TO_DATE(ds.date) >= TO_DATE(DATEADD(day, -90, CONVERT_TIMEZONE('UTC', 'America/Chicago', CURRENT_TIMESTAMP())))
          GROUP BY
          ds.date,
          o.market_id,
          --mrx.market_name,
          c.company_id--,
          --c.name,
          --pcr.parent_company_name,
          --COALESCE(bs.name, 'No Class Listed'),
          --COALESCE(os.user_id, o.salesperson_user_id),
          --salesperson_full_name,
          --spu.email_address
        )


        , aor_oec_today AS (
          SELECT
            company_id,
            SUM(assets_on_rent) as assets_on_rent,
            SUM(oec_on_rent) as oec_on_rent
          FROM aor_oec
          WHERE TO_DATE(date) = TO_DATE(CONVERT_TIMEZONE('UTC', 'America/Chicago', CURRENT_TIMESTAMP()))
          GROUP BY company_id
        )


        , max_update_date as (
          select
            max(hlfs.gl_date) as max_date
          from
            analytics.branch_earnings.high_level_financials hlfs
            JOIN analytics.gs.plexi_periods pp on pp.trunc::date = hlfs.gl_date::date
          where
            period_published = 'published'
          )
          , market_open_length as (
          select
            market_id,
            IFF(datediff(months,branch_earnings_start_month,max_date)+1 > 12,TRUE,FALSE) as months_open_over_12
          from
            ANALYTICS.GS.REVMODEL_MARKET_ROLLOUT_CONSERVATIVE
            CROSS JOIN max_update_date
          where
            market_id BETWEEN 0 AND 500000
            AND market_id != 15967
        )
        , rental_day_list AS (
            select *
            from
                table(es_warehouse.public.generate_series(
                dateadd(days,-90,current_date)::timestamp_tz,
                current_date::timestamp_tz,
                'day'))
        )
        , average_cost as (
            select PRODUCT_ID,
                 INVENTORY_LOCATION_ID,
                 WEIGHTED_AVERAGE_COST
            from ES_WAREHOUSE.INVENTORY.WEIGHTED_AVERAGE_COST_SNAPSHOTS
            where IS_CURRENT = true
        )
        , on_rent as (
            select rdl.series::date as rental_day
             , r.rental_id
             , r.rental_type_id
             , o.order_id
             , o.MARKET_ID
             , c.company_id
             , c.name as company
             --, pcr.parent_company_name
             , xw.REGION_NAME
             , xw.DISTRICT
             , xw.MARKET_NAME
             , xw.MARKET_TYPE
             , COALESCE(bs.name, 'No Class Listed') AS business_segment_name
             , sp.STORE_PART_ID
             , pt.part_type_id
             , pt.description
             , p.MASTER_PART_ID as part_id
             , p.PART_NUMBER as part_number
             , rpa.QUANTITY
             , ac.WEIGHTED_AVERAGE_COST as cost
             , sp.STORE_ID
             , rpa.QUANTITY * cost as               total_cost
             , rpa.START_DATE::date as start_date
             , rpa.END_DATE::date as end_date
             , os.USER_ID as salesperson_user_id
             , concat(spu.FIRST_NAME, ' ',spu.LAST_NAME) as salesperson_full_name
             , spu.email_address as sp_email
            from ES_WAREHOUSE.PUBLIC.RENTAL_PART_ASSIGNMENTS rpa
            join ES_WAREHOUSE.PUBLIC.RENTALS r
              on rpa.RENTAL_ID = r.RENTAL_ID
            join ES_WAREHOUSE.PUBLIC.ORDERS o
              on r.ORDER_ID = o.ORDER_ID
            left join es_warehouse.public.users ordu on o.user_id = ordu.user_id
            left join es_warehouse.public.companies c on ordu.company_id = c.company_id
            --LEFT JOIN analytics.bi_ops.v_parent_company_relationships pcr ON c.company_id = pcr.company_id
            left join ES_WAREHOUSE.PUBLIC.ORDER_SALESPERSONS os
              on o.ORDER_ID = os.ORDER_ID
            left join ES_WAREHOUSE.PUBLIC.USERS spu
              on os.USER_ID = spu.USER_ID
            left join ANALYTICS.PUBLIC.MARKET_REGION_XWALK xw
              on o.MARKET_ID = xw.MARKET_ID
            join ES_WAREHOUSE.INVENTORY.inventory_locations s
              on o.MARKET_ID = s.BRANCH_ID
            join ANALYTICS.PARTS_INVENTORY.PARTS p
              on rpa.PART_ID = p.PART_ID
            join ES_WAREHOUSE.INVENTORY.STORE_PARTS sp
              on s.inventory_location_id = sp.STORE_ID
                  and sp.PART_ID = p.MASTER_PART_ID
            join rental_day_list rdl
              on rdl.series BETWEEN (convert_timezone('America/Chicago', rpa.start_date))
                and COALESCE((convert_timezone('America/Chicago', rpa.end_date)), '2099-12-31')
            join ES_WAREHOUSE.INVENTORY.PART_TYPES pt
              on pt.PART_TYPE_ID = p.PART_TYPE_ID
            left join average_cost ac --kaa
              on ac.PRODUCT_ID = p.MASTER_PART_ID and ac.INVENTORY_LOCATION_ID = sp.store_id
            LEFT JOIN es_warehouse.public.assets a on a.asset_id = r.asset_id
            LEFT JOIN es_warehouse.public.equipment_classes ec ON ec.equipment_class_id = a.equipment_class_id
            LEFT JOIN ES_WAREHOUSE.PUBLIC.BUSINESS_SEGMENTS bs ON bs.business_segment_id = ec.business_segment_id
            where c.company_id IN (SELECT company_id
                                   FROM es_warehouse.public.billing_company_preferences
                                   WHERE PREFS:national_account = TRUE)
            /*
            and os.user_id IN (SELECT user_id
                             FROM analytics.commission.employee_commission_info
                             WHERE commission_type_id = 6)
            */
        )
        , bulk AS (
          select
               rental_day
               --, onr.REGION_NAME
               --, onr.district
               , onr.market_id
               --, onr.market_name
               --, onr.MARKET_TYPE
               --, onr.business_segment_name
               , onr.company_id
               --, onr.company
               --, onr.parent_company_name
               , onr.rental_id
               , onr.rental_type_id
               , onr.order_id
               , onr.store_id
               , onr.store_part_id
               , onr.part_id
               , onr.part_number
               , onr.description
               , onr.start_date
               , onr.end_date
               --, onr.salesperson_user_id
               --, CASE WHEN position(' ',coalesce(cd.nickname,cd.first_name)) = 0
                --     THEN concat(coalesce(cd.nickname,cd.first_name), ' ', cd.last_name)
                --     ELSE concat(coalesce(cd.nickname,concat(cd.first_name, ' ',cd.last_name))) END as salesperson_full_name
               --, onr.sp_email
               , sum(onr.cost) as bulk_unit_cost_on_rent
               , sum(onr.quantity) as bulk_parts_on_rent
               , sum(onr.total_cost) as bulk_cost_on_rent
               , current_date() as last_updated
               , row_number() OVER(ORDER BY rental_day DESC) as unique_record
               --, mol.months_open_over_12
          from on_rent onr
          join market_open_length mol on onr.market_id = mol.market_id
          --LEFT JOIN es_warehouse.public.users u ON onr.salesperson_user_id = u.user_id
          --LEFT JOIN analytics.payroll.company_directory cd ON lower(u.email_address) = lower(cd.work_email)
          WHERE TO_DATE(rental_day) = TO_DATE(CONVERT_TIMEZONE('UTC', 'America/Chicago', CURRENT_TIMESTAMP()))
          group by
                   rental_day,
                   --onr.region_name,
                   --onr.district,
                   --onr.market_type,
                   onr.market_id,
                   --onr.market_name,
                   --onr.business_segment_name,
                   onr.company_id,
                   --onr.company,
                   --onr.parent_company_name,
                   onr.rental_id,
                   onr.rental_type_id,
                   onr.order_id,
                   onr.store_id,
                   onr.store_part_id,
                   onr.part_id,
                   onr.part_number,
                   onr.description,
                   onr.start_date,
                   onr.end_date--,
                   --onr.salesperson_user_id,
                   --CASE WHEN position(' ',coalesce(cd.nickname,cd.first_name)) = 0
                   --  THEN concat(coalesce(cd.nickname,cd.first_name), ' ', cd.last_name)
                    -- ELSE concat(coalesce(cd.nickname,concat(cd.first_name, ' ',cd.last_name))) END,
                   --onr.sp_email--,
                   --mol.months_open_over_12
          )


          , bulk_today as (
            SELECT
              company_id,
              SUM(bulk_parts_on_rent) as bulk_parts_on_rent
            FROM bulk
            GROUP BY company_id
            )


    , previous_month_rental_revenue as (
      select
        c.company_id as rental_company_id,
        sum(ild.invoice_line_details_amount) as rental_revenue
      from platform.gold.v_line_items r
      JOIN platform.gold.v_invoice_line_details ild on ild.INVOICE_LINE_DETAILS_LINE_ITEM_KEY = r.line_item_key
      JOIN platform.gold.v_dates dd on ild.invoice_line_details_gl_billing_approved_date_key = dd.date_key
      JOIN platform.gold.v_companies c on ild.invoice_line_details_company_key = c.company_key
      WHERE dd.prior_month = TRUE
        AND r.LINE_ITEM_RENTAL_REVENUE = TRUE
        AND c.company_id IN
            (SELECT company_id FROM es_warehouse.public.billing_company_preferences WHERE PREFS:national_account = TRUE)
      group by c.company_id

          )


     , current_month_rental_revenue as (
      select
        c.company_id as rental_company_id,
        sum(ild.invoice_line_details_amount) as rental_revenue
      from platform.gold.v_line_items r
      JOIN platform.gold.v_invoice_line_details ild on ild.INVOICE_LINE_DETAILS_LINE_ITEM_KEY = r.line_item_key
      JOIN platform.gold.v_dates dd on ild.invoice_line_details_gl_billing_approved_date_key = dd.date_key
      JOIN platform.gold.v_companies c on ild.invoice_line_details_company_key = c.company_key
      WHERE dd.current_month = TRUE
        AND r.LINE_ITEM_RENTAL_REVENUE = TRUE
        AND c.company_id IN
          (SELECT company_id FROM es_warehouse.public.billing_company_preferences WHERE PREFS:national_account = TRUE)
      group by c.company_id



          )


          , kpis_combined as (
              SELECT
                COALESCE(aot.company_id, bt.company_id, pr.rental_company_id, cr.rental_company_id) as company_id,
                aot.OEC_on_rent,
                aot.assets_on_rent,
                bt.bulk_parts_on_rent,
                --bt.bulk_cost_on_rent,
                pr.rental_revenue as previous_month_rental_revenue,
                cr.rental_revenue as current_month_rental_revenue
              FROM aor_oec_today aot
              FULL JOIN bulk_today bt ON aot.company_id = bt.company_id
              FULL JOIN previous_month_rental_revenue pr ON aot.company_id = pr.rental_company_id
              FULL JOIN current_month_rental_revenue cr ON aot.company_id = cr.rental_company_id
          )

          , national_accounts as (
            SELECT
              bcp.company_id,
              c.name as company,
              pcr.parent_company_name as parent_company,
              COALESCE(CASE WHEN position(' ',coalesce(cd.nickname,cd.first_name)) = 0
                             THEN concat(coalesce(cd.nickname,cd.first_name), ' ', cd.last_name)
                             ELSE concat(coalesce(cd.nickname,concat(cd.first_name, ' ',cd.last_name))) END,
                       'Unassigned') as assigned_nam,
              lower(cd.work_email) as nam_email,
              CASE WHEN bcp.PREFS:general_services_administration = TRUE AND bcp.PREFS:managed_billing = TRUE THEN 'GSA, Managed Billing'
                   WHEN bcp.PREFS:general_services_administration = TRUE THEN 'GSA'
                   WHEN bcp.PREFS:managed_billing = TRUE THEN 'Managed Billing'
                   ELSE '' END as billing_preferences,
              nca.effective_start_date
            FROM es_warehouse.public.billing_company_preferences bcp
            JOIN es_warehouse.public.companies c ON bcp.company_id = c.company_id
            LEFT JOIN analytics.bi_ops.v_parent_company_relationships pcr ON c.company_id = pcr.company_id
            LEFT JOIN analytics.commission.nam_company_assignments nca ON nca.company_id = c.company_id
            LEFT JOIN es_warehouse.public.users u on u.user_id = nca.nam_user_id
            LEFT JOIN analytics.payroll.company_directory cd ON lower(u.EMAIL_ADDRESS) = lower(cd.WORK_EMAIL)
            WHERE bcp.PREFS:national_account = TRUE
              AND (current_timestamp() BETWEEN nca.effective_start_date AND nca.effective_end_date
                   OR nca.effective_start_date IS NULL AND nca.effective_end_date IS NULL)
          )

          SELECT
            na.company_id,
            na.company,
            na.parent_company,
            na.assigned_nam,
            na.billing_preferences,
            na.effective_start_date as nam_assignment_date,
            --kc.salesperson,
            ZEROIFNULL(kc.OEC_on_rent) as OEC_on_rent,
            ZEROIFNULL(kc.assets_on_rent) as assets_on_rent,
            ZEROIFNULL(kc.bulk_parts_on_rent) as bulk_quantity_on_rent,
            --ZEROIFNULL(kc.bulk_cost_on_rent) as bulk_cost_on_rent,
            ZEROIFNULL(kc.previous_month_rental_revenue) as previous_month_rental_revenue,
            ZEROIFNULL(kc.current_month_rental_revenue) as current_month_rental_revenue
          FROM national_accounts na
          LEFT JOIN kpis_combined kc ON na.company_id = kc.company_id
          WHERE ({{ _user_attributes['job_role'] }} = 'nam' AND na.nam_email = '{{ _user_attributes['email'] }}')
             -- Hardcode for Jessica to only see Tyler Levin's accounts
             OR ('{{ _user_attributes['email'] }}' = 'jessica.howard@equipmentshare.com' AND lower(na.nam_email) = 'tyler.levins@equipmentshare.com')
             OR ('{{ _user_attributes['email'] }}' <> 'jessica.howard@equipmentshare.com' AND {{ _user_attributes['job_role'] }} <> 'nam')
    ;;
  }

  dimension: company_id {
    type: string
    sql: ${TABLE}."COMPANY_ID";;
  }

  dimension: company {
    type: string
    sql: ${TABLE}."COMPANY" ;;
    html: <a href="https://equipmentshare.looker.com/dashboards/1556?Company={{company._filterable_value | url_encode}}&Parent+Company=&Time+Frame=%5E-90" target="_blank" style="color: #0063f3; text-decoration: underline;">{{company_id._value}} - {{value}} ➔</a>
    <br />
    <font style="color: #8C8C8C; text-align: right;">NAM Assigned: {{nam_assignment_date._rendered_value | date: "%b %d, %Y"}} </font>
    <br />
    <font style="color: #8C8C8C; text-align: right;">{{billing_preferences._value }} </font>
    ;;
  }

  dimension: nam_assignment_date {
    type: date
    sql: ${TABLE}."NAM_ASSIGNMENT_DATE" ;;
  }

  dimension: parent_company {
    type: string
    sql: ${TABLE}."PARENT_COMPANY" ;;
  }

  dimension: parent_company_display {
    type: string
    sql: CASE WHEN ${parent_company} IS NULL THEN '' ELSE ${parent_company} END ;;
    html:
    {% if value != '' %}
      <a href="https://equipmentshare.looker.com/dashboards/1556?Company=&Parent+Company={{parent_company_display._filterable_value | url_encode}}" target="_blank" style="color: #0063f3; text-decoration: underline;">{{value}} ➔</a>
    {% else %}
    {% endif %};;
  }

  dimension: assigned_nam {
    type: string
    sql: ${TABLE}."ASSIGNED_NAM" ;;
  }

  dimension: billing_preferences {
    type: string
    sql: ${TABLE}."BILLING_PREFERENCES";;
  }

  dimension: salesperson {
    type: string
    sql: ${TABLE}."SALESPERSON" ;;
  }

  measure: oec_on_rent {
    label: "OEC on Rent"
    type: sum
    sql: ${TABLE}."OEC_ON_RENT" ;;
    value_format_name: usd_0
  }

  measure: assets_on_rent {
    type: sum
    sql: ${TABLE}."ASSETS_ON_RENT" ;;
  }

  measure: bulk_quantity_on_rent {
    type: sum
    sql: ${TABLE}."BULK_QUANTITY_ON_RENT" ;;
  }

  measure: bulk_cost_on_rent {
    type: sum
    sql: ${TABLE}."BULK_COST_ON_RENT" ;;
    value_format_name: usd_0
  }

  measure: previous_month_rental_revenue {
    type: sum
    sql: ${TABLE}."PREVIOUS_MONTH_RENTAL_REVENUE";;
    value_format_name: usd_0
  }

  measure: current_month_rental_revenue {
    type: sum
    sql: ${TABLE}."CURRENT_MONTH_RENTAL_REVENUE";;
    value_format_name: usd_0
  }
}
