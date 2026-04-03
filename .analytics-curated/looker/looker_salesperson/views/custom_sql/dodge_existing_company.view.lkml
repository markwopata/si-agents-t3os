view: dodge_existing_company {

  derived_table: {
    sql:
       WITH ES_DODGE_JOIN AS (
SELECT  LOWER(regexp_replace(C.NAME, '[^a-zA-Z0-9]+', ''))||L.ZIP_CODE AS ES_COMPANY_ZIP,
LOWER(regexp_replace(DC.FIRM_NAME, '[^a-zA-Z0-9]+', ''))||SUBSTRING(DC.C_ZIP_CODE,0,5) AS DODGE_COMPANY_ZIP
FROM  ES_WAREHOUSE."PUBLIC".COMPANIES AS C
LEFT JOIN ES_WAREHOUSE."PUBLIC".LOCATIONS AS L
ON C.BILLING_LOCATION_ID = L.LOCATION_ID
INNER JOIN ANALYTICS.DODGE.FF_OUT_COMPANY AS DC
ON LOWER(regexp_replace(C.NAME, '[^a-zA-Z0-9]+', ''))||L.ZIP_CODE =
LOWER(regexp_replace(DC.FIRM_NAME, '[^a-zA-Z0-9]+', ''))||SUBSTRING(DC.C_ZIP_CODE,0,5)
)
SELECT DISTINCT *, 1 AS EXISTING_COMPANY FROM ES_DODGE_JOIN
    ;;
  }

  dimension: es_company_zip {
    type: string
    sql: ${TABLE}.ES_COMPANY_ZIP ;;
  }

  dimension: dodge_company_zip {
    type: string
    sql: ${TABLE}.DODGE_COMPANY_ZIP ;;
  }

  dimension: existing_company {
    type: number
    sql: ${TABLE}.EXISTING_COMPANY ;;
  }


  dimension: existing_company_prospect {
    type: string
    html:
       {% if existing_company._value == 1 %}
        <font color="blue "><u><a href = "https://equipmentshare.looker.com/dashboards/28?Company%20Name={{ dodge_contacts.firm_name._filterable_value | url_encode }}" target="_blank">{{ dodge_contacts.firm_name._value }}</a></font></u>
        {% else %}
         <font color="blue "><u><a href = "https://app.seekwell.io/form/f9da7270cbaa44a6a1bfc0e846232256?&company_name={{dodge_contacts.firm_name._value }}&company_url={{dodge_contacts.firm_website._value }}&contact_name_1={{dodge_contacts.contact_name._value }}&contact_type_1={{dodge_contacts.contact_title._value }}&contact_phone_number_1={{dodge_contacts.phone._value }}&contact_email_address_1={{dodge_contacts.email._value }}&street_address_1={{dodge_contacts.address._value }}&zip_code={{dodge_contacts.zip_code._value }}&sales_representative_email_address={{  _user_attributes['email'] }}" target="_blank">Create Prospect</a></font></u>
      {% endif %} ;;
    sql: ${dodge_contacts.firm_name};;
  }

  }
