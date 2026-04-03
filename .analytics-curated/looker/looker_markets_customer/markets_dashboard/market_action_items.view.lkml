
view: market_action_items {
  sql_table_name:  analytics.bi_ops.market_action_items ;;



  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: item {
    type: string
    sql: ${TABLE}."ITEM" ;;
  }

  dimension: region_name {
    type: string
    sql: ${TABLE}."REGION_NAME" ;;
  }

  dimension: district {
    type: string
    sql: ${TABLE}."DISTRICT" ;;
  }

  dimension: market_id {
    type: number
    sql: ${TABLE}."MARKET_ID" ;;
  }

  dimension: market_name {
    type: string
    sql: ${TABLE}."MARKET_NAME" ;;
  }

  dimension: special_locations_tf {
    type: yesno
    sql: case when ${market_name} ILIKE '%Landmark%' OR
        ${market_name} ILIKE '%Mobile Tool Trailer%' OR
        ${market_name} ILIKE '%Onsite Yard%' OR
        ${market_name} ILIKE '%Containers%' then true else false end ;;
  }

  dimension: special_locations_type {
    type: string
    sql: CASE WHEN ${market_name} ILIKE '%Landmark%' THEN 'Landmark'
        when ${market_name} ILIKE '%Mobile Tool Trailer%' THEN 'Mobile Tool Trailer'
        WHEN ${market_name} ILIKE '%Onsite Yard%' THEN 'Onsite Yard'
        WHEN ${market_name} ILIKE '%Containers%' then 'Container' ELSE ${market_type} END ;;
  }

  dimension: landmark_locations {
    type: yesno
    sql: case when ${market_name} ILIKE '%Landmark%' then true else false end ;;
  }

  dimension: tool_trailer_locations {
    type: yesno
    sql: case when ${market_name} ILIKE '%Landmark%' OR
        ${market_name} ILIKE '%Mobile Tool Trailer%' OR
        ${market_name} ILIKE '%Onsite Yard%' OR
        ${market_name} ILIKE '%Containers%' then true else false end ;;
  }

  dimension: onsite_yard_locations {
    type: yesno
    sql: case when ${market_name} ILIKE '%Landmark%' OR
        ${market_name} ILIKE '%Mobile Tool Trailer%' OR
        ${market_name} ILIKE '%Onsite Yard%' OR
        ${market_name} ILIKE '%Containers%' then true else false end ;;
  }
  dimension: container_locations {
    type: yesno
    sql: case when ${market_name} ILIKE '%Landmark%' OR
        ${market_name} ILIKE '%Mobile Tool Trailer%' OR
        ${market_name} ILIKE '%Onsite Yard%' OR
        ${market_name} ILIKE '%Containers%' then true else false end ;;
  }



  dimension: market_type {
    type: string
    sql: ${TABLE}."MARKET_TYPE" ;;
  }

  measure: selection_label {
    type: string
    sql:
    CASE
      -- More than one market → first market + count-1 markets
      WHEN COUNT(DISTINCT ${market_id}) > 1 THEN
        SPLIT_PART(
          LISTAGG(DISTINCT ${market_name}, '||')
            WITHIN GROUP (ORDER BY ${market_name}),
          '||', 1
        )
        || ' + ' ||
        TO_VARCHAR(COUNT(DISTINCT ${market_id}) - 1) ||
        CASE
          WHEN (COUNT(DISTINCT ${market_id}) - 1) = 1 THEN ' market'
          ELSE ' markets'
        END

      -- Exactly one market → just its name
      WHEN COUNT(DISTINCT ${market_id}) = 1 THEN
      MIN(${market_name})

      ELSE 'All Company'
      END
      ;;
  }

  dimension: item_count {
    type: number
    sql: ${TABLE}."ITEM_COUNT" ;;
  }

  measure: total_of_all_items {
    type: sum
    sql: ${item_count} ;;
  }


  measure: total_invoice_received {
    type: sum
    sql: ${item_count} ;;
    filters: [item: "invoice_received"]
  }

  measure: total_invoices_needing_branch_approval {
    type: sum
    sql: ${item_count};;
    filters: [item: "invoices_needing_branch_approval"]
  }

  measure: total_unsigned_company_contracts{
    type: sum
    sql: ${item_count} ;;
    filters: [item: "unsigned_company_contracts"]
  }

  measure: cod_outstanding {
    type: sum
    sql: ${item_count} ;;
    filters: [item: "cod_outstanding"]
  }

  measure: pending_invoices {
    type: sum
    sql: ${item_count} ;;
    filters: [item: "pending_invoices"]
  }

  measure: total_open_pos {
    type: sum
    sql: ${item_count} ;;
    filters: [item: "open_pos"]
  }

  measure: total_off_rents {
    type: sum
    sql: ${item_count} ;;
    filters: [item: "off_rents"]
  }

  measure: total_overdue_deliveries {
    type: sum
    sql: ${item_count} ;;
    filters: [item: "overdue_deliveries"]
  }

  measure: total_new_action_items {
    type: number
    sql: ${total_invoice_received}+${total_invoices_needing_branch_approval}+${total_unsigned_company_contracts}+
    ${cod_outstanding}+${pending_invoices}+${total_open_pos}+${total_off_rents} + ${total_overdue_deliveries};;
  }


  measure: first_market_id {
    type: number
    sql: MIN_BY(${market_id}, ${market_name}) ;;
    hidden: yes
  }

 measure: selection_action_items_card2 {
  group_label: "Action Item Card - Selected Locations 2.0"
  label: " "
  type: sum
  sql: ${item_count} ;;

  html:
    {% assign f_region   = _filters['market_action_items.region_name_filter_mapping']  | default: '' | url_encode %}
    {% assign f_district = _filters['market_action_items.district_filter_mapping']     | default: '' | url_encode %}
    {% assign f_market   = _filters['market_action_items.market_name_filter_mapping']  | default: '' | url_encode %}
    {% assign f_type     = _filters['market_action_items.market_type_filter_mapping']  | default: '' | url_encode %}
    {% assign f_market_id = first_market_id._value | default: '' | url_encode %}


    <table border="0" style="font-family: Verdana; font-size: 14px; color: #323232; width: 100%;">
    <tr>
    <td colspan="4" style="font-size: 20px;">Action Items</td>
    </tr>
    <tr>
    <td colspan="4" style="font-size: 14px;">{{ selection_label._value }}</td>
    </tr>

    <tr style="background-color: #ffcfcf;">
    <td colspan="4" style="text-align: left;">
    {% if total_new_action_items._value == 0 %}
    <h3>{{ total_new_action_items._value }}</h3>
    {% else %}
    <font style="color: #DA344D"><h3>◉ {{ total_new_action_items._value }}</h3></font>
    {% endif %}
    </td>
    </tr>

    <tr><td colspan="4"><font style="color: #C0C0C0"><br /></font></td></tr>


    <!-- Unreceived POs With Invoice Received -->
    <tr>
    <td>
    <a href="https://equipmentshare.looker.com/looks/825?f[unreceived_pos_action_items.requesting_branch_name]={{ f_market }}&amp;f[unreceived_pos_action_items.requesting_district]={{ f_district }}&amp;f[unreceived_pos_action_items.requesting_region_name]={{ f_region }}&amp;toggle=det" target="_blank">
    Unreceived POs With Invoice Received:
    </a>
    </td>
    <td>{% if total_invoice_received._value != 0 %}<center><font style="color: #DA344D">◉</font></center>{% endif %}</td>
    <td>
 <a href="https://equipmentshare.looker.com/looks/825?f[unreceived_pos_action_items.requesting_branch_name]={{ f_market }}&amp;f[unreceived_pos_action_items.requesting_district]={{ f_district }}&amp;f[unreceived_pos_action_items.requesting_region_name]={{ f_region }}&amp;toggle=det" target="_blank">
    {{ total_invoice_received._value }}
    </a>
    {% if total_invoice_received._value != 0 %}
 <a href="https://equipmentshare.looker.com/looks/825?f[unreceived_pos_action_items.requesting_branch_name]={{ f_market }}&amp;f[unreceived_pos_action_items.requesting_district]={{ f_district }}&amp;f[unreceived_pos_action_items.requesting_region_name]={{ f_region }}&amp;toggle=det" target="_blank"> ➔</a>
    {% endif %}
    </td>
    </tr>
    <tr><td colspan="4"><hr style="border: 1px solid #DCDCDC; margin: 0;"></td></tr>

    <!-- A/P Invoices Needing Branch Approval -->
    <tr>
    <td>
    <a href="https://equipmentshare.looker.com/looks/826?f[invoices_awaiting_approval_action_items.market]={{ f_market }}&amp;f[invoices_awaiting_approval_action_items.district]={{ f_district }}&amp;f[invoices_awaiting_approval_action_items.region]={{ f_region }}&amp;toggle=det" target="_blank">
    A/P Invoices Needing Branch Approval:
    </a>
    </td>
    <td>{% if total_invoices_needing_branch_approval._value != 0 %}<center><font style="color: #DA344D">◉</font></center>{% endif %}</td>
    <td>
    <a href="https://equipmentshare.looker.com/looks/826?f[invoices_awaiting_approval_action_items.market]={{ f_market }}&amp;f[invoices_awaiting_approval_action_items.district]={{ f_district }}&amp;f[invoices_awaiting_approval_action_items.region]={{ f_region }}&amp;toggle=det" target="_blank">
    {{ total_invoices_needing_branch_approval._value }}
    </a>
    {% if total_invoices_needing_branch_approval._value != 0 %}
      <a href="https://equipmentshare.looker.com/looks/826?f[invoices_awaiting_approval_action_items.market]={{ f_market }}&amp;f[invoices_awaiting_approval_action_items.district]={{ f_district }}&amp;f[invoices_awaiting_approval_action_items.region]={{ f_region }}&amp;toggle=det" target="_blank"> ➔</a>
    {% endif %}
    </td>
    </tr>
    <tr><td colspan="4"><hr style="border: 1px solid #DCDCDC; margin: 0;"></td></tr>



    <!-- Unsigned Company Contracts -->
    <tr>
    <td>
    <a href="https://equipmentshare.looker.com/looks/827?f[unsigned_company_contracts_action_items.market]={{ f_market }}&amp;f[unsigned_company_contracts_action_items.district]={{ f_district }}&amp;f[unsigned_company_contracts_action_items.region]={{ f_region }}&amp;toggle=det" target="_blank">
    Unsigned Company Contracts:
    </a>
    </td>
    <td>{% if total_unsigned_company_contracts._value != 0 %}<center><font style="color: #DA344D">◉</font></center>{% endif %}</td>
    <td>
    <a href="https://equipmentshare.looker.com/looks/827?f[unsigned_company_contracts_action_items.market]={{ f_market }}&amp;f[unsigned_company_contracts_action_items.district]={{ f_district }}&amp;f[unsigned_company_contracts_action_items.region]={{ f_region }}&amp;toggle=det" target="_blank">
    {{ total_unsigned_company_contracts._value }}
    </a>
    {% if total_unsigned_company_contracts._value != 0 %}
    <a href="https://equipmentshare.looker.com/looks/827?f[unsigned_company_contracts_action_items.market]={{ f_market }}&amp;f[unsigned_company_contracts_action_items.district]={{ f_district }}&amp;f[unsigned_company_contracts_action_items.region]={{ f_region }}&amp;toggle=det" target="_blank"> ➔</a>
    {% endif %}
    </td>
    </tr>
    <tr><td colspan="4"><hr style="border: 1px solid #DCDCDC; margin: 0;"></td></tr>



    <!-- COD Outstanding -->
    <tr>
    <td>
    <a href="https://equipmentshare.looker.com/dashboards/2021?Region={{ f_region }}&amp;District={{ f_district }}&amp;Market={{ f_market }}" target="_blank">
    COD Outstanding:
    </a>
    </td>
    <td>{% if cod_outstanding._value != 0 %}<center><font style="color: #DA344D">◉</font></center>{% endif %}</td>
    <td>
    <a href="https://equipmentshare.looker.com/dashboards/2021?Region={{ f_region }}&amp;District={{ f_district }}&amp;Market={{ f_market }}" target="_blank">
    {{ cod_outstanding._value }}
    </a>
    {% if cod_outstanding._value != 0 %}
    <a href="https://equipmentshare.looker.com/dashboards/2021?Region={{ f_region }}&amp;District={{ f_district }}&amp;Market={{ f_market }}" target="_blank"> ➔</a>
    {% endif %}
    </td>
    </tr>

    <tr><td colspan="4"><hr style="border: 1px solid #DCDCDC; margin: 0;"></td></tr>

    <!-- Pending Invoices -->
    <tr>
    <td>
    <a href="https://admin.equipmentshare.com/#/home/transactions/invoices/search?status=pending&branch={{ f_market_id }}&includeDeletedInvoices=false" target="_blank">
    Pending Invoices:
    </a>
    </td>
    <td>{% if pending_invoices._value != 0 %}<center><font style="color: #DA344D">◉</font></center>{% endif %}</td>
    <td>
     <a href="https://admin.equipmentshare.com/#/home/transactions/invoices/search?status=pending&branch={{ f_market_id }}&includeDeletedInvoices=false" target="_blank">
    {{ pending_invoices._value }}
    </a>
    {% if pending_invoices._value != 0 %}
     <a href="https://admin.equipmentshare.com/#/home/transactions/invoices/search?status=pending&branch={{ f_market_id }}&includeDeletedInvoices=false" target="_blank"> ➔</a>
    {% endif %}
    </td>
    </tr>

    <tr><td colspan="4"><hr style="border: 1px solid #DCDCDC; margin: 0;"></td></tr>

        <!-- Open POs -->
    <tr>
    <td>
    <a href="https://equipmentshare.looker.com/looks/1190?f[market_region_xwalk.market_name]={{ f_market }}&amp;f[market_region_xwalk.district]={{ f_district }}&amp;f[market_region_xwalk.region_name]={{ f_region }}&amp;toggle=det" target="_blank">
    Open POs:
    </a>
    </td>
    <td>{% if total_open_pos._value != 0 %}<center><font style="color: #DA344D">◉</font></center>{% endif %}</td>
    <td>
     <a href="https://equipmentshare.looker.com/looks/1190?f[market_region_xwalk.market_name]={{ f_market }}&amp;f[market_region_xwalk.district]={{ f_district }}&amp;f[market_region_xwalk.region_name]={{ f_region }}&amp;toggle=det" target="_blank">
    {{ total_open_pos._value }}
    </a>
    {% if total_open_pos._value != 0 %}
     <a href="https://equipmentshare.looker.com/looks/1190?f[market_region_xwalk.market_name]={{ f_market }}&amp;f[market_region_xwalk.district]={{ f_district }}&amp;f[market_region_xwalk.region_name]={{ f_region }}&amp;toggle=det" target="_blank"> ➔</a>
    {% endif %}
    </td>
    </tr>

    <tr><td colspan="4"><hr style="border: 1px solid #DCDCDC; margin: 0;"></td></tr>

        <!-- Off Rents -->
    <tr>
    <td>
    <a href="https://admin.equipmentshare.com/#/home/dispatch" target="_blank">
    Off Rents or Extensions:
    </a>
    </td>
    <td>{% if total_off_rents._value != 0 %}<center><font style="color: #DA344D">◉</font></center>{% endif %}</td>
    <td>
     <a href="https://admin.equipmentshare.com/#/home/dispatch" target="_blank">
    {{ total_off_rents._value }}
    </a>
    {% if total_off_rents._value != 0 %}
     <a href="https://admin.equipmentshare.com/#/home/dispatch" target="_blank"> ➔</a>
    {% endif %}
    </td>
    </tr>

    <tr><td colspan="4"><hr style="border: 1px solid #DCDCDC; margin: 0;"></td></tr>

        <!-- Overdue Deliveries -->
    <tr>
    <td>
    <a href="https://admin.equipmentshare.com/#/home/dispatch" target="_blank">
    Overdue Deliveries:
    </a>
    </td>
    <td>{% if total_overdue_deliveries._value != 0 %}<center><font style="color: #DA344D">◉</font></center>{% endif %}</td>
    <td>
     <a href="https://admin.equipmentshare.com/#/home/dispatch" target="_blank">
    {{ total_overdue_deliveries._value }}
    </a>
    {% if total_overdue_deliveries._value != 0 %}
     <a href="https://admin.equipmentshare.com/#/home/dispatch" target="_blank"> ➔</a>
    {% endif %}
    </td>
    </tr>

    <tr><td colspan="4"><hr style="border: 1px solid #DCDCDC; margin: 0;"></td></tr>



    </table> ;;
}



  filter: region_name_filter_mapping {
    type: string

  }

  filter: district_filter_mapping {
    type: string

  }

  filter: market_name_filter_mapping {
    type: string

  }

  filter: market_type_filter_mapping {
    type: string
  }

  set: detail {
    fields: [
        item,
  market_id,
  item_count
    ]
  }
}
