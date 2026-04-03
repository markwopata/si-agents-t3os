view: planning_financials {
  derived_table: {
    sql:
    with df as ( select *, row_number() over (partition by MARKET_ID order by GL_DATE desc) as rn from analytics.branch_earnings.high_level_financials WHERE NET_INCOME!=0),

                  df2 as (SELECT MARKET_ID, sum(NET_INCOME) as NET_INCOME_3_MONTHS from df where rn=1 or rn=2 or rn=3 group by MKT_ID),

      df3 as (SELECT * FROM df where rn=1)

      SELECT df3.MARKET_ID,df3.MARKET_NAME, df3.DISTRICT, df3.REGION_NAME, df3.GL_DATE, df3.OEC, df3.EMPLOYEE_ID, df3.FULL_NAME, df3.WORK_EMAIL, df3.PERSONAL_EMAIL, df3.MONTHS_OPEN, ff2.NET_INCOME_3_MONTHS from df3
      left join (select * FROM df2) ff2 on
      df3.MARKET_ID=ff2.MARKET_ID;;
  }





  dimension: mkt_id {
    primary_key: yes
    type: string
    sql: ${TABLE}."MARKET_ID" ;;
  }

  dimension: mkt_name {
    label: "Market Name"
    type: string
    sql: ${TABLE}."MARKET_NAME" ;;

  }

  dimension: district {
    label: "District"
    type: string
    sql: ${TABLE}."DISTRICT";;
  }

  dimension: region_name {
    label: "Region Name"
    type: string
    sql: ${TABLE}."REGION_NAME" ;;

  }

  dimension: region {
    label: "Region"
    type: string
    sql: LEFT(${TABLE}."DISTRICT",1) ;;

  }


  dimension: gl_date {
    type: date
    convert_tz: no
    sql: ${TABLE}."GL_DATE" ;;
  }


  dimension: general_manager_employee_id {
    label: "Employee ID"
    type: string
    sql: ${TABLE}."GENERAL_MANAGER_EMPLOYEE_ID" ;;
  }

  dimension: general_manager_full_name {
    label: "General Manager"
    type: string
    sql: ${TABLE}."GENERAL_MANAGER_NAME" ;;
    #  link: {
    #    label: "Greenhouse Profile"
    #    url: "{{ hr_greenhouse_link_standard.greenhouse_link }}"
  }
  # link: {
  #   label: "DISC Profile ({{ disc_master.environment_style._value }})"
  #   url: "{{ disc_master.disc_website_link}}"
  # }
  #  link: {
  #    label: "DISC Profile ({{ disc_master.environment_style._value }})"
  #    url: "http://www.discoveryreport.com/v/{{disc_master.disc_code._value}}"
  #  }

  #}



  dimension: months_open {
    label: "Months Open"
    type: number
    sql: ${TABLE}."MONTH_RANK" ;;
    value_format: "#"
  }

  dimension: oec {
    type: number
    sql: ${TABLE}."OEC" ;;
  }

  dimension: work_email{
    type: string
    sql: ${TABLE}."GENERAL_MANAGER_EMAIL" ;;
  }

  measure: oec_measure {
    type: number
    sql: ${oec} ;;
  }
}
