test_that("path matching works", {
  router <- signpost()

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

  expect_null(router$find_object("nothing"))

  match <- router$find_object("/")
  expect_named(match, c("path", "object", "params"))
  expect_equal(match$object, 1)

  match <- router$find_object("/login")
  expect_equal(match$object, 2)

  match <- router$find_object("/settings/admin")
  expect_equal(match$object, 5)

  match <- router$find_object("/viz-rs")
  expect_equal(match$object, 6)

  match <- router$find_object("/viz-rs/path-tree")
  expect_equal(match$object, 7)

  match <- router$find_object("/public/js/main.js")
  expect_equal(match$object, 8)

  match <- router$find_object(
    "/rust-lang/rust-analyzer/releases/download/2022-09-12/rust-analyzer-aarch64-apple-darwin.gz"
  )
  expect_equal(match$object, 9)

  match <- router$find_object("/rust-lang/rust-analyzer/tags/2022-09-12")
  expect_equal(match$object, 10)

  match <- router$find_object("/rust-lang/rust-analyzer/actions/ci:bench")
  expect_equal(match$object, 11)

  match <- router$find_object("/rust-lang/rust-analyzer/stargazers")
  expect_equal(match$object, 12)

  match <- router$find_object("/rust-lang/rust-analyzer/stargazers/404")
  expect_equal(match$object, 13)

  match <- router$find_object("/api/v1")
  expect_equal(match$object, 14)

  router$remove_path("/")
  expect_null(router$find_object("/"))

  match <- router$find_object("/login")
  expect_equal(match$object, 2)
})
