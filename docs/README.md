# Predicting Chemical Concentrations at Southern Hydrate Ridge Methane Seeps

## Overview

This project develops machine learning models to predict key chemical concentrations (methane and hydrogen) at the Southern Hydrate Ridge methane seep site using multimodal geophysical data from the Ocean Observatories Initiative (OOI) Regional Cabled Array (RCA). By leveraging reliable, long-lasting instruments (seismometers, pressure sensors, acoustic Doppler current profilers), we aim to predict biogeochemically important chemical concentrations during time periods when direct mass spectrometer measurements are unavailable.

## Scientific Context

Southern Hydrate Ridge, located offshore Oregon, is a methane seep site of significant biogeochemical importance. The site features active methane venting, gas hydrate deposits, and complex fluid flow dynamics. Understanding temporal variations in methane (CH₄) and hydrogen (H₂) concentrations is crucial for:

- Quantifying methane flux to the ocean and atmosphere
- Understanding subsurface biogeochemical processes
- Characterizing seep dynamics and episodic venting events
- Assessing climate-relevant greenhouse gas emissions

However, mass spectrometer instruments require frequent maintenance and calibration, leading to data gaps. This project addresses these gaps by training models on reliable geophysical proxies.

## Data Sources

### Ocean Observatories Initiative (OOI) Regional Cabled Array

All data are collected from the OOI RCA infrastructure at Southern Hydrate Ridge:

#### Input Features (Predictors):

1. **Seismic Data**
   - Station: OO.HYS14 (and other HYS1* stations)
   - Channels: HHZ, HHN, HHE (200 Hz sampling rate)
   - Three-component broadband seismometer data
   - Sensitive to ground motion, tremor, and fluid flow dynamics

2. **Acoustic Data**
   - Instrument: ADCP (Acoustic Doppler Current Profiler)
   - Dataset: RS01SUM2-MJ01B-12-ADCPSK101
   - Measures bubble plume velocity and water column dynamics
   - Hourly measurements of current profiles

3. **Pressure Data**
   - Bottom pressure recorders (BPR)
   - Sensitive to tidal loading and fluid pressure changes
   - Indicator of subsurface pore pressure dynamics

#### Target Variables (Labels):

4. **Mass Spectrometer Data**
   - Methane (CH₄) concentration (nM/L)
   - Hydrogen (H₂) concentration (nM/L)
   - Derived from partial pressure measurements using Henry's Law
   - From: `methane_concentration_2017.csv`

## Data Processing Pipeline

### Temporal Alignment

All data streams are aligned to **22-second time windows** corresponding to mass spectrometer measurement timestamps. This window size balances:
- Sufficient seismic signal for spectral analysis
- ADCP measurement intervals
- Computational efficiency

### Seismic Data Processing

For each 22-second window:

1. **Download**: Query IRIS FDSN web services for three-component data
2. **Detrend**: Remove linear trends using ObsPy
3. **Taper**: Apply 5% Hanning window to edges
4. **Highpass Filter**: Highpass filter at 2 Hz cutoff
   - Removes microseism noise and long-period ocean loading
   - Focuses on signals related to fluid flow and bubble dynamics
5. **Quality Control**: Check for gaps, NaN values, and data quality

### Acoustic (ADCP) Data Processing

1. **Load NetCDF**: Read hourly ADCP velocity data
2. **Temporal Extraction**: For each 22-second window, extract all ADCP measurements
3. **Bin Averaging**: If multiple depth bins present, compute mean across bins
4. **Unit Conversion**: Convert m/s to cm/s where appropriate

### Target Variable Calculation

Methane and hydrogen concentrations are calculated from mass spectrometer partial pressure measurements using **Henry's Law**:

```
C = K_H × P_partial
```

Where:
- C = dissolved gas concentration (nM/L)
- K_H = Henry's Law constant (temperature and salinity dependent)
- P_partial = partial pressure measured by mass spectrometer

## Machine Learning Approaches

This project implements **two complementary modeling strategies**, each suited to different aspects of the data:

### Approach 1: Feature-Based Random Forest Regression

**Training Data Format**: Extracted statistical and spectral features

**Feature Extraction** (per 22-second window):

**Seismic Features** (per component: Z, N, E):
- Amplitude statistics: max, min, mean, median
- Spectral features: top 3 dominant frequencies and their power
- Total: ~24 features per window

**Acoustic Features**:
- Mean velocity in 22-second window
- Maximum velocity
- Minimum velocity
- Standard deviation

