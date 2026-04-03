SELECT
    u.employee_id,
    cd.employee_title,
    coalesce(cd.nickname, cd.full_name) AS employee_name,
    te.start_date AS start_date,
    date_trunc(month, te.start_date) AS gl_month,
    to_char(to_date(dateadd(month, 1, gl_month::date)), 'MMMM YYYY') as filter_month,
    te.end_date AS end_date,
    x.market_id,
    x.market_name,
    x.region,
    x.region_name,
    x.region_district,
    te.work_order_id,
    wot.work_order_type,
    'https://app.estrack.com/#/service/work-orders/'
    || te.work_order_id
    || '/time' AS url_t3,
    listagg(DISTINCT wc.name, ',') AS work_codes,
    sum(te.regular_hours + te.overtime_hours) AS total_hours,
    iff(te.work_order_id IS NULL, 0, total_hours) AS assigned_hours,
    iff(te.work_order_id IS NULL, total_hours, 0) AS unassigned_hours,
    coalesce(datediff(month, date_trunc(month, x.branch_earnings_start_month::date), date_trunc(month, te.start_date)), 0) as market_age_in_months,
    (market_age_in_months > 12) as market_greater_than_12_months,
    md5(
        coalesce(u.employee_id::text, 'no employee_id')
        || coalesce(cd.employee_title, 'no employee_title')
        || coalesce(cd.full_name, 'no employee')
        || coalesce(te.work_order_id::text, 'no work order')
        || coalesce(work_codes, 'no work order')
        || coalesce(x.market_id::text, 'no market')
        || coalesce(x.market_name, 'no market')
        || coalesce(x.region_district, 'no market')
        || coalesce(te.time_entry_id, 'no market')
    ) AS pk_unassigned_tech_hours_id
FROM {{ ref("stg_es_warehouse_time_tracking__time_entries") }} AS te
    INNER JOIN {{ ref("stg_es_warehouse_public__users") }} AS u
        ON te.user_id = u.user_id
    INNER JOIN {{ ref("stg_analytics_payroll__company_directory") }} AS cd
        ON u.employee_id = cd.employee_id::text
    INNER JOIN {{ ref("market") }} AS x
        ON te.branch_id = x.child_market_id
    LEFT JOIN {{ ref("stg_es_warehouse_work_orders__work_orders") }} AS wo
        ON te.work_order_id = wo.work_order_id
    LEFT JOIN {{ ref("stg_es_warehouse_work_orders__work_order_types") }} AS wot
        ON wo.work_order_type_id = wot.work_order_type_id
    LEFT JOIN {{ ref("stg_es_warehouse_time_tracking__time_entry_work_code_xref") }} AS tewcx
        ON te.time_entry_id = tewcx.time_entry_id
    LEFT JOIN {{ ref("stg_es_warehouse_time_tracking__work_codes") }} AS wc
        ON tewcx.work_code_id = wc.work_code_id
WHERE
    te.start_date >= '2022-01-01'
    AND te.event_type_id = 1
    AND te.approval_status = 'Approved'
    AND cd.employee_title ILIKE ANY ('%technician%', '%mechanic%')
    -- Mark W says don't include yard techs
    AND cd.employee_title NOT ILIKE ('%yard technician%')
GROUP BY
    u.employee_id,
    cd.employee_title,
    cd.nickname,
    cd.full_name,
    te.start_date,
    te.end_date,
    x.market_id,
    x.market_name,
    x.region,
    x.region_name,
    x.region_district,
    te.work_order_id,
    wot.work_order_type,
    gl_month,
    market_age_in_months,
    te.time_entry_id
