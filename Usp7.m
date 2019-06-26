clear variables;
close all;

%% Open the file
currdir = pwd;
addpath(pwd);
filedir = uigetdir();
files = dir(strcat(filedir,'/*', '.czi'));
cd(filedir);
Series_plane1 = struct([]);
Series_plane3 = struct([]);

RA = zeros(1,numel(files));
PA = zeros(1,numel(files));

observed = zeros(1,numel(files));
expected = zeros(1,numel(files));
MCC = zeros(1,numel(files));

observedcl = zeros(1,numel(files));
expectedcl = zeros(1,numel(files));
MCCcl = zeros(1,numel(files));

Area = zeros(1,numel(files));

usedefault3 = questdlg(strcat('Which staining?'),'Settings','Golgi','Rab11','Rab7','Golgi');

if strcmp(usedefault3, 'Golgi')
    a1 = 0.3;
    a2 = 'gaussian';
elseif strcmp(usedefault3, 'Rab11')
    a1 = 0.5;
    a2 = 'mean';
else
    a1 = 0.5;
    a2 = 'mean';
end

if exist([filedir,'/summary'],'dir') == 0
    mkdir(filedir,'/summary');
end
sum_dir = [filedir,'/summary'];

for i=1:numel(files)
    cd(filedir);
    Number1 = [num2str(i),'_Out.czi'];
    I=bfopen(Number1);
    
    Series = I{1,1};
    seriesCount = size(Series, 1)/2;
    Series_plane1{1}= double(Series{1,1});
    [ii, jj] = find(Series_plane1{1} >= 0);
    [ix, iy] = size(Series_plane1{1});
    %read Usp7 and trafficking marker planes
    for k=1:seriesCount
        Series_plane1{k}= imgaussfilt(Series{k*2-1,1},1); %Goldgi or Rab11
        Series_plane3{k}= imgaussfilt(Series{k*2,1},1); %Usp7
    end
    
    thresholdUsp;
    
    SignalA = [GolgiA,CadA];
    Signal_all = SignalA;
    SignalA(SignalA(:,8) == 0,:) = []; % all that have E-cad
    Signal_cad = SignalA;
 
    SignalAcl = [GolgiA,CadAcl];
    Signall_all_cl = SignalAcl;
    SignalAcl(SignalAcl(:,8) == 0,:) = []; % all that have E-cad in cytoplasm
    Signal_cadcl = SignalAcl;
    
    clear SignalA
    SignalA = [GolgiA,CadA];
    SignalA(SignalA(:,4) == 0,:) = []; % all that have marker
    Signal_rab = SignalA;
    
    SignalA(SignalA(:,8) == 0,:) = []; %all that E-cad and marker
    Signal_both = SignalA;
    
    clear SignalAcl
    SignalAcl = [GolgiA,CadAcl];
    SignalAcl(SignalAcl(:,4) == 0,:) = []; % all that have marker
    Signal_rabcl = SignalAcl;
    
    SignalAcl(SignalAcl(:,8) == 0,:) = []; %all that E-cad and marker
    Signal_bothcl = SignalAcl;
    
    Signal_original = [Golgiall,Cadall];
    
    % Reference: https://www.ncbi.nlm.nih.gov/pmc/articles/PMC4428547/
    % PCC correlation between marker and E-cad
    [RA(i), PA(i)] = corr(Signal_original(:,8),Signal_original(:,4));
    cd(sum_dir);
    Graph = figure;
    scatter(Signal_original(:,4),Signal_original(:,8),8,'r','o', 'filled');
    text(0.05, 0.9, ['PCC: R = ', num2str(RA(i)), ';  p = ', num2str(PA(i))],...
        'FontSize', 14, 'FontWeight', 'bold', 'Position', [0.05 0.9], 'Units', 'normalized'); % Add correlation coefficient on the plot
    xlabel('Marker', 'FontSize', 18, 'FontWeight', 'bold') % x-axis label
    ylabel('E-cad', 'FontSize', 18, 'FontWeight', 'bold') % y-axis label
    % save image
    
    image_filename = [num2str(i),'_PCC.tif'];
    print(Graph, '-dtiff', '-r150', image_filename);
    close all;
    
    % MCC marker and E-cad
    observed(i) = 100*length(Signal_both)/length(Signal_rab);
    expected(i) = 100*length(Signal_cad)/(length(Signal_all)-1);
    MCC(i) = observed(i) - expected(i);
    
    % MCC marker and E-cad
    observedcl(i) = 100*length(Signal_bothcl)/length(Signal_rabcl);
    expectedcl(i) = 100*length(Signal_cadcl)/(length(Signal_all)-length(SignalA)+length(SignalAcl)-1);
    MCCcl(i) = observedcl(i) - expectedcl(i);
    
    % Marker area
    Area(i) = 100*length(Signal_rab)/(length(Signal_all)-1);
    
end

N = 1:1:numel(files);
Result = [N', RA', PA', MCC', MCCcl', Area'];

headers = {'image','Pearson','p-value','Mander %','Mander no borders %','Area vesicle %'};

csvwrite_with_headers('summary.csv',Result,headers);

cd(currdir);
clear variables;