soccer_engine <- function(job_title,
                          job_desc = NULL,
                          industry = NULL,
                          n_results = 10,
                          req_per_min = 6,
                          user_agent = "Daniel Molitor (dmolitor@ripl.org)",
                          verbose = 0L) {
  request <- soccer_req(job_title = job_title,
                        job_desc = job_desc,
                        industry = industry,
                        n_results = n_results,
                        req_per_min = req_per_min,
                        user_agent = user_agent,
                        verbose = verbose)
  soccer_resp(request)
}

soccer_engine_mem <- memoise::memoise(
  f = soccer_engine,
  cache = cache_disk(cache_dir()),
  omit_args = c("req_per_min", "user_agent", "verbose", "...")
)

soccer_enrich <- function(job_title,
                          job_desc = NULL,
                          industry = NULL,
                          n_results = 10,
                          req_per_min = 6,
                          user_agent = "Daniel Molitor (dmolitor@ripl.org)",
                          verbose = 0L,
                          ...) {
  add_args <- list(...)
  if (identical(add_args, list())) {
    add_args <- NULL
  } else {
    add_args <- dplyr::bind_cols(add_args)
  }
  engine <- soccer_engine_mem(job_title = job_title,
                              job_desc = job_desc,
                              industry = industry,
                              n_results = n_results,
                              req_per_min = req_per_min,
                              user_agent = user_agent,
                              verbose = verbose)
  problems <- if (!is.null(engine$problems)) {
    dplyr::bind_cols(
      add_args,
      engine$problems
    )
  }
  validated <- if (!is.null(engine$validated)) {
    dplyr::bind_cols(
      add_args,
      engine$validated
    )
  }
  return(list("problems" = problems,
              "validated" = validated))
}

soccer_req <- function(job_title,
                       job_desc,
                       industry,
                       n_results,
                       req_per_min,
                       user_agent,
                       verbose) {
  req <- httr2::req_user_agent(
    httr2::req_throttle(
      httr2::req_url_query(
        httr2::request("https://sitf-raft3imjaq-uc.a.run.app/soccer/code"),
        "title" = job_title,
        "task" = job_desc,
        "industry" = industry,
        "n" = n_results
      ),
      rate = req_per_min / 120,
      realm = "https://sitf-raft3imjaq-uc.a.run.app/soccer/code"
    ),
    string = user_agent
  )
  req_out <- tryCatch(
    httr2::req_perform(req = req,
                       verbosity = verbose),
    error = function(e) httr2::last_response()
  )
  req_out
}

soccer_resp <- function(req) {
  if (httr2::resp_is_error(req)) {
    problem <- dplyr::bind_rows(httr2::resp_body_json(req))
    valid <- NULL
  } else {
    valid <- dplyr::bind_rows(httr2::resp_body_json(req))
    problem <- NULL
  }
  list("problems" = problem, "validated" = valid)
}
