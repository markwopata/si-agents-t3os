view: generator_and_fuel_cell_rentals {
  derived_table: {
    sql:

        WITH date_series AS (
                    SELECT
                      dateadd(day, '-' || row_number() over (ORDER BY  null), dateadd(day, '+1', CONVERT_TIMEZONE('UTC', 'America/Chicago', CURRENT_TIMESTAMP())::DATE)) AS date
                    FROM table (generator(rowcount => (365*1)))
                    ),

        fuel_charges as (
            SELECT
                TRY_CAST(COALESCE(r.order_id,
                    ROUND(CASE -- Case with two hyphens (e.g., 'RIC21-3609008-0005')
                         WHEN LEN(li.INVOICE_NO) - LEN(REPLACE(li.INVOICE_NO, '-', '')) = 2 THEN
                    SUBSTRING(li.INVOICE_NO,
                              CHARINDEX('-', li.INVOICE_NO) + 1,
                              CHARINDEX('-', li.INVOICE_NO, CHARINDEX('-', li.INVOICE_NO) + 1) - CHARINDEX('-', li.INVOICE_NO) - 1)
                WHEN LEN(li.INVOICE_NO) - LEN(REPLACE(li.INVOICE_NO, '-', '')) = 1 THEN -- Case with one hyphen (e.g., '3604065-014')
                    LEFT(li.INVOICE_NO, CHARINDEX('-', li.INVOICE_NO) - 1)
            END,0)) as INT) as order_id,
                i.BILLING_APPROVED_DATE::DATE as BILLING_APPROVED_DATE,
                SUM(li.AMOUNT) as fuel_charges
        FROM ANALYTICS.PUBLIC.V_LINE_ITEMS AS li
            LEFT JOIN ES_WAREHOUSE.PUBLIC.INVOICES as i on i.INVOICE_ID = LI.INVOICE_ID
            left join ES_WAREHOUSE.PUBLIC.RENTALS r on li.RENTAL_ID = r.RENTAL_ID
            WHERE li.LINE_ITEM_TYPE_ID in ('129', '130', '131', '132', '138', '142')--(INVOICE_DISPLAY_NAME like '%Gas%' or INVOICE_DISPLAY_NAME like '%Propane%' or INVOICE_DISPLAY_NAME like '%Diesel%')
            --AND i.BILLING_APPROVED_DATE::DATE >= '2024-04-19'
            AND i.BILLING_APPROVED_DATE::DATE <= current_date()
            and BILLING_APPROVED = 'true'
            group by 1,2
            HAVING SUM(AMOUNT) > 0
            ),


        market_company_oec_by_date AS (
                  SELECT
                      ds.date
                    , o.market_id
                    , m.market_name
                    , m.district
                    , m.region
                    , r.RENTAL_ID
                    , r.ORDER_ID
                    , r.EQUIPMENT_CLASS_ID
                    , r.START_DATE
                    , r.END_DATE
                    , CASE
                    WHEN r.EQUIPMENT_CLASS_ID in ('1442','1597','1670','2277','2278','2279','2280','2281','6360','7439','7867','13634','14427','21918','23499','25487','27292','28414') THEN '>=500kw Generator'
                    WHEN r.EQUIPMENT_CLASS_ID in ('1935','7507','7510','8830','8969','9391','9840','12139','12141','12142','12143','13477','13484','14062','21490','30745','4917','1937','1936') THEN '>=500 Gallon Fuel Tank'
                    ELSE 'Other'
                    END AS equipment_size
                    , CASE WHEN fc.BILLING_APPROVED_DATE is not null then r.ORDER_ID else null end as onsite_fueling
        --             , 1 as one_flag
                     FROM date_series ds
                     LEFT JOIN es_warehouse.public.rentals r on r.START_DATE <= ds.date and COALESCE(r.END_DATE, (current_date())) >= ds.date
                     LEFT JOIN es_warehouse.public.orders o ON r.order_id = o.order_id
                     left join fuel_charges fc on fc.order_id = r.order_id and ds.date = fc.BILLING_APPROVED_DATE
                    left join ANALYTICS.PUBLIC.MARKET_REGION_XWALK m on m. market_id = o.market_id
                    WHERE r.EQUIPMENT_CLASS_ID in ('1442','1597','1670','1935','2277','2278','2279','2280','2281','6360','7439','7507','7510','7867','8830','8969','9391','9840','12139','12141','12142','12143','13477','13484','13634','14062','14427','21490','21918','23499','25487','27292','28414','30745','4917','1937','1936')
                    --and date >= '2024-04-19'
                    and date <= current_date()
        --             and r.order_id = 3618929
                    ORDER BY 1,4)

        SELECT * FROM market_company_oec_by_date
            ;;
  }

  dimension: timeframe {
    type: string
    sql: ${TABLE}.timeframe ;;
  }

  dimension: market_name {
    type: string
    sql: ${TABLE}.market_name ;;
  }

  dimension: district {
    type: string
    sql: ${TABLE}.district ;;
  }

  dimension: region_name {
    type: string
    sql: ${TABLE}.region_name ;;
  }

  dimension_group: date {
    type: time
    timeframes: [
      date,
      week,
      month
    ]
    sql: ${TABLE}.date ;;
  }

  dimension: equipment_size {
    type: string
    sql: ${TABLE}.equipment_size ;;
  }

  dimension: onsite_fueling_count {
    type: number
    sql: ${TABLE}.onsite_fueling_count ;;
  }

  measure: rental_count_sum {
    type: number
    sql: COUNT(DISTINCT ${TABLE}.order_id) ;;
  }

  measure: onsite_fueling_count_sum {
    type: number
    sql: COUNT(DISTINCT ${TABLE}.onsite_fueling) ;;
  }

  parameter: date_granularity {
    type: string
    default_value: "Weekly"
    allowed_value: {
      label: "Weekly"
      value: "Weekly"
    }
    allowed_value: {
      label: "Monthly"
      value: "Monthly"
    }
    allowed_value: {
      label: "Quarterly"
      value: "Quarterly"
    }
    allowed_value: {
      label: "Yearly"
      value: "Yearly"
    }
  }

  dimension: date_granularity_selection {
    type: string
    sql:
    CASE
      WHEN {% parameter date_granularity %} = 'Weekly' THEN TO_CHAR(DATE_TRUNC('WEEK', ${TABLE}.date), 'YYYY-MM-DD')
      WHEN {% parameter date_granularity %} = 'Monthly' THEN TO_CHAR(DATE_TRUNC('MONTH', ${TABLE}.date), 'YYYY-MM')
      -- WHEN {% parameter time_grain_toggle %} = 'Quarter' THEN TO_CHAR(DATE_TRUNC('QUARTER', ${TABLE}.billing_approved_date), 'YYYY "Q"Q')
      WHEN {% parameter date_granularity %} = 'Quarterly' THEN
  TO_CHAR(DATE_TRUNC('QUARTER', ${TABLE}.date), 'YYYY') || '-Q' || EXTRACT(QUARTER FROM ${TABLE}.date)
      WHEN {% parameter date_granularity %} = 'Yearly' THEN TO_CHAR(DATE_TRUNC('YEAR', ${TABLE}.date), 'YYYY')
    END ;;
  }

}
