view: hiring_update_table {
  derived_table: {sql:

--Top Focus
    with cd as (select
case when employee_title like '%Territory Account Manager%' then 'Territory Account Managers'
    when employee_title like '%District Sales Manager%' then 'District Sales Managers'
    when employee_title = 'General Manager' OR employee_title = 'General Manager - Advanced Solutions' then 'General Managers'
    when employee_title like '%Service Manager%' then 'Service Managers'
    when employee_title like '%Service Technician%' OR employee_title like '%Field Technician%' OR employee_title like '%Diesel Technician%' OR employee_title like '%Shop Technician%' then 'Techs'
    when employee_title like '%CDL%' then 'CDL Delivery Drivers'
    when employee_title like '%District Operations%' and employee_title not like '%Assistant%' then 'District Operations Managers'
    else null end as top_focus,

--Starts Current Month
COUNT(CASE WHEN (((((_es_update_timestamp)) >= ((DATEADD('hour', -46, DATE_TRUNC('hour', CURRENT_TIMESTAMP())))) AND (( _es_update_timestamp  )) < ((DATEADD('hour', 47, DATEADD('hour', -46, DATE_TRUNC('hour', CURRENT_TIMESTAMP())))))))) AND ((UPPER(( employee_status  )) = UPPER('Active') OR UPPER(( employee_status  )) = UPPER('External Payroll') OR UPPER(( employee_status  )) = UPPER('Leave with Pay') OR UPPER(( employee_status  )) = UPPER('Leave without Pay') OR UPPER(( employee_status  )) = UPPER('On Leave') OR UPPER(( employee_status  )) = UPPER('Work Comp Leave') OR UPPER(( employee_status  )) = UPPER('Seasonal (Fixed Term) (Seasonal)') OR UPPER(( employee_status  )) = UPPER('Terminated'))) AND (NOT (( employee_id  ) IS NULL)) AND ((UPPER(( employee_title  )) <> UPPER('Contractor') OR (( employee_title  )) IS NULL)) AND (CAST(EXTRACT(MONTH FROM ( TO_DATE(date_hired) )) AS BIGINT) = (CAST(EXTRACT(MONTH FROM CURRENT_TIMESTAMP()) AS BIGINT))) AND (CAST(EXTRACT(YEAR FROM ( TO_DATE(date_hired) )) AS BIGINT) = CAST(EXTRACT(YEAR FROM CURRENT_TIMESTAMP()) AS BIGINT)) THEN 1 ELSE NULL END) AS starts_current_month,

--Starts Last Month
COUNT(CASE WHEN (((((_es_update_timestamp)) >= ((DATEADD('hour', -46, DATE_TRUNC('hour', CURRENT_TIMESTAMP())))) AND (( _es_update_timestamp  )) < ((DATEADD('hour', 47, DATEADD('hour', -46, DATE_TRUNC('hour', CURRENT_TIMESTAMP())))))))) AND ((UPPER(( employee_status  )) = UPPER('Active') OR UPPER(( employee_status  )) = UPPER('External Payroll') OR UPPER(( employee_status  )) = UPPER('Leave with Pay') OR UPPER(( employee_status  )) = UPPER('Leave without Pay') OR UPPER(( employee_status  )) = UPPER('On Leave') OR UPPER(( employee_status  )) = UPPER('Work Comp Leave') OR UPPER(( employee_status  )) = UPPER('Seasonal (Fixed Term) (Seasonal)') OR UPPER(( employee_status  )) = UPPER('Terminated'))) AND (NOT (( employee_id  ) IS NULL)) AND ((UPPER(( employee_title  )) <> UPPER('Contractor') OR (( employee_title  )) IS NULL)) AND (CASE WHEN CAST(EXTRACT(MONTH FROM CURRENT_TIMESTAMP()) AS BIGINT) = 1 THEN (CAST(EXTRACT(MONTH FROM ( TO_DATE(date_hired) )) AS BIGINT) = 12) AND (CAST(EXTRACT(YEAR FROM ( TO_DATE(date_hired) )) AS BIGINT) = (CAST(EXTRACT(YEAR FROM CURRENT_TIMESTAMP()) AS BIGINT) - 1)) ELSE (CAST(EXTRACT(MONTH FROM ( TO_DATE(date_hired) )) AS BIGINT) = (CAST(EXTRACT(MONTH FROM CURRENT_TIMESTAMP()) AS BIGINT) - 1)) AND (CAST(EXTRACT(YEAR FROM ( TO_DATE(date_hired) )) AS BIGINT) = CAST(EXTRACT(YEAR FROM CURRENT_TIMESTAMP()) AS BIGINT)) END) THEN 1 ELSE NULL END) AS starts_last_month,

--Starts Two Months Ago
COUNT(CASE WHEN (((((_es_update_timestamp)) >= ((DATEADD('hour', -46, DATE_TRUNC('hour', CURRENT_TIMESTAMP())))) AND (( _es_update_timestamp  )) < ((DATEADD('hour', 47, DATEADD('hour', -46, DATE_TRUNC('hour', CURRENT_TIMESTAMP())))))))) AND ((UPPER(( employee_status  )) = UPPER('Active') OR UPPER(( employee_status  )) = UPPER('External Payroll') OR UPPER(( employee_status  )) = UPPER('Leave with Pay') OR UPPER(( employee_status  )) = UPPER('Leave without Pay') OR UPPER(( employee_status  )) = UPPER('On Leave') OR UPPER(( employee_status  )) = UPPER('Work Comp Leave') OR UPPER(( employee_status  )) = UPPER('Seasonal (Fixed Term) (Seasonal)') OR UPPER(( employee_status  )) = UPPER('Terminated'))) AND (NOT (( employee_id  ) IS NULL)) AND ((UPPER(( employee_title  )) <> UPPER('Contractor') OR (( employee_title  )) IS NULL)) AND (CASE WHEN CAST(EXTRACT(MONTH FROM CURRENT_TIMESTAMP()) AS BIGINT) = 1 THEN (CAST(EXTRACT(MONTH FROM ( TO_DATE(date_hired) )) AS BIGINT) = 11) AND (CAST(EXTRACT(YEAR FROM ( TO_DATE(date_hired) )) AS BIGINT) = (CAST(EXTRACT(YEAR FROM CURRENT_TIMESTAMP()) AS BIGINT) - 1))
WHEN CAST(EXTRACT(MONTH FROM CURRENT_TIMESTAMP()) AS BIGINT) = 2 THEN (CAST(EXTRACT(MONTH FROM ( TO_DATE(date_hired) )) AS BIGINT) = 12) AND (CAST(EXTRACT(YEAR FROM ( TO_DATE(date_hired) )) AS BIGINT) = (CAST(EXTRACT(YEAR FROM CURRENT_TIMESTAMP()) AS BIGINT) - 1))
ELSE (CAST(EXTRACT(MONTH FROM ( TO_DATE(date_hired) )) AS BIGINT) = (CAST(EXTRACT(MONTH FROM CURRENT_TIMESTAMP()) AS BIGINT) - 2)) AND (CAST(EXTRACT(YEAR FROM ( TO_DATE(date_hired) )) AS BIGINT) = CAST(EXTRACT(YEAR FROM CURRENT_TIMESTAMP()) AS BIGINT)) END) THEN 1 ELSE NULL END) AS starts_two_months_ago,

--Starts Three Months Ago
COUNT(
CASE WHEN (((((_es_update_timestamp)) >= ((DATEADD('hour', -46, DATE_TRUNC('hour', CURRENT_TIMESTAMP())))) AND (( _es_update_timestamp  )) < ((DATEADD('hour', 47, DATEADD('hour', -46, DATE_TRUNC('hour', CURRENT_TIMESTAMP())))))))) AND ((UPPER(( employee_status  )) = UPPER('Active') OR UPPER(( employee_status  )) = UPPER('External Payroll') OR UPPER(( employee_status  )) = UPPER('Leave with Pay') OR UPPER(( employee_status  )) = UPPER('Leave without Pay') OR UPPER(( employee_status  )) = UPPER('On Leave') OR UPPER(( employee_status  )) = UPPER('Work Comp Leave') OR UPPER(( employee_status  )) = UPPER('Seasonal (Fixed Term) (Seasonal)') OR UPPER(( employee_status  )) = UPPER('Terminated'))) AND (NOT (( employee_id  ) IS NULL)) AND ((UPPER(( employee_title  )) <> UPPER('Contractor') OR (( employee_title  )) IS NULL)) AND
(CASE WHEN CAST(EXTRACT(MONTH FROM CURRENT_TIMESTAMP()) AS BIGINT) = 1 THEN (CAST(EXTRACT(MONTH FROM ( TO_DATE(date_hired) )) AS BIGINT) = 10) AND (CAST(EXTRACT(YEAR FROM ( TO_DATE(date_hired) )) AS BIGINT) = (CAST(EXTRACT(YEAR FROM CURRENT_TIMESTAMP()) AS BIGINT) - 1))
WHEN CAST(EXTRACT(MONTH FROM CURRENT_TIMESTAMP()) AS BIGINT) = 2 THEN (CAST(EXTRACT(MONTH FROM ( TO_DATE(date_hired) )) AS BIGINT) = 11) AND (CAST(EXTRACT(YEAR FROM ( TO_DATE(date_hired) )) AS BIGINT) = (CAST(EXTRACT(YEAR FROM CURRENT_TIMESTAMP()) AS BIGINT) - 1))
WHEN CAST(EXTRACT(MONTH FROM CURRENT_TIMESTAMP()) AS BIGINT) = 3 THEN (CAST(EXTRACT(MONTH FROM ( TO_DATE(date_hired) )) AS BIGINT) = 12) AND (CAST(EXTRACT(YEAR FROM ( TO_DATE(date_hired) )) AS BIGINT) = (CAST(EXTRACT(YEAR FROM CURRENT_TIMESTAMP()) AS BIGINT) - 1))
ELSE (CAST(EXTRACT(MONTH FROM ( TO_DATE(date_hired) )) AS BIGINT) = (CAST(EXTRACT(MONTH FROM CURRENT_TIMESTAMP()) AS BIGINT) - 3)) AND (CAST(EXTRACT(YEAR FROM ( TO_DATE(date_hired) )) AS BIGINT) = CAST(EXTRACT(YEAR FROM CURRENT_TIMESTAMP()) AS BIGINT)) END) THEN 1 ELSE NULL END) AS starts_three_months_ago,

--Starts YTD
COUNT(CASE WHEN (((((_es_update_timestamp)) >= ((DATEADD('hour', -46, DATE_TRUNC('hour', CURRENT_TIMESTAMP())))) AND (( _es_update_timestamp  )) < ((DATEADD('hour', 47, DATEADD('hour', -46, DATE_TRUNC('hour', CURRENT_TIMESTAMP())))))))) AND ((UPPER(( employee_status  )) = UPPER('Active') OR UPPER(( employee_status  )) = UPPER('External Payroll') OR UPPER(( employee_status  )) = UPPER('Leave with Pay') OR UPPER(( employee_status  )) = UPPER('Leave without Pay') OR UPPER(( employee_status  )) = UPPER('On Leave') OR UPPER(( employee_status  )) = UPPER('Work Comp Leave') OR UPPER(( employee_status  )) = UPPER('Seasonal (Fixed Term) (Seasonal)') OR UPPER(( employee_status  )) = UPPER('Terminated'))) AND (NOT (( employee_id  ) IS NULL)) AND ((UPPER(( employee_title  )) <> UPPER('Contractor') OR (( employee_title  )) IS NULL)) AND ((CAST(EXTRACT(MONTH FROM ( TO_DATE(date_hired) )) AS BIGINT)) < (CAST(EXTRACT(MONTH FROM CURRENT_TIMESTAMP()) AS BIGINT))) AND (CAST(EXTRACT(YEAR FROM ( TO_DATE(date_hired) )) AS BIGINT) = CAST(EXTRACT(YEAR FROM CURRENT_TIMESTAMP()) AS BIGINT)) THEN 1 ELSE NULL END) AS starts_ytd,

--Starts Last Year YTD
COUNT(CASE WHEN (((((_es_update_timestamp)) >= ((DATEADD('hour', -46, DATE_TRUNC('hour', CURRENT_TIMESTAMP())))) AND (( _es_update_timestamp  )) < ((DATEADD('hour', 47, DATEADD('hour', -46, DATE_TRUNC('hour', CURRENT_TIMESTAMP())))))))) AND ((UPPER(( employee_status  )) = UPPER('Active') OR UPPER(( employee_status  )) = UPPER('External Payroll') OR UPPER(( employee_status  )) = UPPER('Leave with Pay') OR UPPER(( employee_status  )) = UPPER('Leave without Pay') OR UPPER(( employee_status  )) = UPPER('On Leave') OR UPPER(( employee_status  )) = UPPER('Work Comp Leave') OR UPPER(( employee_status  )) = UPPER('Seasonal (Fixed Term) (Seasonal)') OR UPPER(( employee_status  )) = UPPER('Terminated'))) AND (NOT (( employee_id  ) IS NULL)) AND ((UPPER(( employee_title  )) <> UPPER('Contractor') OR (( employee_title  )) IS NULL)) AND ((CAST(EXTRACT(MONTH FROM ( TO_DATE(date_hired) )) AS BIGINT)) < (CAST(EXTRACT(MONTH FROM CURRENT_TIMESTAMP()) AS BIGINT))) AND (CAST(EXTRACT(YEAR FROM ( TO_DATE(date_hired) )) AS BIGINT) = CAST(EXTRACT(YEAR FROM CURRENT_TIMESTAMP()) AS BIGINT)- 1) THEN 1 ELSE NULL END) AS starts_last_year_ytd,

--Starts Q1 Current Year
COUNT(CASE WHEN (((((_es_update_timestamp)) >= ((DATEADD('hour', -46, DATE_TRUNC('hour', CURRENT_TIMESTAMP())))) AND (( _es_update_timestamp  )) < ((DATEADD('hour', 47, DATEADD('hour', -46, DATE_TRUNC('hour', CURRENT_TIMESTAMP())))))))) AND ((UPPER(( employee_status  )) = UPPER('Active') OR UPPER(( employee_status  )) = UPPER('External Payroll') OR UPPER(( employee_status  )) = UPPER('Leave with Pay') OR UPPER(( employee_status  )) = UPPER('Leave without Pay') OR UPPER(( employee_status  )) = UPPER('On Leave') OR UPPER(( employee_status  )) = UPPER('Work Comp Leave') OR UPPER(( employee_status  )) = UPPER('Seasonal (Fixed Term) (Seasonal)') OR UPPER(( employee_status  )) = UPPER('Terminated'))) AND (NOT (( employee_id  ) IS NULL)) AND ((UPPER(( employee_title  )) <> UPPER('Contractor') OR (( employee_title  )) IS NULL)) AND ((CAST(EXTRACT(MONTH FROM ( TO_DATE(date_hired) )) AS BIGINT)) in (1,2,3)) AND (CAST(EXTRACT(YEAR FROM ( TO_DATE(date_hired) )) AS BIGINT) = CAST(EXTRACT(YEAR FROM CURRENT_TIMESTAMP()) AS BIGINT)) THEN 1 ELSE NULL END) AS starts_q1_current_year,

--Starts Q1 Last Year
COUNT(CASE WHEN (((((_es_update_timestamp)) >= ((DATEADD('hour', -46, DATE_TRUNC('hour', CURRENT_TIMESTAMP())))) AND (( _es_update_timestamp  )) < ((DATEADD('hour', 47, DATEADD('hour', -46, DATE_TRUNC('hour', CURRENT_TIMESTAMP())))))))) AND ((UPPER(( employee_status  )) = UPPER('Active') OR UPPER(( employee_status  )) = UPPER('External Payroll') OR UPPER(( employee_status  )) = UPPER('Leave with Pay') OR UPPER(( employee_status  )) = UPPER('Leave without Pay') OR UPPER(( employee_status  )) = UPPER('On Leave') OR UPPER(( employee_status  )) = UPPER('Work Comp Leave') OR UPPER(( employee_status  )) = UPPER('Seasonal (Fixed Term) (Seasonal)') OR UPPER(( employee_status  )) = UPPER('Terminated'))) AND (NOT (( employee_id  ) IS NULL)) AND ((UPPER(( employee_title  )) <> UPPER('Contractor') OR (( employee_title  )) IS NULL)) AND ((CAST(EXTRACT(MONTH FROM ( TO_DATE(date_hired) )) AS BIGINT)) in (1,2,3)) AND (CAST(EXTRACT(YEAR FROM ( TO_DATE(date_hired) )) AS BIGINT) = CAST(EXTRACT(YEAR FROM CURRENT_TIMESTAMP()) AS BIGINT)-1) THEN 1 ELSE NULL END) AS starts_q1_last_year,

--Current Headcount
COUNT(CASE WHEN ((UPPER(( employee_status)) = UPPER('Active') OR UPPER((employee_status)) = UPPER('External Payroll') OR UPPER(( employee_status)) = UPPER('Leave with Pay') OR UPPER((employee_status)) = UPPER('Leave without Pay') OR UPPER(( employee_status)) = UPPER('On Leave') OR UPPER((employee_status)) = UPPER('Seasonal (Fixed Term) (Seasonal)') OR UPPER(( employee_status)) = UPPER('Work Comp Leave'))) AND (NOT ((employee_id) IS NULL)) AND ((UPPER((employee_title)) <> UPPER('Contractor') OR (( employee_title)) IS NULL)) AND (((((_es_update_timestamp)) >= ((DATE_TRUNC('month', CURRENT_DATE()))) AND ((_es_update_timestamp)) < ((DATEADD('month', 1, DATE_TRUNC('month', CURRENT_DATE()))))))) AND (( CASE
    WHEN date_rehired IS NOT NULL THEN date_rehired
    ELSE date_hired END  ) <= ( TO_DATE(_es_update_timestamp) )) THEN 1 ELSE NULL END) AS current_headcount,

--Headcount at the Beginning of the Year
    COUNT(CASE WHEN ((UPPER((employee_status)) = UPPER('Active') OR UPPER((employee_status)) = UPPER('External Payroll') OR UPPER(( employee_status)) = UPPER('Leave with Pay') OR UPPER((employee_status)) = UPPER('Leave without Pay') OR UPPER(( employee_status)) = UPPER('On Leave') OR UPPER((employee_status)) = UPPER('Seasonal (Fixed Term) (Seasonal)') OR UPPER(( employee_status)) = UPPER('Work Comp Leave'))) AND (NOT ((employee_id) IS NULL)) AND ((UPPER((employee_title)) <> UPPER('Contractor') OR (( employee_title)) IS NULL)) AND (((( CASE
    WHEN date_rehired IS NOT NULL THEN date_rehired
    ELSE date_hired END  ) <= ( TO_DATE(_es_update_timestamp) )) AND (CAST(EXTRACT(MONTH FROM ( TO_DATE( _es_update_timestamp ) )) AS BIGINT) = 12)) AND (CAST(EXTRACT(YEAR FROM ( TO_DATE(_es_update_timestamp ) )) AS BIGINT) = (CAST(EXTRACT(YEAR FROM CURRENT_TIMESTAMP()) AS BIGINT) - 1))) THEN 1 ELSE NULL END) AS headcount_at_the_beginning_of_year,

--Headcount 2 Months Ago
    COUNT(CASE WHEN ((UPPER((employee_status)) = UPPER('Active') OR UPPER((employee_status)) = UPPER('External Payroll') OR UPPER(( employee_status)) = UPPER('Leave with Pay') OR UPPER((employee_status)) = UPPER('Leave without Pay') OR UPPER((employee_status)) = UPPER('On Leave') OR UPPER((employee_status)) = UPPER('Seasonal (Fixed Term) (Seasonal)') OR UPPER((employee_status)) = UPPER('Work Comp Leave'))) AND (NOT ((employee_id) IS NULL)) AND ((UPPER((employee_title)) <> UPPER('Contractor') OR ((employee_title)) IS NULL)) AND (((( CASE
    WHEN date_rehired IS NOT NULL THEN date_rehired
    ELSE date_hired END  ) <= ( TO_DATE(_es_update_timestamp ) )) AND (CAST(EXTRACT(MONTH FROM ( TO_DATE(_es_update_timestamp) )) AS BIGINT) = (CAST(EXTRACT(MONTH FROM CURRENT_TIMESTAMP()) AS BIGINT) - 2))) AND CASE
  WHEN CAST(EXTRACT(MONTH FROM CURRENT_TIMESTAMP()) AS BIGINT) = 1 THEN (CAST(EXTRACT(MONTH FROM ( TO_DATE(_es_update_timestamp ) )) AS BIGINT) = 11) AND (CAST(EXTRACT(YEAR FROM ( TO_DATE(_es_update_timestamp) )) AS BIGINT) = (CAST(EXTRACT(YEAR FROM CURRENT_TIMESTAMP()) AS BIGINT) - 1))
  WHEN CAST(EXTRACT(MONTH FROM CURRENT_TIMESTAMP()) AS BIGINT) = 2 THEN (CAST(EXTRACT(MONTH FROM ( TO_DATE(_es_update_timestamp) )) AS BIGINT) = 12) AND (CAST(EXTRACT(YEAR FROM ( TO_DATE(_es_update_timestamp) )) AS BIGINT) = (CAST(EXTRACT(YEAR FROM CURRENT_TIMESTAMP()) AS BIGINT) - 1))
  ELSE CAST(EXTRACT(YEAR FROM ( TO_DATE(_es_update_timestamp) )) AS BIGINT) = CAST(EXTRACT(YEAR FROM CURRENT_TIMESTAMP()) AS BIGINT)
END) THEN 1 ELSE NULL END) AS headcount_2_months_ago,

--Headcount 3 Months Ago
    COUNT(CASE WHEN ((UPPER((employee_status)) = UPPER('Active') OR UPPER((employee_status)) = UPPER('External Payroll') OR UPPER(( employee_status)) = UPPER('Leave with Pay') OR UPPER((employee_status)) = UPPER('Leave without Pay') OR UPPER((employee_status)) = UPPER('On Leave') OR UPPER((employee_status)) = UPPER('Seasonal (Fixed Term) (Seasonal)') OR UPPER((employee_status)) = UPPER('Work Comp Leave'))) AND (NOT ((employee_id) IS NULL)) AND ((UPPER((employee_title)) <> UPPER('Contractor') OR ((employee_title)) IS NULL)) AND (((( CASE
    WHEN date_rehired IS NOT NULL THEN date_rehired
    ELSE date_hired END  ) <= ( TO_DATE(_es_update_timestamp ) )) AND (CAST(EXTRACT(MONTH FROM ( TO_DATE(_es_update_timestamp) )) AS BIGINT) = (CAST(EXTRACT(MONTH FROM CURRENT_TIMESTAMP()) AS BIGINT) - 3))) AND CASE
  WHEN CAST(EXTRACT(MONTH FROM CURRENT_TIMESTAMP()) AS BIGINT) = 1 THEN (CAST(EXTRACT(MONTH FROM ( TO_DATE(_es_update_timestamp ) )) AS BIGINT) = 10) AND (CAST(EXTRACT(YEAR FROM ( TO_DATE(_es_update_timestamp) )) AS BIGINT) = (CAST(EXTRACT(YEAR FROM CURRENT_TIMESTAMP()) AS BIGINT) - 1))
  WHEN CAST(EXTRACT(MONTH FROM CURRENT_TIMESTAMP()) AS BIGINT) = 2 THEN (CAST(EXTRACT(MONTH FROM ( TO_DATE(_es_update_timestamp) )) AS BIGINT) = 11) AND (CAST(EXTRACT(YEAR FROM ( TO_DATE(_es_update_timestamp) )) AS BIGINT) = (CAST(EXTRACT(YEAR FROM CURRENT_TIMESTAMP()) AS BIGINT) - 1))
  WHEN CAST(EXTRACT(MONTH FROM CURRENT_TIMESTAMP()) AS BIGINT) = 3 THEN (CAST(EXTRACT(MONTH FROM ( TO_DATE(_es_update_timestamp) )) AS BIGINT) = 12) AND (CAST(EXTRACT(YEAR FROM ( TO_DATE(_es_update_timestamp) )) AS BIGINT) = (CAST(EXTRACT(YEAR FROM CURRENT_TIMESTAMP()) AS BIGINT) - 1))
  ELSE CAST(EXTRACT(YEAR FROM ( TO_DATE(_es_update_timestamp) )) AS BIGINT) = CAST(EXTRACT(YEAR FROM CURRENT_TIMESTAMP()) AS BIGINT)
END) THEN 1 ELSE NULL END) AS headcount_3_months_ago,


--Headcount One Year and One Month Ago
    COUNT(CASE WHEN ((UPPER((employee_status)) = UPPER('Active') OR UPPER((employee_status)) = UPPER('External Payroll') OR UPPER((employee_status)) = UPPER('Leave with Pay') OR UPPER((employee_status)) = UPPER('Leave without Pay') OR UPPER((employee_status)) = UPPER('On Leave') OR UPPER((employee_status)) = UPPER('Seasonal (Fixed Term) (Seasonal)') OR UPPER((employee_status)) = UPPER('Work Comp Leave'))) AND (NOT ((employee_id) IS NULL)) AND ((UPPER((employee_title)) <> UPPER('Contractor') OR ((employee_title)) IS NULL)) AND (((( CASE
    WHEN date_rehired IS NOT NULL THEN date_rehired
    ELSE date_hired END  ) <= ( TO_DATE(_es_update_timestamp) )) AND (CAST(EXTRACT(MONTH FROM ( TO_DATE(_es_update_timestamp) )) AS BIGINT) = (CAST(EXTRACT(MONTH FROM CURRENT_TIMESTAMP()) AS BIGINT) - 1))) AND CASE WHEN CAST(EXTRACT(MONTH FROM CURRENT_TIMESTAMP()) AS BIGINT) = 1 THEN (CAST(EXTRACT(MONTH FROM ( TO_DATE(_es_update_timestamp) )) AS BIGINT) = 12) AND (CAST(EXTRACT(YEAR FROM ( TO_DATE(_es_update_timestamp) )) AS BIGINT) = (CAST(EXTRACT(YEAR FROM CURRENT_TIMESTAMP()) AS BIGINT) - 2)) ELSE CAST(EXTRACT(YEAR FROM ( TO_DATE(_es_update_timestamp) )) AS BIGINT) = (CAST(EXTRACT(YEAR FROM CURRENT_TIMESTAMP()) AS BIGINT) - 1) END) THEN 1 ELSE NULL END) AS headcount_one_year_and_one_month_ago,

--Headcount Last Month
    COUNT(CASE WHEN ((UPPER((employee_status)) = UPPER('Active') OR UPPER((employee_status)) = UPPER('External Payroll') OR UPPER((employee_status)) = UPPER('Leave with Pay') OR UPPER((employee_status)) = UPPER('Leave without Pay') OR UPPER((employee_status)) = UPPER('On Leave') OR UPPER((employee_status)) = UPPER('Seasonal (Fixed Term) (Seasonal)') OR UPPER((employee_status)) = UPPER('Work Comp Leave'))) AND (NOT ((employee_id) IS NULL)) AND ((UPPER((employee_title)) <> UPPER('Contractor') OR ((employee_title)) IS NULL)) AND (((( CASE
    WHEN date_rehired IS NOT NULL THEN date_rehired
    ELSE date_hired END  ) <= ( TO_DATE(_es_update_timestamp) )) AND (CAST(EXTRACT(MONTH FROM ( TO_DATE(_es_update_timestamp) )) AS BIGINT) = (CAST(EXTRACT(MONTH FROM CURRENT_TIMESTAMP()) AS BIGINT) - 1))) AND CASE WHEN CAST(EXTRACT(MONTH FROM CURRENT_TIMESTAMP()) AS BIGINT) = 1 THEN (CAST(EXTRACT(MONTH FROM ( TO_DATE(_es_update_timestamp) )) AS BIGINT) = 12) AND (CAST(EXTRACT(YEAR FROM ( TO_DATE(_es_update_timestamp) )) AS BIGINT) = (CAST(EXTRACT(YEAR FROM CURRENT_TIMESTAMP()) AS BIGINT) - 1)) ELSE CAST(EXTRACT(YEAR FROM ( TO_DATE(_es_update_timestamp) )) AS BIGINT) = CAST(EXTRACT(YEAR FROM CURRENT_TIMESTAMP()) AS BIGINT) END) THEN 1 ELSE NULL END) AS headcount_last_month,

--Headcount End of Q1 Current Year
    COUNT(CASE WHEN ((UPPER((employee_status)) = UPPER('Active') OR UPPER((employee_status)) = UPPER('External Payroll') OR UPPER(( employee_status)) = UPPER('Leave with Pay') OR UPPER((employee_status)) = UPPER('Leave without Pay') OR UPPER(( employee_status)) = UPPER('On Leave') OR UPPER((employee_status)) = UPPER('Seasonal (Fixed Term) (Seasonal)') OR UPPER(( employee_status)) = UPPER('Work Comp Leave'))) AND (NOT ((employee_id) IS NULL)) AND ((UPPER((employee_title)) <> UPPER('Contractor') OR (( employee_title)) IS NULL)) AND (((( CASE
    WHEN date_rehired IS NOT NULL THEN date_rehired
    ELSE date_hired END  ) <= ( TO_DATE(_es_update_timestamp) )) AND (CAST(EXTRACT(MONTH FROM ( TO_DATE( _es_update_timestamp ) )) AS BIGINT) = 3)) AND (CAST(EXTRACT(YEAR FROM ( TO_DATE(_es_update_timestamp ) )) AS BIGINT) = (CAST(EXTRACT(YEAR FROM CURRENT_TIMESTAMP()) AS BIGINT)))) THEN 1 ELSE NULL END) AS headcount_q1_current_year,

--Headcount End of Q1 Last Year
    COUNT(CASE WHEN ((UPPER((employee_status)) = UPPER('Active') OR UPPER((employee_status)) = UPPER('External Payroll') OR UPPER(( employee_status)) = UPPER('Leave with Pay') OR UPPER((employee_status)) = UPPER('Leave without Pay') OR UPPER(( employee_status)) = UPPER('On Leave') OR UPPER((employee_status)) = UPPER('Seasonal (Fixed Term) (Seasonal)') OR UPPER(( employee_status)) = UPPER('Work Comp Leave'))) AND (NOT ((employee_id) IS NULL)) AND ((UPPER((employee_title)) <> UPPER('Contractor') OR (( employee_title)) IS NULL)) AND (((( CASE
    WHEN date_rehired IS NOT NULL THEN date_rehired
    ELSE date_hired END  ) <= ( TO_DATE(_es_update_timestamp) )) AND (CAST(EXTRACT(MONTH FROM ( TO_DATE( _es_update_timestamp ) )) AS BIGINT) = 3)) AND (CAST(EXTRACT(YEAR FROM ( TO_DATE(_es_update_timestamp ) )) AS BIGINT) = (CAST(EXTRACT(YEAR FROM CURRENT_TIMESTAMP()) AS BIGINT) - 1))) THEN 1 ELSE NULL END) AS headcount_q1_last_year,

--Turnover Current Month
    COALESCE(SUM(CASE WHEN (CAST(EXTRACT(MONTH FROM ( TO_DATE(CAST(date_terminated AS TIMESTAMP_NTZ) ) )) AS BIGINT) = (CAST(EXTRACT(MONTH FROM CURRENT_TIMESTAMP()) AS BIGINT))) AND (CAST(EXTRACT(YEAR FROM ( TO_DATE(CAST(date_terminated AS TIMESTAMP_NTZ) ) )) AS BIGINT) = CAST(EXTRACT(YEAR FROM CURRENT_TIMESTAMP()) AS BIGINT))
 THEN terminations  ELSE NULL END), 0) AS turnover_current_month,

--Turnover
    COALESCE(SUM(CASE WHEN CASE WHEN CAST(EXTRACT(MONTH FROM CURRENT_TIMESTAMP()) AS BIGINT) = 1 THEN (CAST(EXTRACT(MONTH FROM ( TO_DATE(CAST(date_terminated AS TIMESTAMP_NTZ) ) )) AS BIGINT) = 12) AND (CAST(EXTRACT(YEAR FROM ( TO_DATE(CAST(date_terminated AS TIMESTAMP_NTZ) ) )) AS BIGINT) = (CAST(EXTRACT(YEAR FROM CURRENT_TIMESTAMP()) AS BIGINT) - 1)) ELSE (CAST(EXTRACT(MONTH FROM ( TO_DATE(CAST(date_terminated AS TIMESTAMP_NTZ) ) )) AS BIGINT) = (CAST(EXTRACT(MONTH FROM CURRENT_TIMESTAMP()) AS BIGINT) - 1)) AND (CAST(EXTRACT(YEAR FROM ( TO_DATE(CAST(date_terminated AS TIMESTAMP_NTZ) ) )) AS BIGINT) = CAST(EXTRACT(YEAR FROM CURRENT_TIMESTAMP()) AS BIGINT)) END
 THEN terminations  ELSE NULL END), 0) AS turnover,

--Turnover YTD
 SUM(CASE WHEN (CAST(EXTRACT(YEAR FROM ( TO_DATE(CAST(date_terminated AS TIMESTAMP_NTZ)))) AS BIGINT)) = (CAST(EXTRACT(YEAR FROM CURRENT_TIMESTAMP()) AS BIGINT)) AND (CAST(EXTRACT(MONTH FROM ( TO_DATE(CAST(date_terminated AS TIMESTAMP_NTZ)))) AS BIGINT)) < (CAST(EXTRACT(MONTH FROM CURRENT_TIMESTAMP()) AS BIGINT)) then terminations else null end) AS turnover_ytd,

--Turnover Last Year YTD
  SUM(CASE WHEN (CAST(EXTRACT(YEAR FROM ( TO_DATE(CAST(date_terminated AS TIMESTAMP_NTZ)))) AS BIGINT)) = (CAST(EXTRACT(YEAR FROM CURRENT_TIMESTAMP()) AS BIGINT)-1) AND (CAST(EXTRACT(MONTH FROM ( TO_DATE(CAST(date_terminated AS TIMESTAMP_NTZ)))) AS BIGINT)) < (CAST(EXTRACT(MONTH FROM CURRENT_TIMESTAMP()) AS BIGINT)) then terminations else null end)  as turnover_last_year_ytd,

--Turnover Q1 Current Year
  SUM(CASE WHEN (CAST(EXTRACT(YEAR FROM ( TO_DATE(CAST(date_terminated AS TIMESTAMP_NTZ)))) AS BIGINT)) = (CAST(EXTRACT(YEAR FROM CURRENT_TIMESTAMP()) AS BIGINT)) AND (CAST(EXTRACT(MONTH FROM ( TO_DATE(CAST(date_terminated AS TIMESTAMP_NTZ)))) AS BIGINT)) in (1,2,3) then terminations else null end) AS turnover_q1_current_year,

--Turnover Last Year YTD
  SUM(CASE WHEN (CAST(EXTRACT(YEAR FROM ( TO_DATE(CAST(date_terminated AS TIMESTAMP_NTZ)))) AS BIGINT)) = (CAST(EXTRACT(YEAR FROM CURRENT_TIMESTAMP()) AS BIGINT)-1) AND (CAST(EXTRACT(MONTH FROM ( TO_DATE(CAST(date_terminated AS TIMESTAMP_NTZ)))) AS BIGINT)) in (1,2,3) then terminations else null end)  as turnover_q1_last_year,

--Turnover 2 Months Ago
    COALESCE(SUM(CASE WHEN (CAST(EXTRACT(MONTH FROM ( TO_DATE(CAST(date_terminated AS TIMESTAMP_NTZ) ) )) AS BIGINT) = (CAST(EXTRACT(MONTH FROM CURRENT_TIMESTAMP()) AS BIGINT) - 2)) AND CASE
  WHEN CAST(EXTRACT(MONTH FROM CURRENT_TIMESTAMP()) AS BIGINT) = 1 THEN (CAST(EXTRACT(MONTH FROM ( TO_DATE(CAST(date_terminated AS TIMESTAMP_NTZ) ) )) AS BIGINT) = 11) AND (CAST(EXTRACT(YEAR FROM ( TO_DATE(CAST(date_terminated AS TIMESTAMP_NTZ) ) )) AS BIGINT) = (CAST(EXTRACT(YEAR FROM CURRENT_TIMESTAMP()) AS BIGINT) - 1))
  WHEN CAST(EXTRACT(MONTH FROM CURRENT_TIMESTAMP()) AS BIGINT) = 2 THEN (CAST(EXTRACT(MONTH FROM ( TO_DATE(CAST(date_terminated AS TIMESTAMP_NTZ) ) )) AS BIGINT) = 12) AND (CAST(EXTRACT(YEAR FROM ( TO_DATE(CAST(date_terminated AS TIMESTAMP_NTZ) ) )) AS BIGINT) = (CAST(EXTRACT(YEAR FROM CURRENT_TIMESTAMP()) AS BIGINT) - 1))
  ELSE CAST(EXTRACT(YEAR FROM ( TO_DATE(CAST(date_terminated AS TIMESTAMP_NTZ) ) )) AS BIGINT) = CAST(EXTRACT(YEAR FROM CURRENT_TIMESTAMP()) AS BIGINT)
END
 THEN terminations  ELSE NULL END), 0) AS turnover_2_months_ago,

 --Turnover 3 Months Ago
    COALESCE(SUM(CASE WHEN (CAST(EXTRACT(MONTH FROM ( TO_DATE(CAST(date_terminated AS TIMESTAMP_NTZ) ) )) AS BIGINT) = (CAST(EXTRACT(MONTH FROM CURRENT_TIMESTAMP()) AS BIGINT) - 3)) AND CASE
  WHEN CAST(EXTRACT(MONTH FROM CURRENT_TIMESTAMP()) AS BIGINT) = 1 THEN (CAST(EXTRACT(MONTH FROM ( TO_DATE(CAST(date_terminated AS TIMESTAMP_NTZ) ) )) AS BIGINT) = 10) AND (CAST(EXTRACT(YEAR FROM ( TO_DATE(CAST(date_terminated AS TIMESTAMP_NTZ) ) )) AS BIGINT) = (CAST(EXTRACT(YEAR FROM CURRENT_TIMESTAMP()) AS BIGINT) - 1))
  WHEN CAST(EXTRACT(MONTH FROM CURRENT_TIMESTAMP()) AS BIGINT) = 2 THEN (CAST(EXTRACT(MONTH FROM ( TO_DATE(CAST(date_terminated AS TIMESTAMP_NTZ) ) )) AS BIGINT) = 11) AND (CAST(EXTRACT(YEAR FROM ( TO_DATE(CAST(date_terminated AS TIMESTAMP_NTZ) ) )) AS BIGINT) = (CAST(EXTRACT(YEAR FROM CURRENT_TIMESTAMP()) AS BIGINT) - 1))
  WHEN CAST(EXTRACT(MONTH FROM CURRENT_TIMESTAMP()) AS BIGINT) = 3 THEN (CAST(EXTRACT(MONTH FROM ( TO_DATE(CAST(date_terminated AS TIMESTAMP_NTZ) ) )) AS BIGINT) = 12) AND (CAST(EXTRACT(YEAR FROM ( TO_DATE(CAST(date_terminated AS TIMESTAMP_NTZ) ) )) AS BIGINT) = (CAST(EXTRACT(YEAR FROM CURRENT_TIMESTAMP()) AS BIGINT) - 1))
  ELSE CAST(EXTRACT(YEAR FROM ( TO_DATE(CAST(date_terminated AS TIMESTAMP_NTZ) ) )) AS BIGINT) = CAST(EXTRACT(YEAR FROM CURRENT_TIMESTAMP()) AS BIGINT)
END
 THEN terminations  ELSE NULL END), 0) AS turnover_3_months_ago
from ANALYTICS.PAYROLL.EE_COMPANY_DIRECTORY_12_MONTH
where top_focus is not null and employee_status in ('Active','External Payroll','Leave with Pay','Leave without Pay','On Leave', 'Seasonal (Fixed Term)(Seasonal)','Work Comp Leave','Terminated')
group by top_focus
order by top_focus),

greenhouse as
      (select
      case when r.requisition_name like '%Territory Account Manager%' then 'Territory Account Managers'
      when r.requisition_name like '%District Sales Manager%' then 'District Sales Managers'
      when r.requisition_name = 'General Manager' OR r.requisition_name = 'General Manager - Advanced Solutions' then 'General Managers'
      when r.requisition_name like '%Service Manager%' then 'Service Managers'
      when r.requisition_name like '%Service Technician%' OR r.requisition_name like '%Field Technician%' OR r.requisition_name like '%Diesel Technician%' OR r.requisition_name like '%Shop Technician%' then 'Techs'
      when r.requisition_name like '%CDL%' then 'CDL Delivery Drivers'
      when r.requisition_name like '%District Operations%' and r.requisition_name not like '%Assistant%' then 'District Operations Managers'
      else null end as top_focus,

      --Offers Extended Current Month
      COUNT(DISTINCT CASE WHEN (((( (r.requisition_custom_type) )) = 'Active Requisition')) AND (((( (o.offer_status) )) <> 'deprecated' OR (( (o.offer_status) )) IS NULL)) AND ((CAST(EXTRACT(MONTH FROM  (TO_DATE((sent.date) )) ) AS BIGINT) = (CAST(EXTRACT(MONTH FROM CURRENT_TIMESTAMP()) AS BIGINT))) AND CAST(EXTRACT(YEAR FROM  (TO_DATE((sent.date) )) ) AS BIGINT) = CAST(EXTRACT(YEAR FROM CURRENT_TIMESTAMP()) AS BIGINT)) THEN (o.offer_id)  ELSE NULL END) AS offers_extended_current_month,

      --Offers Extended Last Month
      COUNT(DISTINCT CASE WHEN (((( (r.requisition_custom_type) )) = 'Active Requisition')) AND (((( (o.offer_status) )) <> 'deprecated' OR (( (o.offer_status) )) IS NULL)) AND ((CAST(EXTRACT(MONTH FROM  (TO_DATE((sent.date) )) ) AS BIGINT) = (CAST(EXTRACT(MONTH FROM CURRENT_TIMESTAMP()) AS BIGINT) - 1)) AND CASE WHEN CAST(EXTRACT(MONTH FROM CURRENT_TIMESTAMP()) AS BIGINT) = 1 THEN (CAST(EXTRACT(MONTH FROM  (TO_DATE((sent.date) )) ) AS BIGINT) = 12) AND (CAST(EXTRACT(YEAR FROM  (TO_DATE((sent.date) )) ) AS BIGINT) = (CAST(EXTRACT(YEAR FROM CURRENT_TIMESTAMP()) AS BIGINT) - 1)) ELSE CAST(EXTRACT(YEAR FROM  (TO_DATE((sent.date) )) ) AS BIGINT) = CAST(EXTRACT(YEAR FROM CURRENT_TIMESTAMP()) AS BIGINT) END) THEN (o.offer_id)  ELSE NULL END) AS offers_extended_last_month,

      --Offers Extended YTD
      COUNT(DISTINCT CASE WHEN (((( (r.requisition_custom_type) )) = 'Active Requisition')) AND (((( (o.offer_status) )) <> 'deprecated' OR (( (o.offer_status) )) IS NULL)) AND CAST(EXTRACT(YEAR FROM  (TO_DATE((sent.date) )) ) AS BIGINT) = CAST(EXTRACT(YEAR FROM CURRENT_TIMESTAMP()) AS BIGINT) AND CAST(EXTRACT(MONTH FROM  (TO_DATE((sent.date) )) ) AS BIGINT) < CAST(EXTRACT(MONTH FROM CURRENT_TIMESTAMP()) AS BIGINT) THEN (o.offer_id)  ELSE NULL END) AS offers_extended_ytd,

      --Offers Extended Last YTD
      COUNT(DISTINCT CASE WHEN (((( (r.requisition_custom_type) )) = 'Active Requisition')) AND (((( (o.offer_status) )) <> 'deprecated' OR (( (o.offer_status) )) IS NULL)) AND CAST(EXTRACT(YEAR FROM  (TO_DATE((sent.date) )) ) AS BIGINT) = (CAST(EXTRACT(YEAR FROM CURRENT_TIMESTAMP()) AS BIGINT)-1) AND CAST(EXTRACT(MONTH FROM  (TO_DATE((sent.date) )) ) AS BIGINT) < CAST(EXTRACT(MONTH FROM CURRENT_TIMESTAMP()) AS BIGINT) THEN (o.offer_id)  ELSE NULL END) AS offers_extended_last_year_ytd,

      --Offers Extended 2 Months Ago
      COUNT(DISTINCT CASE WHEN (((( (r.requisition_custom_type) )) = 'Active Requisition')) AND (((( (o.offer_status) )) <> 'deprecated' OR (( (o.offer_status) )) IS NULL)) AND ((CAST(EXTRACT(MONTH FROM  (TO_DATE((sent.date) )) ) AS BIGINT) = (CAST(EXTRACT(MONTH FROM CURRENT_TIMESTAMP()) AS BIGINT) - 2)) AND CASE
      WHEN CAST(EXTRACT(MONTH FROM CURRENT_TIMESTAMP()) AS BIGINT) = 1 THEN (CAST(EXTRACT(MONTH FROM  (TO_DATE((sent.date) )) ) AS BIGINT) = 11) AND (CAST(EXTRACT(YEAR FROM  (TO_DATE((sent.date) )) ) AS BIGINT) = (CAST(EXTRACT(YEAR FROM CURRENT_TIMESTAMP()) AS BIGINT) - 1))
      WHEN CAST(EXTRACT(MONTH FROM CURRENT_TIMESTAMP()) AS BIGINT) = 2 THEN (CAST(EXTRACT(MONTH FROM  (TO_DATE((sent.date) )) ) AS BIGINT) = 12) AND (CAST(EXTRACT(YEAR FROM  (TO_DATE((sent.date) )) ) AS BIGINT) = (CAST(EXTRACT(YEAR FROM CURRENT_TIMESTAMP()) AS BIGINT) - 1))
      ELSE CAST(EXTRACT(YEAR FROM  (TO_DATE((sent.date) )) ) AS BIGINT) = CAST(EXTRACT(YEAR FROM CURRENT_TIMESTAMP()) AS BIGINT)
      END) THEN (o.offer_id)  ELSE NULL END) AS offers_extended_2_months_ago,

      --Offers Extended Q1 Current Year
      COUNT(DISTINCT CASE WHEN (((( (r.requisition_custom_type) )) = 'Active Requisition')) AND (((( (o.offer_status) )) <> 'deprecated' OR (( (o.offer_status) )) IS NULL)) AND CAST(EXTRACT(YEAR FROM  (TO_DATE((sent.date) )) ) AS BIGINT) = CAST(EXTRACT(YEAR FROM CURRENT_TIMESTAMP()) AS BIGINT) AND CAST(EXTRACT(MONTH FROM  (TO_DATE((sent.date) )) ) AS BIGINT) in (1,2,3) THEN (o.offer_id)  ELSE NULL END) AS offers_extended_q1_current_year,

      --Offers Extended Q1 Last Year
      COUNT(DISTINCT CASE WHEN (((( (r.requisition_custom_type) )) = 'Active Requisition')) AND (((( (o.offer_status) )) <> 'deprecated' OR (( (o.offer_status) )) IS NULL)) AND CAST(EXTRACT(YEAR FROM  (TO_DATE((sent.date) )) ) AS BIGINT) = (CAST(EXTRACT(YEAR FROM CURRENT_TIMESTAMP()) AS BIGINT)-1) AND CAST(EXTRACT(MONTH FROM  (TO_DATE((sent.date) )) ) AS BIGINT) in (1,2,3) THEN (o.offer_id)  ELSE NULL END) AS offers_extended_q1_last_year

      from PEOPLE_ANALYTICS.GREENHOUSE.V_FACT_APPLICATION_REQUISITION_OFFER f
      inner join PEOPLE_ANALYTICS.GREENHOUSE.V_DIM_REQUISITION r on f.application_requisition_offer_requisition_key = r.requisition_key
      inner join PEOPLE_ANALYTICS.GREENHOUSE.V_DIM_OFFER o on f.application_requisition_offer_offer_key = o.offer_key
      left join PEOPLE_ANALYTICS.GREENHOUSE.V_DIM_DATE resolved on f.application_requisition_offer_offer_resolved_date = resolved.date
      left join PEOPLE_ANALYTICS.GREENHOUSE.V_DIM_DATE sent on f.application_requisition_offer_offer_sent_date = sent.date
      where top_focus is not null
      group by top_focus),



offers_accpeted as (

with offers_accepted as (SELECT
    c.candidate_id,
    c.candidate_full_name,
    s.stage_name,
    ah.application_history_date,
    ah.application_history_prior_stage_date,
    a.application_status,
    ah.application_history_new_status,
    case when r.requisition_name like '%Territory Account Manager%' then 'Territory Account Managers'
      when r.requisition_name like '%District Sales Manager%' then 'District Sales Managers'
      when r.requisition_name = 'General Manager' OR r.requisition_name = 'General Manager - Advanced Solutions' then 'General Managers'
      when r.requisition_name like '%Service Manager%' then 'Service Managers'
      when r.requisition_name like '%Service Technician%' OR r.requisition_name like '%Field Technician%' OR r.requisition_name like '%Diesel Technician%' OR r.requisition_name like '%Shop Technician%' then 'Techs'
      when r.requisition_name like '%CDL%' then 'CDL Delivery Drivers'
      when r.requisition_name like '%District Operations%' and r.requisition_name not like '%Assistant%' then 'District Operations Managers'
      else null end as top_focus
FROM PEOPLE_ANALYTICS.GREENHOUSE.V_FACT_APPLICATION_HISTORY ah
INNER JOIN PEOPLE_ANALYTICS.GREENHOUSE.V_DIM_APPLICATION a
    ON ah.application_history_application_key = a.application_key
INNER JOIN PEOPLE_ANALYTICS.GREENHOUSE.V_DIM_REQUISITION r
    ON ah.application_history_requistion_key = r.requisition_key
INNER JOIN PEOPLE_ANALYTICS.GREENHOUSE.V_DIM_STAGE s
    ON ah.application_history_stage_key = s.stage_key
INNER JOIN PEOPLE_ANALYTICS.GREENHOUSE.V_DIM_CANDIDATE c
    ON ah.application_history_candidate_key = c.candidate_key
WHERE application_history_new_status = 'hired' and r.requisition_custom_type = 'Active Requisition'
ORDER BY
    c.candidate_full_name,
    ah.application_history_date)

select
top_focus,

--Offers Accepted Current Month
      COUNT(DISTINCT CASE WHEN ((CAST(EXTRACT(MONTH FROM  (TO_DATE((application_history_date) )) ) AS BIGINT) = (CAST(EXTRACT(MONTH FROM CURRENT_TIMESTAMP()) AS BIGINT))) AND CAST(EXTRACT(YEAR FROM  (TO_DATE((application_history_date) )) ) AS BIGINT) = CAST(EXTRACT(YEAR FROM CURRENT_TIMESTAMP()) AS BIGINT)) THEN (candidate_id)  ELSE NULL END) AS offers_accepted_current_month,

      --Offers Accepted Last Month
      COUNT(DISTINCT CASE WHEN ((CAST(EXTRACT(MONTH FROM  (TO_DATE((application_history_date) )) ) AS BIGINT) = (CAST(EXTRACT(MONTH FROM CURRENT_TIMESTAMP()) AS BIGINT) - 1)) AND CASE WHEN CAST(EXTRACT(MONTH FROM CURRENT_TIMESTAMP()) AS BIGINT) = 1 THEN (CAST(EXTRACT(MONTH FROM  (TO_DATE((application_history_date) )) ) AS BIGINT) = 12) AND (CAST(EXTRACT(YEAR FROM  (TO_DATE((application_history_date) )) ) AS BIGINT) = (CAST(EXTRACT(YEAR FROM CURRENT_TIMESTAMP()) AS BIGINT) - 1)) ELSE CAST(EXTRACT(YEAR FROM  (TO_DATE((application_history_date) )) ) AS BIGINT) = CAST(EXTRACT(YEAR FROM CURRENT_TIMESTAMP()) AS BIGINT) END) THEN (candidate_id)  ELSE NULL END) AS offers_accepted_last_month,

      --Offers Accepted 2 Months Ago
      COUNT(DISTINCT CASE WHEN ((CAST(EXTRACT(MONTH FROM  (TO_DATE((application_history_date) )) ) AS BIGINT) = (CAST(EXTRACT(MONTH FROM CURRENT_TIMESTAMP()) AS BIGINT) - 2)) AND CASE
      WHEN CAST(EXTRACT(MONTH FROM CURRENT_TIMESTAMP()) AS BIGINT) = 1 THEN (CAST(EXTRACT(MONTH FROM  (TO_DATE((application_history_date) )) ) AS BIGINT) = 11) AND (CAST(EXTRACT(YEAR FROM  (TO_DATE((application_history_date) )) ) AS BIGINT) = (CAST(EXTRACT(YEAR FROM CURRENT_TIMESTAMP()) AS BIGINT) - 1))
      WHEN CAST(EXTRACT(MONTH FROM CURRENT_TIMESTAMP()) AS BIGINT) = 2 THEN (CAST(EXTRACT(MONTH FROM  (TO_DATE((application_history_date) )) ) AS BIGINT) = 12) AND (CAST(EXTRACT(YEAR FROM  (TO_DATE((application_history_date) )) ) AS BIGINT) = (CAST(EXTRACT(YEAR FROM CURRENT_TIMESTAMP()) AS BIGINT) - 1))
      ELSE CAST(EXTRACT(YEAR FROM  (TO_DATE((application_history_date) )) ) AS BIGINT) = CAST(EXTRACT(YEAR FROM CURRENT_TIMESTAMP()) AS BIGINT)
      END) THEN (candidate_id)  ELSE NULL END) AS offers_accepted_2_months_ago,

      --Offers Accepted YTD
      COUNT(DISTINCT CASE WHEN CAST(EXTRACT(YEAR FROM  (TO_DATE((application_history_date) )) ) AS BIGINT) = CAST(EXTRACT(YEAR FROM CURRENT_TIMESTAMP()) AS BIGINT) AND CAST(EXTRACT(MONTH FROM  (TO_DATE((application_history_date) )) ) AS BIGINT) < CAST(EXTRACT(MONTH FROM CURRENT_TIMESTAMP()) AS BIGINT) THEN (candidate_id)  ELSE NULL END) AS offers_accepted_ytd,

      --Offers Accepted Last YTD
      COUNT(DISTINCT CASE WHEN CAST(EXTRACT(YEAR FROM  (TO_DATE((application_history_date) )) ) AS BIGINT) = (CAST(EXTRACT(YEAR FROM CURRENT_TIMESTAMP()) AS BIGINT)-1) AND CAST(EXTRACT(MONTH FROM  (TO_DATE((application_history_date) )) ) AS BIGINT) < CAST(EXTRACT(MONTH FROM CURRENT_TIMESTAMP()) AS BIGINT) THEN (candidate_id)  ELSE NULL END) AS offers_accepted_last_year_ytd,

      --Offers Accepted Q1 Current Year
      COUNT(DISTINCT CASE WHEN CAST(EXTRACT(YEAR FROM  (TO_DATE((application_history_date) )) ) AS BIGINT) = CAST(EXTRACT(YEAR FROM CURRENT_TIMESTAMP()) AS BIGINT) AND CAST(EXTRACT(MONTH FROM  (TO_DATE((application_history_date) )) ) AS BIGINT) in (1,2,3) THEN (candidate_id)  ELSE NULL END) AS offers_accepted_q1_current_year,

      --Offers Accepted Q1 Last Year
      COUNT(DISTINCT CASE WHEN CAST(EXTRACT(YEAR FROM  (TO_DATE((application_history_date) )) ) AS BIGINT) = (CAST(EXTRACT(YEAR FROM CURRENT_TIMESTAMP()) AS BIGINT)-1) AND CAST(EXTRACT(MONTH FROM  (TO_DATE((application_history_date) )) ) AS BIGINT) in (1,2,3) THEN (candidate_id)  ELSE NULL END) AS offers_accepted_q1_last_year
from offers_accepted
where top_focus is not null
group by top_focus
order by top_focus
)

      select cd.top_focus,
      cd.starts_current_month + internal_hires.internal_hires_current_month as starts_current_month,
      cd.starts_last_month + internal_hires.internal_hires_last_month as starts_last_month,
      cd.starts_two_months_ago + internal_hires.internal_hires_2_months_ago as starts_two_months_ago,
      cd.starts_three_months_ago + internal_hires.internal_hires_3_months_ago as starts_three_months_ago,
      cd.starts_ytd + internal_hires.internal_hires_ytd as starts_ytd,
      cd.starts_last_year_ytd + internal_hires.internal_hires_last_year_ytd as starts_last_year_ytd,
      cd.starts_q1_current_year + internal_hires.internal_hires_q1_current_year as starts_q1_current_year,
      cd.starts_q1_last_year + internal_hires.internal_hires_q1_last_year as starts_q1_last_year,
      cd.current_headcount,
      cd.headcount_at_the_beginning_of_year,
      cd.headcount_2_months_ago,
      cd.headcount_3_months_ago,
      cd.headcount_one_year_and_one_month_ago,
      cd.headcount_last_month,
      cd.headcount_q1_current_year,
      cd.headcount_q1_last_year,
      cd.turnover_current_month,
      cd.turnover,
      cd.turnover_ytd,
      cd.turnover_last_year_ytd,
      cd.turnover_q1_current_year,
      cd.turnover_q1_last_year,
      cd.turnover_2_months_ago,
      cd.turnover_3_months_ago,
      greenhouse.offers_extended_current_month,
      greenhouse.offers_extended_last_month,
      greenhouse.offers_extended_ytd,
      greenhouse.offers_extended_last_year_ytd,
      greenhouse.offers_extended_2_months_ago,
      greenhouse.offers_extended_q1_current_year,
      greenhouse.offers_extended_q1_last_year,
      oa.offers_accepted_current_month,
      oa.offers_accepted_last_month,
      oa.offers_accepted_2_months_ago,
      oa.offers_accepted_ytd,
      oa.offers_accepted_last_year_ytd,
      oa.offers_accepted_q1_current_year,
      oa.offers_accepted_q1_last_year,

      --Starts Current Month Perc Change
      case when starts_last_month = 0 then starts_current_month
      else (starts_current_month - starts_last_month) / starts_last_month end as starts_current_month_perc_change,

      --Starts MoM Perc Change
      case when starts_two_months_ago = 0 then starts_last_month
      else (starts_last_month - starts_two_months_ago) / starts_two_months_ago end as starts_mom_perc_change,

      --Starts 2 Months Ago MoM Perc Change
      case when starts_three_months_ago = 0 then starts_two_months_ago
      else (starts_two_months_ago - starts_three_months_ago) / starts_three_months_ago end as starts_2mo_perc_change,

      --Starts YoY Perc Change
      case when starts_last_year_ytd = 0 then starts_ytd
      else (starts_ytd - starts_last_year_ytd) / starts_last_year_ytd end as starts_yoy_perc_change,

      --Starts Q1 Perc Change
      case when starts_q1_last_year = 0 then starts_q1_current_year
      else (starts_q1_current_year - starts_q1_last_year) / starts_q1_last_year end as starts_q1_perc_change,

      --MoM HC Perc Change
      case when headcount_2_months_ago = 0 then headcount_last_month
      else (headcount_last_month - headcount_2_months_ago) / headcount_2_months_ago end as mom_hc_perc_change,

      --YoY HC Perc Change
      case when headcount_one_year_and_one_month_ago = 0 then headcount_last_month
      else (headcount_last_month - headcount_one_year_and_one_month_ago) / headcount_one_year_and_one_month_ago end as yoy_hc_perc_change,

      --Q1 HC Perc Change
      case when headcount_q1_last_year = 0 then headcount_q1_current_year
      else (headcount_q1_current_year - headcount_q1_last_year) / headcount_q1_last_year end as headcount_q1_perc_change,

      --Turnover Current Month Perc Change
      case when turnover = 0 then turnover_current_month
      else (turnover_current_month - turnover) / turnover end as turnover_current_month_perc_change,

      --Turnover MoM Perc Change
      case when turnover_2_months_ago = 0 then turnover
      else (turnover - turnover_2_months_ago) / turnover_2_months_ago end as turnover_mom_perc_change,

      --Turnover MoM 2 Months Ago Perc Change
      case when turnover_3_months_ago = 0 then turnover_2_months_ago
      else (turnover_2_months_ago - turnover_3_months_ago) / turnover_3_months_ago end as turnover_2mo_perc_change,

      --Turnover YoY Perc Change
      case when turnover_last_year_ytd = 0 then turnover_ytd
      else (turnover_ytd - turnover_last_year_ytd) / turnover_last_year_ytd end as turnover_yoy_perc_change,

      --Turnover Q1 Perc Change
      case when turnover_q1_last_year = 0 then turnover_q1_current_year
      else (turnover_q1_current_year - turnover_q1_last_year) / turnover_q1_last_year end as turnover_q1_perc_change,

      --Offers Extended MoM Perc Change
      case when offers_extended_2_months_ago = 0 then offers_extended_last_month
      else (offers_extended_last_month - offers_extended_2_months_ago) / offers_extended_2_months_ago end as offers_extended_mom_perc_change,

      --Offers Extended YoY Perc Change
      case when offers_extended_last_year_ytd = 0 then offers_extended_ytd
      else (offers_extended_ytd - offers_extended_last_year_ytd) / offers_extended_last_year_ytd end as offers_extended_yoy_perc_change,

      --Offers Extended Q1 Perc Change
      case when offers_extended_q1_last_year = 0 then offers_extended_q1_current_year
      else (offers_extended_q1_current_year - offers_extended_q1_last_year) / offers_extended_q1_last_year end as offers_extended_q1_perc_change,

      --Offers Accepted MoM Perc Change
      case when offers_accepted_2_months_ago = 0 then offers_accepted_last_month
      else (offers_accepted_last_month - offers_accepted_2_months_ago) / offers_accepted_2_months_ago end as offers_accepted_mom_perc_change,

      --Offers Accepted YoY Perc Change
      case when offers_accepted_last_year_ytd = 0 then offers_accepted_ytd
      else (offers_accepted_ytd - offers_accepted_last_year_ytd) / offers_accepted_last_year_ytd end as offers_accepted_yoy_perc_change,

      --Offers Accepted Q1 Perc Change
      case when offers_accepted_q1_last_year = 0 then offers_accepted_q1_current_year
      else (offers_accepted_q1_current_year - offers_accepted_q1_last_year) / offers_accepted_q1_last_year end as offers_accepted_q1_perc_change,

      --Net HC Current Month
      current_headcount - headcount_last_month as net_hc_current_month,

      --Net HC MoM
      headcount_last_month - headcount_2_months_ago as net_hc_mom,

      --Net HC 2 Months Ago
      headcount_2_months_ago - headcount_3_months_ago as net_hc_2mo_mom,

      --Net HC YoY
      headcount_last_month - headcount_one_year_and_one_month_ago as net_hc_yoy,

      --ALL GOALS
      CAST(REPLACE(last_month_goal.territory_account_managers_goal, ',', '') AS NUMERIC) AS tam_month_goal,
      CAST(REPLACE(dsm_last_month_goal.hiring_goal, ',', '') AS NUMERIC) AS dsm_month_goal,
      CAST(REPLACE(last_month_goal.general_managers_goal, ',', '') AS NUMERIC) AS gm_month_goal,
      CAST(REPLACE(last_month_goal.service_managers_goal, ',', '') AS NUMERIC) AS sm_month_goal,
      CAST(REPLACE(last_month_goal.techs_goal, ',', '') AS NUMERIC) AS techs_month_goal,
      CAST(REPLACE(last_month_goal.cdl_delivery_drivers_goal, ',', '') AS NUMERIC) AS cdl_month_goal,
      CAST(REPLACE(eoy_goal.territory_account_managers_goal, ',', '') AS NUMERIC) AS tam_eoy_goal,
      CAST(REPLACE(dsm_eoy_goal.hiring_goal, ',', '') AS NUMERIC) AS dsm_eoy_goal,
      CAST(REPLACE(eoy_goal.general_managers_goal, ',', '') AS NUMERIC) AS gm_eoy_goal,
      CAST(REPLACE(eoy_goal.service_managers_goal, ',', '') AS NUMERIC) AS sm_eoy_goal,
      CAST(REPLACE(eoy_goal.techs_goal, ',', '') AS NUMERIC) AS techs_eoy_goal,
      CAST(REPLACE(eoy_goal.cdl_delivery_drivers_goal, ',', '') AS NUMERIC) AS cdl_eoy_goal,
      CAST(REPLACE(q1_2025.territory_account_managers_goal, ',', '') AS NUMERIC) AS tam_q1_2025_goal,
      CAST(REPLACE(dsm_q1_2025_goal.hiring_goal, ',', '') AS NUMERIC) AS dsm_q1_2025_goal,
      CAST(REPLACE(q1_2025.general_managers_goal, ',', '') AS NUMERIC) AS gm_q1_2025_goal,
      CAST(REPLACE(q1_2025.service_managers_goal, ',', '') AS NUMERIC) AS sm_q1_2025_goal,
      CAST(REPLACE(q1_2025.techs_goal, ',', '') AS NUMERIC) AS techs_q1_2025_goal,
      CAST(REPLACE(q1_2025.cdl_delivery_drivers_goal, ',', '') AS NUMERIC) AS cdl_q1_2025_goal
      from cd
      left join greenhouse on cd.top_focus = greenhouse.top_focus
      left join offers_accpeted oa on cd.top_focus = oa.top_focus
      left join PEOPLE_ANALYTICS.LOOKER.HIRING_GOALS last_month_goal on LAST_DAY(DATE_TRUNC('MONTH',CURRENT_DATE)-1) = last_month_goal.target_date
      left join PEOPLE_ANALYTICS.LOOKER.HIRING_GOALS eoy_goal on LAST_DAY(TO_DATE(CONCAT(YEAR(CURRENT_DATE),'-',MONTH(TO_DATE('2025-12-01')),'-',DAY(DATE_TRUNC('MONTH',CURRENT_DATE))))) = eoy_goal.target_date
      left join PEOPLE_ANALYTICS.LOOKER.HIRING_GOALS q1_2025 on LAST_DAY(TO_DATE('2025-03-31')) = q1_2025.target_date
      left join (select LAST_DAY(DATE_TRUNC('MONTH',CURRENT_DATE)-1) as eoy, count(distinct(split_part(default_cost_centers_full_path,'/',3))) as hiring_goal

      from ANALYTICS.PAYROLL.EE_COMPANY_DIRECTORY_12_MONTH
      where (((((_es_update_timestamp)) >= ((DATEADD('hour', -46, DATE_TRUNC('hour', CURRENT_TIMESTAMP())))) AND (( _es_update_timestamp  )) < ((DATEADD('hour', 47, DATEADD('hour', -46, DATE_TRUNC('hour', CURRENT_TIMESTAMP())))))))) and employee_status in ('Active','External Payroll','Leave with Pay','Leave without Pay','On Leave','Seasonal (Fixed Term)(Seasonal)','Work Comp Leave') and split_part(default_cost_centers_full_path,'/',3) not in ('','National','Corporate','T3')) dsm_last_month_goal on LAST_DAY(DATE_TRUNC('MONTH',CURRENT_DATE)-1) = TO_DATE(dsm_last_month_goal.eoy)
      left join (select LAST_DAY(TO_DATE(CONCAT(YEAR(CURRENT_DATE),'-',MONTH(TO_DATE('2025-12-01')),'-',DAY(DATE_TRUNC('MONTH',CURRENT_DATE))))) as eoy, count(distinct(split_part(default_cost_centers_full_path,'/',3))) as hiring_goal

      from ANALYTICS.PAYROLL.EE_COMPANY_DIRECTORY_12_MONTH
      where (((((_es_update_timestamp)) >= ((DATEADD('hour', -46, DATE_TRUNC('hour', CURRENT_TIMESTAMP())))) AND (( _es_update_timestamp  )) < ((DATEADD('hour', 47, DATEADD('hour', -46, DATE_TRUNC('hour', CURRENT_TIMESTAMP())))))))) and employee_status in ('Active','External Payroll','Leave with Pay','Leave without Pay','On Leave','Seasonal (Fixed Term)(Seasonal)','Work Comp Leave') and split_part(default_cost_centers_full_path,'/',3) not in ('','National','Corporate','T3')) dsm_eoy_goal on LAST_DAY(TO_DATE(CONCAT(YEAR(CURRENT_DATE),'-',MONTH(TO_DATE('2025-12-01')),'-',DAY(DATE_TRUNC('MONTH',CURRENT_DATE))))) = TO_DATE(dsm_eoy_goal.eoy)
      left join (select LAST_DAY(TO_DATE(CONCAT(YEAR(CURRENT_DATE),'-',MONTH(TO_DATE('2025-03-31')),'-',DAY(DATE_TRUNC('MONTH',CURRENT_DATE))))) as eoy, count(distinct(split_part(default_cost_centers_full_path,'/',3))) as hiring_goal

      from ANALYTICS.PAYROLL.EE_COMPANY_DIRECTORY_12_MONTH
      where (((((_es_update_timestamp)) >= ((DATEADD('hour', -46, DATE_TRUNC('hour', CURRENT_TIMESTAMP())))) AND (( _es_update_timestamp  )) < ((DATEADD('hour', 47, DATEADD('hour', -46, DATE_TRUNC('hour', CURRENT_TIMESTAMP())))))))) and employee_status in ('Active','External Payroll','Leave with Pay','Leave without Pay','On Leave','Seasonal (Fixed Term)(Seasonal)','Work Comp Leave') and split_part(default_cost_centers_full_path,'/',3) not in ('','National','Corporate','T3')) dsm_q1_2025_goal on LAST_DAY(TO_DATE(CONCAT(YEAR(CURRENT_DATE),'-',MONTH(TO_DATE('2025-03-31')),'-',DAY(DATE_TRUNC('MONTH',CURRENT_DATE))))) = TO_DATE(dsm_q1_2025_goal.eoy)
      left join (with all_internals as (select cd.*, cd.employee_id || '|' || f.application_requisition_offer_application_key || '|' ||cd.position_effective_date as internal_hire_key
      from PEOPLE_ANALYTICS.GREENHOUSE.V_FACT_APPLICATION_REQUISITION_OFFER f
      inner join PEOPLE_ANALYTICS.GREENHOUSE.V_DIM_REQUISITION r on f.application_requisition_offer_requisition_key = r.requisition_key
      inner join PEOPLE_ANALYTICS.GREENHOUSE.V_DIM_OFFER o on f.application_requisition_offer_offer_key = o.offer_key
      left join ANALYTICS.PAYROLL.EE_COMPANY_DIRECTORY_12_MONTH cd on f.application_requisition_offer_application_key = cd.greenhouse_application_id
      where o.offer_status = 'accepted' and r.requisition_custom_type = 'Active Requisition' and cd.employee_status in ('Active','External Payroll','Leave with Pay','Leave without Pay','On Leave','Seasonal (Fixed Term)(Seasonal)','Work Comp Leave','Terminated') and position_effective_date is not null and TO_DATE(cd.date_hired) <> TO_DATE(cd.position_effective_date) and o.offer_custom_internal_external_applicant = 'Internal'
      order by cd.position_effective_date desc)



select
--Top Focus
case when employee_title like '%Territory Account Manager%' then 'Territory Account Managers'
    when employee_title like '%District Sales Manager%' then 'District Sales Managers'
    when employee_title = 'General Manager' OR employee_title = 'General Manager - Advanced Solutions' then 'General Managers'
    when employee_title like '%Service Manager%' then 'Service Managers'
    when employee_title like '%Service Technician%' OR employee_title like '%Field Technician%' OR employee_title like '%Diesel Technician%' OR employee_title like '%Shop Technician%' then 'Techs'
    when employee_title like '%CDL%' then 'CDL Delivery Drivers'
    when employee_title like '%District Operations%' and employee_title not like '%Assistant%' then 'District Operations Managers'
    else null end as top_focus,

--Internal Hires Current Month
      COUNT(DISTINCT CASE WHEN ((CAST(EXTRACT(MONTH FROM  (TO_DATE((position_effective_date) )) ) AS BIGINT) = (CAST(EXTRACT(MONTH FROM CURRENT_TIMESTAMP()) AS BIGINT))) AND CAST(EXTRACT(YEAR FROM  (TO_DATE((position_effective_date) )) ) AS BIGINT) = CAST(EXTRACT(YEAR FROM CURRENT_TIMESTAMP()) AS BIGINT)) THEN (internal_hire_key)  ELSE NULL END) AS internal_hires_current_month,

--Internal Hires Last Month
      COUNT(DISTINCT CASE WHEN ((CAST(EXTRACT(MONTH FROM  (TO_DATE((position_effective_date) )) ) AS BIGINT) = (CAST(EXTRACT(MONTH FROM CURRENT_TIMESTAMP()) AS BIGINT) - 1)) AND CASE WHEN CAST(EXTRACT(MONTH FROM CURRENT_TIMESTAMP()) AS BIGINT) = 1 THEN (CAST(EXTRACT(MONTH FROM  (TO_DATE((position_effective_date) )) ) AS BIGINT) = 12) AND (CAST(EXTRACT(YEAR FROM  (TO_DATE((position_effective_date) )) ) AS BIGINT) = (CAST(EXTRACT(YEAR FROM CURRENT_TIMESTAMP()) AS BIGINT) - 1)) ELSE CAST(EXTRACT(YEAR FROM  (TO_DATE((position_effective_date) )) ) AS BIGINT) = CAST(EXTRACT(YEAR FROM CURRENT_TIMESTAMP()) AS BIGINT) END) THEN (internal_hire_key)  ELSE NULL END) AS internal_hires_last_month,

      --Internal Hires 2 Months Ago
      COUNT(DISTINCT CASE WHEN ((CAST(EXTRACT(MONTH FROM  (TO_DATE((position_effective_date) )) ) AS BIGINT) = (CAST(EXTRACT(MONTH FROM CURRENT_TIMESTAMP()) AS BIGINT) - 2)) AND CASE
      WHEN CAST(EXTRACT(MONTH FROM CURRENT_TIMESTAMP()) AS BIGINT) = 1 THEN (CAST(EXTRACT(MONTH FROM  (TO_DATE((position_effective_date) )) ) AS BIGINT) = 11) AND (CAST(EXTRACT(YEAR FROM  (TO_DATE((position_effective_date) )) ) AS BIGINT) = (CAST(EXTRACT(YEAR FROM CURRENT_TIMESTAMP()) AS BIGINT) - 1))
      WHEN CAST(EXTRACT(MONTH FROM CURRENT_TIMESTAMP()) AS BIGINT) = 2 THEN (CAST(EXTRACT(MONTH FROM  (TO_DATE((position_effective_date) )) ) AS BIGINT) = 12) AND (CAST(EXTRACT(YEAR FROM  (TO_DATE((position_effective_date) )) ) AS BIGINT) = (CAST(EXTRACT(YEAR FROM CURRENT_TIMESTAMP()) AS BIGINT) - 1))
      ELSE CAST(EXTRACT(YEAR FROM  (TO_DATE((position_effective_date) )) ) AS BIGINT) = CAST(EXTRACT(YEAR FROM CURRENT_TIMESTAMP()) AS BIGINT)
      END) THEN (internal_hire_key)  ELSE NULL END) AS internal_hires_2_months_ago,

      --Internal Hires 3 Months Ago
      COUNT(DISTINCT CASE WHEN ((CAST(EXTRACT(MONTH FROM  (TO_DATE((position_effective_date) )) ) AS BIGINT) = (CAST(EXTRACT(MONTH FROM CURRENT_TIMESTAMP()) AS BIGINT) - 3)) AND CASE
      WHEN CAST(EXTRACT(MONTH FROM CURRENT_TIMESTAMP()) AS BIGINT) = 1 THEN (CAST(EXTRACT(MONTH FROM  (TO_DATE((position_effective_date) )) ) AS BIGINT) = 10) AND (CAST(EXTRACT(YEAR FROM  (TO_DATE((position_effective_date) )) ) AS BIGINT) = (CAST(EXTRACT(YEAR FROM CURRENT_TIMESTAMP()) AS BIGINT) - 1))
      WHEN CAST(EXTRACT(MONTH FROM CURRENT_TIMESTAMP()) AS BIGINT) = 2 THEN (CAST(EXTRACT(MONTH FROM  (TO_DATE((position_effective_date) )) ) AS BIGINT) = 11) AND (CAST(EXTRACT(YEAR FROM  (TO_DATE((position_effective_date) )) ) AS BIGINT) = (CAST(EXTRACT(YEAR FROM CURRENT_TIMESTAMP()) AS BIGINT) - 1))
      WHEN CAST(EXTRACT(MONTH FROM CURRENT_TIMESTAMP()) AS BIGINT) = 3 THEN (CAST(EXTRACT(MONTH FROM  (TO_DATE((position_effective_date) )) ) AS BIGINT) = 12) AND (CAST(EXTRACT(YEAR FROM  (TO_DATE((position_effective_date) )) ) AS BIGINT) = (CAST(EXTRACT(YEAR FROM CURRENT_TIMESTAMP()) AS BIGINT) - 1))
      ELSE CAST(EXTRACT(YEAR FROM  (TO_DATE((position_effective_date) )) ) AS BIGINT) = CAST(EXTRACT(YEAR FROM CURRENT_TIMESTAMP()) AS BIGINT)
      END) THEN (internal_hire_key)  ELSE NULL END) AS internal_hires_3_months_ago,

      --Internal Hires YTD
      COUNT(DISTINCT CASE WHEN CAST(EXTRACT(YEAR FROM  (TO_DATE((position_effective_date) )) ) AS BIGINT) = CAST(EXTRACT(YEAR FROM CURRENT_TIMESTAMP()) AS BIGINT) AND CAST(EXTRACT(MONTH FROM  (TO_DATE((position_effective_date) )) ) AS BIGINT) < CAST(EXTRACT(MONTH FROM CURRENT_TIMESTAMP()) AS BIGINT) THEN (internal_hire_key)  ELSE NULL END) AS internal_hires_ytd,

      --Internal Hires Last YTD
      COUNT(DISTINCT CASE WHEN CAST(EXTRACT(YEAR FROM  (TO_DATE((position_effective_date) )) ) AS BIGINT) = (CAST(EXTRACT(YEAR FROM CURRENT_TIMESTAMP()) AS BIGINT)-1) AND CAST(EXTRACT(MONTH FROM  (TO_DATE((position_effective_date) )) ) AS BIGINT) < CAST(EXTRACT(MONTH FROM CURRENT_TIMESTAMP()) AS BIGINT) THEN (internal_hire_key)  ELSE NULL END) AS internal_hires_last_year_ytd,

      --Internal Hires Q1 Current Year
      COUNT(DISTINCT CASE WHEN CAST(EXTRACT(YEAR FROM  (TO_DATE((position_effective_date) )) ) AS BIGINT) = CAST(EXTRACT(YEAR FROM CURRENT_TIMESTAMP()) AS BIGINT) AND CAST(EXTRACT(MONTH FROM  (TO_DATE((position_effective_date) )) ) AS BIGINT) in (1,2,3) THEN (internal_hire_key)  ELSE NULL END) AS internal_hires_q1_current_year,

      --Internal Hires Q1 Last Year
      COUNT(DISTINCT CASE WHEN CAST(EXTRACT(YEAR FROM  (TO_DATE((position_effective_date) )) ) AS BIGINT) = (CAST(EXTRACT(YEAR FROM CURRENT_TIMESTAMP()) AS BIGINT)-1) AND CAST(EXTRACT(MONTH FROM  (TO_DATE((position_effective_date) )) ) AS BIGINT) in (1,2,3) THEN (internal_hire_key)  ELSE NULL END) AS internal_hires_q1_last_year
from all_internals
group by 1) internal_hires on cd.top_focus = internal_hires.top_focus;;
  }


  dimension: top_focus {
    type: string
    sql: ${TABLE}."TOP_FOCUS";;
  }

  dimension: starts_current_month {
    type: number
    sql: ${TABLE}."STARTS_CURRENT_MONTH";;
  }

  dimension: starts_last_month {
    type: number
    sql: ${TABLE}."STARTS_LAST_MONTH";;
  }

  dimension: starts_two_months_ago {
    type: number
    sql: ${TABLE}."STARTS_TWO_MONTHS_AGO";;
  }

  dimension: starts_ytd {
    type: number
    sql: ${TABLE}."STARTS_YTD";;
  }

  dimension: starts_last_year_ytd {
    type: number
    sql: ${TABLE}."STARTS_LAST_YEAR_YTD";;
  }

  dimension: starts_q1_current_year {
    type: number
    sql: ${TABLE}."STARTS_Q1_CURRENT_YEAR" ;;
  }

  dimension: starts_q1_last_year {
    type: number
    sql: ${TABLE}."STARTS_Q1_LAST_YEAR" ;;
  }

  dimension: current_headcount {
    type: number
    sql: ${TABLE}."CURRENT_HEADCOUNT";;
  }

  dimension: headcount_at_the_beginning_of_year {
    type: number
    sql: ${TABLE}."HEADCOUNT_AT_THE_BEGINNING_OF_YEAR";;
  }

  dimension: headcount_2_months_ago {
    type: number
    sql: ${TABLE}."HEADCOUNT_2_MONTHS_AGO";;
  }

  dimension: headcount_one_year_and_one_month_ago {
    type: number
    sql: ${TABLE}."HEADCOUNT_ONE_YEAR_AND_ONE_MONTH_AGO";;
  }

  dimension: headcount_last_month {
    type: number
    sql: ${TABLE}."HEADCOUNT_LAST_MONTH";;
  }

  dimension: headcount_q1_current_year {
    type: number
    sql: ${TABLE}."HEADCOUNT_Q1_CURRENT_YEAR" ;;
  }

  dimension: headcount_q1_last_year {
    type: number
    sql: ${TABLE}."HEADCOUNT_Q1_LAST_YEAR" ;;
  }

  dimension: turnover_current_month {
    type: number
    sql: ${TABLE}."TURNOVER_CURRENT_MONTH";;
  }

  dimension: turnover {
    type: number
    sql: ${TABLE}."TURNOVER";;
  }

  dimension: turnover_ytd {
    type: number
    sql: ${TABLE}."TURNOVER_YTD";;
  }

  dimension: turnover_last_year_ytd {
    type: number
    sql: ${TABLE}."TURNOVER_LAST_YEAR_YTD";;
  }

  dimension: turnover_2_months_ago {
    type: number
    sql: ${TABLE}."TURNOVER_2_MONTHS_AGO";;
  }

  dimension: turnover_q1_current_year {
    type: number
    sql: ${TABLE}."TURNOVER_Q1_CURRENT_YEAR" ;;
  }

  dimension: turnover_q1_last_year {
    type: number
    sql: ${TABLE}."TURNOVER_Q1_LAST_YEAR" ;;
  }

  dimension: offers_extended_current_month {
    type: number
    sql: ${TABLE}."OFFERS_EXTENDED_CURRENT_MONTH";;
  }

  dimension: offers_extended_last_month {
    type: number
    sql: ${TABLE}."OFFERS_EXTENDED_LAST_MONTH";;
  }

  dimension: offers_extended_ytd {
    type: number
    sql: ${TABLE}."OFFERS_EXTENDED_YTD";;
  }

  dimension: offers_extended_last_year_ytd {
    type: number
    sql: ${TABLE}."OFFERS_EXTENDED_LAST_YEAR_YTD";;
  }

  dimension: offers_extended_2_months_ago {
    type: number
    sql: ${TABLE}."OFFERS_EXTENDED_2_MONTHS_AGO";;
  }

  dimension: offers_extended_q1_current_year {
    type: number
    sql: ${TABLE}."OFFERS_EXTENDED_Q1_CURRENT_YEAR" ;;
  }

  dimension: offers_extended_q1_last_year {
    type: number
    sql: ${TABLE}."OFFERS_EXTENDED_Q1_LAST_YEAR" ;;
  }

  dimension: offers_accepted_current_month {
    type: number
    sql: ${TABLE}."OFFERS_ACCEPTED_CURRENT_MONTH";;
  }

  dimension: offers_accepted_last_month {
    type: number
    sql: ${TABLE}."OFFERS_ACCEPTED_LAST_MONTH";;
  }

  dimension: offers_accepted_2_months_ago {
    type: number
    sql: ${TABLE}."OFFERS_ACCEPTED_2_MONTHS_AGO";;
  }

  dimension: offers_accepted_ytd {
    type: number
    sql: ${TABLE}."OFFERS_ACCEPTED_YTD";;
  }

  dimension: offers_accepted_last_year_ytd {
    type: number
    sql: ${TABLE}."OFFERS_ACCEPTED_LAST_YEAR_YTD";;
  }

  dimension: offers_accepted_q1_current_year {
    type: number
    sql: ${TABLE}."OFFERS_ACCEPTED_Q1_CURRENT_YEAR" ;;
  }

  dimension: offers_accepted_q1_last_year {
    type: number
    sql: ${TABLE}."OFFERS_ACCEPTED_Q1_LAST_YEAR" ;;
  }

  dimension: starts_mom_perc_change {
    type: string
    sql: concat(ROUND(${TABLE}."STARTS_MOM_PERC_CHANGE"*100,1),'%') ;;
  }

  dimension: starts_yoy_perc_change {
    type: string
    sql: concat(ROUND(${TABLE}."STARTS_YOY_PERC_CHANGE"*100,1),'%') ;;
  }

  dimension: starts_q1_perc_change {
    type: string
    sql: concat(ROUND(${TABLE}."STARTS_Q1_PERC_CHANGE"*100,1),'%') ;;
  }

  dimension: mom_hc_perc_change {
    type: string
    sql: concat(ROUND(${TABLE}."MOM_HC_PERC_CHANGE"*100,1),'%') ;;
  }

  dimension: hc_q1_perc_change {
    type: string
    sql: concat(ROUND(${TABLE}."HEADCOUNT_Q1_PERC_CHANGE"*100,1),'%') ;;
  }

  dimension: yoy_hc_perc_change {
    type: string
    sql: concat(ROUND(${TABLE}."YOY_HC_PERC_CHANGE"*100,1),'%') ;;
  }

  dimension: turnover_mom_perc_change {
    type: string
    sql: concat(ROUND(${TABLE}."TURNOVER_MOM_PERC_CHANGE"*100,1),'%') ;;
  }

  dimension: turnover_yoy_perc_change {
    type: string
    sql: concat(ROUND(${TABLE}."TURNOVER_YOY_PERC_CHANGE"*100,1),'%') ;;
  }

  dimension: turnover_q1_perc_change {
    type: string
    sql: concat(ROUND(${TABLE}."TURNOVER_Q1_PERC_CHANGE"*100,1),'%') ;;
  }

  dimension: offers_extended_mom_perc_change {
    type: string
    sql: concat(ROUND(${TABLE}."OFFERS_EXTENDED_MOM_PERC_CHANGE"*100,1),'%') ;;
  }

  dimension: offers_extended_yoy_perc_change {
    type: string
    sql: concat(ROUND(${TABLE}."OFFERS_EXTENDED_YOY_PERC_CHANGE"*100,1),'%') ;;
  }

  dimension: offers_extended_q1_perc_change {
    type: string
    sql: concat(ROUND(${TABLE}."OFFERS_EXTENDED_Q1_PERC_CHANGE"*100,1),'%') ;;
  }

  dimension: offers_accepted_mom_perc_change {
    type: string
    sql: concat(ROUND(${TABLE}."OFFERS_ACCEPTED_MOM_PERC_CHANGE"*100,1),'%') ;;
  }

  dimension: offers_accepted_yoy_perc_change {
    type: string
    sql: concat(ROUND(${TABLE}."OFFERS_ACCEPTED_YOY_PERC_CHANGE"*100,1),'%') ;;
  }

  dimension: offers_accepted_q1_perc_change {
    type: string
    sql: concat(ROUND(${TABLE}."OFFERS_ACCEPTED_Q1_PERC_CHANGE"*100,1),'%') ;;
  }

  dimension: net_headcount_mom {
    type: number
    sql: ${TABLE}."NET_HC_MOM";;
  }

  dimension: net_headcount_yoy {
    type: number
    sql: ${TABLE}."NET_HC_YOY";;
  }

  dimension: tam_month_goal {
    type: number
    sql: ${TABLE}."TAM_MONTH_GOAL" ;;
  }

  dimension: tam_year_goal {
    type: number
    sql: ${TABLE}."TAM_EOY_GOAL" ;;
  }

  dimension: tam_q1_goal {
    type: number
    sql: ${TABLE}."TAM_Q1_2025_GOAL" ;;
  }

  dimension: dsm_month_goal {
    type: number
    sql: ${TABLE}."DSM_MONTH_GOAL" ;;
  }

  dimension: dsm_year_goal {
    type: number
    sql: ${TABLE}."DSM_EOY_GOAL" ;;
  }

  dimension: dsm_q1_goal {
    type: number
    sql: ${TABLE}."DSM_Q1_2025_GOAL" ;;
  }

  dimension: gm_month_goal {
    type: number
    sql: ${TABLE}."GM_MONTH_GOAL" ;;
  }

  dimension: gm_year_goal {
    type: number
    sql: ${TABLE}."GM_EOY_GOAL" ;;
  }

  dimension: gm_q1_goal {
    type: number
    sql: ${TABLE}."GM_Q1_2025_GOAL" ;;
  }

  dimension: sm_month_goal {
    type: number
    sql: ${TABLE}."SM_MONTH_GOAL" ;;
  }

  dimension: sm_year_goal {
    type: number
    sql: ${TABLE}."SM_EOY_GOAL" ;;
  }

  dimension: sm_q1_goal {
    type: number
    sql: ${TABLE}."SM_Q1_2025_GOAL" ;;
  }

  dimension: techs_month_goal {
    type: number
    sql: ${TABLE}."TECHS_MONTH_GOAL" ;;
  }

  dimension: techs_year_goal {
    type: number
    sql: ${TABLE}."TECHS_EOY_GOAL" ;;
  }

  dimension: techs_q1_goal {
    type: number
    sql: ${TABLE}."TECHS_Q1_2025_GOAL" ;;
  }

  dimension: cdl_month_goal {
    type: number
    sql: ${TABLE}."CDL_MONTH_GOAL" ;;
  }

  dimension: job_group {
    type: string
    sql: CASE WHEN ${top_focus} IN ('Territory Account Managers', 'District Sales Managers') then 'Sales'
              WHEN ${top_focus} IN ('General Managers', 'Service Managers', 'Techs', 'CDL Delivery Drivers','District Operations Manager') then 'Ops'
        ELSE '' END ;;
  }


  dimension: cdl_year_goal {
    type: number
    sql: ${TABLE}."CDL_EOY_GOAL" ;;
  }

  dimension: cdl_q1_goal {
    type: number
    sql: ${TABLE}."CDL_Q1_2025_GOAL" ;;
  }



}
