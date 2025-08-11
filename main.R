library(WaveletANN)
library(forecast)
library(Metrics)

WaveletFittingann_fix <- function(ts, Waveletlevels, Filter='haar',
                                  boundary='periodic', FastFlag=TRUE,
                                  nonseaslag, seaslag=1, hidden, NForecast,
                                  actual_future = NULL) {
  
  # --- helpers ---
  mare_pct <- function(y, yhat) {
    idx <- which(!is.na(y) & !is.na(yhat) & y != 0)
    if (length(idx) == 0) return(NA_real_)
    mean(abs((y[idx] - yhat[idx]) / y[idx])) * 100
  }
  ia_willmott <- function(y, yhat) {
    idx <- which(!is.na(y) & !is.na(yhat))
    y <- y[idx]; yhat <- yhat[idx]
    ybar <- mean(y)
    num <- sum((y - yhat)^2)
    den <- sum((abs(yhat - ybar) + abs(y - ybar))^2)
    if (den == 0) return(NA_real_)
    1 - num/den
  }
  
  # --- wavelet decomp ---
  Actual <- ts
  WF <- WaveletFitting(ts = ts, Wvlevels = Waveletlevels, Filter = Filter,
                       bndry = boundary, FFlag = FastFlag)
  WS <- as.matrix(WF$WaveletSeries)  # n x L
  
  # نام‌گذاری: D1..Dn-1 و آخرین ستون Approximation
  colnames(WS) <- c(
    paste0("D", seq_len(ncol(WS) - 1)),
    "Approximation"
  )
  n <- nrow(WS); L <- ncol(WS)
  
  AllWaveletPrediction <- matrix(NA_real_, nrow = n, ncol = L)
  AllWaveletForecast   <- matrix(NA_real_, nrow = NForecast, ncol = L)
  
  # --- per-level nnetar ---
  for (j in seq_len(L)) {
    y <- WS[, j]
    fit <- forecast::nnetar(y = as.ts(y), p = nonseaslag, P = seaslag, size = hidden)
    
    # fitted (طولش باید n باشه؛ اگر کوتاه بود، به جلو پَد می‌کنیم)
    fitted_j <- as.numeric(fit$fitted)
    if (length(fitted_j) < n) {
      fitted_j <- c(rep(NA_real_, n - length(fitted_j)), fitted_j)
    }
    AllWaveletPrediction[, j] <- fitted_j
    
    # forecast
    fc <- forecast::forecast(fit, h = NForecast)$mean
    AllWaveletForecast[, j] <- as.numeric(fc)
  }
  colnames(AllWaveletPrediction) <- colnames(WS)
  colnames(AllWaveletForecast)   <- colnames(WS)
  
  # --- sums ---
  FinalPrediction <- rowSums(AllWaveletPrediction, na.rm = TRUE)   # length = n
  Finalforecast   <- rowSums(AllWaveletForecast,   na.rm = TRUE)   # length = NForecast
  
  # --- in-sample metrics ---
  k <- min(length(Actual), length(FinalPrediction))
  y_fit    <- tail(as.numeric(Actual), k)
  yhat_fit <- tail(FinalPrediction, k)
  
  RMSE_in <- Metrics::rmse(y_fit, yhat_fit)
  r_in    <- suppressWarnings(cor(y_fit, yhat_fit, use = "complete.obs"))
  MARE_in <- mare_pct(y_fit, yhat_fit)
  IA_in   <- ia_willmott(y_fit, yhat_fit)
  
  acc <- data.frame(
    set  = "in_sample",
    RMSE = RMSE_in,
    r    = r_in,
    MARE = MARE_in,
    IA   = IA_in,
    row.names = NULL
  )
  
  # --- optional forecast metrics ---
  if (!is.null(actual_future)) {
    h <- min(length(actual_future), length(Finalforecast))
    y_fc    <- as.numeric(actual_future[seq_len(h)])
    yhat_fc <- as.numeric(Finalforecast[seq_len(h)])
    
    RMSE_fc <- Metrics::rmse(y_fc, yhat_fc)
    r_fc    <- suppressWarnings(cor(y_fc, yhat_fc, use = "complete.obs"))
    MARE_fc <- mare_pct(y_fc, yhat_fc)
    IA_fc   <- ia_willmott(y_fc, yhat_fc)
    
    acc <- rbind(acc, data.frame(
      set  = "forecast",
      RMSE = RMSE_fc,
      r    = r_fc,
      MARE = MARE_fc,
      IA   = IA_fc
    ))
  }
  
  list(
    WaveletSeries       = WS,                     # برای نام‌گذاری لِوِل‌ها
    FittedByLevel       = AllWaveletPrediction,   # فیتِ هر لِوِل (n x L)
    Finalforecast       = Finalforecast,          # جمعِ forecastها (h)
    FinalPrediction     = FinalPrediction,        # جمعِ fittedها (n)
    Accuracy            = acc
  )
}
