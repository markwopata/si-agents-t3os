SELECT  
    DT_KEY AS DATE_KEY
    , DT_DATE AS DATE
    , DT_YEAR AS YEAR
    , DT_MONTH AS MONTH
    , DT_MONTH_NAME AS MONTH_NAME
    , DT_PERIOD AS PERIOD
    , DT_PRIOR_PERIOD AS PRIOR_PERIOD
    , DT_NEXT_PERIOD AS NEXT_PERIOD
    , DT_YEAR_MONTH AS YEAR_MONTH
    , DT_DAY AS DAY
    , DT_DAY_OF_WEEK AS DAY_OF_WEEK
    , DT_WEEK_OF_YEAR AS WEEK_OF_YEAR
    , DT_DAY_OF_YEAR AS DAY_OF_YEAR
    , DT_WEEKDAY AS is_weekday
    , DT_LAST_7_DAYS AS is_last_7_days
    , DT_LAST_28_DAYS AS is_last_28_days
    , DT_LAST_30_DAYS AS is_last_30_days
    
    , dt_last_31_days as is_last_31_days

    , DT_LAST_60_DAYS AS is_last_60_days
    , DT_LAST_90_DAYS AS is_last_90_days
    , DT_LAST_120_DAYS AS is_last_120_days
    , DT_LAST_180_DAYS AS is_last_180_days
    , DT_YEAR_TO_DATE AS is_year_to_date
    , DT_QUARTER_TO_DATE AS is_quarter_to_date
    , DT_MONTH_TO_DATE AS is_month_to_date
    , DT_PRIOR_YEAR_TO_DATE AS is_prior_year_to_date
    , DT_PRIOR_MONTH_TO_DATE AS is_prior_month_to_date
    , DT_PRIOR_MONTH AS is_prior_month
    , DT_CURRENT_MONTH AS is_current_month
    , DT_PRIOR_QUARTER AS is_prior_quarter
    
    , dt_first_day_of_month as is_first_day_of_month
    , dt_last_day_of_month as is_last_day_of_month
    , dt_trailing_12_months as is_trailing_12_months
    , dt_current_date as is_current_date

    , _created_recordtimestamp
    , _updated_recordtimestamp

FROM    {{ ref('dim_dates_bi') }}