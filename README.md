
<!-- README.md is generated from README.Rmd. Please edit that file -->

# SOCcer

<!-- badges: start -->

[![R-CMD-check](https://github.com/dmolitor/SOCcer/workflows/R-CMD-check/badge.svg)](https://github.com/dmolitor/SOCcer/actions)
<!-- badges: end -->

The goal of SOCcer is to query the SOCcer API.

## Installation

You can install the development version from
[GitHub](https://github.com/) with:

``` r
# install.packages("devtools")
devtools::install_github("dmolitor/SOCcer", auth_token = "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")
```

## Example

This is a basic example of how to use the package:

``` r
library(SOCcer)
```

Using the built-in data set we can query the first three jobs and see
how long it takes. The first three job postings:

``` r
head(job_desc, 3)
#> # A tibble: 3 x 3
#>      job_id title                                         description           
#>       <dbl> <chr>                                         <chr>                 
#> 1 140906257 deli clerk customer service                   polite prompt knowled~
#> 2 140974158 roll off truck driver class b cdl 3 000 bonus operate manual automa~
#> 3 140923731 field engineer 3                              perform advanced trou~
```

Now, using SOCcer to return the top three SOC matches for each:

``` r
system.time({
  jobs <- soccer(
    job_title = job_desc$title[1:3],
    job_desc = job_desc$description[1:3],
    job_id = job_desc$job_id[1:3],
    n_results = 3,
    req_per_min = 12
  )
})
#>    user  system elapsed 
#>    0.16    0.00   10.88
```

Now we can view the top 3 results for each posting.

``` r
jobs
#> $problems
#> # A tibble: 0 x 0
#> 
#> $valid
#> # A tibble: 9 x 4
#>      job_id code    label                                                  score
#>       <dbl> <chr>   <chr>                                                  <dbl>
#> 1 140906257 43-4051 Customer Service Representatives                     0.202  
#> 2 140906257 35-2021 Food Preparation Workers                             0.107  
#> 3 140906257 35-3021 Combined Food Preparation and Serving Workers, Incl~ 0.0601 
#> 4 140974158 53-3032 Heavy and Tractor-Trailer Truck Drivers              0.969  
#> 5 140974158 53-3011 Ambulance Drivers and Attendants, Except Emergency ~ 0.00305
#> 6 140974158 55-3014 Artillery and Missile Crew Members                   0.00101
#> 7 140923731 43-9061 Office Clerks, General                               0.0196 
#> 8 140923731 17-2112 Industrial Engineers                                 0.00550
#> 9 140923731 17-2171 Petroleum Engineers                                  0.00550
```

The API responses are stored locally in a persistent cache to keep
duplicate queries from hitting the API. As we can see, re-running the
function returns cached results and finishes almost immediately.

``` r
system.time({
  jobs <- soccer(
    job_title = job_desc$title[1:3],
    job_desc = job_desc$description[1:3],
    job_id = job_desc$job_id[1:3],
    n_results = 3,
    req_per_min = 30
  )
})
#>    user  system elapsed 
#>       0       0       0
```
