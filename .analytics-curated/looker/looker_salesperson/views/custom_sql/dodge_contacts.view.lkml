view: dodge_contacts {

  derived_table: {
    sql:
       SELECT DISTINCT PC.TITLE AS PROJECT, CC.FIRM_NAME AS FIRM_NAME, CC.CONTACT_NAME, CC.CONTACT_TITLE AS CONTACT_TITLE,
CC.C_ADDR_LINE_1 AS ADDRESS, CC.EMAIL_ID AS EMAIL,CC.C_CITY_NAME AS CITY, ST.NAME AS STATE,
SUBSTRING(CC.PHONE_NBR,0,3)||'-'||SUBSTRING(CC.PHONE_NBR,4,3)||'-'||SUBSTRING(CC.PHONE_NBR,7,4) AS PHONE,
CC.WWW_URL AS FIRM_WEBSITE, SUBSTRING(CC.C_ZIP_CODE,0,5) AS ZIP_CODE,STD_COMPANY_TYPE_DESC AS COMPANY_TYPE
FROM ANALYTICS.DODGE.FF_OUT_REP_PROJECT_CAPSULE AS PC
LEFT JOIN INBOUND.DODGE_CONSTRUCTION_VIEW.FF_OUT_REP_FIRM_RELATIONSHIP  AS FP
ON PC.DR_NBR = FP.DR_NBR
LEFT JOIN INBOUND.DODGE_CONSTRUCTION_VIEW.FF_OUT_COMPANY_CONTACTS AS CC
ON FP.DCIS_FACTOR_CODE = CC.DCIS_FACTOR_CODE
LEFT JOIN ES_WAREHOUSE.PUBLIC.STATES AS ST
ON CC.C_STATE_ID = ST.ABBREVIATION
WHERE PC.PROJ_TYPE NOT IN ('Sale/Spec Homes','Swimming Pool','Custom Homes','Unclassified')
    ;;
  }

  dimension: project {
    type: string
    sql: ${TABLE}.PROJECT ;;
  }

  dimension: firm_name {
    type: string
    sql: ${TABLE}.FIRM_NAME ;;
  }

  dimension: contact_name {
    type: string
    sql: ${TABLE}.CONTACT_NAME ;;
  }

  dimension: contact_title {
    type: string
    sql: ${TABLE}.CONTACT_TITLE ;;
  }

  dimension: city {
    type: string
    sql: ${TABLE}.CITY ;;
  }

  dimension: state {
    type: string
    sql: ${TABLE}.STATE ;;
  }

  dimension: firm_website {
    type: string
    sql: ${TABLE}.FIRM_WEBSITE ;;
  }

  dimension: address {
    type: string
    sql: ${TABLE}.ADDRESS ;;
    html:<font color="blue "><u><a href="https://www.google.com/maps/dir/?api=1&destination={{ address._value | url_encode }}+{{ city._value | url_encode }}+{{ state._value | url_encode }}+{{ zip_code._value | url_encode }}&travelmode=car" target="_blank">{{ address._value }}</a></font></u> ;;
  }



  dimension: email {
    type: string
    sql: ${TABLE}.EMAIL ;;
  }

  dimension: phone {
    type: string
    sql: ${TABLE}.PHONE ;;
  }

  dimension: zip_code {
    type: string
    sql: ${TABLE}.ZIP_CODE ;;
  }

  dimension: firm_market {
    type: string
    sql: case when ${msa.msa} is null and ${city} is null then ${state}
          when ${msa.msa} is null and ${state} is null then ${city}
          when ${msa.msa} is null then ${city}||', '||${state} else ${msa.msa} end ;;
  }

  dimension: existing_company_prospect {
    type: string
    html:
       {% if dodge_existing_company.existing_company.value == 1 %}
        <font color="blue "><u><a href = "https://equipmentshare.looker.com/dashboards/28?Company%20Name={{ firm_name._filterable_value | url_encode }}" target="_blank">{{ firm_name._value }}</a></font></u>
        {% else %}
         <font color="blue "><u><a href = "https://app.seekwell.io/form/f9da7270cbaa44a6a1bfc0e846232256?sales_representative_email_address={{  _user_attributes['email'] }}" target="_blank">Create Prospect</a></font></u>
      {% endif %} ;;
    sql: ${firm_name};;
  }

  dimension: existing_company_prospect_app {
    type: string
    html:
       {% if dodge_existing_company.existing_company.value == 1 %}
        <font color="blue "><u><a href = "https://equipmentshare.looker.com/dashboards/28?Company%20Name={{ firm_name._filterable_value | url_encode }}" target="_blank">{{ firm_name._value }}</a></font></u>
        {% else %}
         <font color="blue "><u><a href = "https://staging-ba.equipmentshare.com/crm/create_prospect_dodge?Firm%20Name={{  firm_name._value }}&Firm%20Website={{  firm_website._value }}&Contact%20Name={{  contact_name._value }}&Contact%20Title={{  contact_title._value }}&Phone={{  phone._value }}&Email={{  email._value }}&Address={{  address._value }}&Zip%20Code={{  zip_code._value }}&City={{  city._value }}&State={{  state._value }}" target="_blank">Create Prospect</a></font></u>
      {% endif %} ;;
    sql: ${firm_name};;
  }

  dimension: company_type {
    type: string
    sql: ${TABLE}.COMPANY_TYPE ;;
  }


  }
