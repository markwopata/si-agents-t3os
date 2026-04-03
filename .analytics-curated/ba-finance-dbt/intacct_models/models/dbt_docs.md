{% docs __overview__ %}
# Financial Analytics dbt Project
This dbt project contains models created and managed by the financial analytics team. Some models are built for other teams. Any team is welcome to add models or make changes. dbt docs are generated every time the production job runs and upload to a static s3 site.

## Useful Links
- [Gitlab](https://gitlab.internal.equipmentshare.com/business-intelligence/ba-finance-dbt) - This project's code is hosted in gitlab. You must make an MR and have someone check/approve it.
- [Jenkins](https://bi-jenkins.internal.equipmentshare.com/job/FA%20Monitored%20-%20FA%20Finance%20dbt%20Model%20Runner%20Jenkinsfile/) - The project is scheduled to run hourly in Jenkins
- [Elementary](https://ba-finance-dbt.prod.internal.equipmentshare.com/elementary) - We use elementary for monitoring model runs/tests.
- [Monte Carlo](https://getmontecarlo.com/assets?search=&tab=TABLES) - Monte Carlo can also be used for data observability.

## Navigating this Website
On the left, there is a Projects > intacct_models page which you can use to see models and other dbt objects. The __search bar__ at the top is the easiest way to find specific models.

## Model documentation
Each model page shows you description, columns, what models use this model, what this model depends on, code that creates the model, and other useful details. The code by default shows you dbt jinja syntax. You click on the Compiled button to see compiled snowflake query.

## Lineage
There's a blue graph button in the bottom right corner on every model page that will show you lineage for the model (what models depend on this model and what tables this model depends on). This is extremely useful to debug where data from your model is coming from or who/what is using your model.

You can zoom in and out with your mouse wheel or two finger swiping on mac. You can right click on nodes and refocus the graph on different models. You can also go to the documentation for the model from this menu.

Node colors:
- green: source (reference to the actual source database table)
- blue: models
- purple: current node

More advanced users can filter/tweak the graph using --select/--exclude which uses dbt's select/exclude syntax. 
Examples: 
- +int_commissions_combined_final - show everything upstream that builds this model
- int_commissions_combined_final+ - show me what this model is used by
- 2+gl_detail - show me what builds gl_detail, back 2 levels
- tag:commissions - show me all models tagged commissions

{% enddocs %}
