function export_ctf(ebsd,fName,varargin)
%function exportCTF(ebsd,fName,varargin)
%
% Export EBSD data to Channel 5 text file (ctf). The resulting ctf file
% can for instance be opened with Channel 5 and Atex or further converted
% to 'ang' format for opening with Edax OIM
%
% Dr. Frank Niessen, University of Wollongong, Australia, 2019
% contactnospam@fniessen.com (remove the nospam to make this email address work)
% Acknowledgements go to Dr. Azdiar A. Gazder, University of Wollongong, Australia
% Version 1.0 - Published 18/04/2019
%
% Syntax
%
%   export_ctf(ebsd,fileName)
%   export_ctf(ebsd,fileName,cprStruct)
%   export_ctf(ebsd,fileName,'manual')
%   export_ctf(ebsd,fileName,'flip')
%
% Input
%  ebsd - @EBSD
%  fileName - Filename, optionally including relative or absolute path
%  cprStruct - structure with properties from cpr-file import
%
% Flags
%  manual - prompt for manual import of microscopy parameters
%  cprStruct - structure with properties from cpr-file import
%  flip - rotate ebsd spatial data (not the orientation data)
%

scrPrnt('SegmentStart','Exporting ''ctf'' file');

% initialize threshold for rounding negative close to 0 x and y coordinates
round0Thrsh = 1e-6;

% pre-processing
scrPrnt('Step','Collecting data');

% get gridified version of ebsd map
ebsdGrid = ebsd.gridify;                                                   

mtexId2ctfId = [1,1,2,2,2,2,2,2,2,2,2,3,3,3,3,3,6,6,7,7,7,7,7,7,4,4,...
  4,5,5,5,5,5,8,8,8,8,8,8,8,8,9,9,10,10,10];

% get microscope acquisition parameters
cprStruct = getClass(varargin,'struct');

if isstruct(cprStruct) && isfield(cprStruct,'job') &&  isfield(cprStruct,'semfields')
  
  %Cpr-file parameter structure from import
  scrPrnt('SubStep','Microscope acquisition parameters imported from Cpr-parameter structure');
  AcquParam.Data{1} = cprStruct.job.magnification; 
  AcquParam.Data{2} = cprStruct.job.coverage;
  AcquParam.Data{3} = cprStruct.job.device;
  AcquParam.Data{4} = cprStruct.job.kv; % acceleration voltage
  AcquParam.Data{5} = cprStruct.job.tiltangle;
  AcquParam.Data{6} = cprStruct.job.tiltaxis;
  AcquParam.Data{7} = cprStruct.semfields.doeuler1; % detector orientation Euler 1
  AcquParam.Data{8} = cprStruct.semfields.doeuler2; % detector orientation Euler 2
  AcquParam.Data{9} = cprStruct.semfields.doeuler3; % detector orientation Euler 3
  AcquParam.Data{10} = 0;                        % working distance (information not available)
  AcquParam.Data{11} = 0;                        % insertion distance (information not available)

elseif check_option(varargin,'manual') %Manual prompt
  
  %Cell-String array with Acquisition parameters
  AcquParam.Str = {'Mag','Coverage','Device','KV','TiltAngle','TiltAxis',...
    'DetectorOrientationE1','DetectorOrientationE2','DetectorOrientationE3',...
    'WorkingDistance','InsertionDistance'};

  %Cell-String array with Acquisition parameter formats
  AcquParam.Fmt = {'%.4f','%.0f','%s','%.4f','%.4f','%.0f','%.4f','%.4f',...
    '%.4f','%.4f','%.4f'};
  
  scrPrnt('SubStep','Insert microscope acquisition parameters manually');
  
  % input dialog box
  answer = inputdlg(strcat(AcquParam.Str,':'),'Input parameters - numeric only',...
    [1 100],sprintfc('%d',zeros(1,11)));                 
  
  % check if terminated
  if isempty(answer); error('Terminated by user'); end                
  
  % convert to numbers
  AcquParam.Data = arrayfun(@str2double, answer, 'Uniform', false);   

else % no microscope data available
  
  scrPrnt('SubStep','Microscope acquisition parameters not available');
  AcquParam.Data(1:11) = {0}; % filling in zeros
  
end

% Open ctf file
scrPrnt('Step','Opening file for writing');
filePh = fopen(fName,'w');                                                 %Open new ctf file for writing

% Write header
scrPrnt('Step','Writing file header');

% write file info
fprintf(filePh,'Channel Text File\r\n');
fprintf(filePh,'Prj %s\r\n',fName);
fprintf(filePh,'Author\t%s\r\n',getenv('USERNAME'));
fprintf(filePh,'JobMode\tGrid\r\n');

% write grid info
fprintf(filePh,'XCells\t%.0f\r\n',size(ebsdGrid,2));
fprintf(filePh,'YCells\t%.0f\r\n',size(ebsdGrid,1));
fprintf(filePh,'XStep\t%.4f\r\n',ebsdGrid.dx);
fprintf(filePh,'YStep\t%.4f\r\n',ebsdGrid.dy);
fprintf(filePh,'AcqE1\t%.4f\r\n',0);
fprintf(filePh,'AcqE2\t%.4f\r\n',0);
fprintf(filePh,'AcqE3\t%.4f\r\n',0);

