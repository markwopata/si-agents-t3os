
view: audit_log_parameter_changes {
  # Or, you could make this view a derived table, like this:
  derived_table: {
    sql:
with exploded_changes as (

    select
        al.company_purchase_order_audit_log_id        as audit_log_id,
        al.user_id,
        al.action,
        to_timestamp_ntz(al.date_created)             as changed_at,

        -- detect grain
        case
            when al.parameters:company_purchase_order_line_item_id is not null
                then 'line_item'
            when al.parameters:company_purchase_order_id is not null
                then 'purchase_order'
        end                                           as change_level,

        al.parameters:company_purchase_order_line_item_id::number
            as company_purchase_order_line_item_id,

        al.parameters:company_purchase_order_id::number
            as company_purchase_order_id,

        f.key                                         as field_name,
        f.value::string                               as after_value

    from ES_WAREHOUSE.PUBLIC.COMPANY_PURCHASE_ORDER_AUDIT_LOG al
         ,lateral flatten(input => al.parameters:changes) f
),

ordered_changes as (

    select
        *,
        row_number() over (
            partition by
                coalesce(company_purchase_order_line_item_id, company_purchase_order_id),
                field_name
            order by changed_at, audit_log_id
        )                                             as change_seq,

        lag(after_value) over (
            partition by
                coalesce(company_purchase_order_line_item_id, company_purchase_order_id),
                field_name
            order by changed_at, audit_log_id
        )                                             as prior_after_value
    from exploded_changes
),

line_items_enriched as (

    select
        pol.company_purchase_order_line_item_id,
        pol.company_purchase_order_line_item_number,
        pol.company_purchase_order_id,
        object_construct_keep_null(pol.*)             as li_obj
    from ES_WAREHOUSE.PUBLIC.COMPANY_PURCHASE_ORDER_LINE_ITEMS pol
),

purchase_orders as (

    select
        po.company_purchase_order_id,
        po.company_purchase_order_type_id,
        object_construct_keep_null(po.*)              as po_obj
    from ES_WAREHOUSE.PUBLIC.COMPANY_PURCHASE_ORDERS po
),

purchase_order_types as (

    select
        cpt.company_purchase_order_type_id,
        cpt.name               as purchase_order_type,
        cpt.prefix
    from ES_WAREHOUSE.PUBLIC.COMPANY_PURCHASE_ORDER_TYPES cpt
)

select
    oc.audit_log_id,
    oc.change_level,

    -- identifiers
    oc.company_purchase_order_id,
    oc.company_purchase_order_line_item_id,
    coalesce(concat(pot.prefix, 'PO',oc.company_purchase_order_id), concat(pot.prefix, 'PO',li.company_purchase_order_id))  as purchase_order_header_number,
    li.company_purchase_order_id as purchase_order_header_id,
    li.company_purchase_order_line_item_number,
    concat(pot.prefix, 'PO',li.company_purchase_order_id,'-',li.company_purchase_order_line_item_number) as purchase_order_line_number,
    --user info

    --user
    oc.user_id,
    u.username,
    u.first_name,
    u.last_name,

    --PO context
    pot.purchase_order_type,

    --change details
    oc.action,
    oc.field_name,

    case
        when oc.change_seq = 1 and oc.change_level = 'line_item' then
            get(li.li_obj, oc.field_name)::string
        when oc.change_seq = 1 and oc.change_level = 'purchase_order' then
            get(po.po_obj, oc.field_name)::string
        else
            oc.prior_after_value
    end                                               as before_value,

    oc.after_value,
    oc.changed_at

from ordered_changes oc

left join line_items_enriched li
  on li.company_purchase_order_line_item_id
   = oc.company_purchase_order_line_item_id

left join purchase_orders po
  on po.company_purchase_order_id
   = coalesce(oc.company_purchase_order_id, li.company_purchase_order_id)

left join purchase_order_types pot
  on pot.company_purchase_order_type_id
   = po.company_purchase_order_type_id

left join ES_WAREHOUSE.PUBLIC.USERS u
  on u.user_id = oc.user_id



       ;;
  }

## =========================
## Identifiers & Grain
## =========================

    dimension: audit_log_id {
      type: string
      sql: ${TABLE}.audit_log_id ;;

    }

    dimension: change_level {
      type: string
      sql: ${TABLE}.change_level ;;
    }

    dimension: company_purchase_order_id {
      type: number
      sql: ${TABLE}.company_purchase_order_id ;;
    }

    dimension: company_purchase_order_line_item_id {
      type: number
      sql: ${TABLE}.company_purchase_order_line_item_id ;;
    }

    dimension: purchase_order_header_id {
      type: number
      sql: ${TABLE}.purchase_order_header_id ;;
    }

  dimension: purchase_order_header_number {
    type: string
    sql: ${TABLE}.purchase_order_header_number ;;
  }
    dimension: company_purchase_order_line_item_number {
      type: number
      sql: ${TABLE}.company_purchase_order_line_item_number ;;
    }

    dimension: purchase_order_line_number {
      type: string
      sql: ${TABLE}.purchase_order_line_number ;;
    }

## =========================
## User Dimensions
## =========================

    dimension: user_id {
      type: number
      sql: ${TABLE}.user_id ;;
    }

    dimension: username {
      type: string
      sql: ${TABLE}.username ;;
    }

    dimension: first_name {
      type: string
      sql: ${TABLE}.first_name ;;
    }

    dimension: last_name {
      type: string
      sql: ${TABLE}.last_name ;;
    }

    dimension: user_full_name {
      type: string
      sql: concat(${first_name}, ' ', ${last_name}) ;;
    }

## =========================
## Purchase Order Context
## =========================

    dimension: purchase_order_type {
      type: string
      sql: ${TABLE}.purchase_order_type ;;
    }

## =========================
## Change Metadata
## =========================

    dimension: action {
      type: string
      sql: ${TABLE}.action ;;
    }

    dimension: field_name {
      type: string
      sql: ${TABLE}.field_name ;;
    }

    dimension: before_value {
      type: string
      sql: ${TABLE}.before_value ;;
    }

    dimension: after_value {
      type: string
      sql: ${TABLE}.after_value ;;
    }

## =========================
## Time Dimensions
## =========================

    dimension_group: changed_at {
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
      sql: ${TABLE}.changed_at ;;
    }

## =========================
## Helper / Boolean Dimensions
## =========================

    dimension: is_line_item_change {
      type: yesno
      sql: ${change_level} = 'line_item' ;;
    }

    dimension: is_purchase_order_change {
      type: yesno
      sql: ${change_level} = 'purchase_order' ;;
    }

    dimension: value_changed {
      type: yesno
      sql: ${before_value} != ${after_value} ;;
    }

  }
