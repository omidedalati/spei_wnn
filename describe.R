# Install packages if needed
# install.packages(c("moments", "tseries", "car"))

library(moments)
library(tseries)
library(car)


data <- unpivoted_pet$pet

# --- Metrics
metrics <- c(
  "Count", "Minimum", "Maximum", "Mean", "Median",
  "Standard Deviation", "Variance", "Skewness", "Kurtosis",
  "Jarque-Bera Statistic", "Jarque-Bera p-value"
)

# --- Values
jb_test <- jarque.bera.test(data)
values <- c(
  length(data),
  min(data),
  max(data),
  mean(data),
  median(data),
  sd(data),
  var(data),
  skewness(data),
  kurtosis(data),
  as.numeric(jb_test$statistic),
  jb_test$p.value
)

# --- Create table: first row = metrics, second row = values
df_stats <- rbind(metrics, values)
colnames(df_stats) <- metrics
rownames(df_stats) <- NULL

# --- Show table
print(df_stats, row.names = FALSE)

# --- Plot 1: Histogram with normal curve (no title)
hist(data, breaks = 15, probability = TRUE,
     main = "",  # حذف عنوان
     xlab = "Value", col = "lightblue", border = "white")
curve(dnorm(x, mean = mean(data), sd = sd(data)),
      col = "red", lwd = 2, add = TRUE)

# --- Plot 2: Base R QQ plot (no title)
qqnorm(data, main = "")  # حذف عنوان
qqline(data, col = "red", lwd = 2)

car::qqPlot(data,
            main = "",    # بدون عنوان
            id = FALSE,   # بدون لیبل نقاط پرت
            ylab = "Pre"  # برچسب محور X
)

