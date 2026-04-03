view: high_level_compatibility {
  derived_table: {
    sql:

    WITH machine_attachment_map (mm_type, attachment_type) AS (
    SELECT * FROM VALUES
        ('Mini Excavator or Backhoe','Mini Excavator'),
        ('Forklift','Material Handling'),
        ('Mini Track Loader','Mini-Track-Loader'),
        ('Rotating Telehandler','Rotator'),
        --('Telehandler','Telehandler'),
        ('Track Excavator','Track Excavator'),
        ('Wheel Loader or Track High Loader','Wheel Loader'),
        ('Track Loader','Track Loader')
)
select *
from machine_attachment_map
       ;;
  }

  dimension: mm_type {
    primary_key: yes
    type: string
    sql: ${TABLE}."MM_TYPE" ;;
  }

  dimension: attachment_type {
    type: string
    sql: ${TABLE}."ATTACHMENT_TYPE" ;;
  }

}
