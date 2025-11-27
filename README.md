
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
router <- waysign::signpost()

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
#> named list()
router$find_object("/login")
#> $path
#> [1] "/login"
#> 
#> $object
#> [1] 2
#> 
#> $params
#> named list()
router$find_object("/settings/admin")
#> $path
#> [1] "/settings/:page"
#> 
#> $object
#> [1] 5
#> 
#> $params
#> $params$page
#> [1] "admin"
router$find_object("/viz-rs")
#> $path
#> [1] "/:user"
#> 
#> $object
#> [1] 6
#> 
#> $params
#> $params$user
#> [1] "viz-rs"
router$find_object("/viz-rs/path-tree")
#> $path
#> [1] "/:user/:repo"
#> 
#> $object
#> [1] 7
#> 
#> $params
#> $params$user
#> [1] "viz-rs"
#> 
#> $params$repo
#> [1] "path-tree"
router$find_object("/rust-lang/rust-analyzer/releases/download/2022-09-12/rust-analyzer-aarch64-apple-darwin.gz")
#> $path
#> [1] "/:org/:repo/releases/download/:tag/:filename.:ext"
#> 
#> $object
#> [1] 9
#> 
#> $params
#> $params$org
#> [1] "rust-lang"
#> 
#> $params$repo
#> [1] "rust-analyzer"
#> 
#> $params$tag
#> [1] "2022-09-12"
#> 
#> $params$filename
#> [1] "rust-analyzer-aarch64-apple-darwin"
#> 
#> $params$ext
#> [1] "gz"
router$find_object("/rust-lang/rust-analyzer/tags/2022-09-12")
#> $path
#> [1] "/:org/:repo/tags/:day-:month-:year"
#> 
#> $object
#> [1] 10
#> 
#> $params
#> $params$org
#> [1] "rust-lang"
#> 
#> $params$repo
#> [1] "rust-analyzer"
#> 
#> $params$day
#> [1] "2022"
#> 
#> $params$month
#> [1] "09"
#> 
#> $params$year
#> [1] "12"
router$find_object("/rust-lang/rust-analyzer/actions/ci:bench")
#> $path
#> [1] "/:org/:repo/actions/:name\\::verb"
#> 
#> $object
#> [1] 11
#> 
#> $params
#> $params$org
#> [1] "rust-lang"
#> 
#> $params$repo
#> [1] "rust-analyzer"
#> 
#> $params$name
#> [1] "ci"
#> 
#> $params$verb
#> [1] "bench"
router$find_object("/rust-lang/rust-analyzer/stargazers")
#> $path
#> [1] "/:org/:repo/:page"
#> 
#> $object
#> [1] 12
#> 
#> $params
#> $params$org
#> [1] "rust-lang"
#> 
#> $params$repo
#> [1] "rust-analyzer"
#> 
#> $params$page
#> [1] "stargazers"
router$find_object("/rust-lang/rust-analyzer/stargazers/404")
#> $path
#> [1] "/:org/:repo/*"
#> 
#> $object
#> [1] 13
#> 
#> $params
#> $params$org
#> [1] "rust-lang"
#> 
#> $params$repo
#> [1] "rust-analyzer"
#> 
#> $params$`*1`
#> [1] "stargazers/404"
router$find_object("/public/js/main.js")
#> $path
#> [1] "/public/:any*"
#> 
#> $object
#> [1] 8
#> 
#> $params
#> $params$any
#> [1] "js/main.js"
router$find_object("/api/v1")
#> $path
#> [1] "/api/+"
#> 
#> $object
#> [1] 14
#> 
#> $params
#> $params$`+1`
#> [1] "v1"
```
