library(ggplot2)
library(zoo)

time_index <- as.yearmon(time(ts_data))
n <- length(time_index)

# --- Original
df_main_orig <- data.frame(
  time = time_index,
  kind = "Original",
  value = as.numeric(ts_data)
)

# --- Fitted
fp <- as.numeric(res$FinalPrediction)
if (length(fp) < n) fp <- c(rep(NA_real_, n - length(fp)), fp)
df_main_fit <- data.frame(
  time = time_index,
  kind = "Fitted",
  value = fp
)

# --- Forecast
fc <- as.numeric(res$Finalforecast)
fc_index <- seq(from = max(time_index) + 1/frequency(ts_data),
                by   = 1/frequency(ts_data),
                length.out = length(fc))
df_main_fc <- data.frame(
  time = fc_index,
  kind = "Forecast",
  value = fc
)

# --- Combine
plot_df <- rbind(df_main_orig, df_main_fit, df_main_fc)

# --- فیلتر: فقط دو سال آخر داده اصلی + پیش‌بینی
last_year_start <- max(df_main_orig$time) - 2
plot_df <- subset(plot_df, time >= last_year_start)

# --- Plot
ggplot() +
  # Original (دو سال آخر، خط‌چین)
  geom_line(data = subset(plot_df, kind == "Original"),
            aes(time, value, color = "Original", linetype = "Original"),
            linewidth = 0.8) +
  # Fitted
  geom_line(data = subset(plot_df, kind == "Fitted"),
            aes(time, value, color = "Fitted", linetype = "Fitted"),
            linewidth = 0.8) +
  # Forecast
  geom_line(data = subset(plot_df, kind == "Forecast"),
            aes(time, value, color = "Forecast", linetype = "Forecast"),
            linewidth = 1) +
  scale_color_manual(values = c(
    "Original" = "red",
    "Fitted" = "blue",
    "Forecast" = "darkgreen"
  )) +
  scale_linetype_manual(values = c(
    "Original" = "dashed",
    "Fitted" = "dotted",
    "Forecast" = "solid"
  )) +
  labs(title = NULL,
       x = NULL, y = NULL, color = "", linetype = "") +
  theme_minimal(base_size = 12) +
  theme(legend.position = "bottom")
