%% The script read npy array ( with Bayer format ) and extract RGB's array in specific area of image.
%% The script use the NDF filter ( Optical Densities ) and Monochromator's characteristic for ploting the QE.
% Verions 0.12 alpha - 26-01-2017 
% Davide Gariselli Git: https://goo.gl/pKFcVZ at Unimore Enzo Ferrari University

clc
clear all
close all
Height = 5;
Width = 5;

%% Debug define, if it is 1 the script will show all plots
debug_plot = 1;

%% What did you have crop?
    %  im = readNPY('/Users/Dave/Desktop/tesi/test.npy');
    %  J = demosaic(im,'grbg');
    %  figure, imshow(J);
    %  [I2, rect] = imcrop(J);
    %  Copy position of area selected, paste it in 'Crop' value.
Crop = [1380.5 1098.5 24 22];
lol = 0;
%% Numbers of captures. 
% If you have more then one, keep in mind to start with NDF lower to NDF highter.
n = input('Number of capture(s): ');

for a=1:n
    %% Grab the datas
    NDF = input('What NDFs filter did you use: ');
    %% Position of folder with all files 
    fprintf('Please load Raw Bayer (.NPY) captured with NDF: %1.1f \n',NDF);
    [FileName,PathName]= uigetfile('*.npy','Select source directory:');
    
    %% Automatic loading the spectrum with NDF(TXT) and Optical Densities(xlsx)
    fprintf('Loading Optical Densities\n');
    [ODM,data,OD] = read_txt(PathName,debug_plot);

    
    %% Load Raw Bayer date with specific NDF from capture
    txt_files = dir([PathName, '*.npy']);   % Search for npy files in the selected path
    files_name = {txt_files.name};         % Name of the npy files in the folder
    N=length (files_name);                  % How many npy files in the folder? N!
    % What to plot in X axis
    vettore = strrep(files_name,'.npy','');
    vettore = str2double(vettore);

    figure('Name','Demosaic and cut','NumberTitle','off'); % necessary for show what and where is crap
    %% scroll all images
    for i=1:N
        %% Initialize variables.
        filename = [PathName,txt_files(i).name];
        %filename = strcat('/Users/Dave/Desktop/tesi/myfile/',N2str(vettore(i)),'.jpg');
        delimiter = '\t';
        %% Function to read NPY files,BayerRgb, into matlab.
        BayerRgb= readNPY(filename);
        %% BayerRgb to Bilinear Demosaicing
        %  3 x Width-by-Height colors
        Demo = demosaic(BayerRgb,'grbg');

        %% What did you have crop?
        I2 = imcrop(Demo, Crop);
        imshow(I2)
        %% Color extraction
        for z=1:3
            pos=1;
            for x=1:Width
                for y=1:Height
                    color(pos) = I2(x,y,z);
                    pos=pos+1;
                end
            end
            %% Normalized and Mean ( Average )
            if z==1
                %a_B_n = color/255;
                a_B_m = mean(color);
                %a_B_m = color/max(abs(color(:)));
                RGB_images(3,i) = a_B_m;
            elseif z==2
                %a_G_n = color/255;
                a_G_m = mean(color);
                %a_G_m = color/max(abs(color(:)));
                RGB_images(2,i) = a_G_m;
            else
                %a_R_n = color/255;
                a_R_m = mean(color);
                %a_R_m = color/max(abs(color(:)));
                RGB_images(1,i) = a_R_m;
            end
        end
    end
    %% Normalized respect max
    RGB_images_n = RGB_images/max(abs(RGB_images(:)));
    
    %% Divide RBG_images (normalized respect max) with Data Spectrum monochromator
    %% txt (normalized respect max) and fill mono (NOT nomalized respect max).
    
    for y=1:N
        for x=1:3
            mono(x,y,a) = RGB_images_n(x,y) / data(y,2);
        end
    end

    %% Add info to the matrix import
    mono(4,1:N,a) = vettore;
    mono(5,1,a) = NDF;
    mono(5,2,a) = N;
    
    
    %% DEBUG ----------------------
    % save volatiles date
    if debug_plot == 1
        figure('Name','Results','NumberTitle','off');
        
        %% Monochromator spectrum (TXT)
        subplot(2,2,1);
        grid on
        hold on
        for i =1:length(data)
            plot(data(i,1),data(i,2),'r--o');
        end
        title(['Monochromator spectrum with ',num2str(NDF),' NDF']);
        
        %% Quantum-Efficiency of NDF
        subplot(2,2,2);
        grid on
        hold on
        for i=1:N
            plot(vettore(1,i),mono(1,i,a),'r--o');
            plot(vettore(1,i),mono(2,i,a),'g--o');
            plot(vettore(1,i),mono(3,i,a),'b--o');
        end
        title(['Quantum-Efficiency of ',num2str(NDF),' NDF']);
        
        %% Optical density NOT mixed
        %var = exist('ODM', 'var');
        if  ODM(1,1) == 0   % if ODM not exist
            clear ODM
            subplot(2,2,3);
            grid on
            hold on
            for i=1:length(OD)
                plot(OD(i,1),OD(i,2),'b--o');
            end
            %Plot limits
            %xlim([300 1100])
            title(['Optical density ',num2str(NDF),' NDF']);
            %optical_density(:,1) = OD(:,1);
            %optical_density(:,a+1) = OD(:,2);
        else   
            %% Optical density MIXED
            subplot(2,2,3);
            grid on
            hold on
            % autonomus raw detector
            %[R,C] = size(mono)
            %for j=1:C
            for i =1:length(OD)
                plot(OD(i,1),ODM(i,1),'r--o');
                plot(OD(i,1),ODM(i,2),'g--o');
                %% Optical density SUM
                plot(OD(i,1),OD(i,2),'b--o');
            end
            %Plot limits
            %xlim([300 1100])
            title(['Optical density MIXED ',num2str(NDF),' NDF']);
        end
    else
        clear ODM
    end
    %% DEBUG END ---------------------- 
    
    
    if (a==n)
        fprintf('Interpolation of data with Transmission Data -optical density- .\n');
    end
