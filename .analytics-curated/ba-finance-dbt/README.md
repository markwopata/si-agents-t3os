# ba-finance-dbt

## Getting Started

- clone the [repo](https://gitlab.internal.equipmentshare.com/business-intelligence/ba-finance-dbt) from Gitlab onto your local machine
- run the following commands:
    - `poetry shell`
        - activates the virtual env
    - `cd intacct_models`
        - go into the dbt folder where the models are
    - `poetry run pre-commit install`
        - installs the git hooks 
        - NOTE: You only need to run this once, and it won't need to be done again.

###  Navigating the CLI
- dbt is run via the command line. Here are the essential [commands](https://www.datacamp.com/cheat-sheet/bash-and-zsh-shell-terminal-basics-cheat-sheet) for navigating folders
### dbt defer
- make sure you're logging into the [AWS Dev Portal](https://equipmentshare.awsapps.com/start/#/?tab=accounts)
  - in the CLI, can also run `aws sso login` and then `pAuth`
  - Our hourly Jenkins job runs dbt and uploads the manifest to S3. This script copies the manifest from the S3 bucket into the `target-base` folder in your repo, ensuring that the most recent manifest is used for [dbt defer](https://docs.getdbt.com/blog/defer-to-prod) runs

- make sure the production manifest is in your repo. in intacct_models folder, run `./shell_scripts/aws_copy_manifest.sh`
- now you can run dbt defer: `dbt build --select [your_new_model] --defer --state $DBT_PROJECT_DIR/target-base `  
  - ex: drop your dev schema and run this command: `dbt build --select int_asset4000_calculations --defer --state $DBT_PROJECT_DIR/target-base `
  - this will create one new model in your dev schema using production models
    - It also finds your repo folder dynamically (from the environment variable $DBT_PROJECT), since users can place it anywhere

### dbt state: modified
dbt supports state-based selection, which compares nodes against a prior project manifest. This makes it easy to see what changed.

A common use case is when you modify multiple models that aren’t connected in the DAG (e.g., renaming columns).

Steps:
- To get the latest production manifest, run `./shell_scripts/aws_copy_manifest.sh` from the intacct_models folder. Without this, changes made to main won’t appear
- to see which models were modified, run `dbt ls --models state:modified  --exclude state:modified.relation --state $DBT_PROJECT_DIR/target-base`
  - This compares the local manifest (target/) against the production manifest (target-base/)
  - this excludes changes to database/schema/alias
- to build the modified models, run: 
`dbt build --select state:modified+ --exclude state:modified.relation --state $DBT_PROJECT_DIR/target-base --defer --state $DBT_PROJECT_DIR/target-base`
  - This builds the modified models + downstream models using defer (see above)

### Recce (data-diff tool)
- [Recce](https://docs.userecce.com/) is a data-change validation tool for dbt projects, providing a UI to compare feature branch changes against the production. It's able to do so by comparing feature branch `manifest.json` vs production `manifest.json`
- Some useful diffs that can be explored:
  - row count diff
  - value diff
  - lineage impact
  - and much more
- We can use these validations in our pull request (PR) comment to demonstrate proof-of-correctness of your modeling changes
- in intacct_models folder, run `./shell_scripts/recce_server.sh`

ie 
![alt text](image.png)

## Useful commands
- `dbt build`
  - Run and test the model
- `dbt run`
  - Run, don't test the model
- `dbt test`
  - Run all tests for the model
- `dbt run --model=gl_detail`
  - Run a specific model
- `dbt build --select "*disc*"`
  - Run all models that match string
- `dbt build --select +market`
  - Run market model plus any upstream models
  - If you put the plus at the end, it will run down stream models
- `sqlfluff fix --dialect snowflake --force`
  - Run sqlfluff auto-formatting. 

## Jenkins/full build commands
```
# Load credentials to environment variables
poetry run python start.py

cd intacct_models
dbt deps
dbt build --profiles-dir ../ --threads 8

# This command will upload the dbt job results to monte carlo - giving us dbt pipeline visibility in monte carlo!
montecarlo --config-path ../ --profile intacct import dbt-run --manifest target/manifest.json --run-results target/run_results.json

# Clean up
cd ..
poetry run python finish.py
```