**Model Architecture**:
- Algorithm: Random Forest Regressor (scikit-learn)
- Configuration:
  - 100-150 trees
  - Max depth: 15-16
  - Min samples split: 5
  - Min samples leaf: 2
  - Max features: 'sqrt'
- Validation: 5-fold cross-validation
- Weighting: Sample weights based on inverse frequency to balance distribution

**Advantages**:
- Interpretable feature importances
- Handles non-linear relationships
- Robust to outliers
- Fast training and inference

### Approach 2: Time Series Convolutional Neural Network

**Training Data Format**: Raw time series arrays (post-filtering)

**Data Structure** (per 22-second window):
- Seismic: 3 channels × 4400 samples (200 Hz × 22 sec)
- Acoustic: Variable samples (hourly measurements interpolated)

**Model Architecture**:
- Framework: PyTorch
- Architecture: 1D CNN Regressor
  - Input layer: Reshape features to (batch, 1, n_features)
  - Convolutional blocks:
    - Conv1D: 1 → 64 channels, kernel=3
    - BatchNorm + ReLU + Dropout(0.2)
    - Conv1D: 64 → 128 channels, kernel=3
    - BatchNorm + ReLU + Dropout(0.2)
    - Conv1D: 128 → 64 channels, kernel=3
    - BatchNorm + ReLU + Dropout(0.2)
  - Global Average Pooling
  - Fully connected layers: 64 → 128 → 64 → 32 → 1
  - Dropout(0.3) in FC layers
- Training:
  - Optimizer: Adam (lr=0.001)
  - Loss: MSE (Mean Squared Error)
  - Epochs: 100 with early stopping (patience=15)
  - Batch size: 32
- Validation: 5-fold cross-validation

**Advantages**:
- Captures temporal patterns and phase relationships
- Learns hierarchical features automatically
- Better for sequential dependencies
- No manual feature engineering required

## Model Evaluation

### Data Split Strategy

- **Training set**: 70% of data (further split in 5-fold CV)
- **Validation sets**: 5 folds for cross-validation
- **Test set**: 15% held-out data for final evaluation

### Performance Metrics

- **RMSE** (Root Mean Squared Error): Prediction accuracy
- **R²** (Coefficient of Determination): Explained variance
- **MAE** (Mean Absolute Error): Average prediction error
- **Weighted metrics**: Account for distribution imbalance

### Distribution Balancing

The target variable (methane concentration) exhibits a skewed distribution. We address this through:

1. **Sample Weighting**: Inverse frequency weighting during training
   - Rare concentration values receive higher weights
   - Prevents model bias toward common values

2. **Transformation Options** (explored):
   - Yeo-Johnson power transformation
   - Quantile transformation to normal distribution
   - Bootstrap resampling for Gaussian approximation
   - Exponential decay transformation

## Results Summary

### Random Forest Performance

- Cross-validation R²: [To be filled with results]
- Test set R²: [To be filled with results]
- Test set RMSE: [To be filled with results]

**Top Feature Importances**:
- [To be filled with analysis]

### CNN Performance

- Cross-validation R²: [To be filled with results]
- Test set R²: [To be filled with results]
- Test set RMSE: [To be filled with results]

### Model Comparison

[Comparative analysis of RF vs CNN performance, including error distribution across different methane concentration ranges]

## Repository Structure

```
mlgeo-methane-seeps/
├── shr_seismicity_relevant_dates.ipynb          # Feature-based RF analysis
├── shr_seismicity_relevant_dates_time_series.ipynb  # Time series CNN analysis
├── data/
│   ├── methane_concentration_2017.csv           # Target variables
│   ├── RS01SUM2-MJ01B-12-ADCPSK101_*.nc        # ADCP data
│   └── seismic_features_*.csv                   # Extracted features
├── models/
│   ├── rf_model_final.pkl                       # Trained Random Forest
│   ├── cnn_model_final.pth                      # Trained CNN
│   └── transformers.pkl                         # Data transformers
├── results/
│   ├── correlation_matrix_*.png
│   ├── pca_analysis_*.png
│   ├── random_forest_5fold_cv_results.png
│   └── cnn_regression_5fold_cv_results.png
└── MLGEO_2026_Hydrothermal_Vents/
    └── docs/
        └── README.md                             # This file
```

## Dependencies

### Python Environment

