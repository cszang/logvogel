#' Show progress using a logfile
#'
#' Use this function in an external R process to track the status of a running
#' loop from a logfile created with `logfile()`.
#'
#' @param path path to the logfile
#' @param here should base path of the logfile be located using `here::here()`
#' @param s update interval in seconds
#'
#' @return nothing, invoked for side effects
#' @importFrom dplyr progress_estimated
#' @importFrom utils tail
#' @export
#'
#' @examples
#' \dontrun{
#' status("logfile.log")
#' }
status <- function(path, here = TRUE, s = 0.1) {

  if (here) {
    path <- file.path(here::here(), path)
  }

  if (!file.exists(path)) {
    stop("No logfile at specified path.")
  }

  get_tail <- function() {
    as.numeric(tail(readLines(path), 1))
  }
  get_head <- function() {
    as.numeric(readLines(path)[1])
  }

  n <- get_head()
  pb <- progress_estimated(n)
  pb$tick()$print()

  # stay in unproductive loop until something happened
  while (length(readLines(path)) == 1) {
    Sys.sleep(s)
  }

  i <- get_tail()

  # fill up progress bar if we chime in late
  if (i < n & i > 1) {
    for (j in seq_along(1:(i - 1))) {
      Sys.sleep(s)
      pb$tick()$print()
    }
  }

  while (i <= n) {
    Sys.sleep(s)
    new_i <- get_tail()
    if (new_i > i) {
      i <- new_i
      pb$tick()$print()
    }
  }

  if (i == n) {
    pb$stop()
  }
}

#' Auto-find logfiles and show progress
#'
#' This is a wrapper around `logvogel::status()`
#' @param path path to project root
#' @param here should base path of the logfile be located using `here::here()`
#' @param s update interval in seconds
#'
#' @return nothing, invoked for side effects
#' @export
#'
#' @examples
#' \dontrun{
#' autostatus()
#' }
autostatus <- function(path = NULL, here = TRUE, s = 0.1) {

  if (here & is.null(path)) {
    path <- here::here()
  } else {
    path <- "."
  }

  logs <- list.files(path, pattern = "*\\.log$")
  n_logs <- length(logs)
  if (n_logs == 0) {
    stop(paste0("No logfiles (extension .log) found in ", path, "."))
  }
  if (n_logs > 1) {
    cat("Select logfile:\n")
    cat(paste0("\t", 1:length(logs), ": ", logs, "\n"))
    n <- readline(prompt = "Enter number: ")
    n <- tryCatch(as.integer(n), warning = function(e) e)
    if (any(class(n) == "warning")) {
      stop("This was not an integer...")
    }
    the_log <- logs[n]
  } else {
    the_log <- logs
  }
  the_log <- file.path(path, the_log)
  cat(paste0("Status of ", the_log, ":\n"))
  logvogel::status(the_log, here = FALSE, s = s)
}
