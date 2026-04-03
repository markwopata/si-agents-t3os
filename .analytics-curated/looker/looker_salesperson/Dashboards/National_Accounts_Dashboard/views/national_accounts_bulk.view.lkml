view: national_accounts_bulk {
  derived_table: {
    sql:
      with max_update_date as (
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
              dateadd(days,{{ time_frame._parameter_value }},current_date)::timestamp_tz,
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

      , national_accounts as (
          SELECT
            bcp.company_id,
            c.name as company,
            pcr.parent_company_name,
            COALESCE(CASE WHEN position(' ',coalesce(cd.nickname,cd.first_name)) = 0
                           THEN concat(coalesce(cd.nickname,cd.first_name), ' ', cd.last_name)
                           ELSE concat(coalesce(cd.nickname,concat(cd.first_name, ' ',cd.last_name))) END,
                     'Unassigned') as assigned_nam,
            lower(cd.work_email) as nam_email
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

      , on_rent as (
          select rdl.series::date as rental_day
           , r.rental_id
           , r.rental_type_id
           , o.order_id
           , o.MARKET_ID
           , c.company_id
           , c.name as company
           , na.parent_company_name
           , na.assigned_nam
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
          LEFT JOIN national_accounts na ON c.company_id = na.company_id
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
            AND (({{ _user_attributes['job_role'] }} = 'nam' AND na.nam_email = '{{ _user_attributes['email'] }}')
                 -- Hardcode for Jessica to only see Tyler Levin's accounts
                 OR ('{{ _user_attributes['email'] }}' = 'jessica.howard@equipmentshare.com' AND lower(na.nam_email) = 'tyler.levins@equipmentshare.com')
                 OR ('{{ _user_attributes['email'] }}' <> 'jessica.howard@equipmentshare.com' AND {{ _user_attributes['job_role'] }} <> 'nam'))
          /*
          and os.user_id IN (SELECT user_id
                           FROM analytics.commission.employee_commission_info
                           WHERE commission_type_id = 6)
          */
      )

      --, final_query as (
        select rental_day
             --, onr.REGION_NAME
             --, onr.district
             , onr.market_id
             , onr.market_name
             --, onr.MARKET_TYPE
             --, onr.business_segment_name
             , onr.company_id
             , onr.company
             , onr.parent_company_name
             , onr.assigned_nam
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
        LEFT JOIN es_warehouse.public.users u ON onr.salesperson_user_id = u.user_id
        LEFT JOIN analytics.payroll.company_directory cd ON lower(u.email_address) = lower(cd.work_email)
        group by rental_day,
                 --onr.region_name,
                 --onr.district,
                 --onr.market_type,
                 onr.market_id,
                 onr.market_name,
                 --onr.business_segment_name,
                 onr.company_id,
                 onr.company,
                 onr.parent_company_name,
                 onr.assigned_nam,
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
                  -- THEN concat(coalesce(cd.nickname,cd.first_name), ' ', cd.last_name)
                  -- ELSE concat(coalesce(cd.nickname,concat(cd.first_name, ' ',cd.last_name))) END,
                 --onr.sp_email--,
                 --mol.months_open_over_12
          ;;
      # )
      # SELECT *
      # FROM final_query
      # WHERE
      #   (
      #     ('salesperson' = {{ _user_attributes['department'] }} AND SP_EMAIL ILIKE '{{ _user_attributes['email'] }}')
      #     )
      #     OR
      #     (
      #     ('salesperson' != {{ _user_attributes['department'] }}
      #       AND
      #       ('developer' = {{ _user_attributes['department'] }}
      #       OR 'god view' = {{ _user_attributes['department'] }}
      #       OR 'managers' = {{ _user_attributes['department'] }}
      #       OR 'finance' = {{ _user_attributes['department'] }}
      #       OR 'collectors' = {{ _user_attributes['department'] }}
      #       )
      #     )
      #     );;
  }

  dimension_group: rental_date {
    type: time
    sql: ${TABLE}."RENTAL_DAY" ;;
  }

  # dimension: sp_user_id {
  #   type: number
  #   sql: ${TABLE}."SALESPERSON_USER_ID" ;;
  # }

  # dimension: sp_name {
  #   type: string
  #   sql: ${TABLE}."SALESPERSON_FULL_NAME" ;;
  # }

  dimension: company_id {
    type: number
    sql: ${TABLE}."COMPANY_ID" ;;
  }

  dimension: company {
    type: string
    sql: ${TABLE}."COMPANY" ;;
  }

  dimension: parent_company {
    type: string
    sql: ${TABLE}."PARENT_COMPANY_NAME";;
  }

  dimension: assigned_nam {
    type: string
    sql: ${TABLE}."ASSIGNED_NAM";;
  }

  dimension: market_id {
    type: number
    sql: ${TABLE}."MARKET_ID" ;;
  }

  dimension: market_name {
    type: string
    sql: ${TABLE}."MARKET_NAME" ;;
  }

  # dimension: business_segment {
  #   type: string
  #   sql: ${TABLE}."BUSINESS_SEGMENT_NAME" ;;
  # }

  dimension: bulk_parts_on_rent {
    type: number
    sql: ${TABLE}."BULK_PARTS_ON_RENT" ;;
  }

  dimension: bulk_cost_on_rent {
    type: number
    sql: ${TABLE}."BULK_COST_ON_RENT" ;;
  }

  measure: bulk_parts_on_rent_sum {
    type: sum
    sql: ${bulk_parts_on_rent} ;;
  }

  measure: bulk_cost_on_rent_sum {
    type: sum
    sql: ${bulk_cost_on_rent} ;;
  }

  dimension: today_flag {
    type: yesno
    sql: TO_DATE(${rental_date_raw}) = TO_DATE(CONVERT_TIMEZONE('America/Chicago', CURRENT_TIMESTAMP())) ;;
  }

  measure: current_bulk_parts_on_rent {
    group_label: "Bulk"
    label: "Bulk Quantity On Rent"
    type: sum
    sql: ${bulk_parts_on_rent} ;;
    value_format_name: decimal_0
    filters: [today_flag: "Yes"]
  }

  dimension: prior_month_day {
    type: yesno
    sql: TO_DATE(${rental_date_raw}) = TO_DATE(CONVERT_TIMEZONE('America/Chicago', CURRENT_TIMESTAMP()) - INTERVAL '1 MONTH');;
  }

  measure: last_mtd_bulk_parts_on_rent {
    group_label: "Bulk"
    label: "Last MTD Bulk Quantity On Rent"
    type: sum
    sql: ${bulk_parts_on_rent} ;;
    value_format_name: decimal_0
    filters: [prior_month_day: "Yes"]
  }

  measure: bulk_parts_on_rent_change {
    group_label: "Bulk"
    label: "MTD vs Last MTD Bulk Quantity On Rent"
    type: number
    sql: ${current_bulk_parts_on_rent} - ${last_mtd_bulk_parts_on_rent} ;;
    value_format_name: decimal_0
  }

  measure: mtd_bulk_parts_percent_change {
    group_label: "Bulk"
    type: number
    sql: ((${current_bulk_parts_on_rent} - ${last_mtd_bulk_parts_on_rent})/ NULLIFZERO(${last_mtd_bulk_parts_on_rent}))  ;;
    value_format_name: percent_1
  }

  measure: mtd_bulk_parts_day_card {
    group_label: "Bulk Parts Fixed Stats Card"
    label: " " #Making label blank so the name doesn't appear in the visual
    type: number
    sql: ${current_bulk_parts_on_rent} ;;
    html:
    <table border="0" style="font-family: Verdana; font-size: 14px; color: #323232; width: 100%;">
  <tr>
    <td colspan="3" style="font-size: 16px;">MTD VS Last MTD Bulk Quantity On Rent</td>
  </tr>


      {% if bulk_parts_on_rent_change._value >= 0 %}
      <tr style="background-color: #c1ecd4;">
      {% else %}
      <tr style="background-color: #ffcfcf;">
      {% endif %}


      <td colspan="3" style="text-align: left;">
      {% if bulk_parts_on_rent_change._value >= 0 %}
      <font style="color: #00ad73"><h4>◉ Ahead of Last Month</h4></font>
      {% else %}
      <font style="color: #DA344D"><h4>◉ Behind Last Month</h4></font>
      {% endif %}
      </td>
      </tr>
      <tr>
      <td colspan="3"><font style="color: #C0C0C0"><br /></font></td>
      </tr>

      <tr>
      <td>Bulk Quantity On Rent: </td>
      <td>
      {% if bulk_parts_on_rent_change._value >= 0 %}
      <center><font style="color: #00CB86"><strong>↑</strong></font></center>
      {% else %}
      <center><font style="color: #DA344D"><strong>↓</strong></font></center>
      {% endif %}
      </td>
      <td>
      {{ current_bulk_parts_on_rent._rendered_value }}
      {% if bulk_parts_on_rent_change._value == 0 %}
      {% else %}
      {% endif %}
      </td>
      </tr>

      <tr>
      <td>Last MTD Bulk Quantity On Rent: </td>
      <td>

      </td>
      <td>
      {{ last_mtd_bulk_parts_on_rent._rendered_value }}
      </td>
      </tr>


      <tr>
      <td><hr style="border: 1px solid #DCDCDC; margin: 0;"></td>
      <td><hr style="border: 1px solid #DCDCDC; margin: 0;"></td>
      <td><hr style="border: 1px solid #DCDCDC; margin: 0;"></td>
      </tr>

      <tr>
      <td> </td>
      <td>
      {% if bulk_parts_on_rent_change._value >= 0 %}
      <center><font style="color: #00CB86"><strong>↑</strong></font></center>
      {% else %}
      <center><font style="color: #DA344D"><strong>↓</strong></font></center>
      {% endif %}
      </td>
      <td>
      {% if bulk_parts_on_rent_change._value >= 0 %}
      <font style="color: #00CB86; font-weight: bold;">{{ bulk_parts_on_rent_change._rendered_value }} </font><font size="2px;">({{ mtd_bulk_parts_percent_change._rendered_value }})</font>
      {% else %}
      <font style="color: #DA344D; font-weight: bold;">{{ bulk_parts_on_rent_change._rendered_value }} </font><font size="2px;">({{ mtd_bulk_parts_percent_change._rendered_value }})</font>
      {% endif %}
      </td>
      </tr>

      </table> ;;
  }

  measure: current_bulk_cost_on_rent {
    group_label: "Bulk"
    label: "Bulk Cost On Rent"
    type: sum
    sql: ${bulk_cost_on_rent} ;;
    value_format_name: usd_0
    filters: [today_flag: "Yes"]
  }

  measure: last_mtd_bulk_cost_on_rent {
    group_label: "Bulk"
    label: "Last MTD Bulk Cost On Rent"
    type: sum
    sql: ${bulk_cost_on_rent} ;;
    value_format_name: usd_0
    filters: [prior_month_day: "Yes"]
  }

  measure: bulk_cost_on_rent_change {
    group_label: "Bulk"
    label: "MTD vs Last MTD Bulk Cost On Rent"
    type: number
    sql: ${current_bulk_cost_on_rent} - ${last_mtd_bulk_cost_on_rent} ;;
    value_format_name: usd_0
  }

  measure: mtd_bulk_cost_percent_change {
    group_label: "Bulk"
    type: number
    sql: ((${current_bulk_cost_on_rent} - ${last_mtd_bulk_cost_on_rent})/ NULLIFZERO(${last_mtd_bulk_cost_on_rent}))  ;;
    value_format_name: percent_1
  }

  measure: mtd_bulk_cost_day_card {
    group_label: "Bulk Cost Fixed Stats Card"
    label: " " #Making label blank so the name doesn't appear in the visual
    type: number
    sql: ${current_bulk_cost_on_rent} ;;
    html:
    <table border="0" style="font-family: Verdana; font-size: 14px; color: #323232; width: 100%;">
  <tr>
    <td colspan="3" style="font-size: 16px;">MTD VS Last MTD Bulk Cost On Rent</td>
  </tr>


      {% if bulk_cost_on_rent_change._value >= 0 %}
      <tr style="background-color: #c1ecd4;">
      {% else %}
      <tr style="background-color: #ffcfcf;">
      {% endif %}


      <td colspan="3" style="text-align: left;">
      {% if bulk_cost_on_rent_change._value >= 0 %}
      <font style="color: #00ad73"><h4>◉ Ahead of Last Month</h4></font>
      {% else %}
      <font style="color: #DA344D"><h4>◉ Behind Last Month</h4></font>
      {% endif %}
      </td>
      </tr>
      <tr>
      <td colspan="3"><font style="color: #C0C0C0"><br /></font></td>
      </tr>

      <tr>
      <td>Bulk Cost On Rent: </td>
      <td>
      {% if bulk_cost_on_rent_change._value >= 0 %}
      <center><font style="color: #00CB86"><strong>↑</strong></font></center>
      {% else %}
      <center><font style="color: #DA344D"><strong>↓</strong></font></center>
      {% endif %}
      </td>
      <td>
      {{ current_bulk_cost_on_rent._rendered_value }}</a>
      {% if bulk_cost_on_rent_change._value == 0 %}
      {% else %}

      {% endif %}
      </td>
      </tr>

      <tr>
      <td>Last MTD Bulk Cost On Rent: </td>
      <td>

      </td>
      <td>
      {{ last_mtd_bulk_cost_on_rent._rendered_value }}
      </td>
      </tr>


      <tr>
      <td><hr style="border: 1px solid #DCDCDC; margin: 0;"></td>
      <td><hr style="border: 1px solid #DCDCDC; margin: 0;"></td>
      <td><hr style="border: 1px solid #DCDCDC; margin: 0;"></td>
      </tr>

      <tr>
      <td> </td>
      <td>
      {% if bulk_cost_on_rent_change._value >= 0 %}
      <center><font style="color: #00CB86"><strong>↑</strong></font></center>
      {% else %}
      <center><font style="color: #DA344D"><strong>↓</strong></font></center>
      {% endif %}
      </td>
      <td>
      {% if bulk_cost_on_rent_change._value >= 0 %}
      <font style="color: #00CB86; font-weight: bold;">{{ bulk_cost_on_rent_change._rendered_value }} </font><font size="2px;">({{ mtd_bulk_parts_percent_change._rendered_value }})</font>
      {% else %}
      <font style="color: #DA344D; font-weight: bold;">{{ bulk_cost_on_rent_change._rendered_value }} </font><font size="2px;">({{ mtd_bulk_parts_percent_change._rendered_value }})</font>
      {% endif %}
      </td>
      </tr>

      </table> ;;
  }

  measure: current_bulk_parts_on_rent_with_null_days {
    group_label: "Bulk With Past Days Null"
    label: "Bulk Quantity On Rent"
    type: number
    sql: case when ${current_bulk_parts_on_rent} = 0 then null else ${current_bulk_parts_on_rent} end ;;
    value_format_name: decimal_0
  }

  measure: current_bulk_cost_on_rent_with_null_days {
    group_label: "Bulk With Past Days Null"
    label: "Bulk Cost On Rent"
    type: number
    sql: case when ${current_bulk_cost_on_rent} = 0 then null else ${current_bulk_cost_on_rent} end ;;
    value_format_name: usd_0
  }

  parameter: time_frame {
    type: string
    default_value: "-90"
    allowed_value: {
      label: "Past 90 Days"
      value: "-90"
    }
    allowed_value: {
      label: "Past 180 Days"
      value: "-180"
    }
    allowed_value: {
      label: "Past Year"
      value: "-365"
    }
    allowed_value: {
      label: "Past Two Years"
      value: "-730"
    }
  }
}
