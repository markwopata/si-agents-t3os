view: new_vendor_setup {
  derived_table: {
    sql:
    SELECT
    NVS.*,
    INITCAP(REPLACE(SPLIT_PART(NVS.REQUESTOR_EMAIL_ADDRESS, '@', 1), '.', ' ')) AS REQUESTOR_NAME
    FROM ANALYTICS.FINANCIAL_SYSTEMS.NEW_VENDOR_SETUP NVS
        ;;
  }


    dimension: _ROW {
      type: number
      sql: ${TABLE}._ROW;;
    }

    dimension: _FIVETRAN_SYNCED {
      type: date_time
      sql: ${TABLE}._FIVETRAN_SYNCED;;
    }

    dimension: WILL_THIS_VENDOR_EVER_BE_PERFORMING_ANY_SERVICE_OR_MAINTENANCE_ON_ANY_EQUIPMENT_SHARE_ASSETS_NOT_LOCATED_AT_AN_EQUIPMENT_SHARE_SITE_OR_LOCATION {
      type: string
      sql: ${TABLE}.WILL_THIS_VENDOR_EVER_BE_PERFORMING_ANY_SERVICE_OR_MAINTENANCE_ON_ANY_EQUIPMENT_SHARE_ASSETS_NOT_LOCATED_AT_AN_EQUIPMENT_SHARE_SITE_OR_LOCATION;;
    }

    dimension: VENDOR_NAME {
      type: string
      sql: ${TABLE}.VENDOR_COMPANY_NAME;;
    }

    dimension: REQUESTOR_NAME {
      type: string
      sql: ${TABLE}.REQUESTOR_NAME;;
    }

    dimension: REQUEST_DATE {
      type: date_time
      sql: TRY_TO_TIMESTAMP(${TABLE}.TIMESTAMP);;
    }

    dimension: VENDOR_CONTACT_S_PHONE_NUMBER {
      type: string
      sql: ${TABLE}.VENDOR_CONTACT_S_PHONE_NUMBER;;
    }

    dimension: IS_THIS_VENDOR_A_TRANSPORTATION_COMPANY_OR_EQUIPMENT_HAULER_ {
      type: string
      sql: ${TABLE}.IS_THIS_VENDOR_A_TRANSPORTATION_COMPANY_OR_EQUIPMENT_HAULER_;;
    }

    dimension: HAVE_YOU_LOOKED_AT_THE_PREFERRED_VENDORS_ON_THE_PROCUREMENT_PAGE_OF_ES_OPS_FIRST_TO_MAKE_SURE_ONE_OF_THEM_CANNOT_MEET_YOUR_NEEDS_IF_NOT_PLEASE_LOOK_AT_THE_PREFERRED_VENDORS_FIRST_BEFORE_PROCEEDING_ {
      type: string
      sql: ${TABLE}.HAVE_YOU_LOOKED_AT_THE_PREFERRED_VENDORS_ON_THE_PROCUREMENT_PAGE_OF_ES_OPS_FIRST_TO_MAKE_SURE_ONE_OF_THEM_CANNOT_MEET_YOUR_NEEDS_IF_NOT_PLEASE_LOOK_AT_THE_PREFERRED_VENDORS_FIRST_BEFORE_PROCEEDING_;;
    }

    dimension: VENDOR_CONTACT_S_EMAIL {
      type: string
      sql: ${TABLE}.VENDOR_CONTACT_S_EMAIL;;
    }

    dimension: PLEASE_EXPLAIN_THE_SPECIFIC_PRODUCT_OR_SERVICE_THIS_VENDOR_WILL_PROVIDE_BE_AS_DETAILED_AS_POSSIBLE_AND_WHY_AN_EXISTING_VENDOR_IF_AVAILABLE_CANNOT_MEET_YOUR_REQUIREMENTS_ {
      type: string
      sql: ${TABLE}.PLEASE_EXPLAIN_THE_SPECIFIC_PRODUCT_OR_SERVICE_THIS_VENDOR_WILL_PROVIDE_BE_AS_DETAILED_AS_POSSIBLE_AND_WHY_AN_EXISTING_VENDOR_IF_AVAILABLE_CANNOT_MEET_YOUR_REQUIREMENTS_;;
    }

    dimension: IF_REQUESTING_A_LINE_OF_CREDIT_WITH_THIS_VENDOR_WHAT_IS_THE_ESTIMATED_AMOUNT_NEEDED_ {
      type: string
      sql: ${TABLE}.IF_REQUESTING_A_LINE_OF_CREDIT_WITH_THIS_VENDOR_WHAT_IS_THE_ESTIMATED_AMOUNT_NEEDED_;;
    }

    dimension: WHAT_IS_YOUR_ESTIMATED_MONTHLY_SPEND_FOR_A_ONE_TIME_EXPENSE_PLEASE_ALSO_INCLUDE_YOUR_BEST_ESTIMATE_OF_SPEND_ {
      type: number
      sql: ${TABLE}.WHAT_IS_YOUR_ESTIMATED_MONTHLY_SPEND_FOR_A_ONE_TIME_EXPENSE_PLEASE_ALSO_INCLUDE_YOUR_BEST_ESTIMATE_OF_SPEND_;;
    }

    dimension: HAS_THE_WORK_BEEN_COMPLETED_ {
      type: string
      sql: ${TABLE}.HAS_THE_WORK_BEEN_COMPLETED_;;
    }

    dimension: PLEASE_ENTER_YOUR_MARKET_NAME_BRANCH_NAME_AS_LISTED_IN_THE_COMPANY_DIRECTORY_ {
      type: string
      sql: ${TABLE}.PLEASE_ENTER_YOUR_MARKET_NAME_BRANCH_NAME_AS_LISTED_IN_THE_COMPANY_DIRECTORY_;;
    }

    dimension: DID_THE_VENDOR_PROVIDE_YOU_WITH_A_CREDIT_APP_W_9_COI_OR_SERVICE_AGREEMENT_IF_SO_PLEASE_ATTACH_IT_HERE_ {
      type: string
      sql: ${TABLE}.DID_THE_VENDOR_PROVIDE_YOU_WITH_A_CREDIT_APP_W_9_COI_OR_SERVICE_AGREEMENT_IF_SO_PLEASE_ATTACH_IT_HERE_;;
    }

    dimension: VENDOR_CATEGORY {
      type: string
      sql: ${TABLE}.VENDOR_CATEGORY;;
    }

    dimension: IF_YOU_SELECTED_EQUIPMENT_ATTACHMENT_TRUCKS_TRAILERS_FLEET_AS_YOUR_CATEGORY_PICK_ONE_BELOW {
      type: string
      sql: ${TABLE}.IF_YOU_SELECTED_EQUIPMENT_ATTACHMENT_TRUCKS_TRAILERS_FLEET_AS_YOUR_CATEGORY_PICK_ONE_BELOW;;
    }

    dimension: WILL_YOU_CONTINUE_TO_USE_THIS_VENDOR_IN_THE_FUTURE_OR_IS_THIS_A_ONE_TIME_USE_ {
      type: string
      sql: ${TABLE}.WILL_YOU_CONTINUE_TO_USE_THIS_VENDOR_IN_THE_FUTURE_OR_IS_THIS_A_ONE_TIME_USE_;;
    }

    dimension: VENDOR_CONTACT_S_ADDRESS_REQUIRED_FOR_A_BACKGROUND_CHECK_STREET_ADDRESS_CITY_STATE_ZIP_ {
      type: string
      sql: ${TABLE}.VENDOR_CONTACT_S_ADDRESS_REQUIRED_FOR_A_BACKGROUND_CHECK_STREET_ADDRESS_CITY_STATE_ZIP_;;
    }

    dimension: VENDOR_CONTACT_S_NAME_FIRST_LAST_ {
      type: string
      sql: ${TABLE}.VENDOR_CONTACT_S_NAME_FIRST_LAST_;;
    }

    dimension: DOES_THIS_VENDOR_QUALIFY_AS_A_POTENTIAL_CANDIDATE_FOR_CREDIT_CARD_PAYMENTS_PLEASE_REVIEW_THE_PURCHASING_GUIDELINES_ON_THE_PROCUREMENT_PAGE_ {
      type: string
      sql: ${TABLE}.DOES_THIS_VENDOR_QUALIFY_AS_A_POTENTIAL_CANDIDATE_FOR_CREDIT_CARD_PAYMENTS_PLEASE_REVIEW_THE_PURCHASING_GUIDELINES_ON_THE_PROCUREMENT_PAGE_;;
    }

    dimension: IS_THIS_A_RE_RENTAL_ {
      type: string
      sql: ${TABLE}.IS_THIS_A_RE_RENTAL_;;
    }

    dimension: WILL_THIS_VENDOR_BE_PERFORMING_OR_DELIVERING_AT_ANY_EQUIPMENT_SHARE_SITES_OR_LOCATIONS_ {
      type: string
      sql: ${TABLE}.WILL_THIS_VENDOR_BE_PERFORMING_OR_DELIVERING_AT_ANY_EQUIPMENT_SHARE_SITES_OR_LOCATIONS_;;
    }

    dimension: EMAIL_ADDRESS {
      type: string
      sql: ${TABLE}.EMAIL_ADDRESS;;
    }

  dimension: IS_URGENT {
    type: string
    sql: ${TABLE}.IS_URGENT;;
  }

  dimension: URGENCY_REASON {
    type: string
    sql: ${TABLE}.URGENCY_REASON;;
  }

  measure: REQUEST_COUNT {
    type: count_distinct
    sql: ${TABLE}._ROW;;
    description: "Count of distinct new vendor requests"
  }

  # # You can specify the table name if it's different from the view name:
  # sql_table_name: my_schema_name.tester ;;
  #
  # # Define your dimensions and measures here, like this:
  # dimension: user_id {
  #   description: "Unique ID for each user that has ordered"
  #   type: number
  #   sql: ${TABLE}.user_id ;;
  # }
  #
  # dimension: lifetime_orders {
  #   description: "The total number of orders for each user"
  #   type: number
  #   sql: ${TABLE}.lifetime_orders ;;
  # }
  #
  # dimension_group: most_recent_purchase {
  #   description: "The date when each user last ordered"
  #   type: time
  #   timeframes: [date, week, month, year]
  #   sql: ${TABLE}.most_recent_purchase_at ;;
  # }
  #
  # measure: total_lifetime_orders {
  #   description: "Use this for counting lifetime orders across many users"
  #   type: sum
  #   sql: ${lifetime_orders} ;;
  # }
}

# view: aprecord_time_difference {
#   # Or, you could make this view a derived table, like this:
#   derived_table: {
#     sql: SELECT
#         user_id as user_id
#         , COUNT(*) as lifetime_orders
#         , MAX(orders.created_at) as most_recent_purchase_at
#       FROM orders
#       GROUP BY user_id
#       ;;
#   }
#
#   # Define your dimensions and measures here, like this:
#   dimension: user_id {
#     description: "Unique ID for each user that has ordered"
#     type: number
#     sql: ${TABLE}.user_id ;;
#   }
#
#   dimension: lifetime_orders {
#     description: "The total number of orders for each user"
#     type: number
#     sql: ${TABLE}.lifetime_orders ;;
#   }
#
#   dimension_group: most_recent_purchase {
#     description: "The date when each user last ordered"
#     type: time
#     timeframes: [date, week, month, year]
#     sql: ${TABLE}.most_recent_purchase_at ;;
#   }
#
#   measure: total_lifetime_orders {
#     description: "Use this for counting lifetime orders across many users"
#     type: sum
#     sql: ${lifetime_orders} ;;
#   }
# }
