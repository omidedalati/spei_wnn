library(ggplot2)
library(cowplot)

# --- helper: build two-panel residual plots ---
residuals_panels <- function(actual, predicted, units = "mm/month") {
  stopifnot(length(actual) == length(predicted))
  idx   <- which(!is.na(actual) & !is.na(predicted))
  y     <- as.numeric(actual[idx])
  yhat  <- as.numeric(predicted[idx])
  resid <- y - yhat
  
  df <- data.frame(pred = yhat, resid = resid)
  
  # Left panel: Residuals vs Predicted
  p_left <- ggplot(df, aes(pred, resid)) +
    geom_point(shape = 21, fill = NA, color = "black", size = 1, alpha = 0.6) +
    geom_hline(yintercept = 0, color = "red", linewidth = 1) +
    labs(x = paste0("Predicted Values (", units, ")"),
         y = paste0("Residuals (", units, ")")) +
    theme_classic(base_size = 13)
  
  # Right panel: Histogram of residuals with normal density
  p_right <- ggplot(data.frame(resid = resid), aes(x = resid)) +
    geom_histogram(aes(y = after_stat(density)),
                   bins = 60, color = "black", fill = "grey70") +
    stat_function(fun = dnorm,
                  args = list(mean = mean(resid, na.rm = TRUE),
                              sd   = sd(resid,   na.rm = TRUE)),
                  color = "red", linewidth = 1) +
    labs(x = paste0("Residuals (", units, ")"), y = "Density") +
    theme_classic(base_size = 13)
  
  plot_grid(p_left, p_right, ncol = 2, rel_widths = c(1, 1))
}

# --- choose data: testing if available, else in-sample ---
if (exists("actual_future") && !is.null(actual_future)) {
  h <- min(length(actual_future), length(res$Finalforecast))
  y_use    <- actual_future[seq_len(h)]
  yhat_use <- res$Finalforecast[seq_len(h)]
} else {
  k <- min(length(ts_data), length(res$FinalPrediction))
  y_use    <- tail(as.numeric(ts_data), k)
  yhat_use <- tail(res$FinalPrediction,  k)
}

# --- remove first 24 months ---
if (length(y_use) > 24) {
  y_use    <- y_use[-(1:24)]
  yhat_use <- yhat_use[-(1:24)]
}

# --- draw panels ---
residuals_panels(
  actual    = y_use,
  predicted = yhat_use,
  units     = "mm/month"
)
