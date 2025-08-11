

x<-unpivoted_pet$pet


ts_data <- ts(x, start = c(1901,1), frequency = 12)

res <- WaveletFittingann_fix(
  ts = ts_data,
  Waveletlevels = 7,
  Filter = 'haar',
  boundary = "periodic",
  FastFlag = TRUE,
  nonseaslag =24,
  seaslag = 1,
  hidden = 10,
  NForecast = 120
)

res$Accuracy
