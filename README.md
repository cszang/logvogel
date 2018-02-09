logvogel <img src="man/figures/logo.png" align="right" height="150"/>
=====================================================================

## Overview

Tracking progress from parallel processes is hard, e.g. when running a
`foreach::foreach()` loop. One [recommended
solution](http://blog.revolutionanalytics.com/2015/02/monitoring-progress-of-a-foreach-parallel-job.html)
is to print the status to an external logfile. This is the strategy of
`logvogel`: it provides an easy way to monitor long-running loops from an
external R process using logfiles.

## Installation

```r
devtools::install_github("cszang/logvogel")
```

## Usage

### In the `foreach` construct

Use `logfile()` to create a new logfile. This creates an `R6` class instance,
whose handling is similar to `dplyr::progress_estimated()`. The resulting
logfile can be printed, updated with `.$update()`, and removed with
`.$remove()`.

Example:

```r
library(foreach)
library(parallel)
library(doSNOW)

cl <- makeCluster(parallel::detectCores())
registerDoSNOW(cl)

n <- 100
log <- logfile("test.log", n)

foreach(i = 1:n, .packages = c("logvogel")) %dopar% {
  Sys.sleep(rnorm(1, mean = 4))
  log$update()
}

log$remove()
```

### In the monitoring process

Start another R process, preferable in the same root directory. Then use
`logvogel::status()` to track the status of the loop.

Example:

```r
logvogel::status("test.log")
```

### TODO

- [ ] fix case when parallel jobs have very similar duration
