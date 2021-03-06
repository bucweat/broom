#' Tidying methods for a nonlinear model
#'
#' These methods tidy the coefficients of a nonlinear model into a summary,
#' augment the original data with information on the fitted values and residuals,
#' and construct a one-row glance of the model's statistics.
#' 
#' @param x An object of class "nls"
#' @param data original data this was fitted on; if not given this will
#' attempt to be reconstructed from nls (may not be successful)
#' 
#' @return All tidying methods return a \code{data.frame} without rownames.
#' The structure depends on the method chosen.
#' 
#' @seealso \code{\link{nls}} and \code{\link{summary.nls}}
#' 
#' @name nls-tidiers
NULL


#' @rdname nls-tidiers
#' 
#' @param conf.int whether to include a confidence interval
#' @param conf.level confidence level of the interval, used only if
#' \code{conf.int=TRUE}
#'
#' @return \code{tidy} returns one row for each coefficient in the model,
#' with five columns:
#'   \item{term}{The term in the nonlinear model being estimated and tested}
#'   \item{estimate}{The estimated coefficient}
#'   \item{stderror}{The standard error from the linear model}
#'   \item{statistic}{t-statistic}
#'   \item{p.value}{two-sided p-value}
#' 
#' @export
tidy.nls <- function(x, conf.int=FALSE, conf.level=.95, ...) {
    nn <- c("estimate", "stderror", "statistic", "p.value")
    ret <- fix_data_frame(coef(summary(x)), nn)

    if (conf.int) {
        # avoid "Waiting for profiling to be done..." message
        CI <- suppressMessages(confint(x, level = conf.level))
        if (is.null(dim(CI))) {
            CI = matrix(CI, nrow=1)
        }
        colnames(CI) = c("conf.low", "conf.high")
        ret <- cbind(ret, unrowname(CI))
    }
    ret
}


#' @rdname nls-tidiers
#' 
#' @return \code{augment} returns one row for each original observation,
#' with two columns added:
#'   \item{.fitted}{Fitted values of model}
#'   \item{.resid}{Residuals}
#' 
#' @export
augment.nls <- function(x, data=NULL, ...) {
    # move rownames if necessary
    data <- fix_data_frame(data, newcol=".rownames")
    
    if (is.null(data)) {
        pars <- names(x$m$getPars())
        env <- as.list(x$m$getEnv())
        data <- as.data.frame(env[!(names(env) %in% pars)])
    }
    data$.fitted <- predict(x)
    data$.resid <- resid(x)
    data
}


#' @rdname nls-tidiers
#' 
#' @param ... extra arguments (not used)
#' 
#' @return \code{glance} returns one row with the columns
#'   \item{sigma}{The square root of the estimated residual variance}
#'   \item{isConv}{Whether the fit successfully converged}
#'   \item{finTol}{The achieved convergence tolerance}
#' 
#' @export
glance.nls <- function(x, ...) {
    s <- summary(x)
    unrowname(data.frame(sigma=s$sigma, isConv=s$convInfo$isConv, finTol=s$convInfo$finTol))
}
