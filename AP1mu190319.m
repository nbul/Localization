clear variables;
close all;

%% Open the file
currdir = pwd;
addpath(pwd);
filedir = uigetdir();
files = dir(strcat(filedir,'/*', '.czi'));
cd(filedir);

if exist([filedir,'/summary'],'dir') == 0
    mkdir(filedir,'/summary');
end
sum_dir = [filedir,'/summary'];

Series_plane1 = struct([]);
Series_plane2 = struct([]);
i=1;
cd(filedir);
Number1 = [num2str(i),'_Out.czi'];
I=bfopen(Number1);

Series = I{1,1};
seriesCount = size(Series, 1)/2;
Rab11 = zeros(seriesCount,numel(files));
AP1 = zeros(seriesCount,numel(files));
Cor = zeros(seriesCount,numel(files));
headers1 = {'Marker','AP1','PCC'};


for i=1:numel(files)
    cd(filedir);
    Number1 = [num2str(i),'_Out.czi'];
    I=bfopen(Number1);
    
    Series = I{1,1};
    seriesCount = size(Series, 1)/2;
    Signal = zeros(seriesCount,3);
    Thr = zeros(seriesCount,2);
    Series_plane1{1}= double(Series{1,1});
    image1 = figure;
    MA = 0;
    MB = 0;
    for k=1:seriesCount
        Series_plane1{k}= imgaussfilt(Series{k*2-1,1},1); %Goldgi or Rab11
        Series_plane2{k}= imgaussfilt(Series{k*2,1},1); %AP1mu
        Thr(k,1) = graythresh(Series_plane1{k});
        Thr(k,2) = graythresh(Series_plane2{k});
        Signal(k,1) = mean(Series_plane1{k}(:));
        Rab11(k,i) = mean(Series_plane1{k}(:));
        Signal(k,2) = mean(Series_plane2{k}(:));
        AP1(k,i) = mean(Series_plane2{k}(:));
        if MA<max(Series_plane1{k}(:))
            MA = max(Series_plane1{k}(:));
        end
       if MB<max(Series_plane2{k}(:))
            MB = max(Series_plane2{k}(:));
        end
    end
    C = 255*255*0.7;
    for k=1:seriesCount   
        A = double(Series_plane1{k}(:));
        B = double(Series_plane2{k}(:));
        %Signal(k,3) = corr(A(A>max(Thr(:,1))*C & B>max(Thr(:,2))*C),...
        %    B(A>max(Thr(:,1))*C & B>max(Thr(:,2))*C));
        Signal(k,3) = corr(A,B);
        Cor(k,i) = Signal(k,3);
        subplot(4, ceil(seriesCount/4),k);
        plot(A,...
            B,'o','Color','r');
        axis([0 MA 0 MB]);
        title({num2str(Signal(k,3)),num2str(k)});
    end
    
    cd(sum_dir);
    print(image1, [num2str(i),'.tif'], '-dtiff', '-r150');
    csvwrite_with_headers([num2str(i),'.csv'],Signal,headers1);
    close all;
end

image2 = figure;
plot(Rab11(:,1),1:size(Rab11,1),'Linewidth',2);
for i = 2:numel(files)
    hold on;
    plot(Rab11(:,i),1:size(Rab11,1),'Linewidth',2);
end
axis ij;
print(image2,'Marker.tif', '-dtiff', '-r150');

image3 = figure;
plot(AP1(:,1),1:size(Rab11,1),'Linewidth',2);
for i = 2:numel(files)
    hold on;
    plot(AP1(:,i),1:size(Rab11,1),'Linewidth',2);
end
axis ij;
print(image3,'AP1.tif', '-dtiff', '-r150');

image4 = figure;
plot(Cor(:,1),1:size(Rab11,1),'Linewidth',2);
for i = 2:numel(files)
    hold on;
    plot(Cor(:,i),1:size(Rab11,1),'Linewidth',2);
end
axis ij;
print(image4,'PCC.tif', '-dtiff', '-r150');

image5 = figure;
errorbar(mean(Rab11,2),1:size(Rab11,1),std(Rab11,0,2),'horizontal','Linewidth',2);
axis ij;
print(image5,'Marker_mean.tif', '-dtiff', '-r150');

image6 = figure;
errorbar(mean(AP1,2),1:size(Rab11,1),std(AP1,0,2),'horizontal','Linewidth',2);
axis ij;
print(image6,'AP1_mean.tif', '-dtiff', '-r150');

image7 = figure;
errorbar(mean(Cor,2),1:size(Rab11,1),std(Cor,0,2),'horizontal','Linewidth',2);
axis ij;
print(image7,'PCC_mean.tif', '-dtiff', '-r150');


cd(currdir);
clear variables;
close all;
