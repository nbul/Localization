clear variables;
close all;

%% Open the file
currdir = pwd;
addpath(pwd);
filedir = uigetdir();
files = dir(strcat(filedir,'/*', '.czi'));
cd(filedir);
Series_plane1 = struct([]);
Series_plane2 = struct([]);
Series_plane3 = struct([]);
Golgi = 0;
AP = 0;
Cad = 0;
if exist([filedir,'/summary'],'dir') == 0
    mkdir(filedir,'/summary');
end
sum_dir = [filedir,'/summary'];

for i=1:numel(files)
    cd(filedir);
    Number1 = [num2str(i),'_Out.czi'];
    I=bfopen(Number1);
    
    Series = I{1,1};
    seriesCount = size(Series, 1)/3; %display size to check type of file
    for k=1:seriesCount
        Series_plane1{k}= double(Series{k*3-2,1}); %Goldgi or Rab11
        Series_plane1{k} = imbinarize(Series_plane1{k},'adaptive');
        Series_plane1{k} = double(Series_plane1{k}).* double(Series{k*3-2,1});
        Golgi = [Golgi;Series_plane1{k}(:)];
        
        Series_plane2{k}= double(Series{k*3-1,1}); %AP1mu
        Series_plane2{k} = imbinarize(Series_plane2{k},'adaptive');
        Series_plane2{k} = double(Series_plane2{k}).* double(Series{k*3-1,1});
        AP = [AP;Series_plane2{k}(:)];
        
        Series_plane3{k}= double(Series{k*3,1}); %E-cad
        Series_plane3{k} = imbinarize(Series_plane3{k},'adaptive');
        Series_plane3{k} = double(Series_plane3{k}).* double(Series{k*3,1});
        Cad = [Cad;Series_plane3{k}(:)];
    end
    
    Signal = [Golgi,AP,Cad];
    Signal(Signal(:,1) == 0,:) = [];
    Signal(Signal(:,2) == 0,:) = [];
    Signal(Signal(:,3) == 0,:) = [];
    % correlation AP1 and E-cad
    [RC, PC] = corr(Signal(:,2),Signal(:,3));
    [RG, PG] = corr(Signal(:,2),Signal(:,1));
    cd(sum_dir);
    Graph = figure;
    scatter(Signal(:,2),Signal(:,3),8,'r','o', 'filled');
    text(0.05, 0.9, ['R = ', num2str(RC), ';  p = ', num2str(PC)],...
        'FontSize', 14, 'FontWeight', 'bold', 'Position', [0.05 0.9], 'Units', 'normalized'); % Add correlation coefficient on the plot
    xlabel('AP1mu', 'FontSize', 18, 'FontWeight', 'bold') % x-axis label
    ylabel('E-cad', 'FontSize', 18, 'FontWeight', 'bold') % y-axis label
    % save image
    
    image_filename = [num2str(i),'_AP_Cad.tif'];
    print(Graph, '-dtiff', '-r150', image_filename);
    
    Graph2 = figure;
    scatter(Signal(:,2),Signal(:,1),8,'r','o', 'filled');
    text(0.05, 0.9, ['R = ', num2str(RG), ';  p = ', num2str(PG)],...
        'FontSize', 14, 'FontWeight', 'bold', 'Position', [0.05 0.9], 'Units', 'normalized'); % Add correlation coefficient on the plot
    xlabel('AP1mu', 'FontSize', 18, 'FontWeight', 'bold') % x-axis label
    ylabel('Rab11', 'FontSize', 18, 'FontWeight', 'bold') % y-axis label
    % save image
    
    image_filename = [num2str(i),'_AP_Rab11.tif'];
    print(Graph2, '-dtiff', '-r150', image_filename);
    
    close all;
end

cd(currdir);
clear variables;