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
