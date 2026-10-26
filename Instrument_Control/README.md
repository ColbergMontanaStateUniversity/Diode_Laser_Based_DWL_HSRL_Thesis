This code controls the lab instruments used with the wind lidar.

MaintainEtalonTemperature runs continuously during data collection and holds the two etalons, their enclosures, and the background etalon at their setpoint temperatures.

ScanLaserMonitorWavelength steps the laser current on the ILX LDC-3724C and records the laser temperature, current, wavelength, and power at each step. It is ran during calibration. 

MonitorWavelength logs the wavelength and power from the Bristol wavemeter. This function is used to calibrate the wavemeter when it is ran while the laser is stabilized to a Rubidium spectral feature at a known wavelength.

The remaining files are functions called by these three scripts. Requires MATLAB, the Instrument Control Toolbox, and a VISA driver for the GPIB connections.

Setpoints, scan currents, and output filenames are set at the top of each script. Instrument addresses (GPIB addresses and the wavemeter IP address and port), PRO8000 slot numbers, and setpoint safety limits are hard-coded and commented, and will need to be changed for other hardware.
