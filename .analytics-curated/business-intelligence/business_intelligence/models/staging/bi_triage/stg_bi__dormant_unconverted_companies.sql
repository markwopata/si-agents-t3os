with company_start_date as (
    select
        r.rental_id,
        i.end_date::date as invoice_date,
        c.company_id,
        c.name as company_name,
        concat(rep.first_name,' ',rep.last_name) as rep,
        rep.email_address as rep_email_address,
        mrx.market_id,
        mrx.market_name,
        mrx.district,
        mrx.region_name,
        r.rental_status_id
    from 
        {{ ref('platform', 'rentals')}} r
        left join {{ ref('platform', 'orders')}} o on r.order_id = o.order_id
        left join {{ ref('platform', 'order_salespersons')}} os on os.order_id = o.order_id
        left join {{ ref('platform', 'users')}} rep on rep.user_id = coalesce(os.user_id, o.user_id)
        left join {{ ref('platform', 'markets')}} m on o.market_id = m.market_id
        left join analytics.public.market_region_xwalk mrx on mrx.market_id = m.market_id
        left join {{ ref('platform', 'assets')}} a on r.asset_id = a.asset_id
        left join {{ ref('platform', 'users')}} u on o.user_id = u.user_id
        left join {{ ref('platform', 'companies')}} c on u.company_id = c.company_id
        left join {{ ref('platform', 'invoices')}} i on i.order_id = o.order_id
        left join {{ ref('platform', 'net_terms')}} n on c.net_terms_id = n.net_terms_id
        left join {{ ref('platform', 'billing_company_preferences')}} bcp
            on bcp.company_id = c.company_id 
            AND bcp.PREFS:legal_audit IS NOT NULL
    where
        m.market_id is not null
        AND u.company_id is not null
        AND m.company_id = 1854
        AND r.rental_status_id != 8  --ONLY SHOW RENTALS THAT HAVE NOT BEEN CANCELLED
        AND bcp.PREFS:legal_audit = false --ONLY SHOW COMPANIES NOT IN LEGAL
        AND n.net_terms_id <> 1 --ONLY SHOW COMPANIES NOT IN COD
        AND c.DO_NOT_RENT = FALSE --ONLY SHOW COMPANIES NOT IN DO NOT RENT STATUS
        AND ((SUBSTR(TRIM(a.serial_number), 1, 3) != 'RR-' and SUBSTR(TRIM(a.serial_number), 1, 2) != 'RR') or a.serial_number is null) --DONT INCLUDE ASSET RERENTS
)
, company_ttm_rentals_by_market as (
    select
        company_id,
        market_id,
        count(rental_id) as total_rentals_at_market
    from
        company_start_date
    where
        invoice_date >= (current_date - INTERVAL '12 months')
    group by
        company_id,
        market_id
)

, company_ttm_rentals_at_market_rank as (
    select
        company_id,
        market_id,
        total_rentals_at_market,
        ROW_NUMBER() OVER (PARTITION BY company_id ORDER BY total_rentals_at_market DESC) as rentals_market_rank
    FROM
        company_ttm_rentals_by_market
    group by
        company_id,
        market_id,
        total_rentals_at_market
)

, last_invoice_date as (
    select
        max(invoice_date) as last_invoice_date,
        datediff(day,last_invoice_date,current_date) as days_since_invoice,
        company_id,
        company_name
    from
        company_start_date
    group by
        company_id,
        company_name
)

, reps_to_company_invoices AS (
    SELECT 
        i.company_id,
        ais.primary_salesperson_id as salesperson_user_id,
        SUM(li.amount) AS total_rental_revenue
    FROM
        {{ ref ('platform', 'es_warehouse__public__approved_invoice_salespersons')}} ais
        join {{ ref('platform', 'invoices')}} i on i.INVOICE_ID = ais.INVOICE_ID
        join analytics.intacct_models.int_admin_invoice_and_credit_line_detail li on i.INVOICE_ID = li.INVOICE_ID
    WHERE
        li.billing_approved_date >= (current_date - INTERVAL '12 months')
        AND li.LINE_ITEM_TYPE_ID in (6,8,108,109)
        AND li.amount > 0
    GROUP BY
        i.company_id,
        ais.primary_salesperson_id
)

