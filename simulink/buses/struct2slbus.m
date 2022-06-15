function id = struct2slbus( s, varargin )
% struct2slbus create simulink bus object(s) from struct
% 
% Syntax:
%   id = struct2slbus( s )
%   id = struct2slbus( s, bus_name )
% 
% Inputs:
%   s           A struct which is meant to be used as a Simulink bus signal
%   bus_name    Optional: Desired name of the corresponding bus object
%               (chars). The chars 'Bus' will be appended to the specified
%               bus_name. If no bus_name was specified, the bus object will
%               be named as the struct s but with the appendix 'Bus'.
% 
% Outputs:
%   id          The number which was appendended to the desired bus_name 
%               (numbers as chars). An id is appended in case the was
%               already a variable of the same name. If no id was appended,
%               the id is empty.
%   
% See also: struct2bus, struct2bus_

% Disclamer:
%   SPDX-License-Identifier: GPL-2.0-only
%
%   Copyright (C) 2020-2022 Yannic Beyer
%   Copyright (C) 2022 TU Braunschweig, Institute of Flight Guidance
% *************************************************************************

if isempty(varargin)
    bus_name = inputname(1);
else
    bus_name = varargin{1};
end

% Obtain the fieldnames of the structure
sfields = fieldnames(s);

if( length(s) > 1 )
    s = s(1);
end

elems = repmat( Simulink.BusElement, length(sfields), 1 );

% Loop through the structure
for i = 1:length(sfields)
    
    sfields_diff = sfields{i};
    
    % fill BusElement for each field
    if isequal( class(s.(sfields{i})), 'struct' )
        % Here is struct inside a struct identified. And only existing types
        % could be added as type in this script. So we have to create a bus
        % for this struct and add them to this element.
        % Create new bus
        id = struct2slbus( s.(sfields{i}), sfields_diff );
        if isempty(id)
            final_bus_name = [sfields_diff, 'Bus'];
        else
            final_bus_name = [sfields_diff, 'Bus',num2str(id)];
        end
        elems(i).DataType = ['Bus: ', final_bus_name];
    else
        
        elems(i) = Simulink.BusElement;
        % avoid problems with generated C/C++ code
        if strcmp(elems(i).DataType, 'logical')
            elems(i).DataType = 'boolean';
        else
            elems(i).DataType = class(s.(sfields{i}));
        end
    end
    elems(i).Name = sfields{i};
    elems(i).Dimensions = size(s.(sfields{i}));
    elems(i).SampleTime = -1;
    elems(i).Complexity = 'real';
    elems(i).SamplingMode = 'Sample based';
end

% Create main fields of Bus Object and generate Bus Object in the base
% workspace.
BusObject = Simulink.Bus;
BusObject.HeaderFile = '';
BusObject.Description = sprintf('');
BusObject.Elements = elems;
full_bus_name = [ bus_name, 'Bus' ];
id = assignInBaseNoOverwrite( BusObject, full_bus_name, [] );
end

function id = assignInBaseNoOverwrite( var, var_name, id )
if evalin('base',['exist(''',var_name,''')'])
    base_var = evalin('base',var_name);
    if isequal( base_var, var )
        % do nothing if the same bus exists with the same name
        return;
    else
        % increment appended name number (id) and save the new id
        [var_name,id] = incrementName( var_name );
        id = assignInBaseNoOverwrite( var, var_name, id );
    end
else
    % assign bus to base workspace if it does not exist
    assignin('base', var_name, var);
end

    function [name,id] = incrementName( name )
        % detect current appended bus name number (id) and increment it
        i = 0;
        while true
            current_char = str2double(name(end-i));
            if isnan( current_char )
                i = i - 1;
                break;
            else
                i = i + 1;
            end
        end
        id = str2double(name(end-i:end));
        if isnan(id)
            id = 0;
        end
        id = id + 1;
        name = [name(1:end-i-1),num2str(id)];
    end

end
