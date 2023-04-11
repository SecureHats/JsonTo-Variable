![logo](./media/sh-banner.png)
=========
[![Maintenance](https://img.shields.io/maintenance/yes/2023.svg?style=flat-square)]()
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg?style=flat-square)](http://makeapullrequest.com)</br>
[![Good First Issues](https://img.shields.io/github/issues/securehats/toolbox/good%20first%20issue?color=important&label=good%20first%20issue&style=flat)](https://github.com/securehats/toolbox/issues?q=is%3Aissue+is%3Aopen+label%3A%22good+first+issue%22)
[![Needs Feedback](https://img.shields.io/github/issues/securehats/toolbox/needs%20feedback?color=blue&label=needs%20feedback%20&style=flat)](https://github.com/securehats/toolbox/issues?q=is%3Aopen+is%3Aissue+label%3A%22needs+feedback%22)

# SecureHats - JsonTo-Variable solution

This GitHub action can be used to create workflow variables from a json file<br />

### Example 1

> Add the following code block to your Github workflow:

```yaml
name: Create-Variables
on: push

jobs:
  Create-Variables:
    name: Creating and passing variables
    runs-on: ubuntu-latest
    steps:
      - name: Check out repository code
        uses: actions/checkout@v3
      - name: SecureHats JsonTo-Variable
        uses: SecureHats/JsonTo-Variable@v0.0.15
        with:
          filePath: 'variables/env.json'
          arraySeparator: ','          
```

### Inputs

This Action has the following format inputs.

| Name | Required | Description
|-|-|-|
| **`filePath`**  | true | Path to the directory containing the log files to be send, relative to the root of the project.<br /> This path is optional and defaults to the project root, in which case all files CSV files and JSON wills across the entire project tree will be discovered.  
| **`arraySeparator`** | true | The character used to separate an array of values.


## Current limitations / Under Development

See backlog

If you encounter any issues, or hae suggestions for improvements, feel free to open an Issue

[Create Issue](../../issues/new/choose)
