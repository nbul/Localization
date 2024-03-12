clear variables;
close all;

%% Open the file
currdir = pwd;
addpath(pwd);
filedir = uigetdir();
files = dir(strcat(filedir,'/*', '.oib'));
cd(filedir);
Series_plane1 = struct([]);
Series_plane3 = struct([]);

RA = zeros(1,numel(files));
PA = zeros(1,numel(files));

observedEcad = zeros(1,numel(files));
expectedEcad = zeros(1,numel(files));
MCCEcad = zeros(1,numel(files));

observedSTAT = zeros(1,numel(files));
expectedSTAT = zeros(1,numel(files));
MCCSTAT = zeros(1,numel(files));
Number1 = strings(1,numel(files));


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
    [ii, jj] = find(Series_plane1{1} >= 0);
    [ix, iy] = size(Series_plane1{1});
    %read E-cad and STAT planes
    for k=1:seriesCount
        Series_plane1{k}= imgaussfilt(Series{k*2-1,1},1); %STAT
        Series_plane3{k}= imgaussfilt(Series{k*2,1},1); %E-cad
    end

    thresholdSTAT;

    SignalwithEcad = Signal_all;
    SignalwithEcad(SignalwithEcad(:,2) == 0,:) = []; % all that have E-cad
    SignalwithSTAT = Signal_all;
    SignalwithSTAT(SignalwithSTAT(:,1) == 0,:) = []; % all that have STAT
    Signalwithboth = SignalwithSTAT;
    Signalwithboth(Signalwithboth(:,2) == 0,:) = []; % all that have both E-cad and STAT

    %% Pearson's correlation
    % Reference: https://www.ncbi.nlm.nih.gov/pmc/articles/PMC4428547/
    % PCC correlation between marker and E-cad
    [RA(i), PA(i)] = corr(Signal_original(:,2),Signal_original(:,1));
    cd(sum_dir);
    Graph = figure;
    scatter(Signal_original(:,2),Signal_original(:,1),8,'r','o', 'filled');
    text(0.05, 0.9, ['PCC: R = ', num2str(RA(i)), ';  p = ', num2str(PA(i))],...
        'FontSize', 14, 'FontWeight', 'bold', 'Position', [0.05 0.9], 'Units', 'normalized'); % Add correlation coefficient on the plot
    xlabel('E-cad', 'FontSize', 18, 'FontWeight', 'bold') % x-axis label
    ylabel('STAT92E', 'FontSize', 18, 'FontWeight', 'bold') % y-axis label
    % save image

    image_filename = [num2str(i),'_PCC.tif'];
    print(Graph, '-dtiff', '-r150', image_filename);
    close all;

    % MCC marker and E-cad
    observedEcad(i) = 100*length(Signalwithboth)/length(SignalwithSTAT);
    expectedEcad(i) = 100*length(SignalwithSTAT)/(length(Signal_all)-1);
    MCCEcad(i) = observedEcad(i) - expectedEcad(i);

    % MCC marker and E-cad
    observedSTAT(i) = 100*length(Signalwithboth)/length(SignalwithEcad);
    expectedSTAT(i) = 100*length(SignalwithEcad)/(length(Signal_all)-1);
    MCCSTAT(i) = observedSTAT(i) - expectedSTAT(i);


end

Result = [Number1', RA', PA', MCCEcad', MCCSTAT'];
Results2 = array2table(Result);

Results2.Properties.VariableNames = {'image','Pearson','pvalue','MandersEcad','ManderSTAT'};

writetable(Results2,'SummaryColocalisation.xls');

cd(currdir);
clear variables;