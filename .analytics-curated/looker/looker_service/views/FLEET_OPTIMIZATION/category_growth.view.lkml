view: category_growth {
  derived_table: {
    sql:
      with fleet_category_growth as (
          select
              da.asset_id,
              da.asset_purchase_date,
              da.ASSET_EQUIPMENT_CATEGORY_NAME,
              round(sum(da.ASSET_CURRENT_OEC),2) as oec,
              count(da.ASSET_ID) as asset_count
          from FLEET_OPTIMIZATION.GOLD.DIM_ASSETS_FLEET_OPT as da
          -- where VENDORID is null
          group by 1,2,3
          order by oec desc
      )
      , vendor_category_growth as (
          select
              da.asset_id,
              da.asset_purchase_date,
              da.ASSET_EQUIPMENT_CATEGORY_NAME,
              iff(vendorid is null,'unknown',VENDOR_NAME) as don_vendor,
              v.vendorid,
              v.vendor_name,
              v.MAPPED_VENDOR_NAME,
              v.preferred,
              v.category,
              v.vendor_type,
              v.sage_vendor_category,
              round(sum(da.ASSET_CURRENT_OEC),2) as oec,
              count(da.ASSET_ID) as asset_count
          from FLEET_OPTIMIZATION.GOLD.DIM_ASSETS_FLEET_OPT as da
          left join ES_WAREHOUSE.PUBLIC.ASSETS_AGGREGATE as aa
              on aa.asset_id = da.asset_id
          left join (
                      select tvm.vendorid
                           , tvm.vendor_name
                           , tvm.mapped_vendor_name
                           , tvm.preferred
                           , tvm.category
                           , tvm.vendor_type
                           , v.vendor_category as sage_vendor_category
                           , iff(tvm.mapped_vendor_name <> 'Doosan / Bobcat', tvm.mapped_vendor_name, 'DOOSAN') as join1
                           , iff(join1 = 'DOOSAN', 'BOBCAT', null) as join2
                      from ANALYTICS.PARTS_INVENTORY.TOP_VENDOR_MAPPING as tvm
                      join ANALYTICS.INTACCT.VENDOR v
                        on v.vendorid = tvm.vendorid
                      where tvm.primary_vendor ilike 'yes') as v
            on upper(join1) = aa.make or upper(join2) = aa.make
          -- where VENDORID is null
          group by 1,2,3,4,5,6,7,8,9,10,11
          order by oec desc
      )

      , vendor_category_filtered AS (
      SELECT *
      FROM vendor_category_growth
      WHERE 1=1
      {% if _filters['vendor_id_filter'] %} AND vendorid = {% parameter vendor_id_filter %} {% endif %}
      {% if _filters['vendor_name_filter'] %} AND vendor_name = {% parameter vendor_name_filter %} {% endif %}
      {% if _filters['mapped_vendor_name_filter'] %} AND mapped_vendor_name = {% parameter mapped_vendor_name_filter %} {% endif %}
      {% if _filters['preferred_filter'] %} AND vendorid = {% parameter preferred_filter %} {% endif %}
      {% if _filters['vendor_type_filter'] %} AND vendor_name = {% parameter vendor_name_filter %} {% endif %}
      {% if _filters['vendor_type_filter'] %} AND mapped_vendor_name = {% parameter vendor_type_filter %} {% endif %}
      )
      , vendor_categories AS (
      SELECT DISTINCT asset_equipment_category_name
      FROM vendor_category_filtered
      )
      , combined_growth AS (
      SELECT
      vcf.asset_id,
      vcf.asset_purchase_date,
      vcf.asset_equipment_category_name,
      vcf.don_vendor,
      vcf.vendorid,
      vcf.vendor_name,
      vcf.mapped_vendor_name,
      vcf.preferred,
      vcf.category,
      vcf.vendor_type,
      vcf.sage_vendor_category,
      vcf.oec,
      vcf.asset_count,
      'Vendor' AS source
      FROM vendor_category_filtered vcf

      UNION

      SELECT
      fcg.asset_id,
      fcg.asset_purchase_date,
      fcg.asset_equipment_category_name,
      NULL,
      NULL,
      NULL,
      NULL,
      NULL,
      NULL,
      NULL,
      NULL,
      fcg.oec,
      fcg.asset_count,
      'Fleet' AS source
      FROM fleet_category_growth fcg
      INNER JOIN vendor_categories vc
      ON fcg.asset_equipment_category_name = vc.asset_equipment_category_name
      )
      select * from combined_growth as cg ;;
  }
  # the vendor_category_filter and vendor_categories CTEs allow the visual to drop categories when filtered to a vendor.
  # removing these will keep all categories present, even when filtered, since all categories always exist in the fleet side.

  dimension: asset_id {
    type: string
    sql: ${TABLE}.asset_id ;;
    primary_key: yes
    hidden: yes
  }

  dimension: purchase_date {
    type: date
    sql: ${TABLE}.asset_purchase_date ;;
  }

  dimension: asset_equipment_category {
    label: "Equipment Category"
    type: string
    sql: ${TABLE}.asset_equipment_category_name ;;
  }

  dimension: vendor_id {
    type: string
    sql: ${TABLE}.vendorid ;;
  }

  dimension: vendor_name {
    type: string
    sql: ${TABLE}.vendor_name ;;
  }

  dimension: mapped_vendor_name {
    type: string
    sql: ${TABLE}.mapped_vendor_name ;;
  }

  dimension: preferred {
    type: string
    sql: ${TABLE}.preferred ;;
  }

  dimension: tier {
    type: string
    sql: ${TABLE}.category ;;
  }

  dimension: category{
    type: string
    sql: ${TABLE}.category ;;
  }

  dimension: vendor_type {
    type: string
    sql: ${TABLE}.vendor_type ;;
  }

  dimension: sage_vendor_category {
    type: string
    sql: ${TABLE}.sage_vendor_category ;;
  }

  dimension: source {
    type: string
    sql: ${TABLE}.source ;;
    group_label: "Breakout"
  }

  measure: oec {
    label: "Original Equipment Cost"
    type: sum
    value_format_name: "usd"
    sql: zeroifnull(${TABLE}.oec) ;;
    drill_fields: [asset_id,
                  vendor_id,
                  vendor_name,
                  mapped_vendor_name,
                  dim_assets_fleet_opt.asset_equipment_make,
                  dim_assets_fleet_opt.asset_equipment_model,
                  dim_assets_fleet_opt.asset_equipment_category_name,
                  dim_assets_fleet_opt.asset_equipment_subcategory_name,
                  dim_assets_fleet_opt.asset_equipment_class_name,
                  purchase_date,
                  oec]
  }

  measure: asset_count {
    label: "Asset Count"
    type: sum
    sql: ${TABLE}.asset_count ;;
  }

  # Optional: derived month field for trend analysis
  dimension: purchase_month {
    type: date
    sql: DATE_TRUNC('MONTH', ${purchase_date}) ;;
    convert_tz: no
    group_label: "Time"
  }

  filter: vendor_id_filter {
    type: string
  }

  filter: vendor_name_filter {
    type: string
  }

  filter: mapped_vendor_name_filter {
    type: string
  }

  filter: preferred_filter {
    type: string
  }

  filter: tier_filter {
    type: string
  }

  filter: vendor_type_filter {
    type: string
  }
}
