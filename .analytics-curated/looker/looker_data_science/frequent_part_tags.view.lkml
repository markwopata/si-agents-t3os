view: frequent_part_tags {
  derived_table: {
    sql: WITH to_wo AS (
              SELECT t.to_id AS work_order_id,
                  ti.part_id,
                  SUM(ti.cost_per_item * ti.quantity_received) AS cost,
                  SUM(ti.quantity_received) as quantity
              FROM es_warehouse.inventory.transactions t
                  JOIN es_warehouse.inventory.transaction_items ti ON t.transaction_id = ti.transaction_id
              WHERE t.transaction_type_id = 7
                  AND t.transaction_status_id = 5
                  and t.date_completed is not null
              GROUP BY t.to_id, ti.part_id
          ), from_wo AS ( SELECT t.from_id AS work_order_id,
              ti.part_id,
              SUM(ti.cost_per_item * ti.quantity_received) AS cost,
              SUM(ti.quantity_received) as quantity
              FROM es_warehouse.inventory.transactions t
                JOIN es_warehouse.inventory.transaction_items ti ON t.transaction_id = ti.transaction_id
              WHERE t.transaction_type_id = 9
                AND t.transaction_status_id = 5
                and t.date_completed is not null
              GROUP BY t.from_id, ti.part_id
          ), to_from_wo_diff AS ( SELECT to_wo.work_order_id,
              to_wo.part_id,
              to_wo.cost - COALESCE(from_wo.cost, 0) AS cost,
              to_wo.quantity - COALESCE(from_wo.quantity, 0) AS quantity
              FROM to_wo
                LEFT JOIN from_wo ON to_wo.work_order_id = from_wo.work_order_id AND to_wo.part_id = from_wo.part_id
          ), model_part_totals AS ( SELECT part_id, equipment_model_id, sum(quantity) as part_quantity
              FROM to_from_wo_diff t
              JOIN es_warehouse.work_orders.work_orders w using (work_order_id)
              JOIN es_warehouse.public.assets using(asset_id)
              WHERE 1 = 1
                {% if start_date._parameter_value != 'NULL' %}
                and w.date_completed >= {% parameter start_date %}
                {% endif %}
              GROUP BY part_id, equipment_model_id
          )
          SELECT part_id, part_number, pt.description, em.name as make, m.name as model, equipment_model_id, part_quantity
          FROM model_part_totals
              JOIN es_warehouse.inventory.parts p using (part_id)
              JOIN es_warehouse.inventory.part_types pt using (part_type_id)
              JOIN es_warehouse.public.equipment_models m using (equipment_model_id)
              JOIN es_warehouse.public.equipment_makes em using (equipment_make_id)
          where 1 = 1
            {% if search_type._parameter_value == 'part_id' %}
              {% if s_part_id._parameter_value != 'NULL' and s_part_id._parameter_value != "''"%}
              and part_id = TO_NUMBER({% parameter s_part_id %})
              {% endif %}
            {% elsif search_type._parameter_value == 'part_number'%}
              {% if s_part_id._parameter_value != 'NULL' and s_part_id._parameter_value != "''"%}
              and part_number = TO_VARCHAR({% parameter s_part_id %})
              {% endif %}
            {% endif %}

            {% if minimum_part_quantity._parameter_value != 'NULL' %}
            and part_quantity >= {% parameter minimum_part_quantity %}
            {% endif %}
          ORDER BY part_quantity desc
            ;;
  }

  dimension: part_id {
    type: number
    sql: part_id ;;
    link: {
      label: "Part Filter Type"
      url: "https://equipmentshare.looker.com/dashboards/482?Part+Filter+Type=part%5E_id&Filter+ID={{ value }}"
    }
  }

  dimension: part_number {
    type: string
    sql: part_number ;;
  }

  dimension: description {
    type: string
    sql: description ;;
  }

  dimension: make {
    type: string
    sql: make ;;
  }

  dimension: model {
    type: string
    sql: model ;;
  }

  dimension: equipment_model_id {
    type: number
    sql: equipment_model_id ;;
  }

  dimension: part_quantity {
    type: number
    sql: part_quantity ;;
  }

  set: detail {
    fields: [part_id, part_number]
  }

  parameter: search_type {
    label: "Part Filter Type"
    type: unquoted
    allowed_value: {
      label: "Part ID"
      value: "part_id"
    }

    allowed_value: {
      label: "Part Number"
      value: "part_number"
    }
    suggestions: ["Part ID"]
  }

  parameter: s_part_id {
    label: "Part Filter ID"
    type: string
  }

  parameter: minimum_part_quantity {
    label: "Minimum Part Usage Quantity"
    type: number
  }

  parameter: start_date {
    label: "Start Date"
    type: date
  }

}
