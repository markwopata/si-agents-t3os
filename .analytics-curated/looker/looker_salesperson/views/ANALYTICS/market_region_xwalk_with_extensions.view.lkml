include: "/views/ANALYTICS/market_region_xwalk.view"

view: market_region_xwalk_with_extensions {
    extends: [market_region_xwalk]

    dimension: district_extend {
      label: "District"
      type: string
      sql:  COALESCE(${district}, 'Corporate') ;;
    }

    dimension: region_extend {
      label: "Region"
      type: string
      sql:  COALESCE(${region_name}, 'Corporate') ;;
    }


  }
