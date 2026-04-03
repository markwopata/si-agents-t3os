 view: detailed_part_view {
  derived_table: {
    sql:

select p.part_id
     , part.ITEM_ID -- necessary for PO matching
     , p.part_key
     , p.PART_MASTER_KEY
     , p.PART_PROVIDER_ID
     , p.PART_PROVIDER_NAME
     , p.PART_NUMBER
     , p.PART_NAME as description
     , p.part_search
     , p.PART_ARCHIVED
     , p.PART_MSRP
     , p.part_reporting_category
     , pa.PART_CATEGORIZATION_ID
     , pcs.CATEGORY
     , pcs.SUBCATEGORY
     , pcs.PART_CONTAINERS
     , pa.has_reman_option
     --, coalesce(yd.YEARLY_DEMAND, 0) as cw_yearly_demand
     , coalesce(ps.PART_FAMILY_ID, psx.PART_FAMILY_ID) as family_id
     , concat(p.part_number, ', ', listagg(coalesce(ps.sub_part_number, psx.part_number), ', ')) as sub_match
from FLEET_OPTIMIZATION.GOLD.DIM_PARTS_FLEET_OPT p
         join ES_WAREHOUSE.INVENTORY.PARTS part on p.PART_ID = part.PART_ID -- required for item_id
         left join ANALYTICS.PARTS_INVENTORY.PARTS_ATTRIBUTES pa on p.PART_ID = pa.part_id
                      and END_DATE = '2999-01-01' -- TB 12.10.25 Filtering join to rows with open end date to avoid duplicates
         left join ANALYTICS.PARTS_INVENTORY.PART_CATEGORIZATION_STRUCTURE pcs on pa.part_categorization_id = pcs.part_categorization_id
        -- left join ANALYTICS.PARTS_INVENTORY.YEARLY_DEMAND_VW yd on p.PART_ID = yd.PART_ID
        --taking yearly demand out of here because there is a separate view file for a table that can be joined in the explore if needed. referencing the snowflake view is causing timeout errors HL2.25.26
         left join ANALYTICS.PARTS_INVENTORY.PART_SUBSTITUTES ps on p.PART_ID = ps.PART_ID -- part_family_id groups them together
         left join ANALYTICS.PARTS_INVENTORY.PART_SUBSTITUTES psx on p.part_id = psx.SUB_PART_ID
where p.PART_INTERNAL_USE
group by 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18
;;
  }

  dimension: part_id {
    type: number
    value_format_name: id
    sql: ${TABLE}.part_id ;;
  }

  dimension: item_id {
    type: number
    value_format_name: id
    sql: ${TABLE}.item_id ;;
  }

  dimension: part_key {
    type: string
    sql: ${TABLE}.part_key ;;
  }

  dimension: part_master_key {
    type: string
    sql: ${TABLE}.part_master_key ;;
  }

  dimension: provider_id {
    type: number
    value_format_name: id
    sql: ${TABLE}.part_provider_id ;;
  }

  dimension: provider_name {
    type: string
    sql: ${TABLE}.part_provider_name ;;
  }

  dimension: part_number {
    type: string
    sql: ${TABLE}.part_number ;;
  }

  dimension: description {
    type: string
    sql: ${TABLE}.description ;;
  }

  dimension: part_search {
    type: string
    sql: ${TABLE}.part_search ;;
  }

  dimension: part_archived {
    type: yesno
    sql: ${TABLE}.part_archived ;;
  }

  dimension: msrp {
    type: number
    value_format_name: usd
    sql: ${TABLE}.part_msrp ;;
  }

  dimension: category_id {
    type: number
    value_format_name: id
    sql: ${TABLE}.part_categorization_id ;;
  }

  dimension: category {
    type: string
    sql: ${TABLE}.category ;;
  }

  dimension: subcategory {
    type: string
    sql: ${TABLE}.subcategory ;;
  }

  dimension: part_containers {
    type: string
    sql: ${TABLE}.part_containers ;;
  }

  # dimension: yearly_demand { #taking yearly demand out of here because there is a separate view file that can be joined in the explore if needed
  #   type: number
  #   sql: ${TABLE}.cw_yearly_demand ;;
  # }

  dimension: part_family_id {
    type: number
    value_format_name: id
    sql: ${TABLE}.family_id ;;
  }

  dimension: sub_match {
    type: string
    sql: ${TABLE}.sub_match ;;
  }

  dimension: part_reporting_category {
    type: string
    sql: ${TABLE}.part_reporting_category ;;
  }

  dimension: has_reman_option {
    type: yesno
    sql: ${TABLE}.has_reman_option ;;
  }

 }
