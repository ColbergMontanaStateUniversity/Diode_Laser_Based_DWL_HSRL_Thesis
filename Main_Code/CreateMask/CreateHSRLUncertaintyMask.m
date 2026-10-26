function [HSRL] = CreateHSRLUncertaintyMask(HSRL)

% This function creates a mask for the HSRL data (1 = masked, 0 = kept).
% Cells are masked where the backscatter ratio uncertainty is NaN or the
% relative uncertainty BR_std/BR exceeds 10%. The mask is then cleaned up:
% unmasked cells with 6 or more masked neighbors (of 8) are masked, masked
% cells with 6 or more unmasked neighbors are unmasked, and the first step
% is repeated.

    Mask = zeros(size(HSRL.BR_std));
    Mask(isnan(HSRL.BR_std)) = 1;
    Mask(HSRL.BR_std./abs(HSRL.BR)>0.1) = 1;

    kernel = [1 1 1; 1 0 1; 1 1 1];
    neighborCount = conv2(double(Mask), kernel, 'same');
    
    Mask(Mask == 0 & neighborCount >= 6) = 1;

    kernel = [1 1 1; 1 0 1; 1 1 1];
    zeroCount = conv2(double(~Mask), kernel, 'same');
    
    Mask(Mask == 1 & zeroCount >= 6) = 0;

    kernel = [1 1 1; 1 0 1; 1 1 1];
    neighborCount = conv2(double(Mask), kernel, 'same');
    
    Mask(Mask == 0 & neighborCount >= 6) = 1;

    Mask(isnan(HSRL.BR_std) | isnan(HSRL.BR)) = 1; % keep NaN cells masked

    HSRL.Mask = Mask;


end