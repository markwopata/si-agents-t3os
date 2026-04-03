view: ifta_state_summary {
  derived_table: {
    sql:
    WITH ASSET_GROUPS AS (
    SELECT distinct a.asset_id
  --    LISTAGG(distinct concat(coalesce(o.name, 'Ungrouped Assets')), ', ') as groups
    from assets A JOIN ASSET_SETTINGS AA ON A.ASSET_SETTINGS_ID = AA.ASSET_SETTINGS_ID
      LEFT JOIN ORGANIZATION_ASSET_XREF OA ON A.ASSET_ID = OA.ASSET_ID
      LEFT JOIN ORGANIZATIONS O ON OA.ORGANIZATION_ID = O.ORGANIZATION_ID
      left join company_dot_numbers d on a.dot_number_id = d.dot_number_id
        join table(assetlist({{ _user_attributes['user_id'] }}::numeric)) L on L.asset_id = a.asset_id
    WHERE a.asset_type_id = 2
      AND aa.ifta_reporting = true
      -- This is a templated filter using liquid to pass a dashboard filter to a derived view (multi-select)
      AND {% condition dot_number_filter %} d.dot_number {% endcondition %}
      AND {% condition groups_filter %} o.name {% endcondition %}
      AND {% condition asset_filter %} a.custom_name {% endcondition %}
    GROUP BY a.ASSET_ID
    ), FUEL_DATA as (
    select f.state_id,st.name as state,
        sum(f.gallons_purchased) as state_gallons_purchased,
        sum(f.purchase_price) as state_fuel_purchases
    from FUEL_PURCHASES F
      join asset_groups ag on ag.asset_id = f.asset_id
      left join states st on st.state_id = f.state_id
    where f.purchase_date >= CONVERT_TIMEZONE('{{ _user_attributes['user_timezone'] }}', 'UTC', {% date_start date_filter %})
        and f.purchase_date < CONVERT_TIMEZONE('{{ _user_attributes['user_timezone'] }}', 'UTC', {% date_end date_filter %})
    group by f.state_id, st.name
    )
    , TOTAL_STATE_MILES AS (
    SELECT M.STATE,
      SUM(M.MILES_DRIVEN)::decimal(15,2) AS TOTAL_STATE_MILES_DRIVEN
    FROM (
    SELECT AG.ASSET_ID,
        F."NAME" AS STATE,
        F.MILES_DRIVEN
    FROM ASSET_GROUPS AG
    JOIN TABLE(sharing.f_ifta_detail ({{ _user_attributes['user_id'] }}::numeric ,
    '{{ _user_attributes['user_timezone'] }}',
    convert_timezone('{{ _user_attributes['user_timezone'] }}', 'UTC', {% date_start date_filter %}::timestamp_ntz)::timestamptz,
    convert_timezone('{{ _user_attributes['user_timezone'] }}', 'UTC', {% date_end date_filter %}::timestamp_ntz)::timestamptz)) F ON AG.ASSET_ID = F.ASSET_ID
    ) M
    GROUP BY M.STATE
    )
    SELECT DISTINCT
        SM.STATE,
        SM.TOTAL_STATE_MILES_DRIVEN,
        TM.TOTAL_MILES_DRIVEN,
        TG.TOTAL_GALLONS_PURCHASED,
        ROUND(COALESCE(FD.STATE_GALLONS_PURCHASED,0),1) AS STATE_GALLONS_PURCHASED,
        COALESCE(FD.STATE_FUEL_PURCHASES,0) AS STATE_FUEL_COST,
        ROUND(COALESCE((SM.TOTAL_STATE_MILES_DRIVEN / (TM.TOTAL_MILES_DRIVEN / TG.TOTAL_GALLONS_PURCHASED)),0),1) AS GALLONS_USED
    FROM TOTAL_STATE_MILES SM
        LEFT JOIN FUEL_DATA FD ON FD.STATE = SM.STATE
        CROSS JOIN (SELECT SUM(TOTAL_STATE_MILES_DRIVEN) AS TOTAL_MILES_DRIVEN FROM TOTAL_STATE_MILES) TM
        CROSS JOIN (SELECT SUM(STATE_GALLONS_PURCHASED) AS TOTAL_GALLONS_PURCHASED FROM FUEL_DATA) TG
    ORDER BY SM.STATE
    ;;
    }

    dimension: primary_key {
      primary_key: yes
      type: string
      sql: ${state} ;;
    }

    dimension: state {
      type: string
      sql: ${TABLE}."STATE" ;;
    }

    dimension: total_state_miles_driven {
      type: number
      sql: ${TABLE}."TOTAL_STATE_MILES_DRIVEN" ;;
    }

    dimension: total_miles_driven {
      type: number
      sql: ${TABLE}."TOTAL_MILES_DRIVEN" ;;
    }

    dimension: total_gallons_purchased {
      type: number
      sql: ${TABLE}."TOTAL_GALLONS_PURCHASED" ;;
    }

    dimension: gallons_purchased {
      type: number
      sql: ${TABLE}."STATE_GALLONS_PURCHASED" ;;
    }

    dimension: fuel_cost {
      type: number
      sql: ${TABLE}."STATE_FUEL_COST" ;;
    }

    dimension: gallons_used {
      type: number
      sql: ${TABLE}."GALLONS_USED" ;;
    }

  filter: date_filter {
    type: date_time
  }

  filter: groups_filter {
    type: string
  }

  filter: dot_number_filter {
    type: string
  }

  filter: asset_filter {
    type: string
    suggest_explore: ifta_mileage
    suggest_dimension: ifta_mileage.asset
  }


    }
