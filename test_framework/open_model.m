function open_model(modelname)
% open_model open or load a Simulink model for LADAC unit tests
%   c = open_model( modelname ) opens the model 'modelname'. If the
%   function finds the variable 'TEST_LADAC' in the base workspace it
%   executes load_system(modelname) instead of open(modelname), that
%   prevents Simulink from opening the model in a window, which saves time
%   when the model is just opened for testing purposes.
% 
% Syntax:
%   c = open_model(modelname)
% 
% Inputs:
%   modelname           name of the model without extension
% 
% See also:
%   clc_clear, existInBaseWorkspace, validateModelBuild
% 

% Disclamer:
%   SPDX-License-Identifier: GPL-3.0-only
% 
%   Copyright (C) 2020-2022 Fabian Guecker
%   Copyright (C) 2022 TU Braunschweig, Institute of Flight Guidance
% *************************************************************************

if(~existInBaseWorkspace('TEST_LADAC'))
    open(modelname);
else
    assignin('base', 'MODEL_NAME', modelname);
end

end