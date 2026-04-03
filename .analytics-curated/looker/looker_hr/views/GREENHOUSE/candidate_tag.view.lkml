view: candidate_tag {
   derived_table: {
    sql:

    with consolidate_tags as(
    select
    ct.candidate_id
    ,ct.tag_id
    ,ROW_NUMBER() OVER (PARTITION BY ct.candidate_id ORDER BY _fivetran_synced DESC ) AS tag_rn
    from greenhouse.candidate_tag ct
   )
   ,first_tag as(
   select
   *
   from consolidate_tags ct1
        left join greenhouse.tag t1
      on ct1.tag_id=t1.id
   where tag_rn=1
   )
    ,second_tag as(
   select
   *
   from consolidate_tags ct2
   left join greenhouse.tag t2
      on ct2.tag_id=t2.id
   where tag_rn=2
   )
   select
   ft.candidate_id
   ,ft.tag_id as first_tag_id
   ,ft.name as first_tag
   ,st.tag_id as second_tag_id
   ,st.name as second_tag
   from first_tag ft
   left join second_tag st
   on ft.candidate_id=st.candidate_id

    ;;
  }

  dimension_group: _fivetran_synced {
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
    sql: CAST(${TABLE}."_FIVETRAN_SYNCED" AS TIMESTAMP_NTZ) ;;
  }

  dimension: candidate_id {
    type: number
    # hidden: yes
    sql: ${TABLE}."CANDIDATE_ID" ;;
  }

  dimension: first_tag_id {
    type: number
    sql: ${TABLE}."FIRST_TAG_ID" ;;
  }

  dimension: second_tag_id {
    type: number
    sql: ${TABLE}."SECOND_TAG_ID" ;;
  }

  dimension: first_tag {
    type: string
    sql: ${TABLE}."FIRST_TAG" ;;
  }

  dimension: second_tag {
    type: string
    sql: ${TABLE}."SECOND_TAG" ;;
  }

  dimension: sales_experience {
    type: string
    sql: CASE WHEN ${first_tag_id}='910917' OR ${second_tag_id}='910917' THEN 'Yes' ELSE 'No' END ;;
  }

  dimension: sales_experience_tag {
    type: string
    sql: CASE WHEN ${office.name} = 'Kansas City, MO Tech Hub'
        OR ${office.name} = 'Columbia, MO HQ' THEN 'Corporate' ELSE ${sales_experience} END ;;
  }

  dimension: rental_experience {
    type: string
    sql: CASE WHEN ${first_tag_id}='910924' OR ${second_tag_id}='910924' THEN 'Yes' ELSE 'No' END ;;
  }

  dimension: rental_experience_tag {
    type: string
    sql: CASE WHEN ${office.name} = 'Kansas City, MO Tech Hub'
        OR ${office.name} = 'Columbia, MO HQ' THEN 'Corporate' ELSE ${rental_experience} END ;;
  }

  measure: count {
    type: count
    drill_fields: [candidate.first_name, candidate.last_name, candidate.id, tag.id, tag.name]
  }
}
