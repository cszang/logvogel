#' @importFrom R6 R6Class
#' @importFrom here here
#' @importFrom utils tail
#' @import seagull
Logfile <- R6::R6Class(
  "Logfile",
  public = list(
    path = NULL,
    lock = NULL,
    n = NULL,
    active = NULL,
    initialize = function(path, n, here = TRUE) {
      if (here) {
        path <- file.path(here::here(), path)
      }
      self$path <- path
      self$lock <- paste0(path, "lock")
      self$n <- n
      self$active <- TRUE
      self$create()
      cat("Created new logfile for", self$n, "iterations at", path, "\n")
    },
    create = function() {
      cat(self$n, "\n", file = self$path)
    },
    get_iterator = function() {
      f <- readLines(self$path)
      iterator <- as.numeric(tail(f, 1))
      if (iterator == self$n & length(f) == 1) {
        0
      } else {
        iterator
      }
    },
    update = function() {
      seagull::with_flock(self$lock, {
        updated_iterator <- self$get_iterator() + 1
        cat(updated_iterator, "\n", file = self$path, append = TRUE)
      })
    },
    remove = function() {
      self$active <- FALSE
      removed <- file.remove(self$path)
      cat("Deleted logfile at", self$path, "\n")
      invisible(removed)
    },
    print = function(...) {
      if (self$active) {
        cat(paste0("Active logfile (",
                   round(self$get_iterator() * 100/self$n, 1),
                   "%) at ", self$path, "\n"))
      } else {
        cat("This was a logfile at", self$path, "\n")
      }
    }
  ))

#' Logfile for external progress tracking
#'
#' This reference class keeps track of a logfile, which can be updated within a
#' loop etc. and tracked from _outside_ (in an external process), using
#' `status()`.
#'
#' @param path path to the logfile
#' @param n total number of iterations
#' @param here should base path of the logfile be located using `here::here()`
#'
#' @return A ref class with methods `update()`, `print()`, and `remove()`
#' @keywords internal
#' @export
#'
#' @examples
#' \dontrun{
#' log <- logfile("logfile.log", 100)
#' }
logfile <- function(path, n, here = TRUE) {
  Logfile$new(path, n)
}
