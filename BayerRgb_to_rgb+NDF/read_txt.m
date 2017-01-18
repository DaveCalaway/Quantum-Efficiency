%% Import data from monochromator spectrum (TXT) and Transmission Data -optical density- (xlsx) file.
% Script for importing data from the following text file.
% Spectrum: https://goo.gl/Zaojol
%
% clc
% clear all
% close all
function [data,OD] =read_txt(PathName,deb_plot)
vettore=[400:5:810];
Wave = [];
Ampl = [];
%nWave = [];

% How many txt files in the folder?
my_dir = fullfile(PathName,'NDF');
num = length(dir([my_dir, '/*.TXT']));

for i=1:num
    %% Initialize variables.
    filename = strcat(PathName,'/NDF/',num2str(vettore(i)),'.txt');
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
 
 if deb_plot == 1
     figure()
     grid on
     hold on
     title('Monochromator spectrum TXT files')
 end
 
 for i=1:num
     data(i,1) = max(nAmpl(:,i));
      if deb_plot == 1
          plot(vettore(1,i),data(i,1),'r--o');
      end
 end
 
 %% Call for optical density
 OD = Transmission(PathName,deb_plot);
end
 

%% Import Transmission Data ( optical density ) from xlsx file
    % example: OD=log10(1/Transmission)
function OD = Transmission(PathName,deb_plot)
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
        
        for j=1:length(transmission())
                OD(j,1) = log10(100/transmission(j,2));
        end
        transmission(:,2) = OD(:,1);
        OD = transmission;
        
        if deb_plot == 1
            figure()
            grid on
            hold on
            title('Optical Density xlsx files')
            
            for i=1:length(OD())
                plot(OD(i,1),OD(i,2),'r--o');
            end
        end
        % Clear temporary variables
        clearvars raw; 
        
    %% More then one xlsx files
    else
        fprintf('You have used a combination of %d NDF\n',num);
        % crate the struct with all xlsx files
        files = dir([PathName, '/*.xlsx']);
        if deb_plot == 1
            figure()
            grid on
            hold on
            title('Optical Density mixed')
        end
        for i=1:num
            filename = fullfile(PathName,char({files(i).name}));
            % open xlsx file and copy the raws
            [~, ~, raw] = xlsread(filename,'%Transmission');
            raw = raw(3:end,3:4);
            
            % from rawCell to rawMatrix
            transmission = reshape([raw{:}],size(raw));
            %% from transmission% to optical density
            for j=1:length(transmission())
                OD(j,i) = log10(100/transmission(j,2));
                if deb_plot == 1
                    if i == 1
                        plot(transmission(j,1),OD(j,1),'r--o');
                    else
                        plot(transmission(j,1),OD(j,2),'g--x');
                    end
                end
            end
        end
        OD = sum(OD,2);
        transmission(:,2) = OD(:,1);
        OD = transmission;
        if deb_plot == 1
            for i=1:length(OD())
                plot(OD(i,1),OD(i,2),'b--o');
            end
        end
    end
end
% for i=1:80
%   plot(Wave(:,i),nAmpl(:,i))
% end
%Plot limits
% xlim([350 850])