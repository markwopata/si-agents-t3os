
view: es_asset_inventory_status {
  derived_table: {
    sql: with asset_list as (
            select asset_id
            from analytics.assets.int_assets
            where is_managed_by_es_owned_market = true
            AND rental_branch_id is not null
            AND is_rerent_asset = false
          ),
          asset_status as (
            select asset_id, value
            from es_warehouse.public.asset_status_key_values
            where name = 'asset_inventory_status'
          ),
          approved_assets as (
            select asset_id,
            max(iff(status = 'Approved', 1, 0)) as has_approved,
            max(iff(status = 'Requested', 1, 0)) as has_requested
            from asset_transfer.public.transfer_orders
            group by asset_id
          )
          select
            al.asset_id,
            iff(aa.has_approved = 1, 'Yes', 'No') as has_approved_transfer_order,
            iff(aa.has_requested = 1, 'Yes', 'No') as has_requested_transfer_order,
            case
              when aa.has_approved = 1 then concat(askv.value, ' - In Transit')
              when aa.has_requested = 1 then concat(askv.value, ' - Requested Transfer')
              else askv.value
            end as inventory_status_with_transfer_info
          from asset_list al
          join asset_status askv
            on askv.asset_id = al.asset_id
          left join approved_assets aa
            on aa.asset_id = al.asset_id ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: asset_id {
    type: number
    sql: ${TABLE}."ASSET_ID" ;;
  }

  dimension: has_approved_transfer_order {
    type: string
    label: "In Transit"
    sql: ${TABLE}."HAS_APPROVED_TRANSFER_ORDER" ;;
  }

  dimension: has_requested_transfer_order {
    type: string
    label: "Requested Transfer"
    sql: ${TABLE}."HAS_REQUESTED_TRANSFER_ORDER" ;;
  }

  dimension: inventory_status_with_transfer_info {
    label: "Inventory Status"
    type: string
    sql: ${TABLE}."INVENTORY_STATUS_WITH_TRANSFER_INFO" ;;

    html:
    <span style="display:inline-flex;align-items:center;gap:6px;">
    {% if value == "Assigned" %}
    <span style="width:8px;height:8px;border-radius:50%;background:#28a745;display:inline-block;"></span>
    {% elsif value == "Ready To Rent" %}
    <span style="width:8px;height:8px;border-radius:50%;background:#28a745;display:inline-block;"></span>
    {% elsif value == "Pre-Delivered" %}
    <span style="width:8px;height:8px;border-radius:50%;background:#28a745;display:inline-block;"></span>

    {% elsif value == "Hard Down" %}
    <span style="width:8px;height:8px;border-radius:50%;background:#dc3545;display:inline-block;"></span>
    {% elsif value == "Soft Down" %}
    <span style="width:8px;height:8px;border-radius:50%;background:#dc3545;display:inline-block;"></span>

    {% elsif value == "Make Ready" %}
    <span style="width:8px;height:8px;border-radius:50%;background:#bdbdbd;display:inline-block;"></span>

    {% elsif value == "Needs Inspection" %}
    <span style="width:8px;height:8px;border-radius:50%;background:#ffc107;display:inline-block;"></span>

    {% elsif value == "On RPO" %}
    <span style="width:8px;height:8px;border-radius:50%;background:#6f42c1;display:inline-block;"></span>

    {% elsif value == "On Rent" %}
    <span style="width:8px;height:8px;border-radius:50%;background:#0d6efd;display:inline-block;"></span>

    {% elsif value == "Pending Return" %}
    <span style="width:8px;height:8px;border-radius:50%;background:#fd7e14;display:inline-block;"></span>
    {% endif %}

    {{ rendered_value }}
    </span> ;;
  }

  set: detail {
    fields: [
      asset_id,
      inventory_status_with_transfer_info
    ]
  }
}
