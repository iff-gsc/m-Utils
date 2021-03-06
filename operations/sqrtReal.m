function y = sqrtReal( u ) %#codegen
% sqrtReal compute the square root and avoid complex numbers
%   This function wraps sqrt but assures that no complex number is returned.
%   This is important for use in Simulink to avoid errors in special cases.
%   If the input is negative, the output will be zero.
% 
% Syntax:
%   y = sqrtReal( u )
% 
% Inputs:
%   u           input of the sqrt function (NxM array)
% 
% Outputs:
%   y           output of the sqrt function (NxM array)
% 
% See also:
%   acosReal, asinReal
% 

% Disclamer:
%   SPDX-License-Identifier: GPL-2.0-only
% 
%   Copyright (C) 2020-2022 Yannic Beyer
%   Copyright (C) 2022 TU Braunschweig, Institute of Flight Guidance
% *************************************************************************

u(u<0) = 0;
y = sqrt(u);

end