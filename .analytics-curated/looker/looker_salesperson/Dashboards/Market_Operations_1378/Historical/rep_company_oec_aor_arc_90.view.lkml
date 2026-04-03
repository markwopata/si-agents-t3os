
view: rep_company_oec_aor_arc_90 {
  derived_table: {
    sql:
    WITH combo as
      (select * from analytics.bi_ops.rep_company_oec_aor_historical where date >= dateadd(day, ((-{{ days_timeframe._parameter_value }})-1), CONVERT_TIMEZONE('America/Chicago', CURRENT_TIMESTAMP())::DATE)
        union
       select * from analytics.bi_ops.rep_company_oec_aor_current)
 ,  tam_manager_manager_info AS (
    SELECT
      t1.employee_id AS id_1
    , t1.work_email AS tam_email
    , CASE WHEN position(' ',COALESCE(t1.nickname,t1.first_name)) = 0 THEN concat(COALESCE(t1.nickname,t1.first_name), ' ', t1.last_name)
                ELSE concat(COALESCE(t1.nickname,concat(t1.first_name, ' ',t1.last_name))) END AS tam_name
    , t1.employee_status as tam_status
    , t1.direct_manager_employee_id AS m_id_1
    , t2.employee_id AS id_2
    , t2.work_email AS manager_email_present
   -- , concat(t2.first_name, ' ', t2.last_name) AS manager_name_present
    , CASE WHEN position(' ',coalesce(t2.nickname,t2.first_name)) = 0 then concat(coalesce(t2.nickname,t2.first_name), ' ', t2.last_name)
                ELSE concat(coalesce(t2.nickname,concat(t2.first_name, ' ',t2.last_name))) END as manager_name_present
    , t2.direct_manager_employee_id AS m_id_2
    , t2.employee_status as manager_status
    FROM analytics.payroll.company_directory t1
    LEFT JOIN analytics.payroll.company_directory t2 ON t1.direct_manager_employee_id = t2.employee_id
)
, final_tam_manager AS (
    SELECT
      tmmi.tam_name
    , tmmi.tam_email
    , u1.user_id AS tam_user_id
    , tam_status
    , u2.user_id AS manager_user_id_present
    , tmmi.manager_name_present
    , tmmi.manager_email_present
    , manager_status
    FROM tam_manager_manager_info tmmi
    LEFT JOIN es_warehouse.public.users u1 ON lower(u1.email_address) = lower(tmmi.tam_email)
    LEFT JOIN es_warehouse.public.users u2 ON lower(u2.email_address) = lower(tmmi.manager_email_present)
)
, final_tam_manager_info AS (
    SELECT *
    FROM final_tam_manager
    QUALIFY row_number() OVER (PARTITION BY tam_user_id ORDER BY CASE WHEN tam_status ILIKE '%TERMINATED%' THEN 1 ELSE 0 End) = 1
    )


    SELECT c.*,

          location as employee_location,
          case when date = CONVERT_TIMEZONE('America/Chicago', CURRENT_TIMESTAMP())::DATE THEN 1 ELSE 0 END today_flag,
          mrx.district,
          ftmi.manager_name_present AS current_direct_manager
          FROM combo c
          join es_warehouse.public.users u on u.user_id = c.salesperson_user_id
          join analytics.payroll.company_directory cd on lower(u.email_address) = lower(cd.work_email)
          join analytics.payroll.pa_employee_access ca on ca.employee_id = cd.employee_id
          left join analytics.public.market_region_xwalk mrx on mrx.market_id = cd.market_id
          left join final_tam_manager_info ftmi ON ftmi.tam_user_id = c.salesperson_user_id

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

  dimension: date_formatted {
    group_label: "HTML Formatted Date"
    label: "Date"
    type: date
    sql: ${date_date} ;;
    html: {{ rendered_value | date: "%b %d, %Y" }};;
  }

  dimension: salesperson_user_id {
    group_label: "Sales Person Info"
    type: string
    sql: ${TABLE}."SALESPERSON_USER_ID" ;;
  }


  dimension: today_flag{
    type: string
    sql: ${TABLE}."TODAY_FLAG" ;;
  }

  dimension: rep {
    group_label: "Sales Person Info"
    type: string
    sql: ${TABLE}."REP" ;;
  }

  dimension: current_direct_manager {
    group_label: "Sales Person Info"
    type: string
    sql: ${TABLE}."CURRENT_DIRECT_MANAGER" ;;
  }

  dimension: employee_location  {
    group_label: "Sales Person Info"
    type:  string
    sql: ${TABLE}."EMPLOYEE_LOCATION" ;;
  }

  dimension: rep_home_market {
    group_label: "Sales Person Info"
    type: string
    sql: concat(${rep}, ' - ',${employee_location}) ;;
  }

  dimension: salesperson {
    group_label: "Sales Person Info"
    label: "Rep*"
    type: string
    sql: ${rep} ;;
    html:
    <font color="#0063f3 "><a href="https://equipmentshare.looker.com/dashboards/1409?Rep={{rep_home_market._filterable_value}}"target="_blank">
    {{rendered_value}} ➔</a>
    <br />
    <font style="color: #8C8C8C; text-align: right;">Home: {{employee_location._rendered_value }} </font>
    ;;
  }

  dimension: direct_manager {
    group_label: "Sales Person Info"
    type: string
    sql: ${TABLE}."DIRECT_MANAGER" ;;
  }

  dimension: new_sp_flag_current {
    group_label: "Sales Person Info"
    type: string
    sql: ${TABLE}."NEW_SP_FLAG_CURRENT" ;;
  }

  dimension: first_date_as_TAM {
    group_label: "Sales Person Info"
    type: date
    sql:  ${TABLE}."FIRST_DATE_AS_TAM" ;;
  }

  dimension: rerent_assets_on_rent {
    type: number
    sql:  ${TABLE}."RERENT_ASSETS_ON_RENT" ;;
  }

  measure: rerents_on_rent_sum {
    type: sum
    sql: ${rerent_assets_on_rent} ;;
  }

  dimension: assets_on_rent {
    type: number
    sql: ${TABLE}."ASSETS_ON_RENT" ;;
  }

  measure: assets_on_rent_tot {
    type: number
    sql: ${assets_on_rent} ;;
    label: "Assets on Rent"
  }

  measure: assets_on_rent_sum {
    type: sum
    sql: ${assets_on_rent} ;;
    label: "Assets on Rent"
    drill_fields: [assets_on_rent_individuals_drill*]
  }


  dimension: company_id {
    type: string
    sql: ${TABLE}."COMPANY_ID" ;;
  }

  dimension: company_name {
    type: string
    sql: ${TABLE}."COMPANY_NAME" ;;
  }

 dimension: oec_on_rent {
    label: "OEC On Rent"
    type: number
    sql: ${TABLE}."OEC_ON_RENT" ;;
    value_format_name: usd_0
  }

  dimension: district {
    group_label: "Sales Person Info"
    type: string
    sql: ${TABLE}."DISTRICT" ;;
  }

  measure: oec_on_rent_tot {
    label: "OEC On Rent"
    type: sum
    sql: ${oec_on_rent} ;;
    value_format_name: usd_0
  }

  measure: actively_renting_customers {
    type: count_distinct
    sql:  ${company_id} ;;
    drill_fields: [company_name, company_id]
  }

  measure: actively_renting_customers_today {
    type: count_distinct
    sql:  ${company_id} ;;
    drill_fields: [assets_on_rent_individuals_drill*]
    filters: [today_flag: "1"]
  }

  measure: current_actively_renting_customers_with_null_days {
    label: "Actively Renting Customers Today"
    type: number
    sql: case when ${actively_renting_customers_today} = 0 then null else ${actively_renting_customers_today} end ;;
  }

  measure: actively_renting_customers_mtd {
    type: count_distinct
    sql: case when ${date_date} = dateadd(day, '-1', CONVERT_TIMEZONE('America/Chicago', CURRENT_TIMESTAMP())::DATE) THEN ${company_id} ELSE NULL END---- this is actually yesterday's numbers;;

    drill_fields: [arc_individuals_drill*]
  }

  measure: actively_renting_customers_lmtd {
    type: count_distinct
    sql: case when ${date_date} = dateadd(month, '-1',CONVERT_TIMEZONE('America/Chicago', CURRENT_TIMESTAMP())::DATE) THEN ${company_id} ELSE NULL END;;
  }

  measure: actively_renting_customers_change {
    type: number
    sql: ${actively_renting_customers_mtd} - ${actively_renting_customers_lmtd};;
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

  measure:actively_renting_customers_percent_change {
    type: number
    sql: CASE WHEN ${actively_renting_customers_lmtd} = 0 AND ${actively_renting_customers_mtd} = 0 THEN 0
              WHEN ${actively_renting_customers_lmtd} = 0 THEN 1
              ELSE ((${actively_renting_customers_mtd} - ${actively_renting_customers_lmtd})/ NULLIFZERO(${actively_renting_customers_lmtd}))  END ;;
    value_format_name: percent_1
  }


  dimension: one_flag {
    type: number
    sql: ${TABLE}."ONE_FLAG" ;;
  }

  measure: actively_renting_customers_card {
    group_label: "Actively Renting Customer Fixed Stats Card"
    label: " " #Making label blank so the name doesn't appear in the visual
    type: number
    sql: ${actively_renting_customers} ;;
    html:
    <table border="0" style="font-family: Verdana; font-size: 14px; color: #323232; width: 100%;">
  <tr>
    <td colspan="3" style="font-size: 16px;">MTD VS Last MTD Actively Renting Customers</td>
  </tr>


      {% if actively_renting_customers_change._value >= 0 %}
      <tr style="background-color: #c1ecd4;">
      {% else %}
      <tr style="background-color: #ffcfcf;">
      {% endif %}


      <td colspan="3" style="text-align: left;">
      {% if actively_renting_customers_change._value >= 0 %}
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
      <td>Actively Renting Customers: </td>
      <td>
      {% if actively_renting_customers_change._value >= 0 %}
      <center><font style="color: #00CB86"><strong>↑</strong></font></center>
      {% else %}
      <center><font style="color: #DA344D"><strong>↓</strong></font></center>
      {% endif %}
      </td>
      <td>
      <a href="https://equipmentshare.looker.com/dashboards/1134?Territory%20Account%20Manager=" target="_blank">{{ actively_renting_customers_mtd._rendered_value }}</a>
      {% if actively_renting_customers_change._value == 0 %}
      {% else %}
      <a href="https://equipmentshare.looker.com/dashboards/1134?Territory%20Account%20Manager=" target="_blank"></a>
      {% endif %}
      </td>
      </tr>

      <tr>
      <td>Last MTD Actively Renting Customers: </td>
      <td>

      </td>
      <td>
      <a href="https://equipmentshare.looker.com/dashboards/1134?Territory%20Account%20Manager=" target="_blank">{{ actively_renting_customers_lmtd._rendered_value }}</a>
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
      {% if actively_renting_customers_change._value >= 0 %}
      <center><font style="color: #00CB86"><strong>↑</strong></font></center>
      {% else %}
      <center><font style="color: #DA344D"><strong>↓</strong></font></center>
      {% endif %}
      </td>
      <td>
      {% if actively_renting_customers_change._value >= 0 %}
      <a href="https://equipmentshare.looker.com/dashboards/1134?Territory%20Account%20Manager=" target="_blank"><font style="color: #00CB86; font-weight: bold;">{{ actively_renting_customers_change._rendered_value }} </font><font size="2px;">({{ actively_renting_customers_percent_change._rendered_value }})</font></a>
      {% else %}
      <a href="https://equipmentshare.looker.com/dashboards/1134?Territory%20Account%20Manager=" target="_blank"><font style="color: #DA344D; font-weight: bold;">{{ actively_renting_customers_change._rendered_value }} </font><font size="2px;">({{ actively_renting_customers_percent_change._rendered_value }})</font></a>
      {% endif %}
      </td>
      </tr>

      </table> ;;
  }

  parameter: days_timeframe {
    type: string
    default_value: "90"
    allowed_value: { value: "7"}
    allowed_value: { value: "30"}
    allowed_value: { value: "90"}
    allowed_value: { value: "180"}
    allowed_value: { value: "365"}
  }

  set: arc_individuals_drill {
    fields: [
      rep,
      company_name,
      assets_on_rent,
      oec_on_rent

    ]
  }

  set: assets_on_rent_individuals_drill {
    fields: [
      company_name,
      oec_on_rent_tot,
      assets_on_rent_sum
    ]
  }

  set: detail {
    fields: [
date_date,
  salesperson_user_id,
  assets_on_rent,
  company_id,
  company_name,
  oec_on_rent,
  one_flag
    ]
  }
}
