#' A simple, multi-purpose router
#'
#' @description
#' The `signpost` class implements a high-performance, multipurpose router build
#' on top of the [path-tree](https://github.com/viz-rs/path-tree) library. A
#' router associates filepath-like patterns with a piece of data for latter
#' retrieval. Often that data is a function and the path to be matched against
#' the pattern comes from a URL, but it can be anything, adapting to the need
#' of the user. Objects of the class uses reference semantics so they do not get
#' copied and alterations will affect all instances of the object.
#'
#' @details
#' The path pattern supported by Waysign mirrors that of path-tree and while the
#' full documentation can be found there, it will be briefly explained here.
#'
#' A path pattern consist of zero, one, or more elements separated by `/`
#' (always started by `/`). Each element can either be a literal or one of the
#' following variable types:
#'
#' * `:name` matches a single path piece
#' * `:name?` matches an optional path piece
#' * `:name+` or `+` matches one or more path pieces
#' * `:name*` or `*` matches zero or more path pieces
#'
#' A variable don't have to consume a full path element. E.g. you could have a
#' path pattern like this: `/date/:day-:month-:year` which would match to paths
#' such as `/date/24-12-2025`
#'
#' # Methods
#'
#' ## `add_path(path, object)`
#' Add a new path to the router. See *Details* for allowed path syntax
#'
#' ### Arguments
#' * `path`: A string giving the path to add
#' * `object`: An R object to be associated with the path
#'
#' ### Returns
#' The object, invisibly
#
#' ## `find_object(path)`
#' Search for a path in the router
#'
#' ### Arguments
#' * `path`: The path to search for
#'
#' ### Returns
#' If no matching path is found then `NULL`, otherwise a list with
#' the elements `path` giving the path pattern that was matched, `object`
#' giving the object associated with the path, and `params` being a named list
#' of the path parameters from the match
#'
#' ## `remove_path(path)`
#' Remove a path from the router. Due to the underlying implementation this
#' causes a complete rebuild of the router
#'
#' ### Arguments
#' * `path`: A string giving the path to remove
#'
#' ### Returns
#' The object, invisibly
#'
#' ## `has_path(path)`
#' Check if a given path is present in the router
#'
#' ### Arguments
#' * `path`: The path pattern to check for
#'
#' ### Returns
#' A boolean indicating the existence of `path`
#'
#' ## `paths()`
#' Provides a named list of all the objects, named by their path pattern
#'
#' @return A `waysign` router. See the *Methods* section for a description of
#' its behavior
#'
#' @export
#'
#' @examples
#' # Adapted from path-tree docs
#' router <- signpost()
#'
#' router$add_path("/", 1)
#' router$add_path("/login", 2)
#' router$add_path("/signup", 3)
#' router$add_path("/settings", 4)
#' router$add_path("/settings/:page", 5)
#' router$add_path("/:user", 6)
#' router$add_path("/:user/:repo", 7)
#' router$add_path("/public/:any*", 8)
#' router$add_path("/:org/:repo/releases/download/:tag/:filename.:ext", 9)
#' router$add_path("/:org/:repo/tags/:day-:month-:year", 10)
#' router$add_path("/:org/:repo/actions/:name\\::verb", 11)
#' router$add_path("/:org/:repo/:page", 12)
#' router$add_path("/:org/:repo/*", 13)
#' router$add_path("/api/+", 14)
#'
#' router$find_object("/")
#' router$find_object("/login")
#' router$find_object("/settings/admin")
#' router$find_object("/viz-rs")
#' router$find_object("/viz-rs/path-tree")
#' router$find_object("/rust-lang/rust-analyzer/tags/2022-09-12")
#' router$find_object("/rust-lang/rust-analyzer/actions/ci:bench")
#' router$find_object("/rust-lang/rust-analyzer/stargazers")
#' router$find_object("/rust-lang/rust-analyzer/stargazers/404")
#' router$find_object("/public/js/main.js")
#' router$find_object("/api/v1")
#'
signpost <- function() {
  ROUTER <- create_router()
  PATHS <- list()

  obj <- structure(
    list(),
    class = "waysign_signpost",
    format = function(...) {
      paste0(
        "<Waysign router with ",
        count_paths(ROUTER),
        " routes>\n\n",
        format_router(ROUTER)
      )
    }
  )

  obj$paths <- function() PATHS
  obj$has_path <- function(path) path %in% names(PATHS)
  obj$remove_path <- function(path) {
    check_string(path)
    if (path %in% names(PATHS)) {
      paths <- PATHS
      # We have to build tree from scratch without the removed path
      ROUTER <<- create_router()
      PATHS <<- list()
      for (p in names(paths)) {
        if (path != p) {
          obj$add_path(p, paths[[p]])
        }
      }
    }
    invisible(obj)
  }
  obj$find_object <- function(path) {
    check_string(path)
    res <- router_find_handler(ROUTER, path)
    if (is.null(res)) {
      return(NULL)
    }
    list(
      path = res$id,
      object = PATHS[[res$id]],
      params = set_names(as.list(res$values), res$keys)
    )
  }
  obj$add_path <- function(path, object) {
    check_string(path)
    router_add_path(ROUTER, path, path)
    PATHS[[path]] <<- object
    invisible(obj)
  }

  obj
}

#' @export
print.waysign_signpost <- function(x, ...) {
  cat(attr(x, "format")())
}
