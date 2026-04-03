view: tam_flag_list {

  derived_table: {
    sql:

    select o.ID as order_id
    from analytics.shopify."ORDER" o
    join analytics.PARTS_INVENTORY.shopify_ops_tam_assignment tam
          on o.COMPANY_LOCATION_ID = tam.shopify_company_location_id
    where tam.onboarding_date <= o.created_at::date
      ;;
  }

  dimension: order_id {
    primary_key: yes
    type: number
    value_format_name: id
    sql: ${TABLE}."ORDER_ID" ;;
  }

  dimension: tam_order {
    type: yesno
    sql: ${order_id} is not null ;;
  }

}
