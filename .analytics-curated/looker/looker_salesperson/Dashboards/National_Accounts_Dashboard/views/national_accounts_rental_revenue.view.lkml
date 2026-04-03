view: national_accounts_rental_revenue {
  derived_table: {
    sql:
        WITH national_accounts as (
          SELECT
            bcp.company_id,
            c.name as company,
            pcr.parent_company_name,
            COALESCE(CASE WHEN position(' ',coalesce(cd.nickname,cd.first_name)) = 0
                           THEN concat(coalesce(cd.nickname,cd.first_name), ' ', cd.last_name)
                           ELSE concat(coalesce(cd.nickname,concat(cd.first_name, ' ',cd.last_name))) END,
                     'Unassigned') as assigned_nam
          FROM es_warehouse.public.billing_company_preferences bcp
          JOIN es_warehouse.public.companies c ON bcp.company_id = c.company_id
          LEFT JOIN analytics.bi_ops.v_parent_company_relationships pcr ON c.company_id = pcr.company_id
          LEFT JOIN analytics.commission.nam_company_assignments nca ON nca.company_id = c.company_id
          LEFT JOIN es_warehouse.public.users u on u.user_id = nca.nam_user_id
          LEFT JOIN analytics.payroll.company_directory cd ON lower(u.EMAIL_ADDRESS) = lower(cd.WORK_EMAIL)
          WHERE bcp.PREFS:national_account = TRUE
            AND current_timestamp() BETWEEN nca.effective_start_date AND nca.effective_end_date
            AND (({{ _user_attributes['job_role'] }} = 'nam' AND lower(cd.work_email) = '{{ _user_attributes['email'] }}')
                 -- Hardcode for Jessica to only see Tyler Levin's accounts
                 OR ('{{ _user_attributes['email'] }}' = 'jessica.howard@equipmentshare.com' AND lower(cd.work_email) = 'tyler.levins@equipmentshare.com')
                 OR ('{{ _user_attributes['email'] }}' <> 'jessica.howard@equipmentshare.com' AND {{ _user_attributes['job_role'] }} <> 'nam'))
        )

        , date_series AS (
          SELECT
            DATEADD(
              day,
              '-' || ROW_NUMBER() over (ORDER BY  NULL),
              DATEADD(day, '+1', CONVERT_TIMEZONE('UTC', 'America/Chicago', CURRENT_TIMESTAMP())::DATE)
            ) AS date
          FROM table (generator(rowcount => (365*2)))
        )

        , company_every_day AS (
          SELECT *
          FROM date_series
          CROSS JOIN national_accounts
          CROSS JOIN (SELECT DISTINCT business_segment_name FROM analytics.bi_ops.salesperson_line_items_current)
        )



        , daily_rental_rev as (
        select
        dd.date as rental_date,
        c.company_id as rental_company_id,
        COALESCE(bs.name, 'No Class Listed') AS business_segment_name,
        sum(ild.invoice_line_details_amount) as rental_revenue
        from
        platform.gold.v_line_items r
        JOIN platform.gold.v_invoice_line_details ild on ild.INVOICE_LINE_DETAILS_LINE_ITEM_KEY = r.line_item_key
        LEFT JOIN platform.gold.v_assets va ON va.asset_key = ild.invoice_line_details_asset_key
        LEFT JOIN es_warehouse.public.assets a ON a.asset_id = va.asset_id
        LEFT JOIN es_warehouse.public.equipment_classes ec ON ec.equipment_class_id = a.equipment_class_id
        LEFT JOIN ES_WAREHOUSE.PUBLIC.BUSINESS_SEGMENTS bs ON bs.business_segment_id = ec.business_segment_id
        JOIN platform.gold.v_dates dd on ild.invoice_line_details_gl_billing_approved_date_key = dd.date_key
        JOIN platform.gold.v_companies c on ild.invoice_line_details_company_key = c.company_key
      where
        --dd.current_month = TRUE and
        dd.date >= DATEADD(year, '-2', CURRENT_DATE())
        --and c.company_id = 149587
        AND r.LINE_ITEM_RENTAL_REVENUE = TRUE
        AND c.company_id IN (SELECT company_id
                                        FROM es_warehouse.public.billing_company_preferences
                                        WHERE PREFS:national_account = TRUE)
      group by
        dd.date, c.company_id, business_segment_name

        )

        SELECT
          ced.date as rental_date,
          ced.company_id as rental_company_id,
          ced.company as RENTAL_COMPANY,
          ced.parent_company_name,
          ced.assigned_nam,
          --RENTAL_MARKET_ID,
          --RENTAL_MARKET,
          ced.BUSINESS_SEGMENT_NAME,
          COALESCE(rental_revenue, 0) as rental_revenue,
          COALESCE(SUM(COALESCE(rental_revenue,0))
                    OVER (PARTITION BY
                            date_trunc('month', ced.date),
                            ced.company_id,
                            ced.business_segment_name
                          ORDER BY ced.date)
                   , 0) as rolling_rental_revenue,
          IFF(ced.date =  TO_DATE(CONVERT_TIMEZONE('America/Chicago', CURRENT_TIMESTAMP())),
              1, 0) AS today_flag,
          IFF(ced.date >=  TO_DATE(DATE_TRUNC('month', CONVERT_TIMEZONE('America/Chicago', CURRENT_TIMESTAMP()))),
              1, 0) AS MTD_flag,
          IFF(TO_DATE(DATE_TRUNC('month', ced.date)) = TO_DATE(DATE_TRUNC('month', CONVERT_TIMEZONE('America/Chicago', CURRENT_TIMESTAMP())) - INTERVAL '1 MONTH'),
              1, 0) AS last_full_month_flag
        FROM company_every_day ced
        LEFT JOIN daily_rental_rev drr
          ON ced.company_id = drr.rental_company_id AND ced.date = drr.rental_date AND ced.business_segment_name = drr.business_segment_name



        ;;
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
    sql:  ${TABLE}."RENTAL_DATE";;
  }

  dimension: sp_user_id {
    type: number
    sql: ${TABLE}."SP_USER_ID" ;;
  }

  dimension: sp_name {
    type: string
    sql: ${TABLE}."SP_NAME" ;;
  }

  dimension: rental_company_id {
    type: number
    sql: ${TABLE}."RENTAL_COMPANY_ID" ;;
  }

  dimension: rental_company {
    type: string
    sql: ${TABLE}."RENTAL_COMPANY" ;;
  }

  dimension: parent_company {
    type: string
    sql: ${TABLE}."PARENT_COMPANY_NAME";;
  }

  dimension: assigned_nam {
    type: string
    sql: ${TABLE}."ASSIGNED_NAM" ;;
  }

  dimension: rental_market_id {
    type: number
    sql: ${TABLE}."RENTAL_MARKET_ID" ;;
  }

  dimension: rental_market_name {
    type: string
    sql: ${TABLE}."RENTAL_MARKET" ;;
  }

  dimension: business_segment {
    type: string
    sql: ${TABLE}."BUSINESS_SEGMENT_NAME" ;;
  }

  dimension: rental_revenue {
    type: number
    sql: ${TABLE}."RENTAL_REVENUE" ;;
  }

  dimension: rolling_rental_revenue {
    type: number
    sql: ${TABLE}."ROLLING_RENTAL_REVENUE" ;;
  }

  measure: rental_revenue_sum {
    type: sum
    sql: ${rental_revenue} ;;
    value_format_name: "usd_0"
  }

  dimension: mtd {
    type: yesno
    sql: TO_DATE(${rental_date_raw}) BETWEEN
          TO_DATE(DATE_TRUNC('month', CONVERT_TIMEZONE('America/Chicago', CURRENT_TIMESTAMP()))) AND
          TO_DATE(CONVERT_TIMEZONE('America/Chicago', CURRENT_TIMESTAMP()));;
  }

  measure: mtd_total_rev {
    group_label: "Fixed Timeframes"
    label: "MTD Rental Revenue"
    type: sum
    sql: ZEROIFNULL(${rental_revenue}) ;;
    value_format_name:  usd_0
    filters: [mtd: "yes"]
  }

  dimension: mtd_flag {
    type: number
    sql: ${TABLE}."MTD_FLAG";;
  }

  measure: mtd_rolling_rev_filter {
    group_label: "Fixed Timeframes"
    type: number
    sql: case when ${mtd_flag} = 1 then ${rolling_rental_revenue} else null end ;;
    value_format_name:  usd_0
  }

  measure: mtd_rolling_rev {
    group_label: "Fixed Timeframes"
    type: number
    sql: sum(${mtd_rolling_rev_filter});;
    value_format_name:  usd_0
  }

  measure: mtd_rolling_rental_revenue_by_day_test {
    group_label: "Fixed Timeframes"
    type: number
    sql: case when ${mtd_rolling_rev} = 0 then null
          when  ${mtd_rolling_rev} <> 0 then ${mtd_rolling_rev}
          else null end ;;
    value_format_name: usd_0
  }

  dimension: past_mtd {
    type: yesno
    sql: TO_DATE(${rental_date_raw}) BETWEEN
          TO_DATE(DATE_TRUNC('month', CONVERT_TIMEZONE('America/Chicago', CURRENT_TIMESTAMP()) - INTERVAL '1 MONTH')) AND
          TO_DATE(CONVERT_TIMEZONE('America/Chicago', CURRENT_TIMESTAMP()) - INTERVAL '1 MONTH');;
  }

  measure: past_mtd_day_previous_total_rev {
    group_label: "Fixed Timeframes Previous"
    label: "Last MTD Rental Revenue"
    type: sum
    sql: ZEROIFNULL(${rental_revenue}) ;;
    value_format_name:  usd_0
    filters: [past_mtd: "yes"]
  }

  measure: mtd_change_total_rev {
    group_label: "Fixed Timeframes Change"
    label: "MTD Change %"
    type: number
    sql: DIV0NULL(${mtd_total_rev} - ${past_mtd_day_previous_total_rev}, ${past_mtd_day_previous_total_rev}) ;;
    value_format_name: percent_1
  }

  measure: mtd_change_total_rev_total_arrows {
    group_label: "Fixed Timeframes Change"
    type: number
    sql: ${mtd_total_rev} - ${past_mtd_day_previous_total_rev};;
    value_format_name:  usd_0
    html:
      {% if value > 0 %}
        <font color="#00CB86">
        <strong>&#9650;&nbsp;{{rendered_value}}</strong></font> <!-- Up Triangle with space -->
    {% elsif value == 0 %}
        <font color="#808080">
        <strong>{{rendered_value}}</strong></font>
    {% elsif value < 0 %}
        <font color="#DA344D">
        <strong>&#9660;&nbsp;{{rendered_value}}</strong></font> <!-- Down Triangle with space -->
    {% else %}
        <font color="#808080">
        <strong>{{rendered_value}}</strong></font>
    {% endif %}
       ;;
  }

  measure: mtd_rr_card {
    group_label: "Fixed Stats Card"
    label: " " #Making label blank so the name doesn't appear in the visual
    description: "mtd_rr_card"
    type: sum
    sql: ${rental_revenue} ;;
    html:
    <table border="0" style="font-family: Verdana; font-size: 14px; color: #323232; width: 100%;">
  <tr>
    <td colspan="3" style="font-size: 16px;">MTD VS Last MTD Rental Revenue</td>
  </tr>


      {% if mtd_change_total_rev._value >= 0 %}
      <tr style="background-color: #c1ecd4;">
      {% else %}
      <tr style="background-color: #ffcfcf;">
      {% endif %}


      <td colspan="3" style="text-align: left;">
      {% if mtd_change_total_rev._value >= 0 %}
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
      <td>MTD Rental Revenue: </td>
      <td>
      {% if mtd_change_total_rev._value >= 0 %}
      <center><font style="color: #00CB86"><strong>↑</strong></font></center>
      {% else %}
      <center><font style="color: #DA344D"><strong>↓</strong></font></center>
      {% endif %}
      </td>
      <td>
      <!--<a href="https://equipmentshare.looker.com/dashboards/1134?Territory%20Account%20Manager=" target="_blank"> -->{{ mtd_total_rev._rendered_value }} <!-- </a> -->
      <!--{% if mtd_change_total_rev._value == 0 %} -->
      <!--{% else %} -->
      <!--<a href="https://equipmentshare.looker.com/dashboards/1134?Territory%20Account%20Manager=" target="_blank"></a> -->
      <!--{% endif %} -->
      </td>
      </tr>

      <tr>
      <td>Last MTD Rental Revenue: </td>
      <td>

      </td>
      <td>
      <!-- <a href="https://equipmentshare.looker.com/dashboards/1134?Territory%20Account%20Manager=" target="_blank"> --> {{ past_mtd_day_previous_total_rev._rendered_value }} <!-- </a> -->
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
      {% if mtd_change_total_rev._value >= 0 %}
      <center><font style="color: #00CB86"><strong>↑</strong></font></center>
      {% else %}
      <center><font style="color: #DA344D"><strong>↓</strong></font></center>
      {% endif %}
      </td>
      <td>
      {% if mtd_change_total_rev._value >= 0 %}
      <!-- <a href="https://equipmentshare.looker.com/dashboards/1134?Territory%20Account%20Manager=" target="_blank"> --> <font style="color: #00CB86; font-weight: bold;">{{ mtd_change_total_rev_total_arrows._rendered_value }} </font><font size="2px;">({{ mtd_change_total_rev._rendered_value }})</font> <!-- </a> -->
      {% else %}
      <!-- <a href="https://equipmentshare.looker.com/dashboards/1134?Territory%20Account%20Manager=" target="_blank"> --> <font style="color: #DA344D; font-weight: bold;">{{ mtd_change_total_rev_total_arrows._rendered_value }} </font><font size="2px;">({{ mtd_change_total_rev._rendered_value }})</font> <!-- </a> -->
      {% endif %}
      </td>
      </tr>

      </table> ;;
  }

  dimension: last_full_month_flag {
    type: number
    sql: ${TABLE}."LAST_FULL_MONTH_FLAG" ;;
  }

  measure: previous_month_rental_revenue {
    type: sum
    sql:  ${rental_revenue};;
    filters: [last_full_month_flag: "1"]
    value_format_name: usd_0
  }

  measure: previous_month_rolling_rev_filter {
    group_label: "Fixed Timeframes"
    type: number
    sql: case when ${last_full_month_flag} = 1 then ${rolling_rental_revenue} else null end ;;
    value_format_name: usd_0
  }

  measure: previous_month_rolling_rev_test {
    group_label: "Fixed Timeframes"
    type: number
    sql: sum(${previous_month_rolling_rev_filter});;
    value_format_name: usd_0
  }

  dimension: today_flag {
    group_label: "Time Period Flags"
    type: number
    sql: ${TABLE}."TODAY_FLAG" ;;
  }

  measure: mtd_current_day_rolling_rental_revenue_filter {
    group_label: "Fixed Timeframes"
    type: number
    sql: case when ${today_flag} = 1 then ${rolling_rental_revenue} else null end ;;
    value_format: "$#,##0"
  }

  measure: mtd_current_day_rolling_rental_revenue {
    group_label: "Fixed Timeframes"
    type: number
    sql: sum(${mtd_current_day_rolling_rental_revenue_filter});;
    value_format: "$#,##0"
  }

  measure: current_day_mtd_rolling_rev {
    group_label: "Fixed Timeframes"
    type: number
    sql: case when ${mtd_current_day_rolling_rental_revenue} = 0 then null
          when  ${mtd_current_day_rolling_rental_revenue} <> 0 then ${mtd_current_day_rolling_rental_revenue}
          else null end ;;
    value_format_name: usd_0
  }

  measure: adv_rev {
    type: sum
    sql: rental_revenue ;;
    filters: [business_segment: "Advanced Solutions"]
    value_format_name: usd_0
  }

  measure: gen_rev {
    type: sum
    sql: rental_revenue ;;
    filters: [business_segment: "Gen Rental"]
    value_format_name: usd_0
  }

  measure: itl_rev {
    type: sum
    sql: rental_revenue ;;
    filters: [business_segment: "ITL"]
    value_format_name: usd_0
  }

  measure: no_class_rev {
    type: sum
    sql: rental_revenue ;;
    filters: [business_segment: "No Class Listed"]
    value_format_name: usd_0
  }
}
