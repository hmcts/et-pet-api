# Et S3 To Azure Transfer Gem

This gem provides a wrapper around the azure importer script (compiled with some modifications to allow it to be used in local environments as well as server environments) and is pre configured
using the standard ET environment variables.

It will be removed once we are migrated across to azure - hence putting it in a gem for easy removal

## Usage

From a command line do

```
bundle exec rails azure_import:import_files_from_s3

```

and it should just work

If you want it to perform even better (its really quick anyway) - then play with some of the underlying settings.  To find out what they
are do

```
bundle exec rails azure_import:import_files_from_s3 --help

```