% write acquisition parameters
fprintf(filePh,'Euler angles refer to Sample Coordinate system (CS0)!\t');	
for i = 1:length(AcquParam.Str) %Loop over aquisition parameters
  if ~strcmp(AcquParam.Fmt{i},'%s') %if numeric format is required
    AcquParam.Data{i} = num2str(AcquParam.Data{i},AcquParam.Fmt{i});    %Convert number to string
  elseif strcmp(AcquParam.Fmt{i},'%s') %if string format is required
    if ~ischar(AcquParam.Data{i}) %check if manual input is numeric
      AcquParam.Data{i} = num2str(AcquParam.Data{i}); %Convert to string
    end
  end
  fprintf(filePh,'%s\t%s\t',AcquParam.Str{i},AcquParam.Data{i}); %Write parameter
end
fprintf(filePh,'\r\n');


% extract crystal system information
CSlst = ebsd.CSList(ebsd.indexedPhasesId);

% write phase info
fprintf(filePh,'Phases\t%.0f\r\n',length(CSlst));                               %Write nr of phases
for i = 1:length(CSlst)
  mineral = CSlst{i}.mineral;
  a = CSlst{i}.aAxis.abs;
  b = CSlst{i}.bAxis.abs;
  c = CSlst{i}.cAxis.abs;
  alpha = CSlst{i}.alpha / degree;
  beta = CSlst{i}.beta / degree;
  gamma = CSlst{i}.gamma / degree;
  laueGr = mtexId2ctfId(CSlst{i}.id);     %Get Laue Group
  spaceGr = 0;                            %Space Group (information not available)
  comment = 'Created from mtex';          %Phase information comment
  fprintf(filePh,'%.3f;%.3f;%.3f\t%.3f;%.3f;%.3f\t%s\t%.0f\t%.0f\t\t\t%s\r\n',...
    a,b,c,alpha,beta,gamma,mineral,laueGr,spaceGr,comment);%Write phase info
end

% assemble data array
scrPrnt('Step','Assembling data array');

% write data header
fprintf(filePh,'Phase\tX\tY\tBands\tError\tEuler1\tEuler2\tEuler3\tMAD\tBC\tBS\r\n'); %Data header

if check_option(varargin,'flip') %Flip spatial ebsd data
  ebsd = rotate(ebsd,180*degree,'keepEuler');
  scrPrnt('Step','Rotating EBSD spatial data 180 degree');
end
A(:,1) = ebsd.phase;
A(:,2) = ebsd.prop.x;
A(:,3) = ebsd.prop.y;

% rounding close to 0 X and Y coordinates
A( abs(A(:,2)) < round0Thrsh,2 ) = 0;
A( abs(A(:,3)) < round0Thrsh,3 ) = 0;
A(:,4) = ebsd.prop.bands; % number of bands 
A(:,5) = ebsd.prop.error; 
A(:,6) = ebsd.rotations.phi1/degree;
A(:,7) = ebsd.rotations.Phi/degree;
A(:,8) = ebsd.rotations.phi2/degree;
A(:,9) = ebsd.prop.mad; % mean angular deviation
A(:,10) = ebsd.prop.bc; % band contrast
A(:,11) = ebsd.prop.bs; % band slope

% change X/Y order
[~,idx] = sort(A(:,3)); % make x-coordinates increase first
A = A(idx,:); % assign this convention to all data

% write data array
scrPrnt('Step','Writing data array to ''ctf'' file');
fprintf(filePh,'%.0f\t%.4f\t%.4f\t%.0f\t%.0f\t%.4f\t%.4f\t%.4f\t%.4f\t%.0f\t%.0f\r\n',A.');

% close ctf file
scrPrnt('Step','Closing file');
fclose(filePh);                                                            
scrPrnt('Step','All done',fName);    

end

% *** Function scrPrnt - Screen Printing
function scrPrnt(mode,varargin)
%function scrPrnt(mode,varargin)
switch mode
  case 'SegmentStart'
    titleStr = varargin{1};
    fprintf('\n------------------------------------------------------');
    fprintf(['\n     ',titleStr,' \n']);
    fprintf('------------------------------------------------------\n');
  case 'Step'
    titleStr = varargin{1};
    fprintf([' -> ',titleStr,'\n']);
  case 'SubStep'
    titleStr = varargin{1};
    fprintf(['    - ',titleStr,'\n']);
end
end


% MIT License
%
% Copyright (c) 2019 Frank Niessen
%
% Permission is hereby granted, free of charge, to any person obtaining a copy
% of this software and associated documentation files (the "Software"), to deal
% in the Software without restriction, including without limitation the rights
% to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
% copies of the Software, and to permit persons to whom the Software is
% furnished to do so, subject to the following conditions:
%
% The above copyright notice and this permission notice shall be included in all
% copies or substantial portions of the Software.
%
% THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
% IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
% FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
% AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
% LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
% OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
% SOFTWARE.