, rep_to_company_ranking as (
    select
        company_id,
        salesperson_user_id,
        total_rental_revenue,
        ROW_NUMBER() OVER (PARTITION BY company_id ORDER BY SUM(total_rental_revenue) DESC) AS rental_revenue_rank
    FROM
        reps_to_company_invoices
    group by
        company_id,
        salesperson_user_id,
        total_rental_revenue
    )
    , company_rank_rep_pivot as (
    SELECT 
        company_id,
        MAX(CASE WHEN rental_revenue_rank = 1 THEN salesperson_user_id END) AS rank_1_user_id,
        MAX(CASE WHEN rental_revenue_rank = 1 THEN total_rental_revenue END) AS rank_1_revenue,
        MAX(CASE WHEN rental_revenue_rank = 2 THEN salesperson_user_id END) AS rank_2_user_id,
        MAX(CASE WHEN rental_revenue_rank = 2 THEN total_rental_revenue END) AS rank_2_revenue,
        MAX(CASE WHEN rental_revenue_rank = 3 THEN salesperson_user_id END) AS rank_3_user_id,
        MAX(CASE WHEN rental_revenue_rank = 3 THEN total_rental_revenue END) AS rank_3_revenue
    FROM 
        rep_to_company_ranking
    WHERE 
        rental_revenue_rank <= 3
    GROUP BY 
        company_id
)

, company_reservations as (
    select 
        distinct(o.company_id)
    from es_warehouse.public.rentals r 
    left join es_warehouse.public.orders o on o.order_id = r.order_id
    left join es_warehouse.public.invoices i on i.order_id = o.order_id
    left join ES_WAREHOUSE.public.users u on o.user_id = u.user_id
    left join ES_WAREHOUSE.public.companies c on u.company_id = c.company_id
    where 
        -- if a pending rental or draft rental was in the last month
        (r.rental_status_id in (2,3) and r.start_date::date >= DATEADD(day, -30, current_date()) )
        -- any rentals currently on rent
        OR (r.rental_status_id = 5) 
)

, dormant_account_list as (
    select
        company_id,
        company_name,
        days_since_invoice,
        case 
            when days_since_invoice >= 120 then 'Dormant'
            when days_since_invoice >= 90 AND days_since_invoice < 120 then 'Inactive'
        end as company_status
    from 
        last_invoice_date
    where
        days_since_invoice >= 90
        and company_id not in (select company_id from company_reservations)
)

, dormant_companies_ttm_revenue as (
    select
        dal.company_id,
        sum(li.amount) as total_rental_revenue
    from
        dormant_account_list dal
        join {{ ref('platform', 'invoices') }} i on dal.company_id = i.company_id
        join analytics.intacct_models.int_admin_invoice_and_credit_line_detail li on li.invoice_id = i.invoice_id
    where
        li.line_item_type_id in (6,8,108,109)
        AND li.billing_approved_date >= (current_date - INTERVAL '12 months')
    group by 
        dal.company_id
)

, dormant_billing_location as (
    select
        dal.company_id,
        m.market_id,
        ROUND(haversine(l.latitude, l.longitude, les.latitude, les.longitude) * 0.621371, 6) AS distance_from_branch
    from
        dormant_account_list dal
        join {{ ref('platform', 'companies') }} c on c.company_id = dal.company_id
        join {{ ref('platform', 'locations') }} l on l.location_id = c.billing_location_id
        join {{ ref('platform', 'markets') }} m on 1=1 AND m.company_id = 1854 AND m.is_public_rsp = TRUE AND m.active = TRUE
        join {{ ref('platform', 'locations') }} les on les.location_id = m.location_id
),

dormant_closest_branch_location as (
select
    dbl.company_id,
    mrx.district,
    dbl.market_id,
    mrx.market_name,
    dbl.distance_from_branch,
    ROW_NUMBER() OVER (PARTITION BY company_id ORDER BY distance_from_branch ASC) AS distance_from_branch_rank
from 
    dormant_billing_location dbl
    join analytics.public.market_region_xwalk mrx on mrx.market_id = dbl.market_id
where mrx.abbreviation not like 'MTT%'
and mrx.market_type <> 'Materials'
)

