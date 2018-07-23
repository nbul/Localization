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
Golgi = [0,0,0,0];
AP = [0,0,0,0];
Cad = [0,0,0,0];
if exist([filedir,'/summary'],'dir') == 0
    mkdir(filedir,'/summary');
end
sum_dir = [filedir,'/summary'];

for i=1:numel(files)
    cd(filedir);
    Number1 = [num2str(i),'_Out.czi'];
    I=bfopen(Number1);
    
    Series = I{1,1};
    seriesCount = size(Series, 1)/3;
    Series_plane1{1}= double(Series{1,1});
    [ii, jj] = find(Series_plane1{1} >= 0);
    %display size to check type of file
    for k=1:seriesCount
        Series_plane1{k}= double(imgaussfilt(Series{k*3-2,1},1)); %Goldgi or Rab11
        %Series_plane1{k} = imbinarize(Series_plane1{k},'adaptive');
        %Series_plane1{k} = double(Series_plane1{k}).* double(Series{k*3-2,1});
        temp1 = [k*3-3+ones(size(Series_plane1{k}(:))), ii,jj,Series_plane1{k}(:)];
        Golgi = [Golgi;temp1];
        
        
        Series_plane2{k}= double(imgaussfilt(Series{k*3-1,1},1)); %AP1mu
        %Series_plane2{k} = imbinarize(Series_plane2{k},'adaptive');
        %Series_plane2{k} = double(Series_plane2{k}).* double(Series{k*3-1,1});
        temp1 = [k*3-2+ones(size(Series_plane2{k}(:))), ii,jj,Series_plane2{k}(:)];
        AP = [AP;temp1];
        
        Series_plane3{k}= double(imgaussfilt(Series{k*3,1},1)); %E-cad
        %Series_plane3{k} = imbinarize(Series_plane3{k},'adaptive');
        %Series_plane3{k} = double(Series_plane3{k}).* double(Series{k*3,1});
        temp1 = [k*3-1+ones(size(Series_plane3{k}(:))), ii,jj,Series_plane3{k}(:)];
        Cad = [Cad;temp1];
    end
    
    Signal = [Golgi,AP,Cad];
    Signal(Signal(:,4) == 0,:) = [];
    Signal(Signal(:,8) == 0,:) = [];
    Signal(Signal(:,12) == 0,:) = [];
    % correlation AP1 and E-cad
    [RC, PC] = corr(Signal(:,8),Signal(:,12));
    [RG, PG] = corr(Signal(:,8),Signal(:,4));
    cd(sum_dir);
    Graph = figure;
    scatter(Signal(:,8),Signal(:,12),8,'r','o', 'filled');
    text(0.05, 0.9, ['R = ', num2str(RC), ';  p = ', num2str(PC)],...
        'FontSize', 14, 'FontWeight', 'bold', 'Position', [0.05 0.9], 'Units', 'normalized'); % Add correlation coefficient on the plot
    xlabel('AP1mu', 'FontSize', 18, 'FontWeight', 'bold') % x-axis label
    ylabel('E-cad', 'FontSize', 18, 'FontWeight', 'bold') % y-axis label
    % save image
    
    image_filename = [num2str(i),'_AP_Cad.tif'];
    print(Graph, '-dtiff', '-r150', image_filename);
    
    Graph2 = figure;
    scatter(Signal(:,8),Signal(:,4),8,'r','o', 'filled');
    text(0.05, 0.9, ['R = ', num2str(RG), ';  p = ', num2str(PG)],...
        'FontSize', 14, 'FontWeight', 'bold', 'Position', [0.05 0.9], 'Units', 'normalized'); % Add correlation coefficient on the plot
    xlabel('AP1mu', 'FontSize', 18, 'FontWeight', 'bold') % x-axis label
    ylabel('Rab11', 'FontSize', 18, 'FontWeight', 'bold') % y-axis label
    % save image
    
    image_filename = [num2str(i),'_AP_Rab11.tif'];
    print(Graph2, '-dtiff', '-r150', image_filename);
    
    
    
    [RC2, PC2] = corr(Signal(Signal(:,8)>450,8),Signal(Signal(:,8)>450,12));
    Graph3 = figure;
    scatter(Signal(Signal(:,8)>450,8),Signal(Signal(:,8)>450,12),8,'r','o', 'filled');
    text(0.05, 0.9, ['R = ', num2str(RC2), ';  p = ', num2str(PC2)],...
        'FontSize', 14, 'FontWeight', 'bold', 'Position', [0.05 0.9], 'Units', 'normalized'); % Add correlation coefficient on the plot
    xlabel('AP1mu', 'FontSize', 18, 'FontWeight', 'bold') % x-axis label
    ylabel('E-cad', 'FontSize', 18, 'FontWeight', 'bold') % y-axis label
    image_filename = [num2str(i),'_AP_Cad_450.tif'];
    print(Graph, '-dtiff', '-r150', image_filename);
    
    close all;
    
    Signal_cor = Signal;
    Signal_cor(Signal_cor(:,8)<450,:) = [];
    
    [ix, iy] = size(Series_plane3{k});
    x = 5;
    Image = zeros(ix, iy);
    for k = 1:length(Signal_cor(Signal_cor(:,1)==x*3-2,2))
        Signal_clean = [Signal_cor(Signal_cor(:,1)==x*3-2,2),Signal_cor(Signal_cor(:,1)==x*3-2,3)];
        Image(Signal_clean(k,1), Signal_clean(k,2)) = 1;
    end
    imshow(Image);
end

cd(currdir);
clear variables;