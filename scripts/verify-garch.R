# Run from the repository root. Baselines stay outside the repository.
args <- commandArgs(trailingOnly = TRUE)
baseline_path <- file.path(Sys.getenv("TEMP"), "tutorial-emf-garch-baseline.rds")
code_path <- tempfile(fileext = ".R")
options(knitr.table.format = "html")
invisible(knitr::purl("03-garch-volatility.qmd", output = code_path, quiet = TRUE))
chapter <- new.env(parent = globalenv())
source(code_path, local = chapter)
unlink(code_path)

result_names <- c(
  "sp500", "u", "long_run_variance", "theta_full", "alpha_vt", "beta_vt",
  "omega_vt", "v_full", "v_vt", "full_summary", "vt_summary", "forecast_variance"
)
results <- mget(result_names, envir = chapter)
if ("--baseline" %in% args) {
  saveRDS(results, baseline_path)
  cat("Baseline saved to", baseline_path, "\n")
} else {
  if (!file.exists(baseline_path)) stop("Run with --baseline before editing.")
  baseline <- readRDS(baseline_path)
  for (name in result_names) {
    if (!isTRUE(all.equal(results[[name]], baseline[[name]], tolerance = 1e-10))) {
      stop("Existing result changed: ", name)
    }
  }
  cat("PASS: training data, parameters, variances, likelihood, AIC/BIC and forecasts unchanged.\n")
}
print(chapter$full_summary)
print(chapter$vt_summary)
cat("Training prices:", format(min(chapter$sp500$date)), "to",
    format(max(chapter$sp500$date)), "\n")
if (exists("evaluation_summary", envir = chapter)) {
  with(chapter, {
    # Price-row alignment, daily contributions, and exact algebraic updates.
    for (model in c("full", "vt")) {
      daily <- get(paste0(model, "_daily"))
      omega <- get(paste0("omega_", model))
      alpha <- get(paste0("alpha_", model))
      beta <- get(paste0("beta_", model))
      stopifnot(
        is.na(daily$return[1]), all(is.na(daily$variance[1:2])),
        identical(which(is.finite(daily$variance))[1], 3L),
        daily$variance[3] == daily$return[2]^2,
        nrow(compact_garch_calculation(daily)) == 9L
      )
      for (i in 4:5) {
        value <- omega + alpha * daily$return[i - 1]^2 + beta * daily$variance[i - 1]
        stopifnot(abs(value - daily$variance[i]) < 1e-14)
        displayed <- round(omega, 10) + round(alpha, 8) * round(daily$return[i - 1], 10)^2 +
          round(beta, 8) * round(daily$variance[i - 1], 10)
        stopifnot(abs(displayed - daily$variance[i]) < 1e-10)
      }
    }
    cat("PASS: row alignment, initialized day 3, day 4/5 substitutions and daily likelihood totals.\n")

    stopifnot(
      nrow(test_returns) == 20L,
      all(test_returns$date > max(sp500$date)),
      abs(test_returns$return[1] - (test_returns$price[1] / tail(sp500$price, 1) - 1)) < 1e-14,
      all(is.finite(test_paths$fixed_origin)), all(test_paths$fixed_origin > 0),
      all(is.finite(test_paths$filtered)), all(test_paths$filtered > 0)
    )
    # Extending the original recursion must reproduce the sequential test path.
    for (model in c("Full MLE", "Variance targeting")) {
      par <- if (model == "Full MLE") theta_full else c(omega_vt, alpha_vt, beta_vt)
      extended <- garch_variance(c(u, test_returns$return), par[1], par[2], par[3])
      path <- test_paths[test_paths$model == model, ]
      stopifnot(isTRUE(all.equal(tail(extended, 20), path$filtered, tolerance = 1e-12)))
      stopifnot(abs(path$filtered[1] - path$fixed_origin[1]) < 1e-14)
      loss <- evaluation_summary[evaluation_summary$model == model, ]
      stopifnot(abs(loss$qlike - mean(log(path$fixed_origin) + path$squared_return / path$fixed_origin)) < 1e-12)
    }
    cat("PASS: chronological test split, boundary return, fixed-origin forecasts and ex-post filtering.\n")

    stopifnot(
      all(simulated_variance > 0),
      all(simulated_variance[1, ] == v_next),
      forecast_interval$lower[1] == forecast_interval$upper[1],
      all(forecast_interval$lower <= forecast_interval$upper)
    )
    mc_se <- apply(simulated_variance, 1, sd) / sqrt(simulation_count)
    stopifnot(all(abs(rowMeans(simulated_variance) - forecast_variance) <= 6 * mc_se + 1e-12))
    stopifnot(nrow(diag_tests) == 4L, nrow(acf_tbl) == 80L)
    cat("PASS: simulation interval, analytical forecast versus Monte Carlo mean, and parallel diagnostics.\n")
    print(as.data.frame(evaluation_summary), digits = 10, row.names = FALSE)
    print(test_paths |>
      group_by(model) |>
      summarise(first_filtered = first(filtered), last_filtered = last(filtered),
                last_forecast = last(fixed_origin)), digits = 10)
    cat("Test dates:", format(min(test_returns$date)), "to", format(max(test_returns$date)), "\n")
  })
}
if (exists("diag_tests", envir = chapter)) print(chapter$diag_tests)
