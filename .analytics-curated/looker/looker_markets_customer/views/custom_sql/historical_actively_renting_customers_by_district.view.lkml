view: historical_actively_renting_customers_by_district {

    derived_table: {
      sql: -- District Counts
                 WITH combo AS (
                    select *
                    FROM analytics.bi_ops.historical_arc where market_name IS NOT NULL
                    UNION
                    SELECT *
                    FROM analytics.bi_ops.current_arc where market_name IS NOT NULL)

        , date_series AS (
        SELECT DATEADD(day, '-' || ROW_NUMBER() OVER (ORDER BY NULL), DATEADD(day, '+1', CONVERT_TIMEZONE('UTC', 'America/Chicago', CURRENT_TIMESTAMP())::DATE)) AS date
        FROM TABLE (GENERATOR(rowcount => (365 * 4))) QUALIFY date >= '2022-01-01' AND date < CONVERT_TIMEZONE('UTC', 'America/Chicago', CURRENT_DATE())
        )

        , each_district AS (
        SELECT  district, region, region_name,  MIN(date) as first_date
        FROM combo
        GROUP BY district, region, region_name
        )

        , empty_days AS (
        select *, 0 as arc
        FROM date_series ds
        JOIN each_district ed ON ed.first_date <= ds.date
        --ORDER BY district, date ASC
        )



        , daily_arc AS (
        SELECT date,district, region, region_name, COUNT(DISTINCT company_id) as actively_renting_customers
        FROM combo
        GROUP BY date, district, region, region_name
        )

        -- , daily_and_empty AS (
        SELECT COALESCE(da.date, em.date) as date,
        COALESCE(da.district, em.district) as district,
        COALESCE(da.region, em.region) as region,
        COALESCE(da.region_name, em.region_name) as region_name,
        first_date,
        COALESCE(actively_renting_customers, arc) as actively_renting_customers
        FROM daily_arc da
        FULL OUTER JOIN empty_days em ON em.date = da.date AND em.district = da.district AND em.region = da.region AND em.region_name = da.region_name


        ;;
    }

    measure: count {
      type: count
      drill_fields: [detail*]
    }

    dimension_group: date {
      type: time
      sql: ${TABLE}."DATE" ;;
    }

    dimension: district {
      type: string
      sql: ${TABLE}."DISTRICT" ;;
    }


  dimension: region {
    type: string
    sql: ${TABLE}."REGION" ;;
  }

  dimension: region_name {
    type: string
    sql: ${TABLE}."REGION_NAME" ;;
  }

    dimension: total_actively_renting_customers {
      type: number
      sql: ${TABLE}."ACTIVELY_RENTING_CUSTOMERS" ;;
    }

    measure: total_arc_sum {
      type: sum
      sql: ${total_actively_renting_customers} ;;
    }

    measure: avg_actively_renting_customers {
      type: number
      sql:  SUM(${total_actively_renting_customers})/COUNT(DISTINCT ${date_date}) ;;
      value_format_name: decimal_1
    }


    measure: max_actively_renting_customers {
      type: max
      sql:  ${total_actively_renting_customers};;

    }


    measure: median_actively_renting_customers {
      type: median
      sql:  ${total_actively_renting_customers} ;;

    }


    set: detail {
      fields: [
        date_date,
      district,
        total_actively_renting_customers
      ]
    }
  }
