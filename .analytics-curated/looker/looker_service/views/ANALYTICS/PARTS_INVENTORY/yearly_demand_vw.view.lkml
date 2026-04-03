view: yearly_demand_vw {
  sql_table_name: "ANALYTICS"."PARTS_INVENTORY"."YEARLY_PARTS_DEMAND" ;;
#changing to the table, view takes too long to load and causes time out errors

  # dimension: part_description {
  #   type: string
  #   sql: ${TABLE}."PART_DESCRIPTION" ;;
  # }
  dimension: part_id {
    primary_key: yes
    type: number
    sql: ${TABLE}."PART_ID" ;;
  }
  # dimension: part_number {
  #   type: string
  #   sql: ${TABLE}."PART_NUMBER" ;;
  # }
  # dimension: provider {
  #   type: string
  #   sql: ${TABLE}."PROVIDER" ;;
  # }
  dimension: yearly_demand {
    type: number
    sql: ${TABLE}."YEARLY_DEMAND" ;;
  }
  dimension: procurement_filtered_yearly_demand {
    description: "Procurement provided an exclusion list for this calculation."
    hidden: yes
    type: number
    sql: ${TABLE}.procurement_filtered_yearly_demand ;;
  }
  dimension: top_ten_thousand_demand {
    type: yesno
    # sql: ${TABLE}."TOP_10K" ;;
    sql: iff(${row_num} <= 10000,true,false) ;;
  }
  dimension: procurement_top_ten_thousand_demand {
    description: "Top 10k items with Procurement eclusions removed."
    type: yesno
    # sql: ${TABLE}."TOP_10K" ;;
    sql: iff(${procurement_row_num} <= 10000,true,false) ;;
  }
  dimension: row_num {
    hidden: yes
    type: number
    sql: ${TABLE}.row_num ;;
  }
  dimension: procurement_row_num {
    hidden: yes
    type: number
    sql: ${TABLE}.procurement_row_num ;;
  }
  measure: count {
    type: count
  }
}