, rep_check as (
    select
        dal.company_id,
        dal.company_name,
        dal.company_status,
        dal.days_since_invoice,
        IFF( 
        (crp.rank_1_user_id IS NULL OR (cd1.date_terminated IS NOT NULL AND cd1.employee_id IS NOT NULL)) AND (crp.rank_2_user_id IS NULL OR (cd2.date_terminated IS NOT NULL AND cd2.employee_id IS NOT NULL)) AND (crp.rank_3_user_id IS NULL OR (cd3.date_terminated IS NOT NULL AND cd3.employee_id IS NOT NULL)) 
        ,TRUE,FALSE) all_reps_on_account_terminated,
        crp.rank_1_user_id,
        concat(u1.first_name,' ',u1.last_name) as rep_1_name,
        IFF(cd1.date_terminated IS NULL AND cd1.employee_id IS NOT NULL,TRUE,FALSE) as active_employee_check_rep_1,
        cd1.market_id as rep_1_market_id,
        crp.rank_1_revenue,
        crp.rank_2_user_id,
        concat(u2.first_name,' ',u2.last_name) as rep_2_name,
        IFF(cd2.date_terminated IS NULL AND cd2.employee_id IS NOT NULL,TRUE,FALSE) as active_employee_check_rep_2,
        cd2.market_id as rep_2_market_id,
        crp.rank_2_revenue,
        crp.rank_3_user_id,
        concat(u3.first_name,' ',u3.last_name) as rep_3_name,
        IFF(cd3.date_terminated IS NULL AND cd3.employee_id IS NOT NULL,TRUE,FALSE) as active_employee_check_rep_3,
        cd3.market_id as rep_3_market_id,
        crp.rank_3_revenue,
        coalesce(dcttm.total_rental_revenue,0) as company_ttm_rental_revenue,
        crr.total_rentals_at_market as ttm_rentals_at_market,
        crr.market_id as ttm_rentals_market_id,
        crbl.market_id as closest_rental_branch_id,
        crbl.market_name as closest_rental_branch
    from
    dormant_account_list dal 
    left join company_rank_rep_pivot crp on crp.company_id = dal.company_id
    left join dormant_companies_ttm_revenue dcttm on dcttm.company_id = dal.company_id
    left join company_ttm_rentals_at_market_rank crr on crr.company_id = dal.company_id AND crr.rentals_market_rank = 1
    left join dormant_closest_branch_location crbl on crbl.company_id = dal.company_id AND crbl.distance_from_branch_rank = 1
    left join {{ ref('platform', 'users') }} u1 on u1.user_id = crp.rank_1_user_id
    left join analytics.payroll.company_directory cd1 on TO_VARCHAR(cd1.employee_id) = TO_VARCHAR(u1.employee_id)
    left join {{ ref('platform', 'users') }} u2 on u2.user_id = crp.rank_2_user_id
    left join analytics.payroll.company_directory cd2 on TO_VARCHAR(cd2.employee_id) = TO_VARCHAR(u2.employee_id)
    left join {{ ref('platform','users') }} u3 on u3.user_id = crp.rank_3_user_id
    left join analytics.payroll.company_directory cd3 on TO_VARCHAR(cd3.employee_id) = TO_VARCHAR(u3.employee_id)
    where crbl.distance_from_branch_rank is not null
)
, quote_rep as (
    select 
        duq.company_id,
        duq.last_modified_date,
        concat(cd.first_name, ' ', cd.last_name) as quote_rep,
        u.user_id,
        cd.employee_status,
        cd.market_id,
        xw.market_name
    from analytics.bi_ops.dormant_unconverted_quotes duq
    left join {{ ref('stg_quotes__quotes') }} q
    on duq.quote_id = q.quote_id
    left join {{ ref('platform', 'users') }} u
    on q.salesperson_user_id = u.user_id
    left join analytics.payroll.company_directory cd
    on u.email_address = cd.work_email
    left join analytics.public.market_region_xwalk xw 
    on cd.market_id = xw.market_id
    where cd.employee_status = 'Active'
    qualify row_number() over (
        partition by duq.company_id 
        order by duq.last_modified_date desc
    ) = 1
)
, dormant_company_revenue as (
    select 
        dal.company_id,
        dal.company_name,
        li.market_id,
        SUM(li.amount) AS total_rental_revenue
    from dormant_account_list dal
    join {{ ref('platform', 'invoices') }} i
    on dal.company_id = i.company_id
    join analytics.intacct_models.int_admin_invoice_and_credit_line_detail li 
    on i.INVOICE_ID = li.INVOICE_ID
    where
        li.LINE_ITEM_TYPE_ID in (6, 8, 108, 109)
        and li.amount > 0
        and li.billing_approved_date >= (current_date - INTERVAL '12 months')
    group by
    dal.company_id, dal.company_name, li.market_id
    qualify row_number() over (partition by dal.company_id order by sum(li.amount) desc) = 1
)
, dormant_market as (
    select 
        rc.*
        , IFF(
            rc.active_employee_check_rep_1 = true, 
            rc.rank_1_user_id,
            IFF(
                rc.active_employee_check_rep_2 = true,
                rc.rank_2_user_id,
                IFF(
                    rc.active_employee_check_rep_3 = true,
                    rank_3_user_id,
                    IFF(
                        qr.user_id is not null,
                        qr.user_id,
                        null
                    )
                )
            )
        ) sp_user_id
        , dcm.market_id
    from rep_check rc
    left join dormant_company_revenue dcm
    on rc.company_id = dcm.company_id
    left join quote_rep qr on 
    rc.company_id = qr.company_id
)
, dormant_companies as (
    select 
        dm.company_id,
        dm.company_name,
        dm.company_status,
        dm.company_ttm_rental_revenue,
        dm.ttm_rentals_at_market,
        dm.days_since_invoice,
        null days_since_created,
        -- null quotes,
        dm.sp_user_id,
        concat(cd.first_name, ' ', cd.last_name) sp_name,
        cd.work_email email_address,
        cd.employee_status,
        dm.market_id,
        xw1.market_name,
        xw1.district,
        xw1.region_name,
        dm.closest_rental_branch_id,
        dm.closest_rental_branch,
        xw2.district closest_district,
        xw2.region_name closest_region
    from dormant_market dm
    left join ANALYTICS.PUBLIC.MARKET_REGION_XWALK xw1
    on dm.market_id = xw1.market_id 
    left join analytics.public.market_region_xwalk xw2
    on dm.closest_rental_branch_id = xw2.market_id
    left join {{ ref('platform', 'users') }} u
    on dm.sp_user_id = u.user_id
    left join analytics.payroll.company_directory cd
    on u.email_address = cd.work_email
),

