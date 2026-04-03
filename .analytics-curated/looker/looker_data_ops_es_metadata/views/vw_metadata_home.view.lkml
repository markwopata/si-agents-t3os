view: vw_home {
  # # You can specify the table name if it's different from the view name:
  sql_table_name: NON_PROD_ES_METADATA.DATA_DICTIONARY.TBL_HOME ;;
  #
  # # Define your dimensions and measures here, like this:

  dimension: HOME_ID {
    type: number
    sql: ${TABLE}.HOME_ID ;;
  #  html: <h1>TO_STRING({{value}})</h1> ;;
  }
  dimension: HOME_ID_HTML_TEXT {
    type: string
#.   sql: ${TABLE}.HOME_ID ;;
    html:  <ul>
      <li> value:  </li>
      <li> rendered_value: </li>
      <li> linked_value: </li>
      <li> link: </li>
      <li> model: </li>
      <li> view: </li>
      <li> explore: </li>
      <li> field: </li>
      <li> dialect: </li>
      <li> access filter:  </li>
      <li> user attribute: </li>
      <li> query timezone: </li>
      <li> filters:  </li>
    </ul> ;;
  }
  dimension: HOME_HTML_TEXT {
    type: string
    sql:  ${TABLE}.HOME_HTML_TEXT ;;
  #  html: {{value}} ;;
  }

  dimension: BUSINESS_GLOSSARY_HTML_TEXT {
     type: string
     sql: ${TABLE}.BUSINESS_GLOSSARY_HTML_TEXT ;;
  }

}
