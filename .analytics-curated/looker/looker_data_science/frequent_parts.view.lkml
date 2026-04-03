view: frequent_parts {
  derived_table: {
    sql: with frequent_parts_search_results as (select equipment_make_id,
    equipment_model_id,
    parts,
    support
          from data_science.public.frequent_parts
          where 1 = 1
            {% if search_type._parameter_value == 'equipment_make_id' %}
            and equipment_make_id = {% parameter search_id %}
            {% elsif search_type._parameter_value != 'equipment_model_id' and search_type._parameter_value != 'asset_id'%}
            and equipment_make_id IS NULL
            {% endif %}

            {% if search_type._parameter_value == 'equipment_model_id' %}
            and equipment_model_id = {% parameter search_id %} and equipment_make_id is not NULL
            {% elsif search_type._parameter_value != 'asset_id' %}
            and equipment_model_id IS NULL
            {% endif %}

            {% if search_type._parameter_value == 'asset_id' %}
            and (equipment_make_id, equipment_model_id) in (select equipment_make_id, equipment_model_id from assets where asset_id = {% parameter search_id %})
            {% endif %}

            {% if max_number_of_parts._parameter_value != 'NULL' %}
            and ARRAY_SIZE(parts) <= {% parameter max_number_of_parts %}
            {% endif %}
      ), pn as (
        select p.value as part_number, *
        from frequent_parts_search_results fp, lateral flatten(fp.parts) as p
      ), pn1 as (
        select p.part_number, array_to_string(array_agg(distinct pt.description), ', ') as descriptions
        from es_warehouse.inventory.parts p
        join es_warehouse.inventory.part_types pt on (p.part_type_id = pt.part_type_id)
        where p.part_number in (select distinct part_number from pn)
        group by p.part_number
      ), result as (
        select equipment_make_id, equipment_model_id, pn.parts, support,
        array_to_string(array_agg(pn.part_number) within group (order by pn.part_number asc), ', ') as parts_str,
        array_agg(object_construct(as_varchar(pn.part_number), pn1.descriptions)) within group (order by pn.part_number asc) as part_lookup
        from pn
            join pn1 on (pn.part_number = pn1.part_number)
        group by equipment_make_id, equipment_model_id, pn.parts, support
      )
      select fpsr.equipment_make_id,
        fpsr.equipment_model_id,
        fpsr.parts_str,
        fpsr.support,
        fpsr.part_lookup,
        ARRAY_TO_STRING(array_agg(em.name) within group (order by fp.support desc), ', ') as top_makes
      from result fpsr
        left join data_science.public.frequent_parts fp using (parts)
        left join es_warehouse.public.equipment_makes em on (em.equipment_make_id = fp.equipment_make_id)
      where fp.equipment_make_id is not null
        and fp.equipment_model_id is null
      group by fpsr.equipment_make_id, fpsr.equipment_model_id, fpsr.parts_str, fpsr.support, fpsr.part_lookup
      order by fpsr.support desc
      ;;
  }

  dimension: parts {
    type: string
    sql: parts_str ;;
  }

  dimension: support {
    type: number
    sql: support ;;
  }

  dimension: part_lookup {
    type: string
    sql: part_lookup ;;
  }

  dimension: top_makes {
    type: string
    sql: top_makes ;;
  }

  set: detail {
    fields: [parts, support]
  }

  parameter: search_type {
    label: "1) Search Level Selection (All | Make | Model | Asset)"
    type: unquoted
    allowed_value: {
      label: "All Make/Models"
      value: "all"
    }

    allowed_value: {
      label: "Equipment Make ID"
      value: "equipment_make_id"
    }
    allowed_value: {
      label: "Equipment Model ID"
      value: "equipment_model_id"
    }
    allowed_value: {
      label: "Asset ID"
      value: "asset_id"
    }
    suggestions: ["All Make/Models"]
  }

  parameter: search_id {
    label: "2) (Make | Model | Asset) Search ID"
    type: number
    suggestions: ["224"]
  }

  parameter: max_number_of_parts {
    label: "3) Maximum Part Pattern Size"
    type: number
  }

}
