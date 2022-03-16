function bus_var = struct2bus_( struct_ )
%struct2bus_ converts a struct into a Simulink bus object.
%   If the struct contains structs, for each of these structs bus objects
%   will be assigned to the base workspace. Existing busses will not be
%   overwritten, they will be distinguished by a prefix (slBusX_, where X
%   is a number).
%
% Inputs:
%   struct_         an arbritary struct that is compatible with Simulink
% 
% Outputs:
%   bus_var         bus object of the input struct (note that busses
%                   corresponding to structs inside of the struct will be
%                   assigned to the base workspace automatically)
% 
% Example:
%   a1 = struct('a',1);
%   a2 = struct('a',[1 1]);
%   b = struct('a',a2);
%   c = struct('a',a1,'b',b);
%   c_bus = struct2bus_(c);
%   % you should now have the following bus objects in your base workspace:
%   % c_bus, a, slBus1_a, slBus2_b
% 
% See also:
%   struct2bus, struct2slbus
% 

% Disclamer:
%   SPDX-License-Identifier: GPL-2.0-only
% 
%   Copyright (C) 2020-2022 Yannic Beyer
%   Copyright (C) 2022 TU Braunschweig, Institute of Flight Guidance
% *************************************************************************

busInfo = Simulink.Bus.createObject(struct_);
bus_var = evalin('base',busInfo.busName);
evalin('base',['clear ', busInfo.busName] );

end