view: part_suppression_categories {
  derived_table: {
    sql: select p.PART_ID
             , case
                 when tpi.PART_ID is not null then 'telematics'
                 when apl.PART_ID is not null then 'attachment'
                 when p.PART_PROVIDER_NAME ilike 'bulk -%' then 'bulk'
                else null
                end as suppression_group
        from platform.GOLD.DIM_PARTS p
        left join ANALYTICS.PARTS_INVENTORY.TELEMATICS_PART_IDS tpi on p.PART_ID = tpi.PART_ID
        left join ANALYTICS.PARTS_INVENTORY.ATTACHMENT_PARTS_LIST apl on p.PART_ID = apl.PART_ID
       ;;
  }

  dimension: part_id {
    primary_key: yes
    type: number
    value_format_name: id
    sql: ${TABLE}.part_id ;;
  }

  dimension: suppression_group {
    type: string
    sql: coalesce(${TABLE}.suppression_group,'none') ;;
  }
}
