view: line_items_dates_combined {
  derived_table: {
    sql:
 /*with classcount as (
select  distinct
li.invoice_id
, li.rental_id
, bs.name
, rank() over (PARTITION BY li.invoice_id ORDER BY  bs.name) as invoice_class_count
, rank() over (PARTITION BY li.rental_id ORDER BY  bs.name) as rental_class_count
from analytics.public.v_line_items li
LEFT JOIN es_warehouse.public.assets a on a.asset_id = li.asset_id
LEFT JOIN es_warehouse.public.equipment_classes ec ON ec.equipment_class_id = a.equipment_class_id
LEFT JOIN ES_WAREHOUSE.PUBLIC.BUSINESS_SEGMENTS bs ON bs.business_segment_id = ec.business_segment_id
where (li.GL_DATE_CREATED >= DATEADD(YEAR,-1,current_date) ) or (li.GL_BILLING_APPROVED_DATE >= DATEADD(YEAR,-1,current_date) and li.GL_BILLING_APPROVED_DATE is not null)
)
, invoice_class as (select
invoice_id
, name
, max(invoice_class_count) as invoice_max_class
from classcount
group by invoice_id, name
having invoice_max_class <= 1
and name is not null
)
, rental_class as (select
rental_id
, name
, max(rental_class_count) as rental_max_class
from classcount
group by rental_id, name
having rental_max_class <= 1
and name is not null
)
,  class_distinct as (
select
distinct
ec.name
, ec.business_segment_id
, bs.name as business_segment_name
from
es_warehouse.public.equipment_classes ec
LEFT JOIN ES_WAREHOUSE.PUBLIC.BUSINESS_SEGMENTS bs ON bs.business_segment_id = ec.business_segment_id
where ec.deleted = FALSE and bs.name is not null
)*/
WITH base_classmap AS (
  SELECT DISTINCT
    li.invoice_id,
    li.rental_id,
    bs.name AS business_segment_name
  FROM analytics.public.v_line_items li
  LEFT JOIN es_warehouse.public.assets a
    ON a.asset_id = li.asset_id
  LEFT JOIN es_warehouse.public.equipment_classes ec
    ON ec.equipment_class_id = a.equipment_class_id
  LEFT JOIN es_warehouse.public.business_segments bs
    ON bs.business_segment_id = ec.business_segment_id
  WHERE
    (
      li.GL_DATE_CREATED >= DATEADD(YEAR, -1, CURRENT_DATE)
      OR (
        li.GL_BILLING_APPROVED_DATE >= DATEADD(YEAR, -1, CURRENT_DATE)
        AND li.GL_BILLING_APPROVED_DATE IS NOT NULL
      )
    )
    AND bs.name IS NOT NULL
),

invoice_class AS (
  SELECT
    invoice_id,
    MAX(business_segment_name) AS name
  FROM base_classmap
  GROUP BY invoice_id
  HAVING COUNT(DISTINCT business_segment_name) = 1
),

rental_class AS (
  SELECT
    rental_id,
    MAX(business_segment_name) AS name
  FROM base_classmap
  GROUP BY rental_id
  HAVING COUNT(DISTINCT business_segment_name) = 1
)
,  class_distinct as (
select
distinct
ec.name
, ec.business_segment_id
, bs.name as business_segment_name
from
es_warehouse.public.equipment_classes ec
LEFT JOIN ES_WAREHOUSE.PUBLIC.BUSINESS_SEGMENTS bs ON bs.business_segment_id = ec.business_segment_id
where ec.deleted = FALSE and bs.name is not null
)
SELECT li.GL_DATE_CREATED                      as date,
                    li.gl_billing_approved_date,
                    i.INVOICE_ID,
                    i.INVOICE_NO,
                    li.RENTAL_ID,
                    i.SALESPERSON_USER_ID,
                    li.AMOUNT,
                    li.LINE_ITEM_TYPE_ID,
                    li.LINE_ITEM_ID,
                    li.CREDIT_NOTE_LINE_ITEM_ID,
                    li.BRANCH_ID                as market_id,
                    TRUE                        as date_created_tf,
                    i.COMPANY_ID,
                    ra.RATE_TIER,
                    ra.EQUIPMENT_CLASS as final_equipment_class,
                    ra.percent_discount,
                    case
                        when ais.secondary_salesperson_ids = '[]' then 'No' else 'Yes' end as secondary_salesperson_ind,
                    concat(u.first_name,' ',u.last_name,' - ',u.user_id) as salesperson_with_id,
                    ifnull(coalesce(coalesce(bs.name,ic.name),rc.name), 'No Class Listed') as business_segment_name,
                    case
                    when coalesce(coalesce(bs.name,ic.name),rc.name) = 'Gen Rental' then 1
                    when coalesce(coalesce(bs.name,ic.name),rc.name) = 'Advanced Solutions' then 2
                    when coalesce(coalesce(bs.name,ic.name),rc.name) = 'ITL' then 3
                    else 5 end as segment_sort
             FROM es_warehouse.public.invoices i
                    LEFT JOIN analytics.public.v_line_items li
                    ON i.invoice_id = li.invoice_id

                    --LEFT JOIN es_warehouse.public.assets a on a.asset_id = li.asset_id
                    --LEFT JOIN es_warehouse.public.equipment_classes ec ON ec.equipment_class_id = a.equipment_class_id
                    --LEFT JOIN ES_WAREHOUSE.PUBLIC.BUSINESS_SEGMENTS bs ON bs.business_segment_id = ec.business_segment_id
                    LEFT JOIN invoice_class ic ON ic.invoice_id = li.invoice_id
                    LEFT JOIN rental_class rc ON rc.rental_id = li.rental_id

                    LEFT JOIN es_warehouse.public.approved_invoice_salespersons ais
                    ON i.invoice_id = ais.invoice_id
                    LEFT JOIN es_warehouse.public.orders o
                    ON i.order_id = o.order_id
                    LEFT JOIN es_warehouse.public.rentals r
                    ON i.order_id = r.order_id AND li.asset_id = r.asset_id and li.rental_id = r.rental_id
                    LEFT JOIN analytics.public.rateachievement_points ra
                    ON r.rental_id = ra.rental_id AND i.invoice_id = ra.invoice_id AND r.asset_id = ra.asset_id

                    LEFT JOIN class_distinct ec ON ec.name = ra.equipment_class

                    LEFT JOIN ES_WAREHOUSE.PUBLIC.BUSINESS_SEGMENTS bs ON bs.business_segment_id = ec.business_segment_id

                    LEFT JOIN es_warehouse.public.users u on u.user_id = i.salesperson_user_id
             WHERE li.GL_DATE_CREATED >= DATEADD(YEAR,-1,current_date)
                  AND i.company_id not in (1854,1855,8151,155)
                  AND i.invoice_no NOT ILIKE '%deleted%' AND
                   {% if _user_attributes['department']  == "'salesperson'" %}
                   u.email_address = '{{ _user_attributes['email'] }}'
                   {% else %}
                   1 = 1
                   {% endif %}
             UNION ALL
             SELECT li.GL_BILLING_APPROVED_DATE as date,
                    li.gl_billing_approved_date,
                    i.INVOICE_ID,
                    i.INVOICE_NO,
                    li.RENTAL_ID,
                    i.SALESPERSON_USER_ID,
                    li.AMOUNT,
                    li.LINE_ITEM_TYPE_ID,
                    li.LINE_ITEM_ID,
                    li.CREDIT_NOTE_LINE_ITEM_ID,
                    li.BRANCH_ID                as market_id,
                    FALSE                       as date_created_tf,
                    i.COMPANY_ID,
                    ra.RATE_TIER,
                    ra.EQUIPMENT_CLASS as FINAL_EQUIPMENT_CLASS,
                    ra.percent_discount,
                    case
                        when ais.secondary_salesperson_ids = '[]' then 'No' else 'Yes' end as secondary_salesperson_ind,
                    concat(u.first_name,' ',u.last_name,' - ',u.user_id) as salesperson_with_id,
                     ifnull(coalesce(coalesce(bs.name,ic.name),rc.name), 'No Class Listed') as business_segment_name,
                    case
                    when coalesce(coalesce(bs.name,ic.name),rc.name) = 'Gen Rental' then 1
                    when coalesce(coalesce(bs.name,ic.name),rc.name) = 'Advanced Solutions' then 2
                    when coalesce(coalesce(bs.name,ic.name),rc.name) = 'ITL' then 3
                    else 5 end as segment_sort
             FROM es_warehouse.public.invoices i
                    LEFT JOIN analytics.public.v_line_items li
                    ON i.invoice_id = li.invoice_id

                    --LEFT JOIN es_warehouse.public.assets a on a.asset_id = li.asset_id
                    --LEFT JOIN es_warehouse.public.equipment_classes ec ON ec.equipment_class_id = a.equipment_class_id
                    --LEFT JOIN ES_WAREHOUSE.PUBLIC.BUSINESS_SEGMENTS bs ON bs.business_segment_id = ec.business_segment_id
                    LEFT JOIN invoice_class ic ON ic.invoice_id = li.invoice_id
                    LEFT JOIN rental_class rc ON rc.rental_id = li.rental_id

                    LEFT JOIN es_warehouse.public.approved_invoice_salespersons ais
                    ON i.invoice_id = ais.invoice_id
                    LEFT JOIN es_warehouse.public.orders o
                    ON i.order_id = o.order_id
                    LEFT JOIN es_warehouse.public.rentals r
                    ON i.order_id = r.order_id AND li.asset_id = r.asset_id and li.rental_id = r.rental_id
                    LEFT JOIN analytics.public.rateachievement_points ra
                    ON r.rental_id = ra.rental_id AND i.invoice_id = ra.invoice_id AND r.asset_id = ra.asset_id

                    LEFT JOIN class_distinct ec ON ec.name = ra.equipment_class

                    LEFT JOIN ES_WAREHOUSE.PUBLIC.BUSINESS_SEGMENTS bs ON bs.business_segment_id = ec.business_segment_id

                    LEFT JOIN es_warehouse.public.users u on u.user_id = i.salesperson_user_id
             WHERE li.GL_BILLING_APPROVED_DATE is not null
             AND li.GL_BILLING_APPROVED_DATE >= DATEADD(YEAR,-1,current_date)
             AND i.company_id not in (1854,1855,8151,155) and i.invoice_no NOT ILIKE '%deleted%'
             AND
             {% if _user_attributes['department']  == "'salesperson'" %}
             u.email_address ILIKE '{{ _user_attributes['email'] }}'
             {% else %}
             1 = 1
             {% endif %}
       ;;
  }

  filter: salesperson_filter {
  }

  dimension_group: date {
    type: time
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: CAST(${TABLE}."DATE" AS TIMESTAMP_NTZ) ;;
  }

  dimension_group: gl_billing_approved_date {
    type: time
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: CAST(${TABLE}."GL_BILLING_APPROVED_DATE" AS TIMESTAMP_NTZ) ;;
  }

  dimension: invoice_id {
    type: number
    sql: ${TABLE}."INVOICE_ID" ;;
    value_format_name: id
  }

  dimension: invoice_no {
    type: string
    sql: ${TABLE}."INVOICE_NO" ;;
  }

  dimension: invoice_id_pk {
    type: number
    sql: concat(${TABLE}."INVOICE_ID", ${TABLE}."LINE_ITEM_ID",COALESCE(${TABLE}."CREDIT_NOTE_LINE_ITEM_ID",0), ${TABLE}."DATE_CREATED_TF") ;;
    primary_key: yes
  }

  dimension: rental_id {
    type: number
    sql: ${TABLE}."RENTAL_ID" ;;
    value_format_name: id
  }

  dimension: salesperson_user_id {
    type: number
    sql: ${TABLE}."SALESPERSON_USER_ID" ;;
    value_format_name: id
  }

  dimension: amount {
    type: number
    sql: ${TABLE}."AMOUNT" ;;
    value_format_name: usd
  }

  dimension: line_item_type_id {
    type: number
    sql: ${TABLE}."LINE_ITEM_TYPE_ID" ;;
    value_format_name: id
  }

  dimension: market_id {
    type: number
    sql: ${TABLE}."MARKET_ID" ;;
    value_format_name: id
  }

  dimension: date_created_tf {
    type: yesno
    sql: ${TABLE}."DATE_CREATED_TF" ;;
  }

  dimension: company_id {
    type: number
    sql: ${TABLE}."COMPANY_ID" ;;
    value_format_name: id
  }

  dimension: rate_tier {
    type: number
    sql: ${TABLE}."RATE_TIER" ;;
  }

  dimension: final_equipment_class {
    label: "Equipment Class"
    type: string
    sql: ${TABLE}."FINAL_EQUIPMENT_CLASS" ;;
  }

  dimension: percent_discount {
    type: number
    sql: ${TABLE}."PERCENT_DISCOUNT" ;;
    value_format_name: percent_0
  }

  dimension: rate_tier_name {
    type: string
    sql: case when ${rate_tier} = 0 then 'Below Online/Above Floor'
              when ${rate_tier} = 1 then 'Above Online'
              when ${rate_tier} = 2 then 'Below Online/Above Floor'
              when ${rate_tier} = 3 then 'Below Floor' else 'Below Online/Above Floor' end;;
  }

  dimension: secondary_salesperson_ind {
    type: string
    sql: ${TABLE}."SECONDARY_SALESPERSON_IND" ;;
    html: <p style="text-align: center">{{rendered_value}}</p> ;;
  }

  dimension: salesperson_with_id {
    type: string
    sql: ${TABLE}."SALESPERSON_WITH_ID" ;;
  }

  dimension: commission_line_items {
    type: yesno
    sql: (${line_item_type_id} in (6,8,108,109,44)
        or (${line_item_type_id} = 5 and ${amount}>=95 and ${date_raw}>'2022-01-31'::date) and ${date_raw}<'2022-09-01'::date)
        or (${line_item_type_id} = 5 and ${amount}>=125 and ${date_raw}>'2022-08-31'::date);;
  }

  dimension: rental_line_items {
    type: yesno
    sql: ${line_item_type_id} in (6,8,108,109) ;;
  }

  dimension: delivery_line_items {
    type: yesno
    sql: ${line_item_type_id} = 5 ;;
  }

  dimension: line_item_name {
    type: string
    sql: case when ${line_item_type_id} in (6,8,108,109) then 'Rental'
         when ${line_item_type_id} = 5 then 'Delivery'
         when ${line_item_type_id} = 44 then 'Nonserialized Rental (Bulk)' else null end;;
  }

  measure: total_amount {
    type: sum
    sql: ${amount} ;;
    value_format_name: usd_0
  }

  measure: billing_approved_amount {
    type: sum
    sql: ${amount} ;;
    filters: [date_created_tf: "No"]
    drill_fields: [detail*]
  }

  dimension: business_segment_name {
    label: "Business Segment"
    type: string
    sql: ${TABLE}."BUSINESS_SEGMENT_NAME" ;;
  }

  dimension: is_deleted_invoice {
    type: yesno
    sql: ${invoice_no} ILIKE '%deleted%' ;;
    label: "Deleted Invoice"
    group_label: "Invoice Flags"
  }


  measure: billing_approved_amount_gen_rental {
    group_label: "Business Segment Bill Approved Amounts"
    label: "Gen Rental"
    type: sum
    sql: CASE WHEN ${date_created_tf} = FALSE and ${business_segment_name} = 'Gen Rental' then ${amount} end ;;

    drill_fields: [detail*]
    html: {{rendered_value}} || {{gen_rental_pct_of_billing_aprroved_amount._rendered_value}} of total ;;
    value_format_name: usd_0
  }

  measure: gen_rental_pct_of_billing_aprroved_amount {
    type: number
    sql: ${billing_approved_amount_gen_rental}/NULLIFZERO(${billing_approved_amount}) ;;
    value_format_name: percent_1
  }

  measure: billing_approved_amount_advanced_solutions {
    group_label: "Business Segment Bill Approved Amounts"
    label: "Advanced Solutions"
    type: sum
    sql:  CASE WHEN ${date_created_tf} = FALSE and ${business_segment_name} = 'Advanced Solutions' then ${amount} end ;;
    drill_fields: [detail*]
    html: {{rendered_value}} || {{advanced_solutions_pct_of_billing_aprroved_amount._rendered_value}} of total ;;
    value_format_name: usd_0
  }

  measure: advanced_solutions_pct_of_billing_aprroved_amount {
    type: number
    sql: ${billing_approved_amount_advanced_solutions}/NULLIFZERO(${billing_approved_amount}) ;;
    value_format_name: percent_1
  }

  measure: billing_approved_amount_itl {
    group_label: "Business Segment Bill Approved Amounts"
    label: "ITL"
    type: sum
    sql:  CASE WHEN ${date_created_tf} = FALSE and ${business_segment_name} = 'ITL' then ${amount} end ;;

    drill_fields: [detail*]
    html: {{rendered_value}} || {{itl_pct_of_billing_aprroved_amount._rendered_value}} of total ;;
    value_format_name: usd_0
  }

  measure: itl_pct_of_billing_aprroved_amount {
    type: number
    sql: ${billing_approved_amount_itl}/NULLIFZERO(${billing_approved_amount}) ;;
    value_format_name: percent_1
  }

  measure: billing_approved_amount_no_asset_listed {
    group_label: "Business Segment Bill Approved Amounts"
    label: "No Class Listed"
    type: sum
    sql:  CASE WHEN ${date_created_tf} = FALSE and ${business_segment_name} = 'No Class Listed' then ${amount} end ;;
    drill_fields: [detail*]
    html: {{rendered_value}} || {{no_asset_listed_pct_of_billing_aprroved_amount._rendered_value}} of total ;;
    value_format_name: usd_0
  }

  measure: no_asset_listed_pct_of_billing_aprroved_amount {
    type: number
    sql: ${billing_approved_amount_no_asset_listed}/NULLIFZERO(${billing_approved_amount}) ;;
    value_format_name: percent_1
  }

  measure: date_created_amount {
    type: sum
    sql: ${amount} ;;
    filters: [date_created_tf: "Yes"]
    drill_fields: [detail*]
  ##  html: Rental - {{ total_rental_revenue._rendered_value }} <br> >$95 Delivery - {{ total_delivery_revenue._rendered_value }} ;;
  }

  measure: date_created_rental {
    type: sum
    sql: ${amount} ;;
    filters: [date_created_tf: "Yes",
      rental_line_items: "Yes"]
    drill_fields: [detail*]
  ##  html: Rental - {{ total_rental_revenue._rendered_value }} <br> >$95 Delivery - {{ total_delivery_revenue._rendered_value }} ;;
  }

  measure: date_created_delivery {
    type: sum
    sql: ${amount} ;;
    filters: [date_created_tf: "Yes",
      line_item_type_id: "5"]
    drill_fields: [detail*]
  ##  html: Rental - {{ total_rental_revenue._rendered_value }} <br> >$95 Delivery - {{ total_delivery_revenue._rendered_value }} ;;
  }

  measure: in_market_rental_revenue {
    type: sum
    sql: ${amount} ;;
    filters: [salesperson_to_market.is_main_market: "yes", line_item_type_id: "6,8,108,109",date_created_tf: "no"]
    drill_fields: [detail*]
    html: {{rendered_value}} || {{in_market_pct_of_billing_approved._rendered_value}} of total ;;
    value_format_name: usd_0
  }

  measure: out_of_market_rental_revenue {
    type: sum
    sql: ${amount} ;;
    filters: [salesperson_to_market.is_main_market: "no",line_item_type_id: "6,8,108,109",date_created_tf: "no"]
    drill_fields: [detail*]
    html: {{rendered_value}} || {{out_of_market_pct_of_billing_approved._rendered_value}} of total ;;
    value_format_name: usd_0
  }

  measure: total_delivery_revenue {
    type: sum
    sql: ${amount} ;;
    value_format_name: usd_0
    filters: [line_item_type_id: "5"]
    drill_fields: [detail*]
  }

  measure: total_rental_revenue {
    type: sum
    sql: ${amount} ;;
    value_format_name: usd_0
    filters: [rental_line_items: "yes"]
    drill_fields: [detail*]
  }

  measure: below_floor_date_created {
    type: sum
    sql: ${amount} ;;
    filters: [date_created_tf: "Yes", rate_tier: "3"]
    drill_fields: [detail*]
    html: {{rendered_value}} || {{below_floor_pct_of_date_created._rendered_value}} of total ;;
    value_format_name: usd_0
  }

  measure: below_floor_billing_approved {
    type: sum
    sql: ${amount} ;;
    filters: [date_created_tf: "No", rate_tier: "3"]
    drill_fields: [detail*]
    html: {{rendered_value}} || {{below_floor_pct_of_billing_approved._rendered_value}} of total ;;
    value_format_name: usd_0
  }

  measure: between_floor_online_date_created {
    type: sum
    sql: ${amount} ;;
    filters: [date_created_tf: "Yes", rate_tier: "0,2,null"]
    drill_fields: [detail*]
    html: {{rendered_value}} || {{btw_floor_online_pct_of_date_created._rendered_value}} of total ;;
    value_format_name: usd_0
  }

  measure: between_floor_online_billing_approved {
    type: sum
    sql: ${amount} ;;
    filters: [date_created_tf: "No", rate_tier: "0,2,null"]
    drill_fields: [detail*]
    html: {{rendered_value}} || {{btw_floor_online_pct_of_billing_approved._rendered_value}} of total ;;
    value_format_name: usd_0
  }

  measure: above_online_date_created {
    type: sum
    sql: ${amount} ;;
    filters: [date_created_tf: "Yes", rate_tier: "1"]
    drill_fields: [detail*]
    html: {{rendered_value}} || {{above_online_pct_of_date_created._rendered_value}} of total ;;
    value_format_name: usd_0
  }

  measure: above_online_billing_approved {
    type: sum
    sql: ${amount} ;;
    filters: [date_created_tf: "No", rate_tier: "1"]
    drill_fields: [detail*]
    html: {{rendered_value}} || {{above_online_pct_of_billing_approved._rendered_value}} of total ;;
    value_format_name: usd_0
  }

  # measure: no_rate_date_created {
  #   type: sum
  #   sql: ${amount} ;;
  #   filters: [date_created_tf: "Yes", rate_tier: "0, null"]
  #   drill_fields: [detail*]
  #   html: {{rendered_value}} || {{no_rate_pct_of_date_created._rendered_value}} of total ;;
  #   value_format_name: usd
  # }

  measure: below_floor_pct_of_date_created {
    type: number
    sql: ${below_floor_date_created}/nullifzero(${date_created_amount}) ;;
    value_format_name: percent_1
  }

  measure: below_floor_pct_of_billing_approved {
    type: number
    sql: ${below_floor_billing_approved}/nullifzero(${billing_approved_amount}) ;;
    value_format_name: percent_1
  }

  measure: btw_floor_online_pct_of_date_created {
    type: number
    sql: ${between_floor_online_date_created}/nullifzero(${date_created_amount}) ;;
    value_format_name: percent_1
  }

  measure: btw_floor_online_pct_of_billing_approved {
    type: number
    sql: ${between_floor_online_billing_approved}/nullifzero(${billing_approved_amount}) ;;
    value_format_name: percent_1
  }

  measure: above_online_pct_of_date_created {
    type: number
    sql: ${above_online_date_created}/nullifzero(${date_created_amount}) ;;
    value_format_name: percent_1
  }

  measure: above_online_pct_of_billing_approved {
    type: number
    sql: ${above_online_billing_approved}/nullifzero(${billing_approved_amount}) ;;
    value_format_name: percent_1
  }

  measure: in_market_pct_of_billing_approved {
    type: number
    sql: ${in_market_rental_revenue}/nullifzero(${billing_approved_amount}) ;;
    value_format_name: percent_1
  }

  measure: out_of_market_pct_of_billing_approved {
    type: number
    sql: ${out_of_market_rental_revenue}/nullifzero(${billing_approved_amount}) ;;
    value_format_name: percent_1
  }

  measure: unapproved_total_amount {
    type: sum
    sql: ${amount} ;;
    filters: [date_created_tf: "Yes", gl_billing_approved_date_date: "null"]
    value_format_name: usd_0
    drill_fields: [unapproved_detail*]
  }

  measure: unapproved_rental_amount {
    type: sum
    sql: ${amount} ;;
    filters: [date_created_tf: "Yes",gl_billing_approved_date_date: "null", rental_line_items: "Yes"]
    value_format_name: usd_0
    drill_fields: [unapproved_detail*]
  }

  measure: unapproved_delivery_amount {
    type: sum
    sql: ${amount} ;;
    filters: [date_created_tf: "Yes",gl_billing_approved_date_date: "null", delivery_line_items: "Yes"]
    value_format_name: usd_0
    drill_fields: [unapproved_detail*]
  }

  measure: unapproved_bulk_amount {
    type: sum
    sql: ${amount} ;;
    filters: [date_created_tf: "Yes",gl_billing_approved_date_date: "null", line_item_type_id: "44"]
    value_format_name: usd_0
    drill_fields: [unapproved_detail*]
  }

  set: detail {
    fields: [
      market_id,
      market_region_xwalk.market_name,
      company_id,
      companies.name,
      invoice_id,
      secondary_salesperson_ind,
      business_segment_name,
      final_equipment_class,
      percent_discount,
      total_rental_revenue,
      total_amount
    ]
  }

  set: unapproved_detail {
    fields: [company_id,
      companies.name,
      invoice_id,
      invoice_no,
      date_date,
      gl_billing_approved_date_date,
      unapproved_rental_amount,
      unapproved_delivery_amount,
      unapproved_bulk_amount
    ]
  }
}
