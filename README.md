# Product Syntax Help - the.error.expert

................................................................................

Most software products with a command-line interface (CLI) have the ability to
display the syntax of available comamnds and options to help the operator.

If you wish to submit an error report for a product and this product does not 
exist in this guide, please help our community by submitting details of the 
product you are reporting an error for. 

Create a pull request (PR) for this repository after gathering content using
this helper script to add product content to the proposed/ directory.
	
```
git clone https://github.com/theerrorexpert/product-syntax-help
cd product-syntax-help
export PATH=${PWD}/bin:$PATH
cd proposed
generate-syntax-help.sh <your product command>
```

NOTE: This script makes some assumptions as to the argument syntax. 

## Overrides

You can override several default value with environment variables.
For example if your command does not use `--version`, set VERSION_ARG
If your commands does not use `--help` set HELP_ARG

You can also pre-create your product directory, and place these values into
a `.override.cnf` file.

## Advanced help options
If your commands includes help for sub-commands you can add these. For
example this supports the additional help for `brew` when placed in the
`.override.cnf` file.

```
export EXTRA_HELP_COMMANDS="generate-extra-help-commands.sh"
export EXTRA_HELP_ARGS="commands"
```

Your PR should in the description include the name of your product, a
public URL for the product and all generated content.

Thank you for contributing to **the.error.expert**