```python
# Core scientific computing
numpy>=1.21.0
pandas>=1.3.0
scipy>=1.7.0

# Seismic data processing
obspy>=1.3.0

# NetCDF file handling
netCDF4>=1.5.7

# Machine learning
scikit-learn>=1.0.0
torch>=1.10.0

# Visualization
matplotlib>=3.4.0
seaborn>=0.11.0

# Data access
requests>=2.26.0
```

### External Data Services

- **IRIS FDSN Web Services**: Seismic waveform data
  - Client: `obspy.clients.fdsn.Client("IRIS")`
  - Networks: OO (Ocean Observatories Initiative)

## Usage

### 1. Feature-Based Random Forest Workflow

```python
# Run feature extraction and RF training
jupyter notebook shr_seismicity_relevant_dates.ipynb

# Key cells:
# - Data loading and window creation
# - Feature extraction from seismic/acoustic data
# - Random Forest training with 5-fold CV
# - Model evaluation and visualization
```

### 2. Time Series CNN Workflow

```python
# Run time series extraction and CNN training
jupyter notebook shr_seismicity_relevant_dates_time_series.ipynb

# Key cells:
# - Time series extraction (22-sec windows)
# - Data storage as pickle files
# - CNN model training with PyTorch
# - Model comparison with Random Forest
```

### 3. Loading Pre-trained Models

```python
# Load Random Forest
import pickle
with open('models/rf_model_final.pkl', 'rb') as f:
    rf_model = pickle.load(f)

# Load CNN
import torch
checkpoint = torch.load('models/cnn_model_final.pth')
cnn_model = CNN1DRegressor(input_dim=n_features)
cnn_model.load_state_dict(checkpoint['model_state_dict'])
```

## Scientific Applications

### Methane Flux Estimation

- Continuous prediction of CH₄ concentrations during instrument downtime
- Improved temporal resolution for flux calculations
- Better characterization of episodic venting events

### Seep Dynamics Studies

- Correlation between seismic tremor and chemical release
- Relationship between bottom currents and plume dispersal
- Pressure-driven fluid migration patterns

### Early Warning Systems

- Real-time prediction of elevated methane concentrations
- Detection of anomalous venting events
- Integration with autonomous sampling strategies

## Limitations and Future Work

### Current Limitations

1. **Temporal Coverage**: Training data limited to 2017 when all instruments operational
2. **Spatial Coverage**: Single seismic station (HYS14)
3. **ADCP Sampling**: Hourly measurements limit temporal resolution
4. **Seasonal Bias**: May not capture full range of environmental conditions

### Future Directions

1. **Multi-year Training**: Incorporate data from 2014-2020
2. **Multi-station Ensemble**: Use all HYS1* stations for spatial context
3. **Additional Features**: 
   - Temperature and salinity from CTD sensors
   - Tidal phase and magnitude
   - Seafloor imagery (if available)
4. **Transfer Learning**: Apply models to other seep sites
5. **Real-time Deployment**: Implement models in OOI cyberinfrastructure
6. **Physics-informed ML**: Incorporate fluid dynamics constraints

## Contributors

[Your names/affiliations here]

## Acknowledgments

- **Ocean Observatories Initiative (OOI)**: Data infrastructure and access
- **IRIS Data Management Center**: Seismic waveform services
- **NSF**: OOI funding and support
- **[Your institution/course]**: Computational resources and guidance

## References

### Scientific Background

1. Hautala, S. L., et al. (2014). "Dissociation of Cascadia margin gas hydrates in response to contemporary ocean warming." *Geophysical Research Letters*, 41(23).

2. Suess, E., et al. (1999). "Flammable ice." *Scientific American*, 281(5), 76-83.

3. Riedel, M., et al. (2006). "Nature and distribution of gas hydrates in the southern Hydrate Ridge region, Cascadia margin." *Journal of Geophysical Research*, 111(B11).

### Machine Learning Methods

4. Breiman, L. (2001). "Random forests." *Machine Learning*, 45(1), 5-32.

5. LeCun, Y., Bengio, Y., & Hinton, G. (2015). "Deep learning." *Nature*, 521(7553), 436-444.

### OOI Documentation

6. Ocean Observatories Initiative. "Regional Cabled Array." https://oceanobservatories.org/

## Citation

If you use this code or methodology, please cite:

```
[Your citation format here]
```

## License

[Specify license - e.g., MIT, GPL, Academic use only, etc.]

---

**Last Updated**: February 2026  
**Project Status**: Active Development
