view: planning_financials {
  derived_table: {
    sql:
    with df as ( select *, row_number() over (partition by MKT_ID order by GL_DATE desc) as rn from analytics.public.high_level_financials_snap WHERE NET_INCOME!=0),

df2 as (SELECT MKT_ID, sum(NET_INCOME) as NET_INCOME_3_MONTHS from df where rn=1 or rn=2 or rn=3 group by MKT_ID),

df3 as (SELECT * FROM df where rn=1)

SELECT df3.MKT_ID,df3.MKT_NAME, df3.DISTRICT, df3.REGION_NAME, df3.GL_DATE, df3.OEC, df3.EMPLOYEE_ID, df3.FULL_NAME, df3.WORK_EMAIL, df3.PERSONAL_EMAIL, df3.MONTHS_OPEN, ff2.NET_INCOME_3_MONTHS from df3
left join (select * FROM df2) ff2 on
df3.MKT_ID=ff2.MKT_ID;;
  }





  dimension: mkt_id {
    primary_key: yes
    type: string
    sql: ${TABLE}."MKT_ID" ;;
  }

  dimension: mkt_name {
    label: "Market Name"
    type: string
    sql: ${TABLE}."MKT_NAME" ;;

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


  dimension: employee_id {
    label: "Employee ID"
    type: string
    sql: ${TABLE}."EMPLOYEE_ID" ;;
  }

  dimension: full_name {
    label: "General Manager"
    type: string
    sql: ${TABLE}."FULL_NAME" ;;
    link: {
      label: "Greenhouse Profile"
      url: "{{ hr_greenhouse_link.greenhouse_link }}"
    }
    # link: {
    #   label: "DISC Profile ({{ disc_master.environment_style._value }})"
    #   url: "{{ disc_master.disc_website_link}}"
    # }
    link: {
      label: "DISC Profile ({{ disc_master.environment_style._value }})"
      url: "http://www.discoveryreport.com/v/{{disc_master.disc_code._value}}"
    }

  }



  dimension: months_open {
    label: "Months Open"
    type: number
    sql: ${TABLE}."MONTHS_OPEN" ;;
    value_format: "#"
  }

 dimension: oec {
    type: number
    sql: ${TABLE}."OEC" ;;
  }

  dimension: work_email{
    type: string
    sql: ${TABLE}."WORK_EMAIL" ;;
  }

 dimension: personal_email{
    type: string
    sql: ${TABLE}."PERSONAL_EMAIL" ;;
  }

  measure: net_income_3_months  {
    label: "Net Income 3 Months Trailing"
    type: average
    value_format: "$#,##0;-$#,##0;-"
    sql:  ${TABLE}."NET_INCOME_3_MONTHS" ;;
  }

  measure: oec_measure {
    type: number
    sql: ${oec} ;;
  }

}
