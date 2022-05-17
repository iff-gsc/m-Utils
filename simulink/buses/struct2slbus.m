% struct2slbus(s, BusName, ....)
%
% Converts the structure s to a Simulink Bus Object with name BusName. This
% function can create the Simulink Bus Object for a structure with its fields as
% structures and thus this nesting of structures is accomodated to any desired
% level. The parent Bus Object for the structure will be created with the name
% 'BusName' provided as input to the function.  The standard names for the
% subbus objects are set same as their field names, unless additional inputs
% (like ID) are provided to append or prepend the standard names.
% Inputs:
%   s:          Struct whose Bus Object needds to be created
%   BusName:    A character array which will be given as name of the Bus Object
%               for the struct. For eg: BusName = 'BusDerivative'
%
% Consider a following example
%   Consider a struct 'derivatives' with 2 fileds, 'data' which is a 1D array of
%   double , say, [1 15] and 'dim' which itself is a struct with 2 fields 'rows'
%   and 'cols' which are just 'double'. Let us also consider this field 'dim; to
%   be an array of size [1 4]. So the struct would look something like:
%       derivatives.data = omes(1,16)
%       derivatives.dim(1).rows = 1, derivatives.dim(1).cols = 2
%       derivatives.dim(2).rows = 1, derivatives.dim(2).cols = 4
%       derivatives.dim(3).rows = 1, derivatives.dim(3).cols = 6
%       derivatives.dim(4).rows = 1, derivatives.dim(4).cols = 3
%
% Syntax: struct2slbus(derivatives, 'BusDerivative')
%
% This will create a Bus Object 'BusDerivative' with the Bus element 'data' of
% type double and a Bus Element named 'dim'. This 'dim' is a type of a Bus
% Object 'dim' with elements 'rows' and 'cols' each of type double.
%
% One can append the names of all Bus Objects (parent and subbus objects) with
% an ID. This can be done as follows: Syntax: struct2slbus(derivatives,
% 'BusDerivative', 'ID', 4) This will create a parent Bus Object
% 'BusDerivative4' with elements 'data' and 'dim'. The element 'dim' is a type
% of Bus Object 'dim4' with elements 'row' and 'cols'. Remember only the Bus
% object names will be appended with ID, the names of the elements of the Bus
% Objects will be same as field names in their respective structures.
%
% One needs to sometimes distinguish between Bus Objects of different structures
% with same field names. For example consider a structure 'newStruct' with
% fields 'data' which is an 1D array of double and 'dim' which is a struct with
% fields 'rows', 'cols' and 'index' each of type double. Now we clearly need to
% differentiate between the Bus Objects for the field 'dim' of the structs
% 'derivatives' and 'newStruct'. One can do it in a following way:
% Syntax: struct2slbus(derivatives, 'BusDerivative', 'Differentiate', 'dim')
%
% This indicates that the field 'dim' will be distinguished and its
% corresponding Bus Object will be prepended with the name of its parent struct.
% A parent Bus Object 'BusDerivative' with elements 'data' and
%'dim' will be created. The element 'dim' is a type of Bus Object
%'derivatives_dim' with elements 'row' and 'cols'.  Now, struct2slbus(newStruct,
%'newStructBus', 'Differentiate', 'dim') will create a parent Bus Object
%'newStructBus' with elements 'data' and 'dim'.  The element 'dim' is a type of
%Bus Object 'newStruct_dim' with elements 'rows' and 'cols'.
%
% The following variants are possible:
% struct2slbus(derivatives, 'BusDerivative', 'ID', 4, ...
%   'Differentiate','field1', 'field2', ....)
% 'ID' should never be given after 'Differentiate'
%
% See also:  createNet,  scellArr2cell,  setScellArrAt,  getScellArrAt

% Disclamer:
%   SPDX-License-Identifier: GPL-2.0-only
% 
%   Copyright (C) 2020-2022 Yannic Beyer
%   Copyright (C) 2022 TU Braunschweig, Institute of Flight Guidance
% *************************************************************************

function struct2slbus( s, BusName, varargin )

    n = length(varargin);
    start_diff = 1;
    end_diff = 0;

    if (n == 0)
        charID = [];
    end

    for i = 1:n
        if ( strcmp(varargin{1}, 'ID') )
            ID = varargin{2};
            charID = num2str(ID);
        end

        if ( strcmp(varargin{i}, 'Differentiate') )
            start_diff = i + 1;
            end_diff = n;
            break;
        end
    end

    % Obtain the fieldnames of the structure
    sfields = fieldnames(s);

    if( length(s) > 1 )
        s = s(1);
    end

    % Loop through the structure
    for i = 1:length(sfields)
        sfieldsID = [ sfields{i}, charID ];

        sfields_diff = sfields{i};

        for k = start_diff:end_diff
            if( strcmp(sfields{i}, varargin{k}) )
                sfields_diff = [ BusName, '_', sfields{i} ];
            end
        end

        if isequal( class(s.(sfields{i})), 'struct' )
            % Here is struct inside a struct identified. And only existing types
            % could be addi as type in this script. So we have to create a bus
            % for this struct and add them to this element.
            % Create new bus
            struct2slbus( s.(sfields{i}), sfields_diff, varargin{:} );
            % We have to check how this is done ... TODO
            elems(i) = Simulink.BusElement;
            elems(i).Name = sfields{i};
            elems(i).Dimensions = size(s.(sfields{i}));
            elems(i).DataType = ['Bus: ', [sfields_diff, 'Bus',charID]];
            elems(i).SampleTime = -1;
            elems(i).Complexity = 'real';
            elems(i).SamplingMode = 'Sample based';
        else
            % Create BusElement for each field
            elems(i) = Simulink.BusElement;
            elems(i).Name = sfields{i};
            elems(i).Dimensions = size(s.(sfields{i}));
            elems(i).DataType = class(s.(sfields{i}));
            if strcmp(elems(i).DataType, 'logical')
                elems(i).DataType = 'boolean';
            end
            elems(i).SampleTime = -1;
            elems(i).Complexity = 'real';
            elems(i).SamplingMode = 'Sample based';
        end
    end

    % Create main fields of Bus Object and generate Bus Object in the base
    % workspace.
    BusObject = Simulink.Bus;
    BusObject.HeaderFile = '';
    BusObject.Description = sprintf('');
    BusObject.Elements = elems;
    assignin('base', [ BusName, 'Bus', charID ], BusObject);
end
