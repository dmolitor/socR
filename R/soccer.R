#' Send and Retrive data from SOCcer API
#'
#' This function facilitates querying the SOCcer API in a vectorized manner.
#' Each argument must be either length 1 or n. This function facilitates request
#' throttling and verbose output.
#'
#' @param job_title Character string of job title.
#' @param job_desc Optional character string of job description.
#' @param industry Optional character string of industry code.
#' @param n_results Integer specifying the number of top matches to return.
#' @param req_per_min Integer specifying the max number of requests per minute.
#' @param user_agent Character string of user agent. Set to helpful value so
#'   for API maintainer in case of serious problems.
#' @param verbose An integer between 0 and 3 specifying level of verbosity.
#' @param progress A boolean; whether to print progress across job
#'   classifications. Will only work if the `progressr` package is installed.
#' @param ... Additional arguments that will be mutated onto the returned data
#'   frame.
#'
#' @examples
#' dat <- head(job_desc, 1)
#' soccer(job_title = dat$title,
#'        job_desc = dat$description,
#'        job_id = dat$job_id)
#'
#' @return A list with two elements: `problems` which contains a tibble of all
#'   requests that encountered an error and `valid` which contains a tibble of
#'   all successfully validated results.
#'
#' @export
soccer <- function(job_title,
                   job_desc = NULL,
                   industry = NULL,
                   n_results = 10,
                   req_per_min = 5000,
                   user_agent = "Daniel Molitor (dmolitor@ripl.org)",
                   verbose = 0L,
                   progress = FALSE,
                   ...) {
  if (progress && !requireNamespace("progressr", quietly = TRUE)) {
    message("Package \"progressr\" required to print progress bar.",
            appendLF = TRUE)
    progress_allowed <- FALSE
  } else {
    progress_allowed <- TRUE
  }
  args <- append(
    list("job_title" = job_title,
         "job_desc" = job_desc,
         "industry" = industry,
         "n_results" = n_results,
         "req_per_min" = req_per_min,
         "user_agent" = user_agent,
         "verbose" = verbose),
    list(...)
  )
  args <- wrap_null(args)
  if (progress && progress_allowed) {
    progressr::with_progress({
      pb <- progressr::progressor(along = 1:length(args[[1]]))
      results <- purrr::pmap(
        .l = args,
        .f = function(job_title,
                      job_desc,
                      industry,
                      n_results,
                      req_per_min,
                      user_agent,
                      verbose,
                      ...) {
          out <- soccer_enrich(job_title,
                               job_desc,
                               industry,
                               n_results,
                               req_per_min,
                               user_agent,
                               verbose,
                               ...)
          pb()
          out
        }
      )
    })
  } else {
    results <- purrr::pmap(
      .l = args,
      .f = soccer_enrich
    )
  }
  coalesce_results(results)
}
