library(ggplot2)
library(zoo)

# فرض: ts_data و res از قبل ساخته شده‌اند
f <- frequency(ts_data)
time_index <- as.yearmon(time(ts_data))
n <- length(time_index)

# --- Original (سری اصلی) ---
df_main_orig <- data.frame(
  time  = time_index,
  kind  = "Original",
  value = as.numeric(ts_data)
)

# --- Fitted (جمع فیتِ لِوِل‌ها) ---
fp <- as.numeric(res$FinalPrediction)
# اگر طول فیت کوتاه‌تر از سری بود، از ابتدا با NA پَد کن
if (length(fp) < n) fp <- c(rep(NA_real_, n - length(fp)), fp)

df_main_fit <- data.frame(
  time  = time_index,
  kind  = "Fitted",
  value = fp
)

# نمایش ندادن 24 ماه اول فیت
warmup <- 24
if (nrow(df_main_fit) >= 1) {
  df_main_fit$value[seq_len(min(warmup, nrow(df_main_fit)))] <- NA
}

# --- Forecast (اختیاری؛ اگر داری) ---
fc <- as.numeric(res$Finalforecast)
fc_index <- seq(from = max(time_index) + 1/f,
                by   = 1/f,
                length.out = length(fc))
df_main_fc <- data.frame(
  time  = fc_index,
  kind  = "Forecast",
  value = fc
)

# --- Plot ---
ggplot() +
  # Original (پشت همه)
  geom_line(data = df_main_orig, aes(time, value, color = "Original"),
            linewidth = 0.5) +
  # Fitted (روی Original، با 24 ماه اولِ NA)
  geom_line(data = df_main_fit, aes(time, value, color = "Fitted"),
            linewidth = 0.4) +
  # Forecast (روی همه)
  geom_line(data = df_main_fc, aes(time, value, color = "Forecast"),
            linewidth = 0.6) +
  scale_color_manual(values = c(
    "Original"  = "red",
    "Fitted"    = "blue",
    "Forecast"  = "darkgreen"
  )) +
  labs(title = NULL, x = NULL, y = NULL, color = "") +
  theme_minimal(base_size = 12) +
  theme(legend.position = "bottom")
