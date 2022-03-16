function y = acosReal( u ) %#codegen
% acosReal compute the arccos and assure a real output
%   This function wraps acos but assures that no complex number is returned.
%   This is important for use in Simulink to avoid errors in special cases.
%   If the input is less than -1, the output will be 0.
%   If the input is greater than 1, the output will be pi.
% 
% Syntax:
%   y = acosReal( u )
% 
% Inputs:
%   u           input of the acos function (NxM array), dimensionless
% 
% Outputs:
%   y           output of the acos function (NxM array), in rad
% 
% See also:
%   asinReal, sqrtReal
% 

% Disclamer:
%   SPDX-License-Identifier: GPL-2.0-only
% 
%   Copyright (C) 2020-2022 Yannic Beyer
%   Copyright (C) 2022 TU Braunschweig, Institute of Flight Guidance
% *************************************************************************

u(u>1) = 1;
u(u<-1) = -1;
y = acos(u);

end