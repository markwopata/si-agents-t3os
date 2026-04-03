view: error_invoices_credit_notes {
  derived_table: {
    sql: select ORIGINATING_INVOICE_ID
                           from ES_WAREHOUSE.PUBLIC.CREDIT_NOTES
                           where memo ilike '%incorrect vendor%id%'
                              or memo ilike '%generated in error%'
                              or memo ilike '%wrong location%'
                              or memo ilike '%wrong branch%'
                              or memo ilike '%duplicate invoice%' ;;
  }

  dimension: originating_invoice_id {
    type: number
    primary_key: yes
    value_format_name: id
    sql: ${TABLE}.originating_invoice_id ;;
  }
}
