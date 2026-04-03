view: integrations_vic_t3__po_line_check {
  sql_table_name: "INTEGRATIONS_GOLD"."INTEGRATIONS_VIC_T3__PO_LINE_CHECK" ;;

  dimension: pk_po_line_id {
    type: string
    primary_key: yes
    sql: ${TABLE}."PK_PO_LINE_ID" ;;
  }

  dimension: fk_po_header_id {
    type: string
    sql: ${TABLE}."FK_PO_HEADER_ID" ;;
  }

  dimension: po_number {
    type: string
    sql: ${TABLE}."PO_NUMBER" ;;
  }

  dimension: matching_type {
    type: string
    sql: ${TABLE}."MATCHING_TYPE" ;;
  }

  dimension: effective_branch_id {
    type: number
    sql: ${TABLE}."EFFECTIVE_BRANCH_ID" ;;
  }

  dimension: is_line_blocked {
    type: yesno
    sql: ${TABLE}."IS_LINE_BLOCKED" ;;
    html:
      {% if value == 'Yes' %}
        <span style="background-color:yellow; color:black; padding:3px;">Yes</span>
      {% else %}
        No
      {% endif %}
    ;;
  }

  dimension: is_line_alerted {
    type: yesno
    sql: ${TABLE}."IS_LINE_ALERTED" ;;
    html:
      {% if value == 'Yes' %}
        <span style="background-color:yellow; color:black; padding:3px;">Yes</span>
      {% else %}
        No
      {% endif %}
    ;;
  }

  dimension: is_null_po_number {
    type: yesno
    sql: ${TABLE}."IS_NULL_PO_NUMBER" ;;
    html:
      {% if value == 'Yes' %}
        <span style="background-color:yellow; color:black; padding:3px;">Yes</span>
      {% else %}
        No
      {% endif %}
    ;;
  }

  dimension: is_invalid_qty_ordered {
    type: yesno
    sql: ${TABLE}."IS_INVALID_QTY_ORDERED" ;;
    html:
      {% if value == 'Yes' %}
        <span style="background-color:yellow; color:black; padding:3px;">Yes</span>
      {% else %}
        No
      {% endif %}
    ;;
  }

  dimension: is_invalid_ppu {
    type: yesno
    sql: ${TABLE}."IS_INVALID_PPU" ;;
    html:
      {% if value == 'Yes' %}
        <span style="background-color:yellow; color:black; padding:3px;">Yes</span>
      {% else %}
        No
      {% endif %}
    ;;
  }

  dimension: is_null_sage_item_id {
    type: yesno
    sql: ${TABLE}."IS_NULL_SAGE_ITEM_ID" ;;
    html:
      {% if value == 'Yes' %}
        <span style="background-color:yellow; color:black; padding:3px;">Yes</span>
      {% else %}
        No
      {% endif %}
    ;;
  }

  dimension: is_archived_line {
    type: yesno
    sql: ${TABLE}."IS_ARCHIVED_LINE" ;;
    html:
      {% if value == 'Yes' %}
        <span style="background-color:yellow; color:black; padding:3px;">Yes</span>
      {% else %}
        No
      {% endif %}
    ;;
  }

  dimension: is_null_effective_branch_id {
    type: yesno
    sql: ${TABLE}."IS_NULL_EFFECTIVE_BRANCH_ID" ;;
    html:
      {% if value == 'Yes' %}
        <span style="background-color:yellow; color:black; padding:3px;">Yes</span>
      {% else %}
        No
      {% endif %}
    ;;
  }

  dimension: is_unmapped_intacct_department_id {
    type: yesno
    sql: ${TABLE}."IS_UNMAPPED_INTACCT_DEPARTMENT_ID" ;;
    html:
      {% if value == 'Yes' %}
        <span style="background-color:yellow; color:black; padding:3px;">Yes</span>
      {% else %}
        No
      {% endif %}
    ;;
  }

  dimension: is_effective_branch_not_yet_migrated_to_vic {
    type: yesno
    sql: ${TABLE}."IS_EFFECTIVE_BRANCH_NOT_YET_MIGRATED_TO_VIC" ;;
    html:
      {% if value == 'Yes' %}
        <span style="background-color:yellow; color:black; padding:3px;">Yes</span>
      {% else %}
        No
      {% endif %}
    ;;
  }

  dimension: is_stale_po_date_compared_to_effective_branch_migration {
    type: yesno
    sql: ${TABLE}."IS_STALE_PO_DATE_COMPARED_TO_EFFECTIVE_BRANCH_MIGRATION" ;;
    html:
      {% if value == 'Yes' %}
        <span style="background-color:yellow; color:black; padding:3px;">Yes</span>
      {% else %}
        No
      {% endif %}
    ;;
  }

  dimension: is_po_already_converted_in_intacct {
    type: yesno
    sql: ${TABLE}."IS_PO_ALREADY_CONVERTED_IN_INTACCT" ;;
    html:
      {% if value == 'Yes' %}
        <span style="background-color:yellow; color:black; padding:3px;">Yes</span>
      {% else %}
        No
      {% endif %}
    ;;
  }

  dimension: is_qty_rejected_likely_wrong {
    type: yesno
    sql: ${TABLE}."IS_QTY_REJECTED_LIKELY_WRONG" ;;
    html:
      {% if value == 'Yes' %}
        <span style="background-color:yellow; color:black; padding:3px;">Yes</span>
      {% else %}
        No
      {% endif %}
    ;;
  }

  measure: count {
    type: count
  }
}
