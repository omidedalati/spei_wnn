library(dplyr)
library(tidyr)
library(ggplot2)
library(zoo)

# --- فرض: ts_data و res از قبل ساخته شده‌اند
time_index <- as.yearmon(time(ts_data))
n <- length(time_index)

# --- Wavelet components: Original ---
ws <- as.data.frame(res$WaveletSeries)

# نام‌گذاری استاندارد: D1..D(L-1) و آخرین ستون Approximation
L <- ncol(ws)
colnames(ws) <- c(paste0("D", 1:(L-1)), "Approximation")
ws$time <- time_index

df_ws <- ws |>
  pivot_longer(-time, names_to = "level", values_to = "value") |>
  mutate(kind = "Original")

# --- Wavelet components: Fitted (pad به طول سری) ---
fit_mat <- as.matrix(res$FittedByLevel)
if (nrow(fit_mat) < n) {
  fit_mat <- rbind(matrix(NA_real_, n - nrow(fit_mat), ncol(fit_mat)), fit_mat)
}
colnames(fit_mat) <- colnames(ws)[colnames(ws) != "time"]

fit_df_wide <- as.data.frame(fit_mat)
fit_df_wide$time <- time_index

df_fit <- fit_df_wide |>
  pivot_longer(-time, names_to = "level", values_to = "value") |>
  mutate(kind = "Fitted")

# --- Main series: Original + Fitted
fp <- as.numeric(res$FinalPrediction)
if (length(fp) < n) fp <- c(rep(NA_real_, n - length(fp)), fp)

df_main_orig <- data.frame(
  time = time_index, level = "Main", kind = "Original",
  value = as.numeric(ts_data)
)
df_main_fit <- data.frame(
  time = time_index, level = "Main", kind = "Fitted",
  value = fp
)

# --- Combine (بدون Forecast) ---
plot_df2 <- bind_rows(df_main_orig, df_main_fit, df_ws, df_fit) |>
  filter(!is.na(value))

# --- ترتیب پنل‌ها: Main → Approximation → D1..D(L-1)
detail_levels <- paste0("D", 1:(L-1))
levs <- c("Main", "Approximation", detail_levels)
plot_df2$level <- factor(plot_df2$level, levels = levs)

# --- Plot
ggplot() +
  geom_line(
    data = subset(plot_df2, kind == "Original"),
    aes(time, value, color = kind, linetype = kind, linewidth = kind)
  ) +
  geom_line(
    data = subset(plot_df2, kind == "Fitted"),
    aes(time, value, color = kind, linetype = kind, linewidth = kind)
  ) +
  facet_wrap(~ level, ncol = 1, scales = "free_y") +
  scale_color_manual(values = c("Original" = "red", "Fitted" = "dodgerblue")) +
  scale_linetype_manual(values = c("Original" = "solid", "Fitted" = "solid")) +
  scale_linewidth_manual(values = c("Original" = 0.3, "Fitted" = 0.2)) +
  labs(title = NULL, x = NULL, y = NULL, color = "", linetype = "", linewidth = "") +
  theme_minimal(base_size = 12) +
  theme(legend.position = "bottom")
