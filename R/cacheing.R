cache_create <- function(dir) {
  if (!dir.exists(dir)) dir.create(dir, recursive = TRUE)
  invisible()
}

cache_dir <- function(author = "soccer") {
  stopifnot(is.character(author))
  rappdirs::user_cache_dir("soccer", author)
}

cache_disk <- function(dir) {
  stopifnot(is.character(dir))
  cache_create(dir)
  memoise::cache_filesystem(path = dir)
}
