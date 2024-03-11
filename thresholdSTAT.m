maxSTAT = 0;
maxEcad = 0;
for k=1:seriesCount
    maxtempSTAT = max(Series_plane1{k}(:));
    maxSTAT = max(maxSTAT,maxtempSTAT);
    maxtempEcad = max(Series_plane3{k}(:));
    maxEcad = max(maxEcad, maxtempEcad);
end

STATmontageimage = figure;
STATmontage = montage({Series_plane1{1},Series_plane1{2},Series_plane1{3},Series_plane1{4},...
Series_plane1{5},Series_plane1{6},Series_plane1{7},Series_plane1{8}}, "Size", [4,2],...
"DisplayRange",[0 maxSTAT]);
STATim = STATmontage.CData;

Ecadmontageimage = figure;
Ecadmontage = montage({Series_plane3{1},Series_plane3{2},Series_plane3{3},Series_plane3{4},...
Series_plane3{5},Series_plane3{6},Series_plane3{7},Series_plane3{8}}, "Size", [4,2],...
"DisplayRange",[0 maxEcad]);
Ecadim = Ecadmontage.CData;

ThSTAT = graythresh(STATim);
STAT_bw = imbinarize(STATim, ThSTAT*1.7);


ThEcad = graythresh(Ecadim);
Ecad_bw = imbinarize(Ecadim, ThEcad*2);
Ecad_bw = bwareaopen(Ecad_bw, 30);

SignalSTAT = double(STAT_bw) .* double(STATim);
SignalEcad = double(Ecad_bw) .* double(Ecadim);

Signall_all = [SignalSTAT(:), SignalEcad(:)];

C2 = imfuse(SignalSTAT,SignalEcad,...
            'falsecolor','Scaling','joint','ColorChannels',[1 2 0]);
Th_im = figure;
imshow(C2);
cd(bw_dir);
imwrite(C2,[files(k).name, '_threshold.tif']);
close all;