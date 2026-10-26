function [Path] = define_paths()
% This function defines the file paths
    Path.home               = pwd;
    Path.RawData            = "C:\Users\lukec\Desktop\WindLidarData\Raw_Data";
    Path.SaveData           = "C:\Users\lukec\Desktop\WindLidarData\Processed_Data";
    Path.HRRRData           = "C:\Users\lukec\Desktop\HRRRData"; 
    Path.AfterpulsingData   = "C:\Users\lukec\Desktop\WindLidarCalibrationAfterpulsingData\AfterpulsingData";
    Path.CalibrationData    = "C:\Users\lukec\Desktop\WindLidarCalibrationAfterpulsingData\CalibrationCurves";
    Path.CabannesPCA        = "C:\Users\lukec\Desktop\WindLidarCalibrationAfterpulsingData\CabannesPCA";
    Path.HSRLCal            = "C:\Users\lukec\Desktop\HSRLCalibrationAfterpulsing\CalibrationTables";

end