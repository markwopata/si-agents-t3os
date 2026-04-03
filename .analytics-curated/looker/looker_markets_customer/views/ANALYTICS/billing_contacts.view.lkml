# The name of this view in Looker is "Billing Contacts"
view: billing_contacts {
  # The sql_table_name parameter indicates the underlying database table
  # to be used for all fields in this view.
  sql_table_name: "ANALYTICS"."PUBLIC"."BILLING_CONTACTS" ;;

  # No primary key is defined for this view. In order to join this view in an Explore,
  # define primary_key: yes on a dimension that has no repeated values.

    # Here's what a typical dimension looks like in LookML.
    # A dimension is a groupable field that can be used to filter query results.
    # This dimension will be called "Billing Contact Type" in Explore.

  dimension: billing_contact_type {
    type: string
    sql: ${TABLE}."BILLING_CONTACT_TYPE" ;;
  }

  dimension: paperless_billing {
    type: yesno
    sql: ${TABLE}."PAPERLESS_BILLING" ;;
  }

  dimension: company_id {
    type: number
    sql: ${TABLE}."COMPANY_ID" ;;
  }

  dimension: contact_user_id {
    type: string
    sql: ${TABLE}."CONTACT_USER_ID" ;;
  }
  measure: count {
    type: count
    drill_fields: [companies.name, billing_contact_type, paperless_billing, users.email_address]
  }
}
