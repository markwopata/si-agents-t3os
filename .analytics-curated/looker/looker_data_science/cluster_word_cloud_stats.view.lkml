view: cluster_word_cloud_stats {
  derived_table: {
    sql:
with ranked_terms as (
    select
      "index" as cluster_id,
      "term" as terms,
      "tfidf_mean" as metric,
      row_number() over (partition by cluster_id order by metric desc) as term_rank
    from data_science.ds_scratch_not_for_prod.mike_voc_clustering_output_data_keywords
    order by cluster_id, metric desc
)
, population_size as (
  select
    "cluster_id" as cluster_id,
    count(*) as population_size
  from data_science.ds_scratch_not_for_prod.mike_voc_clustering_output_data_labels
  group by cluster_id
)
, top_terms_large as (
  select
    cluster_id,
    listagg(terms, ', ') as term_list
  from ranked_terms
  where term_rank <= 30
  group by cluster_id
)
, top_terms_small as (
  select
    cluster_id,
    listagg(terms, ', ') as top_keywords
  from ranked_terms
  where term_rank <= 5
  group by cluster_id
)
select
  top_terms_large.cluster_id,
  top_terms_large.term_list,
  top_terms_small.top_keywords,
  population_size.population_size
from population_size
join top_terms_large on population_size.cluster_id = top_terms_large.cluster_id
join top_terms_small on top_terms_large.cluster_id = top_terms_small.cluster_id
where top_terms_large.cluster_id >= 0
order by cluster_id
       ;;
  }


  dimension: cluster_id {
    type: number
    sql: ${TABLE}.cluster_id ;;
  }

  dimension: population_size {
    type: number
    sql: ${TABLE}.population_size ;;
  }

  dimension: term_list {
    type: string
    sql: ${TABLE}.term_list ;;
  }

  dimension: top_keywords {
    type: string
    sql: ${TABLE}.top_keywords ;;
  }

  dimension: word_cloud_link {
    link: {
      label: "Cluster ID"
      url: "https://equipmentshare.looker.com/dashboards/717?Index={{cluster_id}}"
    }
    sql: ${TABLE}.top_keywords;;
  }

  set: detail {
    fields: [cluster_id, population_size, word_cloud_link, top_keywords]
  }
}
