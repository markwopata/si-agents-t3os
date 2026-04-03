view: national_accounts_oec_aor {
  derived_table: {
    sql:
        WITH date_series AS (
          SELECT
              DATEADD(
                  day,
                  '-' || ROW_NUMBER() OVER (ORDER BY NULL),
                  DATEADD(day, '+1', CONVERT_TIMEZONE('UTC', 'America/Chicago', CURRENT_TIMESTAMP())::DATE)
              ) AS date
          FROM TABLE (GENERATOR(rowcount => (365 * 2)))
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

        --, final_query as (
          SELECT ds.date
              , o.market_id
              --, mrx.market_name
              , c.company_id
              , c.name as company
              , na.parent_company_name
              , na.assigned_nam
              --, COALESCE(bs.name, 'No Class Listed') AS business_segment_name
              --, COALESCE(os.user_id, o.salesperson_user_id) AS salesperson_user_id
              --, CASE WHEN position(' ',coalesce(cd.nickname,cd.first_name)) = 0
              --     THEN concat(coalesce(cd.nickname,cd.first_name), ' ', cd.last_name)
              --     ELSE concat(coalesce(cd.nickname,concat(cd.first_name, ' ',cd.last_name))) END as salesperson_full_name
              --, spu.email_address as sp_email
              , COUNT(DISTINCT  ea.asset_id) AS assets_on_rent
              , SUM(CASE WHEN  r.rental_status_id in (9,5,3,7,4,6) THEN COALESCE(aa.oec, 0) ELSE 0 end) AS OEC_on_rent
          FROM date_series ds
          LEFT JOIN es_warehouse.public.equipment_assignments ea ON ea.start_date <= ds.date
                                                              and COALESCE(ea.end_date, (CONVERT_TIMEZONE('UTC', 'America/Chicago', CURRENT_TIMESTAMP())::DATE)) >= ds.date
          LEFT JOIN es_warehouse.public.rentals r ON r.rental_id = ea.rental_id
          LEFT JOIN es_warehouse.public.orders o ON r.order_id = o.order_id
          --LEFT JOIN analytics.public.market_region_xwalk mrx on mrx.market_id = o.market_id
          LEFT JOIN es_warehouse.public.users u ON u.user_id = o.user_id
          LEFT JOIN es_warehouse.public.companies c ON c.company_id = u.company_id
          LEFT JOIN national_accounts na ON c.company_id = na.company_id
          LEFT JOIN es_warehouse.public.assets_aggregate aa ON aa.asset_id = ea.asset_id
          --LEFT JOIN es_warehouse.public.order_salespersons os ON os.order_id = o.order_id
          --left join ES_WAREHOUSE.PUBLIC.USERS spu on COALESCE(os.user_id, o.salesperson_user_id) = spu.USER_ID
          --LEFT JOIN analytics.payroll.company_directory cd ON lower(spu.email_address) = lower(cd.work_email)
          --LEFT JOIN es_warehouse.public.assets a on a.asset_id = r.asset_id
          --LEFT JOIN es_warehouse.public.equipment_classes ec ON ec.equipment_class_id = a.equipment_class_id
          --LEFT JOIN ES_WAREHOUSE.PUBLIC.BUSINESS_SEGMENTS bs ON bs.business_segment_id = ec.business_segment_id
          WHERE c.company_id not in (1854,1855,8151,155) AND r.deleted = false AND o.deleted = false
          /*
            AND COALESCE(os.user_id, o.salesperson_user_id) IN (SELECT user_id
                                                                FROM analytics.commission.employee_commission_info
                                                                WHERE commission_type_id = 6)
          */
            AND c.company_id IN (SELECT company_id
                                 FROM es_warehouse.public.billing_company_preferences
                                 WHERE PREFS:national_account = TRUE)
            AND TO_DATE(ds.date) >= TO_DATE(DATEADD(day, {{ time_frame._parameter_value }}, CONVERT_TIMEZONE('UTC', 'America/Chicago', CURRENT_TIMESTAMP())))
            AND (({{ _user_attributes['job_role'] }} = 'nam' AND na.nam_email = '{{ _user_attributes['email'] }}')
                 -- Hardcode for Jessica to only see Tyler Levin's accounts
                 OR ('{{ _user_attributes['email'] }}' = 'jessica.howard@equipmentshare.com' AND lower(na.nam_email) = 'tyler.levins@equipmentshare.com')
                 OR ('{{ _user_attributes['email'] }}' <> 'jessica.howard@equipmentshare.com' AND {{ _user_attributes['job_role'] }} <> 'nam'))
          GROUP BY
            ds.date,
            o.market_id,
            --mrx.market_name,
            c.company_id,
            c.name,
            na.parent_company_name,
            na.assigned_nam--,
            --COALESCE(bs.name, 'No Class Listed'),
            --COALESCE(os.user_id, o.salesperson_user_id),
            --salesperson_full_name,
            --spu.email_address
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

  dimension_group: date {
    type: time
    sql: ${TABLE}."DATE" ;;
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
    sql: ${TABLE}."ASSIGNED_NAM" ;;
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

  dimension: assets_on_rent {
    type: number
    sql: ${TABLE}."ASSETS_ON_RENT" ;;
  }

  dimension: oec_on_rent {
    label: "OEC on Rent"
    type: number
    sql: ${TABLE}."OEC_ON_RENT" ;;
  }

  measure: assets_on_rent_sum {
    type: sum
    sql: ${assets_on_rent} ;;
  }

  measure: oec_on_rent_sum {
    type: sum
    sql: ${oec_on_rent} ;;
    value_format_name: usd_0
  }

  dimension: today_flag {
    type: yesno
    sql: TO_DATE(${date_raw}) = TO_DATE(CONVERT_TIMEZONE('America/Chicago', CURRENT_TIMESTAMP())) ;;
  }

  measure: oec_on_rent_today {
    group_label: "OEC"
    label: "OEC Today"
    type: sum
    sql: ${oec_on_rent} ;;
    value_format_name: usd_0
    filters: [today_flag: "yes"]
  }

  measure: oec_on_rent_today_with_null_days {
    group_label: "OEC With Past Days Null"
    label: "OEC On Rent"
    type: number
    sql: case when ${oec_on_rent_today} = 0 then null else ${oec_on_rent_today} end ;;
    value_format_name: usd_0
  }

  dimension: prior_month_day {
    type: yesno
    sql: TO_DATE(${date_raw}) = TO_DATE(CONVERT_TIMEZONE('America/Chicago', CURRENT_TIMESTAMP()) - INTERVAL '1 MONTH');;
  }

  measure: last_mtd_oec_on_rent {
    group_label: "OEC"
    label: "Last MTD OEC On Rent"
    type: sum
    sql: ${oec_on_rent} ;;
    value_format_name: usd_0
    filters: [prior_month_day: "Yes"]
  }

  measure: oec_on_rent_change {
    group_label: "OEC"
    label: "Today vs Last MTD OEC On Rent"
    type: number
    sql: ${oec_on_rent_today} - ${last_mtd_oec_on_rent} ;;
    value_format_name: usd_0
  }

  measure: mtd_oec_percent_change {
    group_label: "OEC"
    type: number
    sql: ((${oec_on_rent_today} - ${last_mtd_oec_on_rent})/ NULLIFZERO(${last_mtd_oec_on_rent}))  ;;
    value_format_name: percent_1
  }

  measure: mtd_oec_day_card {
    group_label: "Fixed Stats Card"
    label: " " #Making label blank so the name doesn't appear in the visual
    type: number
    sql: ${oec_on_rent_today} ;;
    html:
    <table border="0" style="font-family: Verdana; font-size: 14px; color: #323232; width: 100%;">
  <tr>
    <td colspan="3" style="font-size: 16px;">MTD VS Last MTD OEC On Rent</td>
  </tr>


      {% if oec_on_rent_change._value >= 0 %}
      <tr style="background-color: #c1ecd4;">
      {% else %}
      <tr style="background-color: #ffcfcf;">
      {% endif %}


      <td colspan="3" style="text-align: left;">
      {% if oec_on_rent_change._value >= 0 %}
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
      <td>OEC On Rent: </td>
      <td>
      {% if oec_on_rent_change._value >= 0 %}
      <center><font style="color: #00CB86"><strong>↑</strong></font></center>
      {% else %}
      <center><font style="color: #DA344D"><strong>↓</strong></font></center>
      {% endif %}
      </td>
      <td>
      <!-- <a href="https://equipmentshare.looker.com/dashboards/1405?Market+Name={{ oec_on_rent_today._filterable_value | url_encode }}&Order+ID=&Asset+ID=" target="_blank"> --> {{ oec_on_rent_today._rendered_value }} <!-- </a> -->
      {% if oec_on_rent_change._value == 0 %}
      {% else %}
      <!-- <a href="https://equipmentshare.looker.com/dashboards/1405?Market+Name={{ oec_on_rent_today._filterable_value | url_encode }}&Order+ID=&Asset+ID=" target="_blank"></a> -->
      {% endif %}
      </td>
      </tr>

      <tr>
      <td>Last MTD OEC On Rent: </td>
      <td>

      </td>
      <td>
      <!-- <a href="https://equipmentshare.looker.com/dashboards/202?Market+Name={{ last_mtd_oec_on_rent._filterable_value | url_encode }}&Order+ID=&Asset+ID=" target="_blank"> --> {{ last_mtd_oec_on_rent._rendered_value }} <!-- </a> -->
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
      {% if oec_on_rent_change._value >= 0 %}
      <center><font style="color: #00CB86"><strong>↑</strong></font></center>
      {% else %}
      <center><font style="color: #DA344D"><strong>↓</strong></font></center>
      {% endif %}
      </td>
      <td>
      {% if oec_on_rent_change._value >= 0 %}
      <!-- <a href="https://equipmentshare.looker.com/dashboards/202?Market+Name={{ oec_on_rent_change._filterable_value | url_encode }}&Order+ID=&Asset+ID=" target="_blank"> --> <font style="color: #00CB86; font-weight: bold;"> {{ oec_on_rent_change._rendered_value }} </font><font size="2px;">({{ mtd_oec_percent_change._rendered_value }})</font> <!-- </a> -->
      {% else %}
      <!-- <a href="https://equipmentshare.looker.com/dashboards/202?Market+Name={{ oec_on_rent_change._filterable_value | url_encode }}&Order+ID=&Asset+ID=" target="_blank"> --> <font style="color: #DA344D; font-weight: bold;"> {{ oec_on_rent_change._rendered_value }} </font><font size="2px;">({{ mtd_oec_percent_change._rendered_value }})</font> <!-- </a> -->
      {% endif %}
      </td>
      </tr>

      </table> ;;
  }

  measure: current_assets_on_rent {
    group_label: "Assets on Rent"
    label: "Assets On Rent"
    type: sum
    sql: ${assets_on_rent} ;;
    value_format_name: decimal_0
    filters: [today_flag: "Yes"]
  }

  measure: current_assets_on_rent_past_days_null {
    group_label: "Assets on Rent With Null Past Days"
    label: "Assets On Rent"
    type: number
    sql: case when ${current_assets_on_rent} = 0 then null else ${current_assets_on_rent} end ;;
    value_format_name: decimal_0
  }

  measure: last_mtd_assets_on_rent {
    group_label: "Assets on Rent"
    label: "Last MTD Assets On Rent"
    type: sum
    sql: ${assets_on_rent} ;;
    value_format_name: decimal_0
    filters: [prior_month_day: "Yes"]
  }

  measure: assets_on_rent_change {
    group_label: "Assets on Rent"
    label: "MTD vs Last MTD Assets On Rent"
    type: number
    sql: ${current_assets_on_rent} - ${last_mtd_assets_on_rent} ;;
    value_format_name: decimal_0
  }

  measure: mtd_aor_percent_change {
    group_label: "Assets on Rent"
    type: number
    sql: ((${current_assets_on_rent} - ${last_mtd_assets_on_rent})/ NULLIFZERO(${last_mtd_assets_on_rent}))  ;;
    value_format_name: percent_1
  }

  measure: assets_on_rent_card {
    group_label: "Assets Fixed Stats Card"
    label: " " #Making label blank so the name doesn't appear in the visual
    type: number
    sql: ${current_assets_on_rent} ;;
    html:
    <table border="0" style="font-family: Verdana; font-size: 14px; color: #323232; width: 100%;">
  <tr>
    <td colspan="3" style="font-size: 16px;">MTD VS Last MTD Assets On Rent</td>
  </tr>


      {% if assets_on_rent_change._value >= 0 %}
      <tr style="background-color: #c1ecd4;">
      {% else %}
      <tr style="background-color: #ffcfcf;">
      {% endif %}


      <td colspan="3" style="text-align: left;">
      {% if assets_on_rent_change._value >= 0 %}
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
      <td>Assets On Rent: </td>
      <td>
      {% if assets_on_rent_change._value >= 0 %}
      <center><font style="color: #00CB86"><strong>↑</strong></font></center>
      {% else %}
      <center><font style="color: #DA344D"><strong>↓</strong></font></center>
      {% endif %}
      </td>
      <td>
      <!-- <a href="https://equipmentshare.looker.com/dashboards/1134?Territory%20Account%20Manager=" target="_blank"> --> {{ current_assets_on_rent._rendered_value }} <!-- </a> -->
      {% if assets_on_rent_change._value == 0 %}
      {% else %}
      <!-- <a href="https://equipmentshare.looker.com/dashboards/1134?Territory%20Account%20Manager=" target="_blank"></a> -->
      {% endif %}
      </td>
      </tr>

      <tr>
      <td>Last MTD Assets On Rent: </td>
      <td>

      </td>
      <td>
      <!-- <a href="https://equipmentshare.looker.com/dashboards/1134?Territory%20Account%20Manager=" target="_blank"> --> {{ last_mtd_assets_on_rent._rendered_value }} <!-- </a> -->
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
      {% if assets_on_rent_change._value >= 0 %}
      <center><font style="color: #00CB86"><strong>↑</strong></font></center>
      {% else %}
      <center><font style="color: #DA344D"><strong>↓</strong></font></center>
      {% endif %}
      </td>
      <td>
      {% if assets_on_rent_change._value >= 0 %}
      <!-- <a href="https://equipmentshare.looker.com/dashboards/1134?Territory%20Account%20Manager=" target="_blank"> --> <font style="color: #00CB86; font-weight: bold;">{{ assets_on_rent_change._rendered_value }} </font><font size="2px;">({{ mtd_aor_percent_change._rendered_value }})</font> <!-- </a> -->
      {% else %}
      <!-- <a href="https://equipmentshare.looker.com/dashboards/1134?Territory%20Account%20Manager=" target="_blank"> --> <font style="color: #DA344D; font-weight: bold;">{{ assets_on_rent_change._rendered_value }} </font><font size="2px;">({{ mtd_aor_percent_change._rendered_value }})</font> <!-- </a> -->
      {% endif %}
      </td>
      </tr>

      </table> ;;
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
