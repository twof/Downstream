# Downstream

A pre-commit hook to alert users when files they're changing may cause docs to be out of date. Downstream is more or less a reverse dependency manager in that it's used to describe what relies on your code rather than what your code relies on.

### `pre-commit` Installation

In your `.pre-commit-config.yaml` add the following

```yaml
repos:
-   repo: https://github.com/twof/Downstream
    rev: 0.0.3
    hooks:
    -   id: downstream
```

### Project Structure

You will need to put a file called `downstream.yml` in the directory with the file you'd like to attach documentation to.
```
Sources/Downstream/
├── Associations.swift
├── downstream.yml
└── main.swift
```

`downstream.yml` will need to contain a `[String: [String]]` dictionary where the keys are file names in that directory and values are links/paths/wherever users can find documentation that relies on that file.
```yaml
associations:
  main.swift:
    - https://github.com/JohnSundell/Files/blob/master/Sources/Files.swift
    - https://github.com/twof/Downstream/edit/main/README.md
  Associations.swift
    - https://github.com/twof/Downstream/edit/main/README.md
```

The hook is only capable of failing if a `downstream.yml` is invalid. Otherwise it only exists to provide information. Given the above example, if `Associations.swift` was changed, output would look like this

```
$ git commit -am "bumped pre-commit hook"
Downstream...............................................................Passed
- hook id: downstream
- duration: 1.19s

Our records indicate that you may need to update the docs at https://github.com/twof/Downstream/edit/main/README.md because changes were made to Associations.swift

[main b5db130] bumped pre-commit hook
 2 files changed, 1 insertion(+), 2 deletions(-)
```
