
<!-- README.md is generated from README.Rmd. Please edit that file -->

# waysign

<!-- badges: start -->

[![R-CMD-check](https://github.com/thomasp85/waysign/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/thomasp85/waysign/actions/workflows/R-CMD-check.yaml)
[![Codecov test
coverage](https://codecov.io/gh/thomasp85/waysign/graph/badge.svg)](https://app.codecov.io/gh/thomasp85/waysign)
<!-- badges: end -->

waysign is a multipurpose, high-performance router build on top of the
[path-tree](https://github.com/viz-rs/path-tree) library. A router
associates filepath-like patterns with a piece of data for latter
retrieval. Often that data is a function and the path to be matched
against the pattern comes from a URL, but it can be anything, adapting
to the need of the user.

## Installation

You can install the development version of waysign like so:

``` r
pak::pak("thomasp85/waysign")
```

## Example

Adapted from the [path-tree](https://docs.rs/path-tree/0.8.3/path_tree/)
docs

``` r
library(waysign)

router <- Waysign$new()

router$add_path("/", 1)
router$add_path("/login", 2)
router$add_path("/signup", 3)
router$add_path("/settings", 4)
router$add_path("/settings/:page", 5)
router$add_path("/:user", 6)
router$add_path("/:user/:repo", 7)
router$add_path("/public/:any*", 8)
router$add_path("/:org/:repo/releases/download/:tag/:filename.:ext", 9)
router$add_path("/:org/:repo/tags/:day-:month-:year", 10)
router$add_path("/:org/:repo/actions/:name\\::verb", 11)
router$add_path("/:org/:repo/:page", 12)
router$add_path("/:org/:repo/*", 13)
router$add_path("/api/+", 14)

router$find_object("/")
#> $path
#> [1] "/"
#> 
#> $object
#> [1] 1
#> 
#> $params
#> named character(0)
router$find_object("/login")
#> $path
#> [1] "/login"
#> 
#> $object
#> [1] 2
#> 
#> $params
#> named character(0)
router$find_object("/settings/admin")
#> $path
#> [1] "/settings/:page"
#> 
#> $object
#> [1] 5
#> 
#> $params
#>    page 
#> "admin"
router$find_object("/viz-rs")
#> $path
#> [1] "/:user"
#> 
#> $object
#> [1] 6
#> 
#> $params
#>     user 
#> "viz-rs"
router$find_object("/viz-rs/path-tree")
#> $path
#> [1] "/:user/:repo"
#> 
#> $object
#> [1] 7
#> 
#> $params
#>        user        repo 
#>    "viz-rs" "path-tree"
router$find_object("/rust-lang/rust-analyzer/releases/download/2022-09-12/rust-analyzer-aarch64-apple-darwin.gz")
#> $path
#> [1] "/:org/:repo/releases/download/:tag/:filename.:ext"
#> 
#> $object
#> [1] 9
#> 
#> $params
#>                                  org                                 repo 
#>                          "rust-lang"                      "rust-analyzer" 
#>                                  tag                             filename 
#>                         "2022-09-12" "rust-analyzer-aarch64-apple-darwin" 
#>                                  ext 
#>                                 "gz"
router$find_object("/rust-lang/rust-analyzer/tags/2022-09-12")
#> $path
#> [1] "/:org/:repo/tags/:day-:month-:year"
#> 
#> $object
#> [1] 10
#> 
#> $params
#>             org            repo             day           month            year 
#>     "rust-lang" "rust-analyzer"          "2022"            "09"            "12"
router$find_object("/rust-lang/rust-analyzer/actions/ci:bench")
#> $path
#> [1] "/:org/:repo/actions/:name\\::verb"
#> 
#> $object
#> [1] 11
#> 
#> $params
#>             org            repo            name            verb 
#>     "rust-lang" "rust-analyzer"            "ci"         "bench"
router$find_object("/rust-lang/rust-analyzer/stargazers")
#> $path
#> [1] "/:org/:repo/:page"
#> 
#> $object
#> [1] 12
#> 
#> $params
#>             org            repo            page 
#>     "rust-lang" "rust-analyzer"    "stargazers"
router$find_object("/rust-lang/rust-analyzer/stargazers/404")
#> $path
#> [1] "/:org/:repo/*"
#> 
#> $object
#> [1] 13
#> 
#> $params
#>              org             repo               *1 
#>      "rust-lang"  "rust-analyzer" "stargazers/404"
router$find_object("/public/js/main.js")
#> $path
#> [1] "/public/:any*"
#> 
#> $object
#> [1] 8
#> 
#> $params
#>          any 
#> "js/main.js"
router$find_object("/api/v1")
#> $path
#> [1] "/api/+"
#> 
#> $object
#> [1] 14
#> 
#> $params
#>   +1 
#> "v1"
```
