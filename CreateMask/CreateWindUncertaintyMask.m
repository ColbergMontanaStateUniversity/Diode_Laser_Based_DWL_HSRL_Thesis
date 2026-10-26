function [Winds] = CreateWindUncertaintyMask(Winds)

% This function creates a mask for the wind data (1 = masked, 0 = kept).
% Cells are masked where the radial velocity uncertainty is NaN or exceeds
% 3 m/s. The mask is then cleaned up: unmasked cells with 6 or more masked
% neighbors (of 8) are masked, masked cells with 6 or more unmasked
% neighbors are unmasked, and the first step is repeated.

    Mask = zeros(size(Winds.Vr_std));
    Mask(isnan(Winds.Vr_std)) = 1;
    Mask(Winds.Vr_std>3) = 1;

    kernel = [1 1 1; 1 0 1; 1 1 1];
    neighborCount = conv2(double(Mask), kernel, 'same');
    
    Mask(Mask == 0 & neighborCount >= 6) = 1;

    kernel = [1 1 1; 1 0 1; 1 1 1];
    zeroCount = conv2(double(~Mask), kernel, 'same');
    
    Mask(Mask == 1 & zeroCount >= 6) = 0;

    kernel = [1 1 1; 1 0 1; 1 1 1];
    neighborCount = conv2(double(Mask), kernel, 'same');
    
    Mask(Mask == 0 & neighborCount >= 6) = 1;
    Mask(isnan(Winds.Vr_std) | isnan(Winds.Vr)) = 1; % keep NaN cells masked
    Winds.Mask = Mask;

end