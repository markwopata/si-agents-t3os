view: market_open_date {
  derived_table: {
    sql:
    WITH BranchData AS (
      SELECT
          RIGHT(cd.default_cost_centers_full_path,
                POSITION('/' IN REVERSE(cd.default_cost_centers_full_path)) - 1) AS category,
          cd.market_id,
          xw.market_name,
          xw.district,
          xw.region_name,
          xw.market_type,
          xw.branch_earnings_start_month as market_start,
         -- TO_CHAR(vmt.market_start_month, 'Mon YYYY') AS market_start,
          cd.first_name,
          cd.last_name,
          cd.work_phone,
          cd.work_email,
          cd.employee_title
      FROM analytics.payroll.company_directory cd
      JOIN analytics.public.MARKET_REGION_XWALK xw
          ON cd.market_id = xw.market_id
     -- JOIN analytics.public.v_market_t3_analytics vmt
     --     ON cd.market_id = vmt.market_id
      WHERE cd.employee_status = 'Active'
      GROUP BY
          cd.market_id,
          xw.market_name,
          xw.district,
          xw.region_name,
          xw.market_type,
          xw.branch_earnings_start_month,
          RIGHT(cd.default_cost_centers_full_path,
                POSITION('/' IN REVERSE(cd.default_cost_centers_full_path)) - 1),
          cd.first_name,
          cd.last_name,
          cd.work_phone,
          cd.work_email,
          cd.employee_title
    ),

      ManagerData AS (
      SELECT
      cd.market_id,
      MAX(CASE WHEN cd.employee_title = 'General Manager'
      THEN cd.first_name || ' ' || cd.last_name
      ELSE NULL END) AS general_manager,
      MAX(CASE WHEN cd.employee_title = 'General Manager'
      THEN work_phone
      ELSE NULL END) AS general_manager_phone,
      MAX(CASE WHEN cd.employee_title = 'General Manager'
      THEN work_email
      ELSE NULL END) AS general_manager_email,

      MAX(CASE WHEN cd.employee_title = 'Service Manager'
      THEN cd.first_name || ' ' || cd.last_name
      ELSE NULL END) AS service_manager,
      MAX(CASE WHEN cd.employee_title = 'Service Manager'
      THEN work_phone
      ELSE NULL END) AS service_manager_phone,
      MAX(CASE WHEN cd.employee_title = 'Service Manager'
      THEN work_email
      ELSE NULL END) AS service_manager_email,
      FROM analytics.payroll.company_directory cd
      WHERE employee_status = 'Active'
      GROUP BY cd.market_id
      )

      SELECT
      bd.market_id,
      bd.market_name,
      bd.district,
      bd.region_name,
      bd.market_type,
      bd.market_start,
      bd.category,
      md.general_manager,
      md.general_manager_phone,
      md.general_manager_email,

      md.service_manager,
      md.service_manager_phone,
      md.service_manager_email,
      bd.first_name,
      bd.last_name,
      bd.work_phone,
      bd.work_email,
      bd.first_name || ' ' || bd.last_name AS full_name,
      '<font color="blue"><u><a href="https://equipmentshare.looker.com/dashboards/513?Employee%20Name='
      || bd.first_name || ' ' || bd.last_name ||
      '" target="_blank">DISC Link</a></u></font>' AS disc_link,
      bd.employee_title

      FROM BranchData bd
      LEFT JOIN ManagerData md
      ON bd.market_id = md.market_id;;
  }


  dimension: market_id {
    type: string
    sql: ${TABLE}."MARKET_ID" ;;
    value_format_name: id
  }

  dimension: category {
    type: string
    sql: ${TABLE}."CATEGORY" ;;
  }

  dimension: market_name {
    label: "Market"
    type: string
    sql: ${TABLE}."MARKET_NAME" ;;
  }

  dimension: district {
    type: string
    sql: ${TABLE}."DISTRICT" ;;
  }

  dimension: market_type {
    type: string
    sql: ${TABLE}."MARKET_TYPE" ;;
  }

  dimension: region_name {
    label: "Region"
    type: string
    sql: ${TABLE}."REGION_NAME" ;;
  }

  dimension: market_start {
    type: string
    sql: ${TABLE}."MARKET_START" ;;
    html: {{ rendered_value | date: "%b %Y"  }};;
  }

  measure: employee_count {
    type: count_distinct
    sql: ${work_email} ;;
    html: <a href="#drillmenu" target="_self"> {{rendered_value}} <img src="https://imgur.com/ZCNurvk.png" height="15" width="15"></font></a>;;
  }

  dimension: general_manager {
    type: string
    sql: ${TABLE}."GENERAL_MANAGER" ;;
    html: <font color="#000000">
    {{rendered_value}} </a>
    <br />
    <font style="color: #000000; text-align: right;">Phone: </font>
    <font style="color: #8C8C8C; text-align: right;">{{general_manager_phone._rendered_value }} </font>
      <br />
    <font style="color: #000000; text-align: right;">Email: </font>
    <font style="color: #8C8C8C; text-align: right;">{{general_manager_email._rendered_value }} </font>
    ;;
  }

  dimension: general_manager_phone {
    type: string
    # sql: ${TABLE}."GENERAL_MANAGER_PHONE" ;;
    sql: CONCAT(
    SUBSTR(${TABLE}."GENERAL_MANAGER_PHONE", 1, 3), '-',
    SUBSTR(${TABLE}."GENERAL_MANAGER_PHONE", 4, 3), '-',
    SUBSTR(${TABLE}."GENERAL_MANAGER_PHONE", 7, 4)
    ) ;;
  }

  dimension: general_manager_email {
    type: string
    sql: ${TABLE}."GENERAL_MANAGER_EMAIL" ;;
  }

  dimension: service_manager {
    type: string
    sql: ${TABLE}."SERVICE_MANAGER" ;;
    html: <font color="#000000">
    {{rendered_value}} </a>
    <br />
    <font style="color: #000000; text-align: right;">Phone: </font>
    <font style="color: #8C8C8C; text-align: right;">{{service_manager_phone._rendered_value }} </font>
     <br />
    <font style="color: #000000; text-align: right;">Email: </font>
    <font style="color: #8C8C8C; text-align: right;">{{service_manager_email._rendered_value }} </font>
    ;;
  }
  dimension: service_manager_phone {
    type: string
    # sql: ${TABLE}."SERVICE_MANAGER_PHONE" ;;
    sql: CONCAT(
    SUBSTR(${TABLE}."SERVICE_MANAGER_PHONE", 1, 3), '-',
    SUBSTR(${TABLE}."SERVICE_MANAGER_PHONE", 4, 3), '-',
    SUBSTR(${TABLE}."SERVICE_MANAGER_PHONE", 7, 4)
    ) ;;
  }

  dimension: service_manager_email {
    type: string
    sql: ${TABLE}."SERVICE_MANAGER_EMAIL" ;;
  }

  dimension: first_name {
    type: string
    sql: ${TABLE}."FIRST_NAME" ;;
  }

  dimension: last_name {
    type: string
    sql: ${TABLE}."LAST_NAME" ;;
  }

  dimension: full_name {
    type: string
    sql: ${TABLE}."FULL_NAME" ;;
  }

  dimension: employee_title {
    type: string
    sql: ${TABLE}."EMPLOYEE_TITLE" ;;
  }

  dimension: work_email {
    type: string
    sql: ${TABLE}."WORK_EMAIL" ;;
  }

  dimension: work_phone {
    type: string
    # sql: ${TABLE}.work_phone ;;
    sql: CONCAT(
    SUBSTR(${TABLE}.work_phone, 1, 3), '-',
    SUBSTR(${TABLE}.work_phone, 4, 3), '-',
    SUBSTR(${TABLE}.work_phone, 7, 4)
    ) ;;
  }

  dimension: metric_definition_pdf_link {
    type: string
    sql: 1 ;;
    html:<font color="#0063f3 "><a href="https://drive.google.com/file/d/1PpVT4HdUy0xGq_NXOIAS8DkGf7Tr42H5/view?usp=sharing"target="_blank">
      Metric Definition PDF ➔</font> ;;
  }

  measure: count_markets {
    type: count_distinct
    sql: ${market_name};;
    html: General Manager and Service Manager Info <img src="https://imgur.com/ZCNurvk.png" height="20" width="20"> ;;
    drill_fields: [region_name, district, market_name, market_start, general_manager, service_manager]
  }

  measure: count_districts {
    type: count_distinct
    sql: ${district} ;;
    drill_fields: [region_name, district, market_name, market_start, general_manager, service_manager]
  }

  measure: count_regions {
    type: count_distinct
    sql:${region_name};;
    drill_fields: [region_name, district, market_name, market_start, general_manager, service_manager]
  }

  dimension: disc_link {
    type: string
    label: "DISC Dashboard Link"
    sql: ${TABLE}.disc_link ;;
    html: <font color='blue'><u><a href='https://equipmentshare.looker.com/dashboards/513?Employee%20Name={{ first_name }}%20{{ last_name }}' target='_blank'>DISC Link</a></u></font>;;
  }

  measure: combined_market_info {
    group_label: "Market Info Card"
    type: string
    label: " "
    sql: 'Market Info' ;;
    html:

      <table border="0" style="font-family: Verdana; font-size: 12px; color: #323232; width: 100%;">
      <tr>
          <td colspan="4" style="font-size: 16px;text-align: left; color: #6ba5ed; font-weight: 600;">{{ market_name._value }}</td>
      </tr>
      <tr>
          <td colspan="2"><font style="color: #C0C0C0"><br /></font></td>
      </tr>
      <tr>
          <td style="width: 50%; text-align: left;">Market Start:</td>
          <td style="text-align: right;">{{ market_start._value }}</td>
      </tr>
      <tr>
          <td colspan="2"><hr style="border: 1px solid #DCDCDC; margin: 0;"></td>
      </tr>
      <tr>
          <td style="font-weight: 500; text-align: left;">General Manager:</td>
          <td style="text-align: right;">{{ general_manager._value }}</td>
      </tr>
      <tr>
          <td colspan="2"><hr style="border: 1px solid #DCDCDC; margin: 0;"></td>
      </tr>
      <tr>
          <td style="font-weight: 500; text-align: left;">Service Manager:</td>
          <td style="text-align: right;">{{ service_manager._value }}</td>
      </tr>
      <tr>
          <td colspan="2"><hr style="border: 1px solid #DCDCDC; margin: 0;"></td>
      </tr>
      </table>

    ;;
  }

  measure: first_category {
    type: yesno
    sql: ${category} = MIN(${category}) OVER () ;;
  }

    measure: employees_by_category {
      group_label: "Employee Category Card"
      type: string
      label: " "
      drill_fields: [full_name, employee_title, work_email, work_phone, disc_link]
      sql: ' ' ;;
      html:
          <table border="0" style="font-family: Verdana; font-size: 14px; color: #323232; width: 100%;">

            {% if category._value and first_category._value == "Yes" %}
              <tr>
                <td colspan="2" style="font-size: 20px; text-align: left;">Employee Breakdown</td>
              </tr>
              <tr>
                <td colspan="2"><font style="color: #C0C0C0"><br /></font></td>
              </tr>
            {% endif %}


        {% if category._value and employee_count._value and employee_count._value > 0 %}
        <tr>
        <td style="font-size: 14px; text-align: left;">{{ category._value }}</td>
        <td style="font-weight: bold; text-align: right;">{{ employee_count._rendered_value }} <img src="https://imgur.com/ZCNurvk.png" height="15" width="15"></td>
        </tr>
        <tr>
        <td><hr style="border: 1px solid #DCDCDC; margin: 0;"></td>
        <td><hr style="border: 1px solid #DCDCDC; margin: 0;"></td>
        </tr>
        {% endif %}
        </table> ;;
    }

  measure: selection_label {
    type: string
    sql:
    CASE
      -- More than one market → first market + count-1 markets
      WHEN COUNT(DISTINCT ${market_id}) > 1 THEN
        SPLIT_PART(
          LISTAGG(DISTINCT ${market_name}, '||')
            WITHIN GROUP (ORDER BY ${market_name}),
          '||', 1
        )
        || ' + ' ||
        TO_VARCHAR(COUNT(DISTINCT ${market_id}) - 1) ||
        CASE
          WHEN (COUNT(DISTINCT ${market_id}) - 1) = 1 THEN ' market'
          ELSE ' markets'
        END

      -- Exactly one market → just its name
      WHEN COUNT(DISTINCT ${market_id}) = 1 THEN
      MIN(${market_name})

      ELSE 'All Company'
      END
      ;;
    html: {{rendered_value}} <img src="https://imgur.com/ZCNurvk.png" height="20" width="20"> ;;
    drill_fields: [region_name, district, market_name, market_start, general_manager, service_manager]

  }



  set: detail {
    fields: [
      market_id,
      market_name,
      market_start,
      employee_count,
      category,
      general_manager,
      service_manager
    ]
  }
}
