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
STATim2 = imadjust(STATim);

Ecadmontageimage = figure;
Ecadmontage = montage({Series_plane3{1},Series_plane3{2},Series_plane3{3},Series_plane3{4},...
Series_plane3{5},Series_plane3{6},Series_plane3{7},Series_plane3{8}}, "Size", [4,2],...
"DisplayRange",[0 maxEcad]);
Ecadim = Ecadmontage.CData;
Ecadim2 = imadjust(Ecadim);

ThSTAT = graythresh(STATim2);
STAT_bw = imbinarize(STATim2, ThSTAT*1.5);

ThEcad = graythresh(Ecadim2);
Ecad_bw = imbinarize(Ecadim2, ThEcad*1.5);
Ecad_bw = bwareaopen(Ecad_bw, 30);

SignalSTAT = double(STAT_bw) .* double(STATim2);
SignalEcad = double(Ecad_bw) .* double(Ecadim2);

Signal_all = [SignalSTAT(:), SignalEcad(:)];
Signal_original = [double(STATim(:)), double(Ecadim(:))];

C2 = imfuse(SignalSTAT,SignalEcad,...
            'falsecolor','Scaling','joint','ColorChannels',[1 2 0]);
Th_im = figure;
imshow(C2);
cd(bw_dir);
imwrite(C2,[files(i).name, '_threshold.tif']);
close all;