-- -- Unconverted logic beings here

cte as (
    select
        nal.company_id,
        nal.company_name,
        nal.email_address,
        case when cd.employee_status = 'Active' then nal.sp_name
            when qr.quote_rep is not null then qr.quote_rep
            else null end as sp_name,
        case when cd.employee_status = 'Active' then nal.sp_user_id
            when qr.quote_rep is not null then qr.user_id
            else null end as sp_user_id,
        cd.employee_status,
        datediff(day, na_date, current_date) days_since_creation,
        case 
            when (cd.employee_status = 'Active' AND cd.market_id is not null) then cd.market_id 
            when (qr.quote_rep is not null and qr.market_name is not null) then qr.market_id
            when cam.market_id is null then cd.market_id
            else cam.market_id 
        end as true_market_id,
        cd.location,
        cd.market_id,
        cam.market,
        cam.market_id cam_market_id
    from
        ANALYTICS.BI_OPS.NEW_ACCOUNT_BY_TYPE_LOG nal
    left join ( 
        select
            company_id, 
            market,
            market_id
        from analytics.bi_ops.credit_app_master_retool
        where deleted <> true
        qualify row_number() over(partition by company_id order by date_created) = 1
    ) cam
    on nal.company_id = cam.company_id
    left join analytics.payroll.company_directory cd 
    on nal.email_address = cd.work_email
    left join quote_rep qr
    on nal.company_id = qr.company_id
    where nal.old_age_flag = true
    and nal.old_age_no_order_flag = true
    and nal.na_date >= '2024-03-04'
    order by nal.na_date asc
),

-- cte2 addresses the blank districts from cte1
cte2 as (
    select 
    cte.*,
    xw.district,
    case 
        when (district is null and cte.employee_status = 'Active') then cte.cam_market_id
        when (district is null and cte.employee_status <> 'Active') then cte.market_id
        else cte.true_market_id end as market_id_2
        -- distinct(cte.location)
    from cte
    left join analytics.public.market_region_xwalk xw
    on cte.true_market_id = xw.market_id
    -- where cte.employee_status = 'Active'
    -- and xw.district is null
    -- order by location asc
),

