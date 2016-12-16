%% The script read npy's array ( with Bayer format ) and extract RGB's array in specific area of image.
%% The script use the NDF filter and Monochromator's characteristic for ploting the QE.
% Verions 0.4 - 15-12-2016 Davide Gariselli Git: https://goo.gl/pKFcVZ at
% Unimore Enzo Ferrari University
clc
clear all
close all
Height = 5;
Width = 5;
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
n = input('Number of NDFs filters: ');

for a=1:n
    %% Search .npy files
    NDF = input('What NDFs filter did you used: ');
    fprintf('Please load NPY capture with NDF: %1.1f \n',NDF);
    [FileName,PathName]= uigetfile('*.npy','Select source directory:');
    % Load spectrum for specific NDF
    fprintf('Loading spectrum\n');
    data = read_txt(NDF);

    txt_files = dir([PathName, '*.npy']);   % Search for npy files in the selected path
    files_name = {txt_files.name};         % Name of the npy files in the folder
    N=length (files_name);                  % How many npy files in the folder? N!
    %% What to plot in X axis
    vettore = strrep(files_name,'.npy','');
    vettore = str2double(vettore);
    %% Preallocate Memory matrix
%     color = zeros(Height*Width, 1);
%     RGB_images = zeros(3,Height*Width);

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
            %% Normalized and Mean
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
    
    %% Subtract RBG_images (normalized respect max) to Data monochromator
    %% txt (normalized respect max) and fill mono.
    
    for y=1:N
        for x=1:3
            mono(x,y,a) = RGB_images_n(x,y) / data(y,1);
        end
    end
    mono(4,1:N,a) = vettore;
    mono(5,1,a) = NDF;
    mono(5,2,a) = N;
    
    if (a==n)
        %fprintf('Jump\n');
        lol=1;
    end
    
end

%% Multi plot with NDF's mean
     %% Start before first time

if lol == 1
    % News matrix in Z with first mattrix (z=1)
    mono(:,:,n+1) = mono(:,:,1);
    % Number of NDFs filters
    for z=2:n
        % cerca ultimo valore di n+1 dentro a z+1
        last = mono(4,:,n+1);
        [rowStart,colStart] = find(mono(4,:,z) == last(end));
        % a me interessano le colonne, inzio di quello che devo copiare in
        % n+1
        % cerca ultimo vettore in z+1
        %prova = mono( 1:3,colStart:mono(5,2,z),z );
        mono(1:3,mono(5,2,n+1):( mono(5,2,n+1)+(mono(5,2,z)-colStart) ), n+1 ) = mono( 1:3,colStart:mono(5,2,z),z );
        last = union(last,mono(4,:,n));
        % delate the first zero column
        last(:,1)=[];
        % new vettore
        mono(4,:,n+1) = last;
        % new NDF
        mono(5,1,n+1) = mono(5,1,n);
        % new size
        mono(5,2,n+1) = size(last,2);
    end
end

%% Print quantum efficiency
    if lol == 1 || n == 1
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
        for i=1:mono(5,2,n+1)
            plot(mono(4,i,n+1),mono(1,i,n+1),'r--o');
            plot(mono(4,i,n+1),mono(2,i,n+1),'g--o');
            plot(mono(4,i,n+1),mono(3,i,n+1),'b--o');
        end
    end
