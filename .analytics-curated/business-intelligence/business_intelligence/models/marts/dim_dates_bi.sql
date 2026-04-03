{{ config(
    materialized='table',
    unique_key=['dt_key']
) }} 

SELECT 
    dt_key
    , dt_date
    , dt_year
    , dt_month
    , dt_month_name 
    , dt_period
    , dt_prior_period
    , dt_next_period
    , dt_year_month
    , dt_day
    , dt_day_of_week 
    , dt_week_of_year 
    , dt_day_of_year 
    , dt_weekday 
    , CASE
        WHEN dt_date >= DATEADD(DAY, -7, CURRENT_DATE)
            AND dt_date <= CURRENT_DATE 
        THEN TRUE
        ELSE FALSE
    END AS dt_last_7_days
    , CASE
        WHEN dt_date >= DATEADD(DAY, -28, CURRENT_DATE)
            AND dt_date <= CURRENT_DATE 
        THEN TRUE
        ELSE FALSE
    END AS dt_last_28_days
    , dt_last_30_days 
    , CASE
        WHEN dt_date >= DATEADD(DAY, -31, CURRENT_DATE)
            AND dt_date <= CURRENT_DATE 
        THEN TRUE
        ELSE FALSE
    END AS dt_last_31_days
    , dt_last_60_days 
    , dt_last_90_days 
    , dt_last_120_days 
    , dt_last_180_days 
    , dt_year_to_date
    , dt_quarter_to_date
    , dt_month_to_date 
    , dt_prior_year_to_date 
    , dt_prior_month_to_date 
    , dt_prior_month
    , dt_current_month 
    , dt_prior_quarter

    , CASE 
        WHEN dt_date = DATE_TRUNC('month', dt_date) THEN TRUE 
        ELSE FALSE 
    END AS dt_first_day_of_month
    , CASE 
        WHEN dt_date = (DATE_TRUNC('month', dt_date) + INTERVAL '1 month' - INTERVAL '1 day') THEN TRUE 
        ELSE FALSE 
    END AS dt_last_day_of_month
    , CASE 
        WHEN dt_date >= CURRENT_DATE - INTERVAL '12 months' THEN TRUE 
        ELSE FALSE 
    END AS dt_trailing_12_months
    , CASE WHEN dt_date = CURRENT_DATE THEN TRUE
        ELSE FALSE 
    END AS dt_current_date

    , {{ get_current_timestamp() }} AS _created_recordtimestamp
    , {{ get_current_timestamp() }} AS _updated_recordtimestamp 

FROM {{ ref('platform', 'dim_dates') }}