Models comprises of various layers of design: staging, intermediate, and marts. Each model lives in a single file and contains logic that either transforms raw data into a dataset that is ready for analytics or, more often, is an intermediate step in such a transformation. Models may be sql or python files and are typically represented in the form of a select statement as a way to describe the model's structure.

See dbt [documentation](https://docs.getdbt.com/docs/build/models) for sql or python models for more information.
