clear variables;
close all;

%% Open the file
currdir = pwd;
addpath(pwd);
filedir = uigetdir();
files = dir(strcat(filedir,'/*', '.oib'));
bor_dir = [filedir, '/borders'];
cd(filedir);
Series_plane1 = struct([]);
Series_plane3 = struct([]);
Number1 = strings(1,numel(files));
 
I=bfopen(files(1).name);
Series = I{1,1};
seriesCount = size(Series, 1)/2;

STATzall = zeros(seriesCount,numel(files));
Ecadzall = zeros(seriesCount,numel(files));
MCC = zeros(numel(files),2);

a1 = 0.4;
a2 = 'gaussian';


if exist([filedir,'/SummaryColocalisation'],'dir') == 0
    mkdir(filedir,'/SummaryColocalisation');
end
sum_dir = [filedir,'/SummaryColocalisation'];

if exist([filedir,'/threshold-images'],'dir') == 0
    mkdir(filedir,'/threshold-images');
end
bw_dir = [filedir,'/threshold-images'];

for i=1:numel(files)
    cd(filedir);
    Number1(i) = files(i).name;
    I=bfopen(files(i).name);

    Series = I{1,1};
    seriesCount = size(Series, 1)/2;
    Series_plane1{1}= double(Series{1,1});
    [ix, iy] = size(Series_plane1{1});
    %read E-cad and STAT planes
    for k=1:seriesCount
        Series_plane1{k}= imgaussfilt(Series{k*2-1,1},1); %STAT
        Series_plane3{k}= imgaussfilt(Series{k*2,1},1); %E-cad
    end
    
    thresholdSTAT;

    cd([bor_dir, '/', num2str(i)]);
    Mask_original = imread('handCorrection.tif');
    Mask_original = imbinarize(Mask_original(:,:,1));
    Mask_original(:,1) = 0;
    Mask_original(:,end) = 0;
    Mask_original(1,:) = 0;
    Mask_original(end,:) = 0;
    Mask = imdilate(Mask_original, strel('diamond',3));
    Mask = bwareaopen(Mask, 500);
    for k=1:seriesCount
        TempS = double(Series_plane1{k}) .* double(Mask);
        STATzall(k,i) = mean(TempS(:));
        TempE = double(Series_plane3{k}) .* double(Mask);
        Ecadzall(k, i) = mean(TempE(:));   
        TempS2 = double(imbinarize(imadjust(Series_plane1{k}), ThSTAT*1.5)) .*...
             double(Mask);
        TempE2 = double(imbinarize(imadjust(Series_plane3{k}), ThEcad*1.5)) .*...
             double(Mask);
        TempES = TempS2 .* TempE2;

        MCC(i,1) = 100 * (sum(TempES(:))/sum(TempE2(:))-sum(TempE2(:))/sum(Mask(:)));
        MCC(i,2) = 100 * (sum(TempES(:))/sum(TempS2(:))-sum(TempS2(:))/sum(Mask(:)));

    end
end

Ecadzall_norm = Ecadzall ./ max(Ecadzall, [], 1);
STATzall_norm = STATzall ./ max(STATzall, [], 1);

cd(sum_dir);

writetable(array2table(Ecadzall_norm), 'E-cad-z-distribution.csv');
writetable(array2table(STATzall_norm), 'STAT-z-distribution.csv');

MCC2 = array2table(MCC);
MCC2.Properties.VariableNames = {'MCC_STAT','MCC_Ecad'};

writetable(MCC2, 'MCC_z_mask.csv');

cd(currdir);

clear variables;
clc