# SPEI‑WNN: Advanced Drought Forecasting using Wavelet Decomposition & Neural Networks

## Overview
**SPEI-WNN** is an advanced time-series modeling framework that integrates **Wavelet Transform** for multi-resolution decomposition with **Artificial Neural Networks (ANNs)** for predictive modeling. This hybrid approach is designed to improve the forecasting accuracy of the **Standardized Precipitation–Evapotranspiration Index (SPEI)**, a widely used drought indicator.

By decomposing the original time series into multiple frequency components, the model captures both short-term fluctuations and long-term climatic trends. Each component is modeled individually with ANNs, and forecasts are reconstructed to provide a unified, high-accuracy prediction.

---

## Key Features
- **SPEI Calculation & Integration**: Works directly with monthly SPEI series or computed SPEI from climatic data.
- **Multi-Level Wavelet Decomposition**: Flexible selection of decomposition levels (J) to capture different temporal scales.
- **ANN-based Forecasting**: Uses `nnetar` or similar neural network architectures for each decomposed component.
- **Model Evaluation Suite**: Built-in computation of RMSE, R², MARE, and Index of Agreement.
- **Full Visualization Support**: Scripts for generating publication-ready plots of actual vs. fitted vs. forecasted series.

---

## Repository Structure
```
spei_wnn/
├── data/               # Example datasets or user-provided inputs
├── describe.R          # Descriptive statistics and normality checks
├── main.R              # Main execution pipeline
├── run.R               # Quickstart execution script
├── predict1.R          # Visualization scripts
├── predict2.R          # Visualization scripts
├── plot1.R             # Visualization scripts
├── res_plot.R          # Evaluation result plots
├── export_data.R       # Export routines for processed data/results
├── SPEI.ipynb          # Exploratory Jupyter Notebook
```

---

## Prerequisites
- **R ≥ 4.2**
- Recommended R packages:
```r
install.packages(c(
  "forecast", "ggplot2", "zoo", "dplyr", "tidyr",
  "moments", "tseries", "car"
))
# Optional: Wavelet packages
# install.packages("waveslim")
# or
# install.packages("wavelets")
```

---

## Quickstart

### 1. Clone the repository
```bash
git clone https://github.com/omidedalati/spei_wnn
cd spei_wnn
```

### 2. Prepare your dataset
Place your SPEI or related climatic data inside the `data/` directory.

### 3. Run the pipeline
```r
# In R or RStudio
source("main.R")
then
source("run.R")

```

---

## Methodology
1. **Data Preparation**  
   - Load and preprocess time-series data.  
   - Create lagged variables for ANN input.

2. **Wavelet Decomposition**  
   - Apply Discrete Wavelet Transform (DWT) to split series into multiple components.  
   - Select decomposition level based on data length and target resolution.

3. **ANN Modeling**  
   - Train `nnetar` models for each component.  
   - Tune hyperparameters (`size`, `p`, `P`).

4. **Forecast Reconstruction**  
   - Combine component forecasts to generate the final SPEI forecast.

5. **Evaluation & Validation**  
   - Compute RMSE, R², MARE, and Index of Agreement.  
   - Optionally run rolling-origin or time-series cross-validation.

---

#

## Visualization
Scripts such as `plot1.R` and `res_plot.R`  provide:
- Actual vs. fitted vs. forecast plots
- Drought threshold lines (e.g., SPEI = 0, -1, -2)
- Boxplots & histograms for statistical insights

---

## License
Distributed under the MIT License. See `LICENSE` for more information.

---

## Acknowledgments

- Built with open-source R libraries and methodologies.