-- cleans up query to select only relevant columns
cte3 as (
    select 
        cte2.company_id, 
        cte2.company_name,
        'Unconverted' company_status,
        cte2.days_since_creation,
        cte2.sp_user_id,
        cte2.sp_name,
        cte2.email_address,
        cte2.employee_status,
        xw.district, 
        xw.market_id, 
        xw.market_name,
        xw.region_name
    from cte2
    left join analytics.public.market_region_xwalk xw
    on cte2.market_id_2 = xw.market_id
    where not (xw.district is null and cte2.market in ('Natioinal', 'Corporate Office', 'National', 'T3 Sales & Support', 'Corporate', null))
),

union_cte as (
    select 
        cte3.company_id,
        cte3.company_name,
        cte3.company_status,
        null company_ttm_rental_revenue,
        null ttm_rentals_at_market,
        null days_since_invoice,
        cte3.days_since_creation,
        cte3.sp_user_id,
        cte3.sp_name,
        cte3.email_address,
        cte3.employee_status,
        cte3.market_id,
        cte3.market_name,
        cte3.district,
        cte3.region_name,
        cte3.market_id closest_rental_branch_id,
        cte3.market_name closest_rental_branch,
        cte3.district closest_district,
        cte3.region_name closest_region
    from cte3

    union
    
    select * from dormant_companies
)

-- Market Type logic begins here

