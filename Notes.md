# The CodeQL pipeline only works in public repo and not in private repo
for private repo, you need to use the CodeQL CLI, as described in the following steps.
and then view the results in sarif-web-viewer

# how to scan locally 

```
gh extension install github/gh-codeql
gh codeql database create js-codeql-db --language=javascript
gh codeql pack download codeql/javascript-queries
gh codeql resolve packs
gh codeql database analyze js-codeql-db   --format=sarif-latest   --output=codeql-results.sarif   --threads=2
gh codeql database analyze ~junedm/work/codeql-databases/js-codeql-db   --format=sarif-latest   --output=codeql-results.sarif   --threads=2
```

# View the Report in the Browser

https://microsoft.github.io/sarif-web-component/