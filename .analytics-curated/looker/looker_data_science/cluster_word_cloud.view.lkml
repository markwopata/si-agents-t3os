view: cluster_word_cloud {
  derived_table: {
    sql: -- select index, term, tfidf_mean
      -- from data_science.public.mike_voc_clustering_output_data_keywords
      select "index", "term", "tfidf_mean" from data_science.ds_scratch_not_for_prod.MIKE_VOC_CLUSTERING_OUTPUT_DATA_KEYWORDS
       ;;
  }

  dimension: index {
    type: number
    sql: ${TABLE}."index" ;;
  }

  dimension: term {
    type: string
    sql: ${TABLE}."term" ;;
  }

  dimension: tfidf_mean_d {
    type: number
    sql: ${TABLE}."tfidf_mean" ;;
  }

  measure: tfidf_mean {
    type: average
    sql: ${tfidf_mean_d} ;;
  }

  set: detail {
    fields: [index, term, tfidf_mean]
  }
}
