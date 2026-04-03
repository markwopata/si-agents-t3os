connection: "es_snowflake"

include: "/views/*.view.lkml"                # include all views in the views/ folder in this project

explore: invoices {
  join: invoice_erp_refs {
    type:  full_outer
    relationship: one_to_one
    sql_on: ${invoice_erp_refs.invoice_id} = ${invoices.invoice_id} ;;
  }
}

explore: credit_notes {
  join: credit_note_erp_refs {
    type:  full_outer
    relationship: one_to_one
    sql_on: ${credit_note_erp_refs.credit_note_id} = ${credit_notes.credit_note_id} ;;
  }
}


explore: payments {
  join: payment_erp_refs {
    type:  full_outer
    relationship: one_to_one
    sql_on: ${payment_erp_refs.payment_id} = ${payments.payment_id} ;;
  }
}

explore: payment_applications {
  join: payment_application_erp_refs {
    type:  full_outer
    relationship: one_to_one
    sql_on: ${payment_application_erp_refs.payment_application_id} = ${payment_applications.payment_application_id} ;;
  }
  join: payments {
    relationship: one_to_one
    sql_on: ${payment_applications.payment_id} = ${payments.payment_id} ;;
  }
}

explore: credit_note_allocations {
  join: credit_note_allocation_erp_refs {
    type:  full_outer
    relationship: one_to_one
    sql_on: ${credit_note_allocation_erp_refs.credit_note_allocation_id} = ${credit_note_allocations.credit_note_allocation_id} ;;
  }
  join: credit_notes {
    relationship: one_to_one
    sql_on: ${credit_note_allocations.credit_note_id} = ${credit_notes.credit_note_id} ;;
  }
}

explore: event {

}
