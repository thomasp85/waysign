#' A simple, multi-purpose router
#'
#' @description
#' The `Waysign` class implements a high-performance, multipurpose router build
#' on top of the [path-tree](https://github.com/viz-rs/path-tree) library. A
#' router associates filepath-like patterns with a piece of data for latter
#' retrieval. Often that data is a function and the path to be matched against
#' the pattern comes from a URL, but it can be anything, adapting to the need
#' of the user.
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
#' @importFrom R6 R6Class
#' @export
#'
#' @examples
#' # Adapted from path-tree docs
#' router <- Waysign$new()
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
Waysign <- R6Class(
  "Waysign",
  public = list(
    #' @description
    #' Create a new Waysign router
    #'
    initialize = function() {
      private$ROUTER <- create_router()
    },
    #' @description
    #' Pretty printing of the object
    #'
    #' @param ... ignored
    #'
    format = function(...) {
      paste0(
        "<Waysign router with ",
        count_paths(private$ROUTER),
        " routes>\n\n",
        format_router(private$ROUTER)
      )
    },
    #' @description
    #' Add a new path to the router. See *Details* for allowed path syntax
    #'
    #' @param path A string giving the path to add
    #' @param object An R object to be associated with the path.
    #'
    #' @return The object, invisibly
    #'
    add_path = function(path, object) {
      check_string(path)
      id <- as.character(sample(.Machine$integer.max, 1))
      router_add_path(private$ROUTER, path, id)
      private$PATHS[[id]] <- list(path = path, object = object)
      invisible(self)
    },
    #' @description
    #' Search for a path in the router
    #'
    #' @param path The path to search for
    #'
    #' @return If no matching path is found then `NULL`, otherwise a list with
    #' the elements `path` giving the path pattern that was matched, `object`
    #' giving the object associated with the path, `keys` giving the name of the
    #' path parameters in the path element, and `values` giving the values of
    #' the keys based on the match.
    #'
    find_object = function(path) {
      check_string(path)
      res <- router_find_handler(private$ROUTER, path)
      if (is.null(res)) {
        return(NULL)
      }
      match <- private$PATHS[[res$id]]
      match$params <- set_names(res$values, res$keys)
      match
    },
    #' @description
    #' Remove a path from the router. Due to the underlying implementation this
    #' causes a complete rebuild of the router
    #'
    #' @param path A string giving the path to remove
    #'
    #' @return The object, invisibly
    #'
    remove_path = function(path) {
      check_string(path)
      paths <- private$PATHS
      path_match <- which(path == vapply(paths, `[[`, character(1), "path"))
      if (length(path_match) != 0) {
        # We have to build tree from scratch without the removed path
        private$ROUTER <- create_router()
        private$PATHS <- list()
        paths <- paths[-path_match]
        for (p in paths) {
          self$add_path(p$path, p$object)
        }
      }
      invisible(self)
    }
  ),
  private = list(
    ROUTER = NULL,
    PATHS = list()
  )
)
