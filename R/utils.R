coalesce_results <- function(x) {
  problems <- purrr::map_dfr(
    .x = x,
    .f = function(i) i$problems
  )
  valid <- purrr::map_dfr(
    .x = x,
    .f = function(i) i$validated
  )
  list("problems" = problems,
       "valid" = valid)
}

wrap_null <- function(.l) {
  stopifnot(is.recursive(.l), is.list(.l))
  nulls <- vapply(.l, is.null, logical(1))
  .l[nulls] <- list(list(NULL))
  .l
}
