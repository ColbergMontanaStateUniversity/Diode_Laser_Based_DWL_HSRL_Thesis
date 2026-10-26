# Diode_Laser_Based_DWL_HSRL_Thesis
This is the code used for the thesis "Diode-Laser-Based Direct-Detection Doppler Wind Lidar and High Spectral Resolution Lidar" by Luke Colberg.

This repository is provided as-is and is not maintained. No support will be provided.

Two functions share the name CreateCabannesSpectrum. Each script changes into the folder containing the correct version before calling it. Do not add the full repository to the MATLAB path or MATLAB may call the wrong one.

## Repository roadmap

Each directory has its own README with requirements and settings.

| Directory | Contents |
|-----------|----------|
| `Instrument_Control` | MATLAB scripts that control the lab instruments during data collection: holding the etalon temperatures, scanning the laser for receiver calibration, and logging the wavemeter. |
| `Afterpulsing` | Generates the afterpulsing curves from a measurement taken with the lidar blocked. |
| `Calibration_Code` | Generates the receiver transmission curves and the HSRL calibration constants from a laser frequency calibration scan. |
| `Cabannes_PCA` | Generates the training set and principal components used to model the Cabannes spectrum in the HSRL calibration and the retrieval. |
| `HRRR_Code` | Obtains the HRRR model data used to model the atmospheric temperature and pressure in the retrieval. |
| `Main_Code` | The main DWL and HSRL retrieval, which produces the radial wind velocity, backscatter ratio, and aerosol backscatter coefficient. |

The retrieval in `Main_Code` uses outputs from `Afterpulsing`, `Calibration_Code`, `Cabannes_PCA`, and `HRRR_Code`, so those need to be run first. The calibration scan in `Calibration_Code` uses the file produced by `ScanLaserMonitorWavelength` in `Instrument_Control`, and the HSRL calibration also uses the PCA file from `Cabannes_PCA`.
