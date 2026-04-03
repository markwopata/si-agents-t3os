view: user_district_pull {
  derived_table: {
    sql:
        select

              case when position(' ',coalesce(cd.nickname,cd.first_name)) = 0 then concat(coalesce(cd.nickname,cd.first_name), ' ', cd.last_name)
                else concat(coalesce(cd.nickname,concat(cd.first_name, ' ',cd.last_name))) end as rep,

      IFF(xw_district.district IS NOT NULL, xw_district.district,
      IFF(xw_region.default_district IS NOT NULL, xw_region.default_district,
      IFF(split_part(DEFAULT_COST_CENTERS_FULL_PATH,'/',2) = 'Corp' OR split_part(DEFAULT_COST_CENTERS_FULL_PATH,'/',2) = 'National', '4-6',
      split_part(DEFAULT_COST_CENTERS_FULL_PATH,'/',3)))) as assigned_district

      from analytics.payroll.company_directory cd
      left join
      (select distinct district from analytics.public.market_region_xwalk) as xw_district
      ON xw_district.district = split_part(DEFAULT_COST_CENTERS_FULL_PATH,'/',3)
      left join
      (select region_name, min(district) as default_district from analytics.public.market_region_xwalk group by region_name) as xw_region
      ON xw_region.region_name =  IFF(split_part(DEFAULT_COST_CENTERS_FULL_PATH,'/',2) =
      'R2 Mountain West', 'Mountain West', split_part(split_part(DEFAULT_COST_CENTERS_FULL_PATH,'/',2), ' ',2))-- Finding default market for region level employees
      where lower(work_email) = '{{ _user_attributes['email'] }}'

      ;;
  }

  dimension: pk {
    hidden: yes
    primary_key: yes
    sql: concat(${rep}, " - ", ${assigned_district}) ;;
  }

  dimension: rep {
    type: string
    sql: ${TABLE}."REP" ;;
  }

  dimension: assigned_district {
    type: string
    sql: ${TABLE}."ASSIGNED_DISTRICT" ;;
  }


  set: detail {
    fields: [
      rep,
      assigned_district
    ]
  }
}