end


%% Interpolation of data with Transmission Data -optical density-
% result in last mono(:,:,n+1)) matrix

% New matrix in Z (n+1) with the first matrix (z=1)
 mono(:,:,n+1) = mono(:,:,1);
% One NDF
if exist('ODM', 'var') == 0
        % search the Wavelength in Transmission
        [raw,col] = find( OD(:,1) == mono(4,1,n+1) );
        for i = 1:mono(5,2,n+1)
            mono(1:3,i,n+1) = mono(1:3,i,n+1) ./ OD(raw,2);
            raw=raw+1;
        end
else
    % More then one of NDFs 
    for z=2:n
        % cerca ultimo valore di n+1 dentro a z+1
        last = mono(4,:,n+1);
        [rowStart,colStart] = find(mono(4,:,z) == last(end));
        % end position
        [rawEnd,colEnd] = find(mono(4,:,z) == max(mono(4,:,z)) );
        
        %% Interpolation with Optical Transmission
        % search the Wavelength in Transmission
        [raw,col] = find( OD(:,1) == last(end) );
        
        for i = colStart:(colStart+(colEnd-colStart))
            % Right-array division (./)
            mono(1:3,i,z) = mono(1:3,i,z) ./ OD(raw,2);
            %mono(1:3,i,z) = mono(1:3,i,z) .* log10( 0.6 );
            %mono(1:3,i,z) = mono(1:3,i,z) ./ log10( 1.2 );
            raw = raw+1;
        end
        
        %% Copy all with z+1 plan
        % a me interessano le colonne, inzio di quello che devo copiare in
        % n+1
        % cerca ultimo vettore in z+1
        mono(1:3,mono(5,2,n+1):( mono(5,2,n+1)+(mono(5,2,z)-colStart) ), n+1 ) = mono( 1:3,colStart:mono(5,2,z),z );
        last = union(last,mono(4,:,n));
        % delate the first zero column
        last(:,1)=[];
        % who many vector has now = vettore
        mono(4,:,n+1) = last;
        % new NDF
        mono(5,1,n+1) = mono(5,1,n);
        % new size
        mono(5,2,n+1) = size(last,2);
    end
end
%% Print quantum efficiency
fprintf('Plot the QE\n');
if n == 1
    % new vettore
    mono(4,:,n+1) = vettore;
    % new NDF
    mono(5,1,n+1) = mono(5,1,n);
    % new size
    mono(5,2,n+1) = N;
end
figure()
grid on
hold on
if n == 1
    title('Quantum-Efficiency with Optical Densities')
else
    title('Quantum-Efficiency mixed with Optical Densities')
end
for i=1:mono(5,2,n+1)
    plot(mono(4,i,n+1),mono(1,i,n+1),'r--o');
    plot(mono(4,i,n+1),mono(2,i,n+1),'g--o');
    plot(mono(4,i,n+1),mono(3,i,n+1),'b--o');
end
