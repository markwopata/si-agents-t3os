view: int_credit_card__citi_fuel_cardholder_status {
  sql_table_name: "CREDIT_CARD"."INT_CREDIT_CARD__CITI_FUEL_CARDHOLDER_STATUS" ;;

  dimension: card_type {
    type: string
    sql: ${TABLE}."CARD_TYPE" ;;
  }
  dimension: corporate_account_name {
    type: string
    sql: ${TABLE}."CORPORATE_ACCOUNT_NAME" ;;
  }
  dimension: corporate_account_number {
    type: string
    sql: ${TABLE}."CORPORATE_ACCOUNT_NUMBER" ;;
  }
  dimension: employee_id {
    type: number
    sql: ${TABLE}."EMPLOYEE_ID" ;;
  }
  dimension: full_name {
    type: string
    sql: ${TABLE}."FULL_NAME" ;;
  }
  dimension: is_card_open {
    type: yesno
    sql: ${TABLE}."IS_CARD_OPEN" ;;
  }

  dimension: card_status_description {
    type: string
    sql: ${TABLE}."CARD_STATUS_DESCRIPTION" ;;
  }

  dimension: card_status_description_modified {
    type: string
    sql:
        case
          when ${card_status_description} != 'Closed Temporary Block' and ${is_card_open} = False then 'Closed'
          when ${is_card_open} = True and ${card_status_description} != 'Card Activation Required' then 'Open'
        else ${card_status_description}
        end ;;
  }

  dimension: is_travel_card {
    type: yesno
    sql: ${TABLE}."IS_TRAVEL_CARD" ;;
  }

  dimension: account_open_or_closed_date {
    type: date
    sql: ${TABLE}."ACCOUNT_OPEN_OR_CLOSED_DATE" ;;
  }

  measure: count {
    type: count
    drill_fields: [full_name, corporate_account_name]
  }
}
