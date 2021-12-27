# Downstream

A tool to alert users when files they're changing may cause docs to be out of date. Downstream is more or less a 
reverse dependency manager in that it's used to describe what relies on your code rather than what your code relies on.

## Why?

There's a pretty consistent problem accross orgs I've been in where people are hesitent to write docs, guides, etc 
because they're concerned that what they write will rapidly become out of date. This fear is legitimate, and out of 
date docs are a common problem. Letting people know what docs need to be updated upon file changes is a step towards 
solving this problem.

## Installation

### `pre-commit` Installation

In your `.pre-commit-config.yaml` add the following

```yaml
repos:
-   repo: https://github.com/twof/Downstream
    rev: 0.3.0
    hooks:
    -   id: downstream
```

Alternatively, if you would like to use Downstream on a system without Swift installed, you may use 
`-   id: downstream-docker`. You will need to have Docker installed on that system.

### Github Actions Installation

You can also have Github comment on PRs when file changes may necessitate other changes. Here is an example setup.

```yaml
name: pre-commit

on:
  workflow_dispatch:
  pull_request:
  push:
    branches: [master]

jobs:
  pre-commit:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v2
    - uses: actions/setup-python@v2
    - id: file_changes
      uses: trilom/file-changes-action@v1.2.3
      with:
        output: ' '
    - id: get_changes
      run: |
        content="$(swift run downstream -o human ${{ steps.file_changes.outputs.files }})"
        content="${content//'%'/'%25'}"
        content="${content//$'\n'/'%0A'}"
        content="${content//$'\r'/'%0D'}"
        echo "::set-output name=content::$content"
    - uses: daohoangson/comment-on-github@v2
      env:
        GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
      with:
        body: ${{ steps.get_changes.outputs.content }}
```

For some background, `file_changes` records a list of files that have been changed in this PR to 
`steps.file_changes.outputs.files`. It's basically the equivalent of `git diff --name-only`. 

These lines
```
content="${content//'%'/'%25'}"
content="${content//$'\n'/'%0A'}"
content="${content//$'\r'/'%0D'}"
```
are necessary due to [a bug in Github Actions](https://github.community/t/set-output-truncates-multiline-strings/16852) 
that prevents multiple lines from being passed to `set-output`.

### Project Structure

You will need to put a file called `downstream.yml` in the directory with the file you'd like to attach documentation 
to.
```
Sources/Downstream/
├── Associations.swift
├── downstream.yml
└── main.swift
```

`downstream.yml` will need to contain a `[String: [String]]` dictionary where the keys are file names in that directory
and values are links/paths/wherever users can find documentation that relies on that file. Anything under a "\*" will 
work as an asociation for the entire directory.

```yaml
associations:
  main.swift:
    - https://github.com/JohnSundell/Files/blob/master/Sources/Files.swift
    - https://github.com/twof/Downstream/edit/main/README.md
  Associations.swift:
    - https://github.com/twof/Downstream/edit/main/README.md
  *:
    - https://docs.downstream.io/usage
```

The hook is only capable of failing if a `downstream.yml` is invalid. Otherwise it only exists to provide information. 
Given the above example, if `Associations.swift` was changed, output would look like this

```
$ git commit -am "bumped pre-commit hook"
Downstream...............................................................Passed
- hook id: downstream
- duration: 1.19s

Due to changes made to Sources/downstream/main.swift, you may need to make updates to the following:
https://github.com/twof/Downstream/blob/main/README.md

[main b5db130] bumped pre-commit hook
 2 files changed, 1 insertion(+), 2 deletions(-)
```

### Usage

Beyond its usage as a pre-commit hook, Downstream can also be executed manually for integration with CI and whatnot like 
can be seen above with Github Actions. It can currently produce output based on the format requested by the user with 
the `-o` flag. Possible options are `human` for human friendly output like seen in the example above, `yaml`, `json`, 
and `list` which simply lists out all of the docs that may need updates in a format that's convenient for intake in a 
bash script.

```
$ downstream -h
USAGE: downstream-argument [--output-format <output-format>] [<files> ...]

ARGUMENTS:
<files>                 Input files

OPTIONS:
-o, --output-format <output-format>
The format of the output
-h, --help              Show help information.
```
