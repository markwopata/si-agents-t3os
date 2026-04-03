view: cc_strikes {
  sql_table_name: "PUBLIC"."CC_STRIKES"
    ;;

  dimension: card_type {
    type: string
    sql: ${TABLE}."CARD_TYPE" ;;
  }

  dimension: corporate_account_name {
    type: string
    sql: ${TABLE}."CORPORATE_ACCOUNT_NAME" ;;
  }

  dimension: days_until_shutoff {
    type: number
    sql: ${TABLE}."DAYS_UNTIL_SHUTOFF" ;;
  }

  dimension: email_address {
    type: string
    sql: ${TABLE}."EMAIL_ADDRESS" ;;
  }

  dimension: employee_id {
    type: number
    sql: ${TABLE}."EMPLOYEE_ID" ;;
  }

  dimension: full_name {
    type: string
    sql: ${TABLE}."FULL_NAME" ;;
  }

  dimension: shutoff_date {
    type: string
    sql: ${TABLE}."SHUTOFF_DATE" ;;
  }


  dimension: total_receipts_not_received {
    type: number
    sql: ${TABLE}."TOTAL_RECEIPTS_NOT_RECEIVED" ;;
  }

  dimension: transaction_date {
    type: string
    sql: ${TABLE}."TRANSACTION_DATE" ;;
  }

  dimension: user_full_name {
    type: string
    sql: ${TABLE}."USER_FULL_NAME" ;;
  }

  dimension: shutoff_date_formatted {
    type: string
    sql: to_varchar(${shutoff_date}::date, 'mon dd, yyyy') ;;
  }

  dimension: card_information{
    type: string
    sql: ${card_type} ;;
    html:
    <b>Cardholder:</b><br /> <font color="#000000">
          {{users.full_name._rendered_value}}
          </font> <br />
    <b>Card Type:</b><br /> {{card_type._rendered_value}} <br />
    <b> # of Unverified Transactions (Credit Card Only):</b><br /> {{transaction_verification.unverified_count._rendered_value}}<br />
    ;;
  }

  dimension: shutoff_information{
    type: string
    sql: ${shutoff_date} ;;
    html:
    {% if days_until_shutoff._value < 0  %}
    <b>Shutoff Date:</b><br /> <b><font color="#B32F37">{{shutoff_date_formatted._rendered_value}}</font> <br />
    <b>Days Since Shutoff:</b><br /> <font color="#B32F37"><b>{{days_until_shutoff._rendered_value}} days </font></b><br />
    {% elsif days_until_shutoff._value < 3 %}
    <b>Shutoff Date:</b><br /> <b><font color="#B32F37">{{shutoff_date_formatted._rendered_value}}</font> <br />
    <b>Days Until Shutoff:</b><br /> <font color="#B32F37"><b>{{days_until_shutoff._rendered_value}} days </font></b><br />
    {% elsif days_until_shutoff._value == null %}
    <b>Shutoff Date:</b><br /> <b><font color="#0063f3">{{shutoff_date_formatted._rendered_value}}</font> <br />
    <b>Days Until Shutoff:</b><br /> <font color="#0063f3">{{days_until_shutoff._rendered_value}} days</font><br />
    {% else %}
    <b>Shutoff Date:</b><br /> <b><font color="#e6771f">{{shutoff_date_formatted._rendered_value}}</font> <br />
    <b>Days Until Shutoff:</b><br /> <b><font color="#e6771f">{{days_until_shutoff._rendered_value}} days</font></b><br />
    {% endif %}
    ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  set: detail {
    fields: [full_name, employee_id, transaction_date, shutoff_date, days_until_shutoff]
  }
}
