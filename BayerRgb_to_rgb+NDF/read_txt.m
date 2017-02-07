%% Import Data from monochromator spectrum (TXT) and Transmission Data -optical density- (xlsx) file.
% Script for importing data from the following text file.
% Spectrum: https://goo.gl/Zaojol
%
% clc
% clear all
% close all
function [ODM,data,OD] =read_txt(PathName,debug_plot)
Wave = [];
Ampl = [];

% How many txt files in the folder?
my_dir = fullfile(PathName,'NDF');
txt_files = dir([my_dir, '/*.TXT']);   % Search for npy files in the selected path
files_name = {txt_files.name};         % Name of the npy files in the folder
num = length(dir([my_dir, '/*.TXT']));

for i=1:num
    %% Initialize variables.
    filename = fullfile(my_dir,char(files_name(1,i)));
    %data(i,1) = extractBetween( filename,'NDF/','.TXT');
    nop = strsplit(char(files_name(1,i)),'.');
    data(i,1) = str2double(nop(1,1));
    %filename = strcat(PathName,'/NDF/',num2str(vettore(i)),'.txt');
    delimiter = '\t';
    %% Format string for each line of text:
    formatSpec = '%f%f%[^\n\r]';
    
    %% Open the text file.
    fileID = fopen(filename,'r');
    
    %% Read columns of data according to format string.
    % This call is based on the structure of the file used to generate this
    % code. If an error occurs for a different file, try regenerating the code
    % from the Import Tool.
    dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter,  'ReturnOnError', false);
    W = dataArray{:, 1};
    A = dataArray{:, 2};
    
    if i==1 %at first iteration saves the data in an array
        Wave=W;
        Ampl=A;
    else    %for the following iterations builds the data matrixes
        Wave=[Wave, W];
        Ampl=[Ampl, A];
    end
    
    %% Close the text file.
    fclose(fileID);
    clearvars filename delimiter formatSpec fileID dataArray ans;
end

%% Apmlitude normalized respect max
 nAmpl = Ampl/max(abs(Ampl(:)));
 
 for i=1:num
     data(i,2) = max(nAmpl(:,i));
 end
 
 %% Call for optical density
 [ODM,OD] = Transmission(PathName,debug_plot);
end
 

%% Import Transmission Data ( optical density ) from xlsx file
    % example: OD=log10(1/Transmission)
function [ODM,OD] = Transmission(PathName,debug_plot)
% How many xlsx files in the folder?
    num = length(dir([PathName, '/*.xlsx']));
    
    %% One xlsx file
    if(num == 1 )
        fprintf('You have used only one NDF\n');
        filename = strcat(PathName,'OP.xlsx');
        [~, ~, raw] = xlsread(filename,'%Transmission');
        raw = raw(3:end,3:4);

        % from rawCell to rawMatrix
        transmission = reshape([raw{:}],size(raw));
        %% Conversion from Transmission% to Optical Density
        for j=1:length(transmission())
                OD(j,1) = log10(100/transmission(j,2));
        end
        transmission(:,2) = OD(:,1);
        OD = real(transmission);
        
        ODM = 0; % Necessary for debug
        
    %% More then one xlsx files
    else
        fprintf('You have used a combination of %d NDF\n',num);
        % crate the struct with all xlsx files
        files = dir([PathName, '/*.xlsx']);
        for i=1:num
            filename = fullfile(PathName,char({files(i).name}));
            % open xlsx file and copy the raws
            [~, ~, raw] = xlsread(filename,'%Transmission');
            raw = raw(3:end,3:4);
            
            % from rawCell to rawMatrix
            transmission = reshape([raw{:}],size(raw));
            %% Conversion from Transmission% to Optical Density
            for j=1:length(transmission())
                OD(j,i) = log10(100/transmission(j,2));
            end
        end
        %% DEBUG
        if debug_plot == 1
            ODM = OD;
        end
        OD = sum(OD,2);
        transmission(:,2) = OD(:,1);
        OD = transmission;
    end
end