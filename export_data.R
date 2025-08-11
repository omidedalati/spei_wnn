library(zoo)  # برای ساخت توالی زمانی

# فرض: ts_data و res موجود هستند
# 1) داده اصلی
dates_main <- as.yearmon(time(ts_data))
values_main <- as.numeric(ts_data)

# 2) داده پیش‌بینی
fc <- as.numeric(res$Finalforecast)
dates_fc <- seq(from = max(dates_main) + 1/frequency(ts_data),
                by   = 1/frequency(ts_data),
                length.out = length(fc))

# 3) ترکیب در یک دیتافریم
df_all <- data.frame(
  Date  = c(dates_main, dates_fc),
  Value = c(values_main, fc),
  Type  = c(rep("Actual", length(values_main)),
            rep("Forecast", length(fc)))
)

# نمایش
print(head(df_all, 15))   # اولین چند ردیف
print(tail(df_all, 15))   # آخرین چند ردیف
write.csv(df_all, file = "dataset_pet.csv", row.names = FALSE)
