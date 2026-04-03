# About dbt models

## Definition

 A model is a single file containing a final select statement, and a dbt project can have multiple models, and models can even reference each other.

Further reading: https://docs.getdbt.com/docs/build/models

## Folder Structure

Folder structure is essential to successful dbt best practices because it allows for clear data-transformation story-telling as we go left to right in the DAG (https://docs.getdbt.com/terms/dag)

The main benefit of folder structure is modularity - code is reusable (DRY - Don't Repeat Yourself), easy to read, and less susceptible to error

There are **3** primary layers in the models directory that build upon each other:
* Staging - where data is cleaned
* Intermediate - business-related CTEs
* Mart - business-defined entities

Further reading: https://docs.getdbt.com/best-practices/how-we-structure/1-guide-overview

####  Staging
* where source data is cleaned (renaming, type casting, basic calculations)
    * remove fields that aren't needed in data marts

* joins are discouraged unless for corrections to ensure a 1-1 relationship with source data

Further reading: https://docs.getdbt.com/best-practices/how-we-structure/2-staging#staging-other-considerations

####  Intermediate

* the most confusing/subjective layer
* business-based transformations
* where staging models are joined together and allow us to create aggregations and breakdowns
* used for:
    * re-graining
    * isolating complex operations (commonly used joins)
    * eliminating 10+ joins in final model

Further reading: https://docs.getdbt.com/best-practices/how-we-structure/3-intermediate

#### Marts
* business-defined entities connected to a visualization tool exposed to business users
* most common types of marts are Dimension and Fact tables
* enriched version of source tables that's easier to use for reporting and analysis (ie orders with header and line level details)

Further reading: https://docs.getdbt.com/best-practices/how-we-structure/4-marts

