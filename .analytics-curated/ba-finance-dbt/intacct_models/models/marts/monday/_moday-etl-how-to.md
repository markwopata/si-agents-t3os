1. Invite  [ba.svc@equipmentshare.com](mailto:ba.svc@equipmentshare.com) to the Monday board so the BA Service user has access.
2. Once this [FiveTran job](https://fivetran.com/dashboard/connections/smugness_cabin/status?groupId=revisable_roamed&service=monday&syncChartPeriod=1%20Day) completes, check the table in Snowflake
    
    ```sql
    SELECT *
    FROM analytics.monday.board
    WHERE name ilike '%<most of the name of the board>%';
    ```
    
    * You could also search by ID. It should match the ID shown in the board url. Note that this column is of varchar type in `analytics.monday.board`.
3. As long as the board is synced into [analytics.monday.columns](https://gitlab.internal.equipmentshare.com/business-intelligence/ba-finance-dbt/-/blob/main/intacct_models/models/staging/analytics/monday/analytics_monday__sources.yml?ref_type=heads#L21) (every 6 hours), run the query to get a starting template for adding your board’s columns to the [column map seed file](https://gitlab.internal.equipmentshare.com/business-intelligence/ba-finance-dbt/-/blob/main/intacct_models/seeds/seed_monday_board_column_map.csv?ref_type=heads). Add the rows to the seed csv, making any needed changes to `column_type_override` and `skip_etl_flag`.
    
    ```sql
    SELECT board_id, id, column_title, '' as column_type_override, FALSE as skip_etl_flag
    FROM analytics.monday.STG_ANALYTICS_MONDAY__COLUMNS
    WHERE board_id = '<your board id>'; 
    ```
    
    1. You will need to rename the `column_title` values to be snakecase.
    2. `column_type_override` is for overriding the given data type
    3. `skip_etl_flag` removes the column from the etl step when set to `TRUE`
4. Make a .yml file for your board, [like this](https://gitlab.internal.equipmentshare.com/business-intelligence/ba-finance-dbt/-/blob/main/intacct_models/models/marts/monday/master_markets_board.yml?ref_type=heads), into that same directory.
5. Make a .sql file for your board that calls the Monday-table-from-map macro, [like this](https://gitlab.internal.equipmentshare.com/business-intelligence/ba-finance-dbt/-/blob/main/intacct_models/models/marts/monday/master_markets_board.sql?ref_type=heads), into that same directory.
    - sample dbt build command: `dbt build --select [model_name] --defer --state $DBT_PROJECT_DIR/target-base`
    - Double-check that the built dbt model values match what's in the Monday board. If not, the [Monday macro](https://gitlab.internal.equipmentshare.com/business-intelligence/ba-finance-dbt/-/blob/main/intacct_models/macros/monday_board_to_table.sql?ref_type=heads) may not be registering the type_maps — add it as needed. Contact Erik Chu or Vishesh if you need help.
6. Create your MR, adding Erik Chu or Vishesh as a reviewer.