, base_table as (
    select
        c.company_id,
        c.name as company_name,
        coalesce(sum(case when mrx.market_type = 'Core Solutions' then 1 else null end),0) as core_count,
        coalesce(sum(case when mrx.market_type = 'ITL' then 1 else null end),0) as itl_count,
        coalesce(sum(case when mrx.market_type = 'Advanced Solutions' then 1 else null end),0) as advanced_count,
        (COALESCE(SUM(CASE WHEN mrx.market_type = 'Core Solutions' THEN 1 ELSE NULL END), 0) +
        COALESCE(SUM(CASE WHEN mrx.market_type = 'ITL' THEN 1 ELSE NULL END), 0) +
        COALESCE(SUM(CASE WHEN mrx.market_type = 'Advanced Solutions' THEN 1 ELSE NULL END), 0)) AS total_count,
        CASE 
            WHEN 
                (COALESCE(SUM(CASE WHEN mrx.market_type = 'Core Solutions' THEN 1 ELSE NULL END), 0) +
                COALESCE(SUM(CASE WHEN mrx.market_type = 'ITL' THEN 1 ELSE NULL END), 0) +
                COALESCE(SUM(CASE WHEN mrx.market_type = 'Advanced Solutions' THEN 1 ELSE NULL END), 0)) > 0
            THEN ROUND(
                (COALESCE(SUM(CASE WHEN mrx.market_type = 'Core Solutions' THEN 1 ELSE NULL END), 0) * 100.0) /
                (COALESCE(SUM(CASE WHEN mrx.market_type = 'Core Solutions' THEN 1 ELSE NULL END), 0) +
                COALESCE(SUM(CASE WHEN mrx.market_type = 'ITL' THEN 1 ELSE NULL END), 0) +
                COALESCE(SUM(CASE WHEN mrx.market_type = 'Advanced Solutions' THEN 1 ELSE NULL END), 0)), 2)
            ELSE 0
        END AS core_percentage,
        CASE 
            WHEN 
                (COALESCE(SUM(CASE WHEN mrx.market_type = 'Core Solutions' THEN 1 ELSE NULL END), 0) +
                COALESCE(SUM(CASE WHEN mrx.market_type = 'ITL' THEN 1 ELSE NULL END), 0) +
                COALESCE(SUM(CASE WHEN mrx.market_type = 'Advanced Solutions' THEN 1 ELSE NULL END), 0)) > 0
            THEN ROUND(
                (COALESCE(SUM(CASE WHEN mrx.market_type = 'ITL' THEN 1 ELSE NULL END), 0) * 100.0) /
                (COALESCE(SUM(CASE WHEN mrx.market_type = 'Core Solutions' THEN 1 ELSE NULL END), 0) +
                COALESCE(SUM(CASE WHEN mrx.market_type = 'ITL' THEN 1 ELSE NULL END), 0) +
                COALESCE(SUM(CASE WHEN mrx.market_type = 'Advanced Solutions' THEN 1 ELSE NULL END), 0)), 2)
            ELSE 0
        END AS itl_percentage,
        CASE 
            WHEN 
                (COALESCE(SUM(CASE WHEN mrx.market_type = 'Core Solutions' THEN 1 ELSE NULL END), 0) +
                COALESCE(SUM(CASE WHEN mrx.market_type = 'ITL' THEN 1 ELSE NULL END), 0) +
                COALESCE(SUM(CASE WHEN mrx.market_type = 'Advanced Solutions' THEN 1 ELSE NULL END), 0)) > 0
            THEN ROUND(
                (COALESCE(SUM(CASE WHEN mrx.market_type = 'Advanced Solutions' THEN 1 ELSE NULL END), 0) * 100.0) /
                (COALESCE(SUM(CASE WHEN mrx.market_type = 'Core Solutions' THEN 1 ELSE NULL END), 0) +
                COALESCE(SUM(CASE WHEN mrx.market_type = 'ITL' THEN 1 ELSE NULL END), 0) +
                COALESCE(SUM(CASE WHEN mrx.market_type = 'Advanced Solutions' THEN 1 ELSE NULL END), 0)), 2)
            ELSE 0
        END AS advanced_percentage
    from 
        {{ ref('platform', 'rentals') }} r
        left join {{ ref('platform', 'orders') }} o on r.order_id = o.order_id
        left join {{ ref('platform', 'markets') }} m on o.market_id = m.market_id
        left join analytics.public.market_region_xwalk mrx on mrx.market_id = m.market_id
        left join {{ ref('platform', 'assets') }} a on r.asset_id = a.asset_id
        left join {{ ref('platform', 'users') }} u on o.user_id = u.user_id
        left join {{ ref('platform', 'companies') }} c on u.company_id = c.company_id
        left join {{ ref('platform', 'net_terms') }} n on c.net_terms_id = n.net_terms_id
        left join {{ ref('platform', 'billing_company_preferences') }} bcp 
            on bcp.company_id = c.company_id AND bcp.PREFS:legal_audit IS NOT NULL
    where
        m.market_id is not null
        AND u.company_id is not null
        AND m.company_id = 1854
        AND r.rental_status_id != 8  --ONLY SHOW RENTALS THAT HAVE NOT BEEN CANCELLED
        AND bcp.PREFS:legal_audit = false --ONLY SHOW COMPANIES NOT IN LEGAL
        AND n.net_terms_id <> 1 --ONLY SHOW COMPANIES NOT IN COD
        AND c.DO_NOT_RENT = FALSE --ONLY SHOW COMPANIES NOT IN DO NOT RENT STATUS
        AND ((SUBSTR(TRIM(a.serial_number), 1, 3) != 'RR-' and SUBSTR(TRIM(a.serial_number), 1, 2) != 'RR') or a.serial_number is null) --DONT INCLUDE ASSET RERENTS
        AND r.end_date >= (current_date - INTERVAL '12 months')
    group by
        c.company_id,
        c.name
)

, market_type_buckets as (
    select
        company_id,
        company_name,
        core_percentage,
        itl_percentage,
        advanced_percentage,
        CASE 
            WHEN core_percentage >= 90 THEN 'Core Only'
            WHEN core_percentage >= 75 THEN 'Mainly Core'
            WHEN core_percentage > 35 THEN 'Core'
            WHEN core_percentage BETWEEN 10 AND 35 THEN 'Low Core'
            ELSE 
            NULL
        END as core_bucket,
        CASE 
            WHEN itl_percentage >= 90 THEN 'ITL Only'
            WHEN itl_percentage >= 80 THEN 'Mainly ITL'
            WHEN itl_percentage > 35 THEN 'ITL'
            WHEN itl_percentage BETWEEN 10 AND 35 THEN 'Low ITL'
            ELSE 
            NULL
        END as itl_bucket,
        CASE 
            WHEN advanced_percentage >= 90 THEN 'Advanced Only'
            WHEN advanced_percentage >= 80 THEN 'Mainly Advanced'
            WHEN advanced_percentage > 35 THEN 'Advanced'
            WHEN advanced_percentage BETWEEN 10 AND 35 THEN 'Low Advanced'
            ELSE 
            NULL
        END as advanced_bucket
    from 
    base_table
),

