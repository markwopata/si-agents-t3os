# looker_people_analytics

## Guidance for project setup and development

### Helpful resources online:
 - [Organizing your LookML into layers with refinements](https://www.googlecloudcommunity.com/gc/Modeling/Organizing-your-LookML-into-layers-with-our-new-refinement/td-p/572605)
 - [Fix your LookML project structure](https://www.spectacles.dev/post/fix-your-lookml-project-structure)

### General overview of struture:

- The project will be set up in layers using machine-generated LookML and hand-written changes.
- Each view layer (_base and _standard) should be organized in folders in accordance with our database organization (i.e., database > schema > table)
- There should be one .view.lkml file per raw database table

#### _base (layer)
 * This layer is for all of the machine-generated LookML views that reference source tables in Snowflake.
 * Use the Create View from Table option.
 * Little to no editing should be made to these views.
 * Machine-generated date dimensions groups WILL need to be adjusted in this layer using the following steps:

    1. Delete the machine-generated dimension group
    2. Create a new dimension using this format:
    ```
                  dimension: billing_approved {
                  type: date_raw
                  sql: ${TABLE}."BILLING_APPROVED_DATE" ;;
                  hidden: yes
                  }
    ```
**NOTE: you may consider removing the word "date" from the dimension name since Looker automatically adds that to date dimensions.


#### _standard (layer)
 * In this layer we will use the refinements option to hand-write changes to any of the base views. This allows us to preserve our column changes should we need to reload the base view.
   [LookML refinements](https://cloud.google.com/looker/docs/lookml-refinements)
```
Refinements are similar to extends in that they allow you to make changes to a base LookML object, but they make that change “in-place”, overwriting the already existing object, rather than requiring you to create a new name for a new object.
```
 * These hand-written changes could include:
    - declaring primary keys
    - hiding non-business dimensions
    - adding descriptions or labels
    - setting value formats
    - creating standard measures applicable to all
    - converting dates to `dimension_groups`.
 * Custom SQL views that are more general and have multiple applications should be created in this layer. For more specific custom SQL views, those will be created in the dashboard folder where the code is needed (more on that below).
 * The files in this layer should be saved using the view_name**.layer.lkml** format.
 * Dates should be refined in this layer and changed to dimension groups using the following format:

```
              dimension_group: billing_approved {
              type: time
              timeframes: [raw, date, week, month, quarter, year]
              sql: ${billing_approved} ;;
              description: "Billing approved date from invoice."
              }
```
**NOTE:** We may want to discuss as a team about a standard layer for explores. If we have explores that will likely need to be used for multiple dashboards, it would make sense to make a standard explore that we can just refine or extend into the dashboard folders we need it. Such as a greenhouse explore (assuming there is really only one way to build out that explore). This would elimiate duplication of work for multiple dashboards.

**NOTE:** We may also want to discuss as a team about how we organize our standard layers for easier navigation. Do we want to group like items, such as keys, dimensions, dates, measures, etc or maybe we do dimensions first, alphabetically, followed by measures, also alphabetically. This would be strictly to facilitate easier navigation and quicker troubleshooting.

#### Dashboard Folders
 * For each new dashboard built from the project, there should be a specific folder to house the code for each dashboard.
 * Within each dashboard folder will be at least one explore file and one model file type.
 * The explore file should include any custom SQL views that are specific to the dashboard, any further refinements to standard layer views, such as additional measures, as well as the final explore needed for the dashboard.

 ```
     EXAMPLE:
          include: "/_standard/some_view.explore.lkml"

     (custom sql view)
     view: custom_view {
       derived_table: {
        sql:
         ...
        }

     dimension:
     dimension:
     measure:

     view: +some_view { --this is a refinement of the included standard view(s) above to add dashboard specific measures.
      measure:
      measure:
      }
     }
     explore: custom_view {

```
 * The model file should be very simple, including only the references for the connection, the explore, and any additional labels, if necessary.

```
     EXAMPLE:

     connection:

     include: (should just be the one explore you created above)

     label: (optional if needed)
```
