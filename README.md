# the.error.expert helpsyntax

Most software products with a command-line interface (CLI)  have a help syntax
that can be displayed to help the operator.

If you wish to submit an error report for a product and it does not exist here,
please help our community by submitting details of the product you are
reporting an error for. 

Create a pull request (PR) for this repository after gathering content from 
this helper script to add product content to the proposed/ directory.
	
```
$ cd proposed
$ /bin/bash -c "$(curl -fsSL https://gist.githubusercontent.com/theerrorexpert/844bbac16cb7becf85ca263552f8c696/raw/generate-helpsyntax.sh)"  
```

NOTE: This script makes some assumptions as to the argument syntax. If these
are incorrect you should download and modify the script accordingly, also
including this in your PR.

Your PR should in the description include the name of your product, a
public URL and ideally the output of this command.

Thank you for contributing to **the.error.expert**
