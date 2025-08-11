library(zoo)  

dates_main <- as.yearmon(time(ts_data))
values_main <- as.numeric(ts_data)

fc <- as.numeric(res$Finalforecast)
dates_fc <- seq(from = max(dates_main) + 1/frequency(ts_data),
                by   = 1/frequency(ts_data),
                length.out = length(fc))

df_all <- data.frame(
  Date  = c(dates_main, dates_fc),
  Value = c(values_main, fc),
  Type  = c(rep("Actual", length(values_main)),
            rep("Forecast", length(fc)))
)


print(head(df_all, 15))    
print(tail(df_all, 15))   
write.csv(df_all, file = "dataset_pet.csv", row.names = FALSE)
