view: existing_companies_folders {

  derived_table: {
    sql:
      select FOLDER_NAME AS FOLDER_NAME, COMPANY_ID AS COMPANY_ID,COMPANY_NAME AS COMPANY_NAME,FOLDER_ID AS FOLDER_ID,FOLDER_URL AS FOLDER_URL
      from analytics.WEBAPPS.CRM__EXISTING__COMPANIES__MAPPING__V4
      where {% condition customer_name %} REPLACE(trim(analytics.WEBAPPS.CRM__EXISTING__COMPANIES__MAPPING__V4.COMPANY_NAME),CHAR(9), '') {% endcondition %}
    ;;
  }

  dimension: folder_name {
    type:string
    sql: ${TABLE}.FOLDER_NAME ;;
  }

  dimension: company_id {
    type: number
    sql: ${TABLE}.COMPANY_ID ;;
  }

  dimension: company_name {
    type: string
    sql: REPLACE(trim(${TABLE}.COMPANY_NAME),CHAR(9), '') ;;
  }

  dimension: folder_id {
    type: string
    sql: ${TABLE}.FOLDER_ID ;;
  }

  dimension: folder_url {
    type: string
    sql: ${TABLE}.FOLDER_URL ;;
  }

  dimension: folder_url_link {
    type: string
    sql: ${TABLE}.FOLDER_URL ;;
    html:<font color="blue "><u><a href="{{ folder_url._value }}" target="_blank">Link to Drive Folder</a></font></u> ;;
  }

  filter: customer_name {
    type: string
  }


  }