market_type as (
    select
        company_id,
        company_name,
        core_percentage,
        itl_percentage,
        advanced_percentage,
        core_bucket,
        itl_bucket,
        advanced_bucket,
        LTRIM(
            COALESCE(core_bucket, '') || 
            CASE WHEN core_bucket IS NOT NULL AND itl_bucket IS NOT NULL THEN ' / ' ELSE '' END || 
            COALESCE(itl_bucket, '') || 
            CASE WHEN (core_bucket IS NOT NULL OR itl_bucket IS NOT NULL) AND advanced_bucket IS NOT NULL THEN ' / ' ELSE '' END || 
            COALESCE(advanced_bucket, ''),
            ' / '
        ) company_market_type_segment
    from 
        market_type_buckets
)

, national_accounts as (
    select 
        company_id,
        case when prefs:national_account = true then true 
            else false end as national_account
    from 
    {{ ref('platform', 'billing_company_preferences') }}
)

, total_rental_revenue as (
    select
        dal.company_id,
        sum(li.amount) as total_rental_revenue
    from
        dormant_account_list dal
        join {{ ref('platform', 'invoices') }} i on dal.company_id = i.company_id
        join analytics.intacct_models.int_admin_invoice_and_credit_line_detail li on li.invoice_id = i.invoice_id
    where
        li.line_item_type_id in (6,8,108,109)
    group by 
        dal.company_id
)

, billing_concat as (
    select 
        u.company_id,
        concat(l.street_1,', ', l.city,', ', s.name,', ', l.zip_code) billing_location
    from union_cte u 
    left join {{ ref('platform', 'companies') }} c on u.company_id = c.company_id
    left join {{ ref('platform', 'locations') }} l on c.billing_location_id = l.location_id
    left join {{ ref('platform', 'states') }} s on l.state_id = s.state_id
)

-- Final Select Statement
select
    u.*,
    dm.rank_1_user_id,
    dm.rep_1_name,
    case when dm.active_employee_check_rep_1 = true then 'Active'
         when dm.active_employee_check_rep_1 = false 
            and dm.rep_1_name is not null then 'Terminated'
         else null end as active_employee_check_rep_1,
    crrp.rank_1_revenue,
    dm.rank_2_user_id,
    dm.rep_2_name,
    case when dm.active_employee_check_rep_2 = true then 'Active'
         when dm.active_employee_check_rep_2 = false 
            and dm.rep_2_name is not null then 'Terminated'
         else null end as active_employee_check_rep_2,
    crrp.rank_2_revenue,
    dm.rank_3_user_id,
    dm.rep_3_name,
    case when dm.active_employee_check_rep_3 = true then 'Active'
         when dm.active_employee_check_rep_3 = false 
            and dm.rep_3_name is not null then 'Terminated'
         else null end as active_employee_check_rep_3,
    crrp.rank_3_revenue,
    q.quotes,
    m.company_market_type_segment,
    na.national_account,
    ttr.total_rental_revenue as lifetime_rental_revenue, 
    bc.billing_location,
    nt.name as net_terms,
    current_timestamp as data_refresh_timestamp
from union_cte u
left join dormant_market dm 
    on u.company_id = dm.company_id
left join (
    select company_id, count(id) quotes
    from quotes.quotes.quote
    where order_id is null 
    and date_trunc(day, expiry_date) > convert_timezone('America/Chicago', current_timestamp())::DATE 
    and missed_rental_reason is null 
    and missed_rental_reason_other is null
    group by company_id
) q
on u.company_id = q.company_id
left join market_type m 
on u.company_id = m.company_id
left join company_rank_rep_pivot crrp 
on u.company_id = crrp.company_id
left join national_accounts na 
on u.company_id = na.company_id
left join total_rental_revenue ttr 
on u.company_id = ttr.company_id
left join billing_concat bc 
on u.company_id = bc.company_id
left join es_warehouse.public.companies c 
on u.company_id = c.company_id
left join es_warehouse.public.net_terms nt 
on nt.net_terms_id = c.net_terms_id