view: ancillary_pct_payout_sales_director {

  derived_table: {
    sql:

      WITH national_accounts AS (
                  SELECT company_id
                  FROM es_warehouse.public.BILLING_COMPANY_PREFERENCES
                  WHERE PREFS:national_account = TRUE
              )

        , parent_company_relationships AS (
        SELECT company_id, parent_company_id
        FROM analytics.bi_ops.parent_company_relationships
        QUALIFY ROW_NUMBER() OVER(PARTITION BY company_id ORDER BY record_created_timestamp desc) = 1
        )

        , commission_assignments AS (
        SELECT *,
        CASE WHEN effective_end_date <> '2099-12-31 23:59:59.999'::timestamp_ntz
        THEN 1 ELSE 0 END as upcoming_assignment_change
        FROM analytics.commission.nam_company_assignments
        WHERE current_timestamp() BETWEEN effective_start_date AND effective_end_date
        )

        , account_info AS (
        SELECT *
        FROM analytics.bi_ops.national_account_info
        QUALIFY ROW_NUMBER() OVER(PARTITION BY company_id ORDER BY record_creation_date desc) = 1
        ),
        user_map AS (
        SELECT u.user_id, u.email_address,
        CASE WHEN position(' ',coalesce(cd.nickname,cd.first_name)) = 0
        THEN concat(coalesce(cd.nickname,cd.first_name), ' ', cd.last_name)
        ELSE concat(coalesce(cd.nickname,concat(cd.first_name, ' ',cd.last_name))) END as name
        FROM es_warehouse.public.users u
        JOIN analytics.payroll.company_directory cd ON lower(u.email_address) = lower(cd.work_email)
        )

        , na_companies AS (
        SELECT na.company_id as company_id,
        c.name                          as company,
        --                                  ai.region,
        --                                  ca.director_user_id,
        COALESCE(ud.name, 'Unassigned') as sales_director,
        --                                  ca.nam_user_id,
        --                                  ai.coordinator_user_id,
        --                                  nt.name                                   as net_term,
        --                                  CONCAT('https://admin.equipmentshare.com/#/home/companies/',
        --                                         ca.company_id::varchar)            as admin_link,
        --                                  pcr.parent_company_id,
                                         COALESCE(pc.name,c.name)                                as parent_company_name_na,
        COALESCE(cg.CUSTOMER_GROUP_NAME,c.name)           as parent_company_name_rebates
        --                                  ai.notes,
        --                                  bcp.PREFS:general_services_administration as GSA_flag,
        --                                  bcp.PREFS:managed_billing                 as managed_billing_flag,
        --                                  ca.upcoming_assignment_change,
        --                                  COALESCE(ai.account_folder_url, '')       as account_folder_url
        FROM national_accounts na
        JOIN es_warehouse.public.companies c ON na.company_id = c.company_id
        LEFT JOIN commission_assignments ca ON ca.company_id = na.company_id
        LEFT JOIN account_info ai ON na.company_id = ai.company_id
        LEFT JOIN parent_company_relationships pcr ON na.company_id = pcr.company_id
        LEFT JOIN es_warehouse.public.companies pc ON pc.company_id = pcr.parent_company_id
        LEFT JOIN es_warehouse.public.net_terms nt ON c.net_terms_id = nt.net_terms_id
        LEFT JOIN es_warehouse.public.billing_company_preferences bcp
        ON na.company_id = bcp.company_id
        LEFT JOIN user_map ud ON ca.director_user_id = ud.user_id
        left join ANALYTICS.GS.AR_BB_CUSTOMER_GROUPING cg
        on try_cast(cg.CUSTOMER_ID as number) = c.COMPANY_ID),


        ---------------------------------------------------------------------------REBATES------------------------------------------------------------------------

        rebate_percents as (with company_rental_rates as (SELECT *,
        IFF(DATE_CREATED < END_DATE AND DATE_VOIDED > END_DATE,
        END_DATE, IFF(DATE_CREATED > END_DATE,
        IFNULL(DATE_VOIDED, '9999-12-31'),
        IFNULL(DATE_VOIDED, IFNULL(END_DATE, '9999-12-31')))) AS RATE_END_DATE
        FROM ES_WAREHOUSE.PUBLIC.COMPANY_RENTAL_RATES),

        t1 as (select i.COMPANY_ID,
        i.INVOICE_ID,
        li.RENTAL_ID,
        li.branch_ID,
        i.PAID_DATE,
        datediff(day, INVOICE_DATE, PAID_DATE)                            as paid_date_diff,
        i.INVOICE_DATE,
        i.BILLING_APPROVED_DATE,
        crr.DATE_CREATED,
        crr.DATE_VOIDED,
        crr.end_date,
        crr.RATE_END_DATE,
        m.name                                                            as branch,
        r.EQUIPMENT_CLASS_ID                                              as rental_class,
        aa.EQUIPMENT_CLASS_ID                                             as invoiced_class,
        case when rental_class <> invoiced_class then True else FALSE end as is_sub,
        case
        when r.PRICE_PER_WEEK is null and r.PRICE_PER_MONTH is null and
        r.PRICE_PER_DAY is not null then true
        else false end                                                as daily_billing_flag,
        li.AMOUNT                                                         as actual_total,
        case
        when daily_billing_flag = true
        then (crr.PRICE_PER_MONTH / 28) * datediff(day, i.START_DATE, i.END_DATE)
        else (li.EXTENDED_DATA:rental:cheapest_period_hour_count::number *
        crr.PRICE_PER_HOUR) +
        (li.EXTENDED_DATA:rental:cheapest_period_day_count::number *
        crr.PRICE_PER_DAY) +
        (li.EXTENDED_DATA:rental:cheapest_period_week_count::number *
        crr.PRICE_PER_WEEK) +
        (li.EXTENDED_DATA:rental:cheapest_period_month_count::number *
        crr.PRICE_PER_MONTH) end                                as expected_total,
        abs(actual_total) - expected_total                                as revenue_difference,
        li.EXTENDED_DATA:rental:price_per_month::number                   as month_rental_rate,
        crr.PRICE_PER_MONTH                                               as month_company_rate,
        month_rental_rate - month_company_rate                            as month_rate_difference,
        case
        when revenue_difference >= 0 then True
        when expected_total is null then True
        else False end                                                as is_valid_rate
        from ES_WAREHOUSE.PUBLIC.INVOICES i
        join analytics.public.v_LINE_ITEMS li on i.INVOICE_ID = li.INVOICE_ID
        join ES_WAREHOUSE.PUBLIC.RENTALS r on li.RENTAL_ID = r.RENTAL_ID
        join ES_WAREHOUSE.PUBLIC.ASSETS_AGGREGATE aa on li.ASSET_ID = aa.ASSET_ID
        join es_warehouse.PUBLIC.MARKETS m on li.branch_ID = m.MARKET_ID
        left join company_rental_rates crr on i.COMPANY_ID = crr.COMPANY_ID and
        r.EQUIPMENT_CLASS_ID =
        crr.EQUIPMENT_CLASS_ID and
        i.BILLING_APPROVED_DATE between crr.DATE_CREATED and crr.RATE_END_DATE
        where li.LINE_ITEM_TYPE_ID = 8
        and i.PAID = true
        and BILLING_APPROVED = 'Yes'),
        customer_rebate_list as (SELECT cr.CUSTOMER_ID,
        cr.CUSTOMER_NAME,
        cr.rebate_start_period                                                                          as rebate_start_for_financials,
        CASE
        WHEN cr.CUSTOMER_ID = '39017' and cr.REBATE_END_PERIOD = '12/31/2024' then '1/1/2024'
        WHEN cr.CUSTOMER_ID = '120962' and cr.rebate_end_period = '12/31/2024' then '4/1/2024'
        else cr.REBATE_START_PERIOD end                                                             as REBATE_START_PERIOD,
        cr.REBATE_END_PERIOD,
        cr.REVENUE_LOWER_BOUND,
        cr.REVENUE_UPPER_BOUND,
        cr.REBATE_PERCENT,
        cr.PAID_IN_DAYS,
        cr.REBATE_PAID,
        cr.REBATE_PAID_AMOUNT,
        cr.CUSTOMER_SPECIFIC_RATES,
        CAST(COALESCE(cg.CUSTOMER_GROUP_ID, cr.CUSTOMER_ID) as NUMBER)                                  as group_id,
        CAST(COALESCE(cg.CUSTOMER_GROUP_NAME, cr.CUSTOMER_NAME) as string)                              as group_name,
        ROW_NUMBER() OVER (PARTITION BY cr.CUSTOMER_ID, REBATE_END_PERIOD ORDER BY REVENUE_LOWER_BOUND) AS TIER_NUMBER
        FROM ANALYTICS.PUBLIC.CUSTOMER_REBATES cr
        LEFT JOIN ANALYTICS.GS.AR_BB_CUSTOMER_GROUPING cg
        on TRY_CAST(cg.CUSTOMER_ID as number) = cr.CUSTOMER_ID),


        customer_rebates_v as (SELECT crl.*,
        --case when crl.CUSTOMER_SPECIFIC_RATES = 'yes' then t1.is_valid_rate else 'yes' end as is_rebate_eligible, --REMOVED TO TAKE INTO ACCOUNT ALL RENTALS REGARDLESS OF IF IT MEETS CUSTOMER SPECIFIC RATE
        t1.actual_total as rebate_eligible_amount
        FROM customer_rebate_list crl
        left join t1 on t1.company_id = crl.CUSTOMER_ID
        WHERE t1.PAID_DATE::Date <=
        DATEADD(day, crl.PAID_IN_DAYS, t1.INVOICE_DATE::Date)
        AND t1.INVOICE_DATE::DATE >= crl.rebate_start_for_financials::DATE
        AND t1.INVOICE_DATE::DATE <= crl.REBATE_END_PERIOD::DATE
        --AND is_rebate_eligible = 'yes' --REMOVED TO TAKE INTO ACCOUNT ALL RENTALS REGARDLESS OF IF IT MEETS CUSTOMER SPECIFIC RATE
        and TIER_NUMBER = 1),

        rental_charges_eligible_for_rebate as (select group_id,
        group_name,
        rebate_start_period,
        REBATE_END_PERIOD,
        min(REVENUE_LOWER_BOUND)    as minimum_spend,
        sum(rebate_eligible_amount) as total_rebate_eligible_amount,
        CASE
        WHEN sum(rebate_eligible_amount) > minimum_spend
        THEN TRUE
        ELSE FALSE END          AS CUSTOMER_REBATE_ELIGIBLE
        --                                               iff(Total_rebate_eligible_amount > minimum_spend, Total_rebate_eligible_amount-minimum_spend,0) as total_rebate_eligible_after_min_spend
        from customer_rebates_v cr
        group by 1, 2, 3, 4),

        rental_charges_eligible_for_rebate_per_customer as (select CUSTOMER_ID,
        CUSTOMER_NAME,
        REBATE_START_PERIOD,
        REBATE_END_PERIOD,
        sum(rebate_eligible_amount) as total_rebate_eligible_amount_per_customer
        --                                               iff(Total_rebate_eligible_amount > minimum_spend, Total_rebate_eligible_amount-minimum_spend,0) as total_rebate_eligible_after_min_spend
        from customer_rebates_v
        --                                         WHERE CUSTOMER_ID in (5652,48614,29659) --performance contractors
        --                                          and REBATE_END_PERIOD = '12/31/2023'
        group by 1, 2, 3, 4),


        rental_charges_eligible_with_rebate_percent as (SELECT DISTINCT r.*,
        zeroifnull(crl.REBATE_PERCENT) as rebate_percent_achieved
        FROM rental_charges_eligible_for_rebate r
        left join customer_rebate_list crl
        on crl.group_id =
        r.group_id and
        crl.group_name =
        r.group_name and
        crl.REBATE_START_PERIOD =
        r.REBATE_START_PERIOD and
        crl.REBATE_END_PERIOD =
        r.REBATE_END_PERIOD and
        r.total_rebate_eligible_amount >
        crl.REVENUE_LOWER_BOUND AND
        r.total_rebate_eligible_amount <=
        crl.REVENUE_UPPER_BOUND),


        rebate_eligibility_and_percent as (select r.CUSTOMER_ID,
        r.CUSTOMER_NAME,
        r.rebate_start_for_financials                                                                            as REBATE_START_PERIOD,
        r.REBATE_END_PERIOD,
        r.REVENUE_LOWER_BOUND,
        r.REVENUE_UPPER_BOUND,
        r.REBATE_PERCENT,
        r.PAID_IN_DAYS,
        rp.group_id,
        rp.group_name,
        COALESCE(rp.CUSTOMER_REBATE_ELIGIBLE, false)                                                             as CUSTOMER_REBATE_ELIGIBLE,
        COALESCE(rp.rebate_percent_achieved, 0)                                                                  as rebate_percent_achieved,
        COALESCE(rp.total_rebate_eligible_amount, 0)                                                             as total_rebate_eligible_amount,
        COALESCE(c.total_rebate_eligible_amount_per_customer, 0)                                                 as total_rebate_eligible_amount_per_customer,
        COALESCE(rp.rebate_percent_achieved *
        c.total_rebate_eligible_amount_per_customer,
        0)                                                                                              as total_rebate_amount,
        ROW_NUMBER() OVER (PARTITION BY r.CUSTOMER_ID, r.REBATE_END_PERIOD ORDER BY REVENUE_LOWER_BOUND)         as tier,
        concat(r.CUSTOMER_ID,
        ROW_NUMBER() OVER (PARTITION BY r.CUSTOMER_ID, r.REBATE_END_PERIOD ORDER BY REVENUE_LOWER_BOUND)) AS key
        from customer_rebate_list r
        left join rental_charges_eligible_with_rebate_percent rp
        on rp.group_id = r.group_id and
        rp.group_name = r.group_name and
        rp.REBATE_START_PERIOD =
        r.REBATE_START_PERIOD and
        rp.REBATE_END_PERIOD =
        r.REBATE_END_PERIOD
        left join rental_charges_eligible_for_rebate_per_customer c
        on c.CUSTOMER_NAME = r.CUSTOMER_NAME
        and c.CUSTOMER_ID = r.CUSTOMER_ID
        and c.rebate_start_period = r.rebate_start_period
        and c.REBATE_END_PERIOD = r.REBATE_END_PERIOD
        )

        SELECT --COALESCE(group_name, customer_name) as c_name,
        customer_name as c_name,
        rebate_start_period,
        REBATE_END_PERIOD,
        Max(REBATE_PERCENT)                 as rebate_percent,
        max(rebate_percent_achieved)        as rebate_percent_achieved,
        min(PAID_IN_DAYS)                   as paid_in_days
        FROM rebate_eligibility_and_percent
        group by 1, 2, 3
        order by 3),


        -----------------------------------------------------------------Current Rates--------------------------------------------------------------------------

        online_rate as (select EQUIPMENT_CLASS_ID,
        avg(PRICE_PER_MONTH) as price_per_month,
        avg(PRICE_PER_WEEK)  as price_per_week,
        avg(PRICE_PER_DAY)   as price_per_day,
        avg(PRICE_PER_HOUR)  as price_per_hour
        from ES_WAREHOUSE.PUBLIC.BRANCH_RENTAL_RATES
        where ACTIVE
        and RATE_TYPE_ID = 1
        group by 1),
        floor_rate as (select EQUIPMENT_CLASS_ID,
        avg(PRICE_PER_MONTH) as price_per_month,
        avg(PRICE_PER_WEEK)  as price_per_week,
        avg(PRICE_PER_DAY)   as price_per_day,
        avg(PRICE_PER_HOUR)  as price_per_hour
        from ES_WAREHOUSE.PUBLIC.BRANCH_RENTAL_RATES
        where ACTIVE
        and RATE_TYPE_ID = 3
        group by 1),


        ----------------------------------------------------------------Regular Rental Revenue---------------------------------------------------------------

        rental_revenue_per_class as (select COALESCE(cg.CUSTOMER_GROUP_NAME, c.Name)                                   as parent_company_name,
        parent_company_name_na,
        c.Name as company_name,
        na.sales_director,
        i.INVOICE_ID,
        li.LINE_ITEM_ID,
        r.EQUIPMENT_CLASS_ID                                                       as equipment_class_id,
        --                                          i.INVOICE_DATE::DATE as INVOICE_DATE,
        QUARTER(i.INVOICE_DATE)                                                      as Invoice_quarter,
        YEAR(i.INVOICE_DATE)                                                         as invoice_year,
        case
        when (r.PRICE_PER_MONTH is null and r.PRICE_PER_WEEK is null and
        r.PRICE_PER_DAY is not null)
        then li.EXTENDED_DATA:rental:price_per_day::number * 28
        else li.EXTENDED_DATA:rental:price_per_month::number end               as monthly_rate,
        f.PRICE_PER_MONTH                                                          as floor_rate,
        o.PRICE_PER_MONTH                                                          as online_rate,
        li.NUMBER_OF_UNITS,
        li.AMOUNT                                                                  as rental_revenue,
        case
        when (r.PRICE_PER_MONTH is null and r.PRICE_PER_WEEK is null and
        r.PRICE_PER_DAY is not null)
        then o.PRICE_PER_MONTH / 28 * datediff(day, i.START_DATE, i.END_DATE)
        else (li.EXTENDED_DATA:rental:cheapest_period_hour_count * o.PRICE_PER_HOUR) +
        (li.EXTENDED_DATA:rental:cheapest_period_day_count * o.PRICE_PER_DAY) +
        (li.EXTENDED_DATA:rental:cheapest_period_week_count * o.PRICE_PER_WEEK) +
        (li.EXTENDED_DATA:rental:cheapest_period_month_count *
        o.PRICE_PER_MONTH) end                                           as revenue_at_online,
        case
        when (o.PRICE_PER_MONTH is not null)
        then li.AMOUNT
        else 0 end                                                             as revenue_with_online,
        ec.BUSINESS_SEGMENT_ID,
        r.SHIFT_TYPE_ID,
        .05                                                                        as commission_pct,
        commission_pct * monthly_rate                                              as monthly_commission_amount,
        rp.paid_in_days,
        YEAR(CURRENT_DATE()) as CURRENT_YEAR,
        DATEADD(DAY, (-1*rp.paid_in_days), CURRENT_DATE()) as current_date_minus_paid_in_days,
        COALESCE(CASE
        WHEN YEAR(INVOICE_DATE) >= CURRENT_YEAR THEN rp.rebate_percent
        ELSE
        CASE
        WHEN INVOICE_DATE::DATE < current_date_minus_paid_in_days THEN rp.rebate_percent_achieved
        WHEN INVOICE_DATE::DATE >= current_date_minus_paid_in_days THEN rp.rebate_percent
        end
        end,
        0)                                                                as rebate_pct,
        rebate_pct * monthly_rate                                                  as monthly_rebate_amount
        from ES_WAREHOUSE.PUBLIC.INVOICES i
        left join analytics.public.v_LINE_ITEMS li on i.INVOICE_ID = li.INVOICE_ID
        left join ES_WAREHOUSE.PUBLIC.RENTALS r on li.RENTAL_ID = r.RENTAL_ID
        left join ANALYTICS.GS.AR_BB_CUSTOMER_GROUPING cg
        on try_cast(cg.CUSTOMER_ID as number) = i.COMPANY_ID
        left join ES_WAREHOUSE.PUBLIC.COMPANIES c on c.COMPANY_ID = i.COMPANY_ID
        left join ANALYTICS.RATE_ACHIEVEMENT.RATE_SPLITS_STAGING rss
        on rss.EQUIPMENT_CLASS_ID = r.EQUIPMENT_CLASS_ID
        left join rebate_percents as rp
        --                                                      on COALESCE(cg.CUSTOMER_GROUP_NAME, c.Name) = rp.C_NAME AND
        on c.Name = rp.C_NAME AND
        i.INVOICE_DATE::DATE >= rp.REBATE_START_PERIOD::DATE AND
        i.INVOICE_DATE::DATE <= rp.REBATE_END_PERIOD::DATE
        -- applying current online rates to all historical data
        left join online_rate o on r.EQUIPMENT_CLASS_ID = o.EQUIPMENT_CLASS_ID
        left join floor_rate f on r.EQUIPMENT_CLASS_ID = f.EQUIPMENT_CLASS_ID
        left join na_companies na on na.COMPANY_ID = i.COMPANY_ID-- and i.INVOICE_DATE::DATE <= na.EFFECTIVE_END_DATE::DATE
        LEFT JOIN ES_WAREHOUSE.PUBLIC.EQUIPMENT_CLASSES ec on r.EQUIPMENT_CLASS_ID = ec.EQUIPMENT_CLASS_ID
        where li.LINE_ITEM_TYPE_ID = 8
        and r.EQUIPMENT_CLASS_ID is not null
        and rental_revenue > 0
        and monthly_rate > 0
        and na.COMPANY_ID is not null --filter to get the NA list of companies
        order by 1),

        other_revenue_per_company as (select na.parent_company_name_na,
                                          --COALESCE(cg.CUSTOMER_GROUP_NAME, c.Name)                                   as parent_company_name,
--         c.Name as company_name,
        na.sales_director,
        --                                          li.invoice_date::DATE as invoice_date,
        YEAR(i.INVOICE_DATE) AS INVOICE_YEAR,
        QUARTER(i.INVOICE_DATE)                                                      as Invoice_quarter,
        SUM(CASE
        WHEN li.LINE_ITEM_TYPE_ID IN (49)
        THEN li.AMOUNT
        ELSE 0 end)                                                       as retail_parts_sales_revenue,
        SUM(CASE
        WHEN li.LINE_ITEM_TYPE_ID IN (17)
        THEN li.AMOUNT
        ELSE 0 end)                                                       as environmental_fees_revenue,

        SUM(CASE WHEN li.LINE_ITEM_TYPE_ID IN (5, 117) THEN li.AMOUNT ELSE 0 end) as pnd_revenue,
        SUM(CASE
        WHEN li.LINE_ITEM_TYPE_ID IN (2, 7, 98, 99, 100, 101, 129, 130, 131, 132, 138, 142)
        THEN li.AMOUNT
        ELSE 0 end)                                                       as fuel_revenue,
        SUM(CASE
        WHEN li.LINE_ITEM_TYPE_ID IN (4, 11, 13, 19, 20, 21, 30, 3, 25, 26)
        THEN li.AMOUNT
        ELSE 0 end)                                                       as service_revenue,
        SUM(CASE
        WHEN li.LINE_ITEM_TYPE_ID = 8
        THEN li.AMOUNT
        ELSE 0 end)                                                       as rent_revenue,
        retail_parts_sales_revenue + environmental_fees_revenue+ pnd_revenue + fuel_revenue + service_revenue + rent_revenue             as total_revenue
        from ES_WAREHOUSE.PUBLIC.INVOICES i
        left join analytics.public.v_LINE_ITEMS li on i.INVOICE_ID = li.INVOICE_ID
        left join ES_WAREHOUSE.PUBLIC.RENTALS r on li.RENTAL_ID = r.RENTAL_ID
        left join ANALYTICS.GS.AR_BB_CUSTOMER_GROUPING cg
        on try_cast(cg.CUSTOMER_ID as number) = i.COMPANY_ID
        left join ES_WAREHOUSE.PUBLIC.COMPANIES c on c.COMPANY_ID = i.COMPANY_ID
        left join na_companies na on na.COMPANY_ID = i.COMPANY_ID-- and i.INVOICE_DATE::DATE <= na.EFFECTIVE_END_DATE::DATE
        where na.COMPANY_ID is not null --filter to get the NA list of companies
        group by 1,2,3,4
        order by 1,2
        ),

        -----------------------------------------------------------------------------Breakeven Rate Data for Core/AS/ITL Classes------------------------------------------------------------------------

        -- At the region and class level
        company_restrictions as (select COMPANY_ID
        FROM ES_WAREHOUSE.public.companies
        WHERE name regexp 'IES\\d+ .*'-- captures all IES# company_ids
        OR COMPANY_ID = 420 -- Demo Units
        OR COMPANY_ID = 62875 -- ES Owned special events - still owned by us
        OR COMPANY_ID in (1854, 1855) -- ES Owned
        OR COMPANY_ID = 61036 -- ES Owned - Trekker Temporary Holding
        --CONTRACTOR OWNED/OWN PROGRAM
        OR COMPANY_ID IN (SELECT DISTINCT AA.COMPANY_ID
        FROM ES_WAREHOUSE.PUBLIC.V_PAYOUT_PROGRAMS VPP
        JOIN ES_WAREHOUSE.PUBLIC.ASSETS_AGGREGATE AA ON VPP.ASSET_ID = AA.ASSET_ID
        WHERE CURRENT_TIMESTAMP >= VPP.START_DATE
        AND CURRENT_TIMESTAMP < COALESCE(VPP.END_DATE, '2099-12-31'))),


        region_and_equipment_class as (SELECT DISTINCT
        ec.EQUIPMENT_CLASS_ID,
        ec.category_id,
        ec.NAME,
        ec.company_id,
        ec.RENTABLE
        FROM ES_WAREHOUSE.PUBLIC.EQUIPMENT_CLASSES ec
        where ec.DELETED = FALSE
        AND COMPANY_ID = 1854
        group by 1,2,3,4,5),


        -- Total Costs = Amort + Rental Commission + Service Costs

        -- We can consider this to be 1.5% of OEC per month. Calculate OEC on a class level by taking the average nonzero OEC of all assets within the class.
        -- Amort = .015 * AVG(OEC)
        OEC as (select EQUIPMENT_CLASS_ID,
        avg(OEC) as avg_oec,
        avg(case when oec > 20 then oec else null end) as avg_oec_clean,
        sum(case when oec > 20 then oec else 0 end) as oec_sum,
        sum(case when oec is null then 1 else 0 end) as null_oec_count,
        sum(case when oec <= 20 then 1 else 0 end) as low_oec_count
        from ES_WAREHOUSE.PUBLIC.ASSETS_AGGREGATE
        WHERE COMPANY_ID in (SELECT COMPANY_ID FROM company_restrictions)
        group by 1),

        -- Assume 4% commission across the board. Although many of these rates may fall below floor, there will likely be a commission exception put in place for national accounts.
        -- This means that 4% of the rental revenue will be paid out to the reps.
        -- Rental Commission = Monthly Floor Rate * .04 * Monthly Time Ute

        region_floor_rates as (SELECT EQUIPMENT_CLASS_ID,
        MAX(CASE WHEN region_name = 'Pacific' THEN monthly_floor_rate END) AS Pacific_monthly_floor_rate,
        MAX(CASE WHEN region_name = 'Mountain West' THEN monthly_floor_rate END) AS Mountain_West_monthly_floor_rate,
        MAX(CASE WHEN region_name = 'Southwest' THEN monthly_floor_rate END) AS Southwest_monthly_floor_rate,
        MAX(CASE WHEN region_name = 'Midwest' THEN monthly_floor_rate END) AS Midwest_monthly_floor_rate,
        MAX(CASE WHEN region_name = 'Southeast' THEN monthly_floor_rate END) AS Southeast_monthly_floor_rate,
        MAX(CASE WHEN region_name = 'Northeast' THEN monthly_floor_rate END) AS Northeast_monthly_floor_rate,
        MAX(CASE WHEN region_name = 'Industrial' THEN monthly_floor_rate END) AS Industrial_monthly_floor_rate,
        MAX(CASE WHEN region_name = 'Southwest O&G' THEN monthly_floor_rate END) AS Southwest_OnG_monthly_floor_rate
        FROM (SELECT brr.EQUIPMENT_CLASS_ID,
        rr.region_name,
        mode(brr.PRICE_PER_MONTH) as monthly_floor_rate
        FROM es_warehouse.public.branch_rental_rates brr
        LEFT JOIN analytics.RATE_ACHIEVEMENT.RATE_REGIONS rr on brr.BRANCH_ID = rr.MARKET_ID
        WHERE brr.ACTIVE = TRUE
        and region is not null
        and RATE_TYPE_ID = 3
        group by 1, 2
        having monthly_floor_rate > 1
        order by 1, 2
        )
        group by 1
        order by 1,2),

        region_online_rates as (SELECT brr.EQUIPMENT_CLASS_ID,
        rr.region_name,
        mode(brr.PRICE_PER_MONTH) as monthly_online_rate
        FROM es_warehouse.public.branch_rental_rates brr
        LEFT JOIN analytics.RATE_ACHIEVEMENT.RATE_REGIONS rr on brr.BRANCH_ID = rr.MARKET_ID
        WHERE brr.ACTIVE = TRUE
        and region is not null
        and RATE_TYPE_ID = 1
        group by 1,2
        having monthly_online_rate >1
        order by 1,2),

        floor_rates as (SELECT brr.EQUIPMENT_CLASS_ID,
        avg(brr.PRICE_PER_MONTH) as company_monthly_floor_rate
        FROM es_warehouse.public.branch_rental_rates brr
        LEFT JOIN analytics.RATE_ACHIEVEMENT.RATE_REGIONS rr on brr.BRANCH_ID = rr.MARKET_ID
        WHERE brr.ACTIVE = TRUE
        and RATE_TYPE_ID = 3
        group by 1
        having company_monthly_floor_rate >1
        order by 1),

        online_rates as (SELECT brr.EQUIPMENT_CLASS_ID,
        avg(brr.PRICE_PER_MONTH) as company_monthly_online_rate
        FROM es_warehouse.public.branch_rental_rates brr
        LEFT JOIN analytics.RATE_ACHIEVEMENT.RATE_REGIONS rr on brr.BRANCH_ID = rr.MARKET_ID
        WHERE brr.ACTIVE = TRUE
        and RATE_TYPE_ID = 1
        group by 1
        having company_monthly_online_rate >1
        order by 1),

        -- Desired output: average maintenance cost per rental day on a class level
        -- Use `ES_WAREHOUSE.SCD.SCD_ASSET_RENTAL_STATUS` to get number of rental days by asset, and make sure to annualize for the dates used in the cost of maintenance code
        -- Service Costs = Avg(Cost per rental per day) * (Monthly Time Ute * 30 days)

        -----------------------------------------------------------------------------------------------Start Heidi's Query---------------------------------------------------------------------------------------------------------------

        service_cost as (
        -- SET BEG_OF_YR = '2022-01-01';
        -- SET END_OF_YR = '2023-12-31'; -- "trusted" date range
        with classes as (select aa.asset_id
        , avg(oec) over (partition by equipment_class_id) as class_oec -- we don't want to look at classes with an avg OEC under a certain $$
        from ES_WAREHOUSE.PUBLIC.ASSETS_AGGREGATE aa
        --                           join analytics.public.ES_COMPANIES ec --filtering to ES assets
        --                                on aa.COMPANY_ID = ec.COMPANY_ID
        where oec is not null
        and oec > 0
        and aa.ASSET_TYPE_ID = 1
        --                      qualify class_oec >= 10000 commented out since we want all OECs
        )
        , rental_rev as (select distinct hu.asset_id
        , aa.EQUIPMENT_CLASS_ID
        , aa.INVENTORY_BRANCH_ID
        , aa.make
        , aa.model
        , aa.class
        , aa.company_id
        , hu.FIRST_RENTAL
        , datediff(year, HU.FIRST_RENTAL, DTE)                              asset_age_rev
        , sum(hu.DAY_RATE) over (partition by hu.ASSET_ID,asset_age_rev) as revenue
        , count(*) over (partition by HU.ASSET_ID, asset_age_rev)        as asset_days_in_fleet
        , (asset_days_in_fleet / 365)                                    as year_portion
        , aa.oec * year_portion                                          as oec_portion
        , sum(hu.DAY_RATE) over (partition by aa.EQUIPMENT_CLASS_ID)     as class_revenue --This isn't used and we'd want to change the logic if it were
        , count(*) over (partition by aa.EQUIPMENT_CLASS_ID)             as class_days_in_fleet
        , class_revenue / class_days_in_fleet                            as class_daily_revenue
        , COUNT_IF(ON_RENT = TRUE) over (partition by hu.ASSET_ID, asset_age_rev) as rented_days_per_asset_per_year
        from ANALYTICS.PUBLIC.HISTORICAL_UTILIZATION HU
        left join ES_WAREHOUSE.PUBLIC.ASSETS_AGGREGATE aa
        on hu.ASSET_ID = aa.ASSET_ID
        join classes c --filtering to classes 10K+
        on hu.ASSET_ID = c.ASSET_ID
        join es_warehouse.scd.scd_asset_rsp r
        on hu.asset_id = r.asset_id
        and hu.dte >= r.date_start and hu.dte < r.date_end
        where DTE between '2022-01-01' and '2023-12-31'
        and r.rental_branch_id is not null --this is in place of in_rental_fleet
        and hu.FIRST_RENTAL is not null
        and RERENT_INDICATOR = FALSE
        )
        , wac_prep as ( -- suppressing overridden wac snapshots based on date_applied values
        select *
        from es_warehouse.inventory.weighted_average_cost_snapshots wacs
        where date_applied::date < '2024-01-03'
        and date_applied::date > '2023-12-09'
        qualify
        row_number() over (
        partition by wacs.inventory_location_id, wacs.product_id, date_applied
        order by wacs.date_created desc)
        = 1
        and
        min(wacs.DATE_APPLIED) over (partition by wacs.PRODUCT_ID, wacs.INVENTORY_LOCATION_ID)
        = wacs.DATE_APPLIED
        order by product_id, INVENTORY_LOCATION_ID, date_applied desc)
        , wac_test as (select distinct wp.product_id
        , k.MASTER_PART_ID
        , p.DUPLICATE_OF_ID
        , avg(wp.WEIGHTED_AVERAGE_COST) over (partition by k.master_part_id) as avg_cost_master_cw
        , avg(wp.WEIGHTED_AVERAGE_COST) over (partition by wp.product_id)    as avg_cost_part_cw --pretty sure i can take this out
        from wac_prep wp
        join ANALYTICS.PARTS_INVENTORY.PARTS k -- superceded loop logic
        on wp.PRODUCT_ID = k.PART_ID
        join ES_WAREHOUSE.INVENTORY.PARTS p
        on wp.PRODUCT_ID = p.PART_ID
        where wp.WEIGHTED_AVERAGE_COST not in (0, 0.01))
        , parts_per_WO AS (SELECT IFF(TRANSACTION_TYPE_ID = 7, t.TO_ID, t.FROM_ID)                              as work_order_id
        , t.DATE_COMPLETED::date                                                        as date_completed
        , k.MASTER_PART_ID                                                              as part_id
        , wt.PRODUCT_ID
        , sum(IFF(transaction_type_id = 7, ti.quantity_received, 0 -
        ti.quantity_received)) AS final_qty
        , coalesce(wt.avg_cost_master_cw, wt2.avg_cost_part_cw, 0)                      as ac --pretty sure this is unnecessary
        , final_qty * ac                                                                   parts_cost
        FROM ES_WAREHOUSE.INVENTORY.TRANSACTIONS t
        LEFT JOIN ES_WAREHOUSE.INVENTORY.TRANSACTION_ITEMS ti
        ON t.TRANSACTION_ID = ti.TRANSACTION_ID
        left join ANALYTICS.PARTS_INVENTORY.PARTS k -- superceded loop logic
        on ti.PART_ID = k.PART_ID
        left join ANALYTICS.PARTS_INVENTORY.TELEMATICS_PART_IDS tpi
        on ti.PART_ID = tpi.PART_ID
        left join ES_WAREHOUSE.INVENTORY.PROVIDERS pr
        on k.PROVIDER_ID = pr.PROVIDER_ID
        join analytics.public.ES_COMPANIES c
        on pr.company_id = c.COMPANY_ID
        left join wac_test wt
        on k.MASTER_PART_ID = wt.PRODUCT_ID
        left join wac_test wt2
        on ti.part_id = wt2.PRODUCT_ID
        WHERE TRANSACTION_TYPE_ID IN (7, 9)
        and t.DATE_CANCELLED is null
        and t.DATE_COMPLETED::date between '2022-01-01' and '2023-12-31'
        and tpi.PART_ID is null -- suppress telematics parts
        group by WORK_ORDER_ID, t.date_completed::date, k.MASTER_PART_ID, wt.PRODUCT_ID, ac
        --having final_qty > 0
        )
        , wo_pop
        as ( --this is for joining to avoid having to refilter multiple ctes. population for the expected hours calc, the pop that its applied to will be smaller
        select wo.*
        from ES_WAREHOUSE.WORK_ORDERS.WORK_ORDERS wo --change this to specific fields at some point
        join ES_WAREHOUSE.PUBLIC.MARKETS m
        on wo.BRANCH_ID = m.MARKET_ID
        join ANALYTICS.PUBLIC.ES_COMPANIES c
        on m.COMPANY_ID = c.COMPANY_ID
        join ES_WAREHOUSE.PUBLIC.ASSETS_AGGREGATE aa
        on wo.asset_id = aa.asset_id
        where                        --wo.DATE_BILLED between '2022-01-01' and '2023-12-31' -- taking out for the BE comparison
        -- and wo.date_completed is not null
        wo.ARCHIVED_DATE is null --taking out for the BE comparison
        and wo.ASSET_ID is not null
        and aa.FIRST_RENTAL < wo.DATE_COMPLETED --getting rid of MMRs
        --and WORK_ORDER_TYPE_ID = 1 --taking out for the BE comparison
        )                --general work orders, no inspections
        , wo_parts as (select                                                                    --WORK_ORDER_ID
        wo.asset_id
        , datediff(years, aa.FIRST_RENTAL, p.date_completed) asset_age_parts --changed to this date for BE
        , sum(final_qty)  as                                 wo_part_qty
        , sum(parts_cost) as                                 wo_part_cost
        from parts_per_WO p
        join wo_pop wo
        on p.work_order_id = wo.WORK_ORDER_ID
        join ES_WAREHOUSE.PUBLIC.ASSETS_AGGREGATE aa
        on wo.asset_id = aa.asset_id
        group by wo.asset_id, asset_age_parts)
        , wo_hours as (select                                                                                   --te.work_order_id
        wo.ASSET_ID
        , datediff(years, aa.FIRST_RENTAL, te.END_DATE)                     asset_age_labor --will this align with BE? or are they using pay dates?
        , sum(zeroifnull(te.regular_hours) + zeroifnull(te.overtime_hours)) total_hours
        from ES_WAREHOUSE.TIME_TRACKING.TIME_ENTRIES te
        join wo_pop wo
        on te.work_order_id = wo.WORK_ORDER_ID
        join ES_WAREHOUSE.PUBLIC.ASSETS_AGGREGATE aa
        on wo.asset_id = aa.asset_id
        where te.EVENT_TYPE_ID = 1 -- ON DUTY
        and te.APPROVAL_STATUS like 'Approved'
        and te.work_order_id is not null
        and datediff('hour'
        , te.START_DATE
        , te.END_DATE)
        <= 12                  --??
        and te.END_DATE between '2022-01-01' and '2023-12-31'
        group by wo.asset_id, asset_age_labor)
        , customer_damage_recovery as ( --may need to add asset ownership scd
        select sum(amount)                                              customer_rev
        , v.asset_id
        , datediff(year, aa.FIRST_RENTAL, i.billing_approved_date) asset_age_invoice
        from ANALYTICS.PUBLIC.V_LINE_ITEMS v
        join ES_WAREHOUSE.PUBLIC.INVOICES i
        on v.invoice_id = i.invoice_id
        join ES_WAREHOUSE.PUBLIC.ASSETS_AGGREGATE aa
        on v.asset_id = aa.asset_id
        left join analytics.public.es_companies c
        on i.company_id = c.company_id
        where line_item_type_id in (25, 26)
        and i.billing_approved_date is not null
        and c.company_id is null --getting rid of internal bills, this will still get OWN bills
        and i.BILLING_APPROVED_DATE between '2022-01-01'
        and '2023-12-31'
        group by v.asset_id, asset_age_invoice)
        , invoice_amt as (select li.invoice_id,
        max(branch_id)       as branch_id,
        sum(amount)          as total_amt,
        max(li.date_created) as date_created
        from ES_WAREHOUSE.PUBLIC.line_items li
        JOIN ES_Warehouse.PUBLIC.Invoices i
        ON li.invoice_id = i.invoice_id
        left join analytics.public.es_companies c
        on i.company_id = c.company_id
        where line_item_type_id in (22, 23)
        AND c.company_id is null --getting rid of internal bills
        group by li.invoice_id)
        , invoice_asset_info as (select invoice_id, --may need to add asset ownership scd here
        max(asset_id) as asset_id
        from ES_WAREHOUSE.PUBLIC.line_items li
        where asset_id is not null
        group by invoice_id)
        , credit_payments as (select p.invoice_id
        , sum(amount)   as credit_amt
        , DENIED_AMOUNT as denied_amt
        from ES_WAREHOUSE.PUBLIC.payment_applications p
        LEFT JOIN (SELECT SUM(PAY_APPLY.AMOUNT) AS DENIED_AMOUNT
        , ADMINV.INVOICE_NO
        , ADMINV.INVOICE_ID
        FROM ES_WAREHOUSE.PUBLIC.PAYMENTS ARPAY
        LEFT JOIN ES_WAREHOUSE.PUBLIC.BANK_ACCOUNT_ERP_REFS BANK_ERP
        ON ARPAY.BANK_ACCOUNT_ID = BANK_ERP.BANK_ACCOUNT_ID
        LEFT JOIN ES_WAREHOUSE.PUBLIC.PAYMENT_APPLICATIONS PAY_APPLY
        ON ARPAY.PAYMENT_ID = PAY_APPLY.PAYMENT_ID
        LEFT JOIN ES_WAREHOUSE.PUBLIC.INVOICES ADMINV
        ON PAY_APPLY.INVOICE_ID = ADMINV.INVOICE_ID
        left join analytics.public.es_companies c
        on adminv.company_id = c.company_id
        LEFT JOIN (SELECT DISTINCT SUBSTR(APR.DOCNUMBER, 12, 100) AS PAYMENT_ID
        FROM ANALYTICS.INTACCT.APRECORD APR
        WHERE APR.RECORDTYPE = 'apbill'
        AND APR.DOCNUMBER LIKE ('WTY_PMT_ID:%')) PMT_ID_SYNCED
        ON TO_VARCHAR(ARPAY.PAYMENT_ID) = PMT_ID_SYNCED.PAYMENT_ID
        WHERE BANK_ERP.INTACCT_UNDEPFUNDSACCT IN ('5316', '1212')
        AND ARPAY.STATUS != 1    --PAYMENT NOT REVERSED
        AND c.COMPANY_ID is null --internal
        GROUP BY ADMINV.INVOICE_NO
        , ADMINV.INVOICE_ID) d
        ON p.invoice_id = d.invoice_id
        GROUP BY p.INVOICE_ID
        , d.denied_amount)
        , credit_memo as (SELECT ARH.CUSTOMERID  AS CUSTOMER_ID,
        ARH.DOCNUMBER   AS INVOICE_NO,
        I.INVOICE_ID,
        SUM(ARD.AMOUNT) AS CM_AMOUNT
        FROM ANALYTICS.INTACCT.ARRECORD ARH
        LEFT JOIN ANALYTICS.INTACCT.ARDETAIL ARD
        ON ARH.RECORDNO = ARD.RECORDKEY
        LEFT JOIN ES_WAREHOUSE.Public.Invoices I
        ON ARH.DOCNUMBER = I.INVOICE_NO
        left join analytics.public.es_companies c
        on i.company_id = c.company_id
        WHERE ARH.RECORDTYPE = 'aradjustment'
        AND ARD.AMOUNT != 0
        AND c.company_id is null --internal bills
        GROUP BY ARH.CUSTOMERID
        , ARH.DOCNUMBER
        , I.Invoice_ID)
        , invoice_credited as (select invoice_id, invoice_no, billing_approved_date, paid
        from ES_WAREHOUSE.PUBLIC.invoices i
        where billing_approved_date is not null)
        , warranty_summary_draft as (select ia.invoice_id,
        ia.branch_id,
        ia.date_created,
        ai.asset_id,
        ia.total_amt,
        CASE
        when ic.paid = 'Yes' THEN ia.total_amt - zeroIFNULL(cp.denied_amt) -
        zeroIFNULL(ABS(cm.cm_amount))
        ELSE 0
        END AS Paid_amt,
        cp.credit_amt,
        ic.invoice_no,
        ic.paid,
        ic.billing_approved_date
        from invoice_amt ia
        left join invoice_asset_info ai
        on ia.invoice_id = ai.invoice_id
        left join credit_payments cp on ia.invoice_id = cp.invoice_id
        left join invoice_credited ic on ia.invoice_id = ic.invoice_id
        left join credit_memo cm on ia.invoice_id = cm.invoice_id
        where ic.BILLING_APPROVED_DATE between '2022-01-01'
        and '2023-12-31')
        , asset_warranty_payments_summary as (select wsd.asset_id
        , sum(wsd.paid_amt)                                             warranty_rev
        , datediff(year, aa.FIRST_RENTAL, wsd.billing_approved_date) as asset_age_warranty --  does not include make ready
        from warranty_summary_draft wsd
        join ES_WAREHOUSE.PUBLIC.ASSETS_AGGREGATE aa
        on wsd.asset_id = aa.ASSET_ID
        where wsd.paid_amt > 0
        group by wsd.asset_id, asset_age_warranty)
        , asset_combo as (select rr.asset_id
        , rr.EQUIPMENT_CLASS_ID
        , rr.INVENTORY_BRANCH_ID
        , rr.make
        , rr.model
        , rr.class
        , rr.asset_age_rev   asset_age
        , rr.revenue
        , rr.year_portion
        , rr.oec_portion
        , wp.warranty_rev
        , cp.customer_rev
        , p.wo_part_cost     parts_cost
        , h.total_hours * 45 labor_cost
        , rr.rented_days_per_asset_per_year
        --                           , wo.lost_rev
        --                           , wo.parts_cost
        --                           , wo.labor_cost
        from rental_rev rr
        left join asset_warranty_payments_summary wp
        on rr.asset_id = wp.asset_id
        and rr.asset_age_rev = wp.asset_age_warranty
        left join customer_damage_recovery cp
        on rr.ASSET_ID = cp.ASSET_ID
        and rr.asset_age_rev = cp.asset_age_invoice
        --                               left join wo_expenses wo
        --                                         on rr.asset_id = wo.ASSET_ID
        --                                             and rr.asset_age_rev = wo.asset_age_wo
        left join wo_hours h
        on rr.asset_id = h.ASSET_ID
        and rr.asset_age_rev = h.asset_age_labor
        left join wo_parts p
        on rr.ASSET_ID = p.asset_id
        and rr.asset_age_rev = p.asset_age_parts),

        og as (
        select          a.EQUIPMENT_CLASS_ID
        --                  , a.make
        --                  , a.model
        , a.class
        --, a.asset_age + 1                 asset_age
        , count(distinct a.asset_id)      dist_asset_count
        , dist_asset_count / sum(dist_asset_count) over (partition by CLASS )    perc_total
        , sum(year_portion)               assets_years -- this is for scaling to per asset per year cost
        , sum(a.rented_days_per_asset_per_year)                rental_day
        , sum(oec_portion)                oec_years
        , sum(a.revenue)                  rental_rev
        --, sum(a.lost_rev)                 lost_rev
        , sum(a.warranty_rev)             warranty_rev
        , sum(a.customer_rev)             damage_rev
        , sum(a.parts_cost)               parts_exp
        , sum(a.labor_cost)               labor_exp
        , sum(zeroifnull(a.parts_cost) + zeroifnull(a.labor_cost) - zeroifnull(a.warranty_rev) -
        zeroifnull(a.customer_rev)) cost_to_own
        --                  , cost_to_own / oec_years         cost_ratio_oec
        --                  , cost_to_own / rental_rev        cost_ratio_rev
        --                  , oec_years / assets_years        weighted_avg_oec
        --                  , cost_to_own / assets_years      wac_per_year
        from asset_combo a
        group by
        EQUIPMENT_CLASS_ID
        , a.class
        --  qualify perc_total >= .1
        order by EQUIPMENT_CLASS_ID, class
        )

        select EQUIPMENT_CLASS_ID,
        class,
        --        make,
        --        model,
        sum(dist_asset_count) dist_asset_count
        , sum(assets_years) asset_years
        , sum(rental_day) rental_days
        , sum(oec_years) oec_class_years
        , sum(rental_rev) rental_rev_class
        , sum(cost_to_own) cost_of_main
        , cost_of_main/nullifzero(oec_class_years) cost_ratio_oec
        , cost_of_main/nullifzero(rental_rev_class) cost_ratio_rev
        , oec_class_years/nullifzero(asset_years) weighted_avg_oec
        , cost_of_main/nullifzero(asset_years) wac_per_year
        , IFF(cost_of_main/nullifzero(rental_days) > 0, cost_of_main/rental_days, 0)  wac_per_rental_day
        --        ,wac_per_year/sum(rental_days) --add rental_days and confirm asset years is not an integer
        --, dist_asset_count / sum(dist_asset_count) over (partition by CLASS )      perc_total
        --, abs(dist_asset_count - avg(dist_asset_count) over (partition by CLASS )) spread
        from og
        group by EQUIPMENT_CLASS_ID, class--, make, model
        order by rental_rev_class desc, class),



        -----------------------------------------------------------------------------------------------End Heidi's Query---------------------------------------------------------------------------------------------------------------



        breakeven_rates_final as (
        SELECT rec.equipment_class_id,
        rec.name as equipment_class_name,
        c.name as category_name,
        nullifzero(o.oec_sum) as total_oec,
        o.avg_oec_clean as avg_oec,
        CASE
        WHEN avg_oec is not null then ROUND(0.015 * o.avg_oec_clean,2)
        ELSE nullifzero(ROUND(.37 * fr.company_monthly_floor_rate,2)) end as monthly_amort, --adding in Amort (if OEC is missing)
        nullifzero(ROUND(sc.wac_per_rental_day,2)) as cost_per_rental_day,
        COALESCE(ROUND(cost_per_rental_day * 30.4,2),0) as monthly_service_costs,
        fr.company_monthly_floor_rate,
        ro.company_monthly_online_rate,
        Pacific_monthly_floor_rate,
        Mountain_west_monthly_floor_rate,
        Southwest_monthly_floor_rate,
        Midwest_monthly_floor_rate,
        Southeast_monthly_floor_rate,
        Northeast_monthly_floor_rate,
        Industrial_monthly_floor_rate,
        Southwest_OnG_monthly_floor_rate,
        rec.company_id,
        rec.rentable
        from region_and_equipment_class rec
        LEFT JOIN OEC o on o.EQUIPMENT_CLASS_ID = rec.EQUIPMENT_CLASS_ID
        LEFT JOIN floor_rates fr on fr.EQUIPMENT_CLASS_ID = rec.EQUIPMENT_CLASS_ID
        LEFT JOIN online_rates ro on ro.EQUIPMENT_CLASS_ID = rec.EQUIPMENT_CLASS_ID
        LEFT JOIN region_floor_rates rfr on rfr.EQUIPMENT_CLASS_ID = rec.EQUIPMENT_CLASS_ID
        LEFT JOIN region_online_rates ror on ror.EQUIPMENT_CLASS_ID = rec.EQUIPMENT_CLASS_ID
        LEFT JOIN service_cost sc on sc.EQUIPMENT_CLASS_ID = rec.EQUIPMENT_CLASS_ID
        LEFT JOIN ES_WAREHOUSE.public.categories c on c.category_id = rec.category_id
        group by 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20
        order by 1,2),


        --------------------------combo---------------------------
        FINAL as (
        select *,
        IFF(IS_NULL_VALUE(NULLIFZERO(b.monthly_amort)),null, b.monthly_amort+b.monthly_service_costs+monthly_commission_amount+monthly_rebate_amount) as breakeven_rate_temp,
        CASE
        WHEN rr.BUSINESS_SEGMENT_ID IN (1,2) and rr.SHIFT_TYPE_ID = 2 THEN 1.5*breakeven_rate_temp
        WHEN rr.BUSINESS_SEGMENT_ID IN (1,2) and rr.SHIFT_TYPE_ID = 3 THEN 2*breakeven_rate_temp
        ELSE breakeven_rate_temp
        END AS breakeven_rate,
        CASE WHEN cycle_length>0 then IFF(IS_NULL_VALUE(NULLIFZERO(breakeven_rate)),null,  rr.rental_revenue - ((breakeven_rate/28) * cycle_length) )
            else IFF(IS_NULL_VALUE(NULLIFZERO(breakeven_rate)),null,  (1 - (breakeven_rate/NULLIFZERO(rr.monthly_rate))) * rr.rental_revenue) end as gross_profit_margin,
--        IFF(IS_NULL_VALUE(NULLIFZERO(breakeven_rate)),null,  (1 - (breakeven_rate/NULLIFZERO(rr.monthly_rate))) * rr.rental_revenue) as gross_profit_margin,
        CASE WHEN cycle_length>0 then IFF(IS_NULL_VALUE(NULLIFZERO(gross_profit_margin)),null,(rr.rental_revenue - ((breakeven_rate/28) * cycle_length))/rr.rental_revenue)
            else IFF(IS_NULL_VALUE(NULLIFZERO(gross_profit_margin)),null,gross_profit_margin/NULLIFZERO(rr.rental_revenue)) end as gross_profit_margin_pct
--         IFF(IS_NULL_VALUE(NULLIFZERO(gross_profit_margin)),null,gross_profit_margin/NULLIFZERO(rr.rental_revenue)) as gross_profit_margin_pct
        from rental_revenue_per_class rr
        left join breakeven_rates_final b on b.EQUIPMENT_CLASS_ID = rr.equipment_class_id
        order by company_name, rr.equipment_class_id, monthly_rate),

        -------------------------------------------------End of Breakeven Rates Data for Core/AS/ITL Classes------------------------------------------
        ---------------------------------------------------Start of Breakeven Rates Data for Bulk Rentals---------------------------------------------

        wac as (
        with wac_prep as (
        select *
        from es_warehouse.inventory.weighted_average_cost_snapshots wacs
        --where date_applied::date <= $END_OF_MTH
        qualify
        row_number() over (
        partition by wacs.inventory_location_id, wacs.product_id, date_applied
        order by wacs.date_created desc)
        = 1
        and
        max(date_applied) over (
        partition by PRODUCT_ID, INVENTORY_LOCATION_ID
        order by date_applied desc)
        = date_applied
        order by product_id, INVENTORY_LOCATION_ID, date_applied desc),

        avg_cost_per_part_company_wide as (
        select product_id as part_id
        , round(avg(weighted_average_cost),2) as average_cost_co
        from wac_prep
        group by part_id)

        SELECT * FROM avg_cost_per_part_company_wide),


        bulk_parts as (
        select pc.PRODUCT_CLASS_ID,
        pc.CAT_CLASS,
        pc.CATEGORY_NAME,
        pc.CLASSIFICATION,
        p.PART_ID,
        p.NAME as part_description,
        p.msrp,
        w.average_cost_co
        from ES_WAREHOUSE.INVENTORY.PRODUCT_CLASSES pc
        left join ES_WAREHOUSE.INVENTORY.PARTS p on pc.PRODUCT_CLASS_ID = p.PRODUCT_CLASS_ID
        left join wac w on w.part_id = p.PART_ID
        where p.PRODUCT_CLASS_ID is not null
        order by cat_class),

        bulk_part_costs_per_product_class_id as (
        SELECT
        CAT_CLASS,
        CATEGORY_NAME,
        CLASSIFICATION,
        AVG(COALESCE(msrp, average_cost_co)) as cost,
        .0196*cost as monthly_amort
        FROM bulk_parts
        group by 1,2,3
        order by 2),

        bulk_online as (
        select
        br.cat_class,
        mode(br.PRICE_PER_HOUR) as PRICE_PER_HOUR,
        mode(br.price_per_day)   as price_per_day,
        mode(br.price_per_week)  as price_per_week,
        mode(br.price_per_month) as PRICE_PER_MONTH
        from BULK_RATES.public.bulk_rates br
        join ANALYTICS.RATE_ACHIEVEMENT.RATE_REGIONS rr on br.branch_id = rr.MARKET_ID
        where br.rate_type_id = 1
        group by 1--, 2, 3
        ),

        bulk_rentals as (select
        p.COMPANY_ID,
        pc.CAT_CLASS,
        p.NAME,
        pc.CLASSIFICATION,
        pc.CATEGORY_NAME,
        li.INVOICE_ID,
        li.RENTAL_ID,
        rr.REGION,
        li.PRICE_PER_UNIT,
        li.NUMBER_OF_UNITS,
        li.AMOUNT,
        li.EXTENDED_DATA:rental:price_per_hour::number  as price_per_hour,
        li.EXTENDED_DATA:rental:price_per_day::number   as price_per_day,
        li.EXTENDED_DATA:rental:price_per_week::number  as price_per_week,
        li.EXTENDED_DATA:rental:price_per_month::number as price_per_month,
        bc.cost,
        bc.monthly_amort
        from ES_WAREHOUSE.PUBLIC.LINE_ITEMS li
        left join ES_WAREHOUSE.INVENTORY.PARTS p on li.EXTENDED_DATA:part_id = p.PART_ID
        left join ES_WAREHOUSE.INVENTORY.PRODUCT_CLASSES pc on p.PRODUCT_CLASS_ID = pc.PRODUCT_CLASS_ID
        left join ANALYTICS.RATE_ACHIEVEMENT.RATE_REGIONS rr on li.BRANCH_ID = rr.MARKET_ID
        LEFT JOIN bulk_part_costs_per_product_class_id bc on pc.cat_class = bc.CAT_CLASS
        where li.LINE_ITEM_TYPE_ID = 44
        and li.EXTENDED_DATA:part_id is not null),


        rental_revenue_per_class_bulk as (select COALESCE(cg.CUSTOMER_GROUP_NAME, c.Name)                                   as parent_company_name,
        na.parent_company_name_na,
        c.Name as company_name,
        na.sales_director,
        i.INVOICE_ID,
        li.LINE_ITEM_ID,
        pc.CAT_CLASS                                                       as equipment_class_id,
        --                                          i.INVOICE_DATE::DATE as Invoice_date,
        QUARTER(i.INVOICE_DATE)                                                      as Invoice_quarter,
        YEAR(i.INVOICE_DATE)                                                         as invoice_year,
        case
        when (r.PRICE_PER_MONTH is null and r.PRICE_PER_WEEK is null and
        r.PRICE_PER_DAY is not null)
        then li.EXTENDED_DATA:rental:price_per_day::number * 28
        else li.EXTENDED_DATA:rental:price_per_month::number end               as monthly_rate,
        null                                                         as floor_rate,
        o.PRICE_PER_MONTH                                                             as online_rate,
        li.NUMBER_OF_UNITS,
        li.AMOUNT                                                                  as rental_revenue,
        case
        when (r.PRICE_PER_MONTH is null and r.PRICE_PER_WEEK is null and
        r.PRICE_PER_DAY is not null)
        then o.PRICE_PER_MONTH / 28 * datediff(day, i.START_DATE, i.END_DATE) * NUMBER_OF_UNITS
        else ((li.EXTENDED_DATA:rental:cheapest_period_hour_count * o.PRICE_PER_HOUR) +
        (li.EXTENDED_DATA:rental:cheapest_period_day_count * o.PRICE_PER_DAY) +
        (li.EXTENDED_DATA:rental:cheapest_period_week_count * o.PRICE_PER_WEEK) +
        (li.EXTENDED_DATA:rental:cheapest_period_month_count *
        o.PRICE_PER_MONTH)) * NUMBER_OF_UNITS end                                           as revenue_at_online,
        case
        when (o.PRICE_PER_MONTH is not null)
        then li.AMOUNT
        else 0 end                                                             as revenue_with_online,
        ec.BUSINESS_SEGMENT_ID,
        r.SHIFT_TYPE_ID,
        .05                                                                        as commission_pct,
        commission_pct * monthly_rate                                              as monthly_commission_amount,
        --                                          COALESCE(CASE
        --                                                       WHEN YEAR(INVOICE_DATE) = 2023 THEN rp.rebate_percent_achieved
        --                                                       WHEN YEAR(INVOICE_DATE) = 2024 THEN rp.rebate_percent end,
        --                                                   0)                                                                as rebate_pct,
        rp.paid_in_days,
        YEAR(CURRENT_DATE()) as CURRENT_YEAR,
        DATEADD(DAY, (-1*rp.paid_in_days), CURRENT_DATE()) as current_date_minus_paid_in_days,
        COALESCE(CASE
        WHEN YEAR(INVOICE_DATE) >= CURRENT_YEAR THEN rp.rebate_percent
        ELSE
        CASE
        WHEN INVOICE_DATE::DATE < current_date_minus_paid_in_days THEN rp.rebate_percent_achieved
        WHEN INVOICE_DATE::DATE >= current_date_minus_paid_in_days THEN rp.rebate_percent
        end
        end,
        0)                                                                as rebate_pct,
        rebate_pct * monthly_rate                                                  as monthly_rebate_amount
        from ES_WAREHOUSE.PUBLIC.INVOICES i
        left join analytics.public.v_LINE_ITEMS li on i.INVOICE_ID = li.INVOICE_ID
        left join ES_WAREHOUSE.INVENTORY.PARTS p on li.EXTENDED_DATA:part_id = p.PART_ID
        LEFT JOIN ES_WAREHOUSE.INVENTORY.PRODUCT_CLASSES pc on pc.PRODUCT_CLASS_ID = p.PRODUCT_CLASS_ID
        left join ES_WAREHOUSE.PUBLIC.RENTALS r on li.RENTAL_ID = r.RENTAL_ID
        left join ANALYTICS.GS.AR_BB_CUSTOMER_GROUPING cg
        on try_cast(cg.CUSTOMER_ID as number) = i.COMPANY_ID
        left join ES_WAREHOUSE.PUBLIC.COMPANIES c on c.COMPANY_ID = i.COMPANY_ID
        left join ANALYTICS.RATE_ACHIEVEMENT.RATE_SPLITS_STAGING rss
        on rss.EQUIPMENT_CLASS_ID = r.EQUIPMENT_CLASS_ID
        left join rebate_percents as rp
        --                                                      on COALESCE(cg.CUSTOMER_GROUP_NAME, c.Name) = rp.C_NAME AND
        on c.Name = rp.C_NAME AND
        i.INVOICE_DATE::DATE >= rp.REBATE_START_PERIOD::DATE AND
        i.INVOICE_DATE::DATE <= rp.REBATE_END_PERIOD::DATE
        -- applying current online rates to all historical data
        left join bulk_online o on pc.cat_class = o.cat_class
        --                                            left join floor_rate f on r.EQUIPMENT_CLASS_ID = f.EQUIPMENT_CLASS_ID
        left join na_companies na on na.COMPANY_ID = i.COMPANY_ID-- and i.INVOICE_DATE::DATE <= na.EFFECTIVE_END_DATE::DATE
        LEFT JOIN ES_WAREHOUSE.PUBLIC.EQUIPMENT_CLASSES ec on r.EQUIPMENT_CLASS_ID = ec.EQUIPMENT_CLASS_ID
        where li.LINE_ITEM_TYPE_ID = 44
        and pc.CAT_CLASS is not null
        and rental_revenue > 0
        and monthly_rate > 0
        and na.COMPANY_ID is not null --filter to get the NA list of companies
        order by 1),

        -----------------------------------------------------------------------------------------------------------------------

        breakeven_rates_final_bulk as (
        SELECT br.cat_class as equipment_class_id,
        br.CLASSIFICATION as equipment_class_name,
        br.CATEGORY_NAME as category_name,
        null as total_oec,
        null as avg_oec,
        br.monthly_amort,
        null as cost_per_rental_day,
        null as monthly_service_costs,
        null as company_monthly_floor_rate,
        bo.PRICE_PER_MONTH as company_monthly_online_rate,
        null as Pacific_monthly_floor_rate,
        null as Mountain_west_monthly_floor_rate,
        null as Southwest_monthly_floor_rate,
        null as Midwest_monthly_floor_rate,
        null as Southeast_monthly_floor_rate,
        null as Northeast_monthly_floor_rate,
        null as Industrial_monthly_floor_rate,
        null as Southwest_OnG_monthly_floor_rate,
        br.company_id,
        TRUE as rentable
        from bulk_rentals br
        LEFT JOIN bulk_online bo on bo.cat_class = br.CAT_CLASS
        group by 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20
        order by 1,2),

        final_bulk as (
        select *,
        IFF(IS_NULL_VALUE(NULLIFZERO(b.monthly_amort)),null, IFNULL(b.monthly_amort,0)+IFNULL(b.monthly_service_costs,0)+IFNULL(monthly_commission_amount,0)+IFNULL(monthly_rebate_amount,0)) as breakeven_rate_temp,
        CASE
        WHEN rr.BUSINESS_SEGMENT_ID IN (1,2) and rr.SHIFT_TYPE_ID = 2 THEN 1.5*breakeven_rate_temp
        WHEN rr.BUSINESS_SEGMENT_ID IN (1,2) and rr.SHIFT_TYPE_ID = 3 THEN 2*breakeven_rate_temp
        ELSE breakeven_rate_temp
        END AS breakeven_rate,
        CASE WHEN cycle_length>0 then IFF(IS_NULL_VALUE(NULLIFZERO(breakeven_rate)),null,  rr.rental_revenue - ((breakeven_rate/28) * cycle_length) )
            else IFF(IS_NULL_VALUE(NULLIFZERO(breakeven_rate)),null,  (1 - (breakeven_rate/NULLIFZERO(rr.monthly_rate))) * rr.rental_revenue) end as gross_profit_margin,
--        IFF(IS_NULL_VALUE(NULLIFZERO(breakeven_rate)),null,  (1 - (breakeven_rate/NULLIFZERO(rr.monthly_rate))) * rr.rental_revenue) as gross_profit_margin,
        CASE WHEN cycle_length>0 then IFF(IS_NULL_VALUE(NULLIFZERO(gross_profit_margin)),null,(rr.rental_revenue - ((breakeven_rate/28) * cycle_length))/rr.rental_revenue)
            else IFF(IS_NULL_VALUE(NULLIFZERO(gross_profit_margin)),null,gross_profit_margin/NULLIFZERO(rr.rental_revenue)) end as gross_profit_margin_pct
--         IFF(IS_NULL_VALUE(NULLIFZERO(gross_profit_margin)),null,gross_profit_margin/NULLIFZERO(rr.rental_revenue)) as gross_profit_margin_pct
        from rental_revenue_per_class_bulk rr
        left join breakeven_rates_final_bulk b on b.equipment_class_id = rr.equipment_class_id
        order by company_name, rr.equipment_class_id, monthly_rate),



        -------------------------------------------------End of Breakeven Rates Data for Bulk Rentals-------------------------------------------------

        FINAL_ALL as (

        SELECT *, 'regular_rentals' as type FROM FINAL
        UNION ALL
        SELECT *, 'bulk_rentals' as type FROM FINAL_bulk),


        all_data as (SELECT fa.*,
        o.retail_parts_sales_revenue,
        o.environmental_fees_revenue,
        o.pnd_revenue,
        o.fuel_revenue,
        o.service_revenue,
        o.rent_revenue
        FROM FINAL_ALL fa
        left join other_revenue_per_company o on o.parent_company_name_na = fa.parent_company_name_na
                                                     and fa.sales_director = o.sales_director
        and o.INVOICE_YEAR = fa.invoice_year
        and o.Invoice_quarter = fa.Invoice_quarter
        ),





        --------------------------------Retail Parts Sales-------------------------------

        retail_parts_sales as (select na.parent_company_name_na,
                                   --COALESCE(cg.CUSTOMER_GROUP_NAME, c.Name)                                  as parent_company_name,
        c.name as company_name,
        YEAR(i.INVOICE_DATE) AS INVOICE_YEAR,
        QUARTER(i.INVOICE_DATE)                                                      as Invoice_quarter,
        na.sales_director,
        li.DESCRIPTION,
        li.EXTENDED_DATA:part_id as part_id,
        li.PRICE_PER_UNIT,
        li.NUMBER_OF_UNITS,
        li.AMOUNT,
        COALESCE(p.msrp, w.average_cost_co,0) as part_cost,
        ROUND(CASE WHEN li.amount = 0 THEN 0
        WHEN li.amount < 0 THEN li.amount + (part_cost*NUMBER_OF_UNITS)
        ELSE li.amount - (part_cost*NUMBER_OF_UNITS) END,2) as gross_margin
        from ES_WAREHOUSE.PUBLIC.INVOICES i
        left join analytics.public.v_LINE_ITEMS li on i.INVOICE_ID = li.INVOICE_ID
        left join ES_WAREHOUSE.PUBLIC.RENTALS r on li.RENTAL_ID = r.RENTAL_ID
        left join ANALYTICS.GS.AR_BB_CUSTOMER_GROUPING cg
        on try_cast(cg.CUSTOMER_ID as number) = i.COMPANY_ID
        left join ES_WAREHOUSE.PUBLIC.COMPANIES c on c.COMPANY_ID = i.COMPANY_ID
        left join na_companies na on na.COMPANY_ID = i.COMPANY_ID-- and i.INVOICE_DATE::DATE <= na.EFFECTIVE_END_DATE::DATE
        left join ES_WAREHOUSE.INVENTORY.PARTS p on li.EXTENDED_DATA:part_id = p.PART_ID
        left join wac w on w.part_id = p.PART_ID
        where na.COMPANY_ID is not null --filter to get the NA list of companies
        and li.LINE_ITEM_TYPE_ID IN (49)
        ),

        retail_part_sales_agg as (
        SELECT
        parent_company_name_na,
        sales_director,
        INVOICE_YEAR,
        Invoice_quarter,
        sum(amount) as retail_sales_parts_revenue,
        sum(gross_margin) as gross_profit
        FROM retail_parts_sales
        group by 1,2,3,4
        --     order by 1
        ),




          gross_profit_pct_payout as (
            SELECT
                0.55 AS min_profit,
                NULL AS max_profit,
                0.0015 AS payout_percentage
            UNION ALL
            SELECT
                0.525 AS min_profit,
                0.55 AS max_profit,
                0.0013 AS payout_percentage
            UNION ALL
            SELECT
                0.50 AS min_profit,
                0.525 AS max_profit,
                0.0012 AS payout_percentage
            UNION ALL
            SELECT
                0.475 AS min_profit,
                0.50 AS max_profit,
                0.0009 AS payout_percentage
            UNION ALL
            SELECT
                0.45 AS min_profit,
                0.475 AS max_profit,
                0.0007 AS payout_percentage
            UNION ALL
            SELECT
                0.425 AS min_profit,
                0.45 AS max_profit,
                0.0004 AS payout_percentage
            UNION ALL
            SELECT
                0.40 AS min_profit,
                0.425 AS max_profit,
                0.0003 AS payout_percentage
            UNION ALL
            SELECT
                0.375 AS min_profit,
                0.40 AS max_profit,
                0.0002 AS payout_percentage
            UNION ALL
            SELECT
                NULL AS min_profit,
                0.375 AS max_profit,
                0.0001 AS payout_percentage

          ),

          ancillary_pct_payout as (
            SELECT
                0.35 AS min_ancillary,
                NULL AS max_ancillary,
                1.250 AS payout_multiplier
            UNION ALL
            SELECT
                0.30 AS min_ancillary,
                0.35 AS max_ancillary,
                1.250 AS payout_multiplier
            UNION ALL
            SELECT
                0.25 AS min_ancillary,
                0.30 AS max_ancillary,
                1.200 AS payout_multiplier
            UNION ALL
            SELECT
                0.20 AS min_ancillary,
                0.25 AS max_ancillary,
                1.150 AS payout_multiplier
            UNION ALL
            SELECT
                0.175 AS min_ancillary,
                0.20 AS max_ancillary,
                1.100 AS payout_multiplier
            UNION ALL
            SELECT
                0.15 AS min_ancillary,
                0.175 AS max_ancillary,
                1.050 AS payout_multiplier
            UNION ALL
            SELECT
                0.125 AS min_ancillary,
                0.15 AS max_ancillary,
                1.000 AS payout_multiplier
            UNION ALL
            SELECT
                0.10 AS min_ancillary,
                0.125 AS max_ancillary,
                0.975 AS payout_multiplier
            UNION ALL
            SELECT
                0.09 AS min_ancillary,
                0.10 AS max_ancillary,
                0.950 AS payout_multiplier
            UNION ALL
            SELECT
                0.08 AS min_ancillary,
                0.09 AS max_ancillary,
                0.925 AS payout_multiplier
            UNION ALL
            SELECT
                0.07 AS min_ancillary,
                0.08 AS max_ancillary,
                0.900 AS payout_multiplier
            UNION ALL
            SELECT
                NULL AS min_ancillary,
                0.07 AS max_ancillary,
                0.850 AS payout_multiplier
                      ),

        -----------------------------------Aggregation----------------------------------
        -- SELECT * FROM retail_parts_sales
        -- --          where company_name = 'Kiewit Power Constructors Co.'
        -- order by company_name, part_id, NUMBER_OF_UNITS
        --

        sales_director_level as (SELECT
        f.parent_company_name_na,
--         f.Company_name,
        f.sales_director,
--         f.invoice_year,
--         f.Invoice_quarter,
                CASE
        WHEN f.invoice_quarter = 1 THEN DATE(CONCAT(f.invoice_year, '-01-01')) -- Q1 starts on January 1st
        WHEN f.invoice_quarter = 2 THEN DATE(CONCAT(f.invoice_year, '-04-01')) -- Q2 starts on April 1st
        WHEN f.invoice_quarter = 3 THEN DATE(CONCAT(f.invoice_year, '-07-01')) -- Q3 starts on July 1st
        WHEN f.invoice_quarter = 4 THEN DATE(CONCAT(f.invoice_year, '-10-01')) -- Q4 starts on October 1st
        END AS invoice_date,
--         ROUND(SUM(CASE WHEN type = 'regular_rentals' THEN gross_profit_margin ELSE 0 END),0) as regular_rental_gross_profit_margin_sum,
--         ROUND(sum(CASE WHEN type = 'regular_rentals' THEN rental_revenue ELSE 0 END),0) as regular_rental_revenue_sum,
--         ROUND(SUM(CASE WHEN type = 'bulk_rentals' THEN gross_profit_margin ELSE 0 END),0) as bulk_rental_gross_profit_margin_sum,
--         ROUND(sum(CASE WHEN type = 'bulk_rentals' THEN rental_revenue ELSE 0 END),0) as bulk_rental_revenue_sum,
        ROUND(SUM(gross_profit_margin),0) as gross_profit_margin_sum,
        ROUND(sum(rental_revenue),0) as rental_revenue_sum,
        ROUND(gross_profit_margin_sum / rental_revenue_sum,4) as gross_profit_margin_pct_sum,
        MAX(environmental_fees_revenue) as environmental_fees_revenue,
        MAX(pnd_revenue) as pnd_revenue,
        MAX(fuel_revenue) as fuel_revenue,
        MAX(service_revenue) as service_revenue,
        MAX(environmental_fees_revenue) + MAX(pnd_revenue) + MAX(fuel_revenue) + MAX(service_revenue) as total_ancillary,
        total_ancillary / NULLIFZERO(rental_revenue_sum) as ancillary_pct_of_revenue,
        ZEROIFNULL(a.retail_sales_parts_revenue) as retail_part_sales,
        ZEROIFNULL(a.gross_profit) as retail_part_sales_gross_profit
        FROM all_data f
        Left join retail_part_sales_agg a on a.parent_company_name_na = f.parent_company_name_na and f.sales_director = a.sales_director and a.Invoice_quarter = f.Invoice_quarter and a.INVOICE_YEAR = f.invoice_year
        group by 1,2,3,13,14
        order by 1,2)
      ,



--         parent_company_level as (
--
--         SELECT
--         f.parent_company_name,
--         f.invoice_year,
--         f.Invoice_quarter,
--         CASE
--         WHEN f.invoice_quarter = 1 THEN DATE(CONCAT(f.invoice_year, '-01-01')) -- Q1 starts on January 1st
--         WHEN f.invoice_quarter = 2 THEN DATE(CONCAT(f.invoice_year, '-04-01')) -- Q2 starts on April 1st
--         WHEN f.invoice_quarter = 3 THEN DATE(CONCAT(f.invoice_year, '-07-01')) -- Q3 starts on July 1st
--         WHEN f.invoice_quarter = 4 THEN DATE(CONCAT(f.invoice_year, '-10-01')) -- Q4 starts on October 1st
--         END AS invoice_date,
--         ROUND(SUM(CASE WHEN type = 'regular_rentals' THEN gross_profit_margin ELSE 0 END),0) as regular_rental_gross_profit_margin_sum,
--         ROUND(sum(CASE WHEN type = 'regular_rentals' THEN rental_revenue ELSE 0 END),0) as regular_rental_revenue_sum,
--         ROUND(SUM(CASE WHEN type = 'bulk_rentals' THEN gross_profit_margin ELSE 0 END),0) as bulk_rental_gross_profit_margin_sum,
--         ROUND(sum(CASE WHEN type = 'bulk_rentals' THEN rental_revenue ELSE 0 END),0) as bulk_rental_revenue_sum,
--         ROUND(SUM(gross_profit_margin),0) as gross_profit_margin_sum,
--         ROUND(sum(rental_revenue),0) as rental_revenue_sum,
--         ROUND(gross_profit_margin_sum / rental_revenue_sum,4) as gross_profit_margin_pct_sum,
--         MAX(environmental_fees_revenue) as environmental_fees_revenue,
--         MAX(pnd_revenue) as pnd_revenue,
--         MAX(fuel_revenue) as fuel_revenue,
--         MAX(service_revenue) as service_revenue,
--         MAX(environmental_fees_revenue) + MAX(pnd_revenue) + MAX(fuel_revenue) + MAX(service_revenue) as total_ancillary,
--         total_ancillary / NULLIFZERO(rental_revenue_sum) as ancillary_pct_of_revenue,
--         ZEROIFNULL(a.retail_sales_parts_revenue) as retail_part_sales,
--         ZEROIFNULL(a.gross_profit) as retail_part_sales_gross_profit
--         FROM all_data f
--         Left join retail_part_sales_agg a on a.company_name = f.company_name and a.Invoice_quarter = f.Invoice_quarter and a.INVOICE_YEAR = f.invoice_year
--         group by 1,2,3,4,18,19
--         order by 1,2)


--         SELECT * FROM sales_director_level
--                  where invoice_date = '2024-07-01'
--         order by 1,2

gp_totals as (SELECT sdl.invoice_date, sdl.sales_director, sum(gross_profit_margin_sum) as gross_profit_margin_sum, SUM(gp.payout_percentage * gross_profit_margin_sum) as payout
              FROM sales_director_level sdl
                       left join gross_profit_pct_payout gp
                                 on COALESCE(gp.min_profit, -9999) <= sdl.gross_profit_margin_pct_sum
                                     and COALESCE(gp.max_profit, 9999) > sdl.gross_profit_margin_pct_sum
              where sdl.invoice_date >= '2024-01-01'
              group by 1,2
              order by 1, 2,3--, gp.max_profit)
)

      SELECT sdl.invoice_date, sdl.sales_director, min_ancillary, max_ancillary, SUM(sdl.gross_profit_margin_sum) as gp_sum, SUM(sdl.rental_revenue_sum) as rev_sum, max(gp.gross_profit_margin_sum) as gp_total_quarter, MAX(a.payout_multiplier) as ancillary_multiplier, SUM(sdl.gross_profit_margin_sum)/max(gp.gross_profit_margin_sum) as pct_total_na, max(gp.payout) as gross_profit_payout, pct_total_na*max(gp.payout)*MAX(a.payout_multiplier) as payout
              FROM sales_director_level sdl
                       left join ancillary_pct_payout a
                                 on COALESCE(a.min_ancillary, -9999) <= sdl.ancillary_pct_of_revenue
                                     and COALESCE(a.max_ancillary, 9999) > sdl.ancillary_pct_of_revenue
              LEFT JOIN gp_totals gp on gp.invoice_date = sdl.invoice_date and gp.sales_director = sdl.sales_director
              where sdl.invoice_date >= '2024-01-01'
              group by 1,2,3,4
              order by 1 desc, 4 desc, 2--, gp.max_profit)

      ;;
  }


  dimension_group: invoice_date {
    type: time
    timeframes: [
      quarter,
      year
    ]
    sql: CAST(${TABLE}."INVOICE_DATE" AS TIMESTAMP_NTZ) ;;
  }


  dimension: sales_director {
    type: number
    sql: ${TABLE}.sales_director ;;
  }

  dimension: min_ancillary {
    type: number
    sql: ${TABLE}.min_ancillary ;;
  }

  dimension: max_ancillary {
    type: number
    sql: ${TABLE}.max_ancillary ;;
  }

  dimension: ancillary_multiplier {
    type: number
    sql: ${TABLE}.ancillary_multiplier ;;
  }

  dimension: pct_total_na {
    type: number
    sql: ${TABLE}.pct_total_na ;;
  }

  dimension: payout {
    type: number
    sql: ${TABLE}.payout ;;
  }

  dimension: gross_profit {
    type: number
    sql: ${TABLE}.gp_sum ;;
  }

  dimension: rental_revenue {
    type: number
    sql: ${TABLE}.rev_sum ;;
  }

  dimension: gross_profit_payout {
    type: number
    sql: ${TABLE}.gross_profit_payout ;;
  }


  measure: payout_sum {
    type: sum
    sql: ${TABLE}.payout ;;
  }

#
#   dimension: lifetime_orders {
#     description: "The total number of orders for each user"
#     type: number
#     sql: ${TABLE}.lifetime_orders ;;
#   }
#
#   dimension_group: most_recent_purchase {
#     description: "The date when each user last ordered"
#     type: time
#     timeframes: [date, week, month, year]
#     sql: ${TABLE}.most_recent_purchase_at ;;
#   }
#
#   measure: total_lifetime_orders {
#     description: "Use this for counting lifetime orders across many users"
#     type: sum
#     sql: ${lifetime_orders} ;;
#   }
}
