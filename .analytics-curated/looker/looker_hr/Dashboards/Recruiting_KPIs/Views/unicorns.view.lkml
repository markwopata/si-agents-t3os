view: unicorns {
  derived_table: {
    sql: WITH df as (SELECT * FROM ANALYTICS.GREENHOUSE.CANDIDATE_TAG ct left join
(SELECT * FROM ANALYTICS.GREENHOUSE.TAG WHERE (CONTAINS(NAME,'Unicorn') OR CONTAINS(NAME,'unicorn')  OR CONTAINS(NAME,'UNICORN'))) tag on ct.tag_id = tag.id )
SELECT CANDIDATE_ID, listagg(NAME, ', ') as TAGS from df
group by CANDIDATE_ID;;
  }



  dimension: candidate_id {
    primary_key: yes
    type: string
    sql: ${TABLE}."CANDIDATE_ID" ;;
  }

  dimension: tags {
    type: string
    sql: ${TABLE}."TAGS" ;;
  }

}
