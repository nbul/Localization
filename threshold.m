GolgiA = [0,0,0,0];
CadA = [0,0,0,0];
CadAcl = [0,0,0,0];
Cadall  = [0,0,0,0];
Golgiall  = [0,0,0,0];
Adaptive1 = struct([]);
Adaptive2 = struct([]);
Adaptive2cl = struct([]);

C2 = struct([]);
C3 = struct([]);

% thresholding adaptive (A) and Global (G) and collecting distributions
    for k=1:seriesCount
        T1 = adaptthresh(imadjust(double(Series_plane1{k})/65535),a1, 'NeighborhoodSize', 15, 'Statistic', a2);
        Adaptive1{k} = imbinarize(imadjust(double(Series_plane1{k})/65535),T1);
        Adaptive1{k} = bwareaopen(Adaptive1{k},15);
        %Adaptive1{k} = imclearborder(Adaptive1{k});
        C2{k} = imfuse(imadjust(double(Series_plane1{k})/65535),Adaptive1{k},...
            'falsecolor','Scaling','joint','ColorChannels',[1 2 0]);
        imshow(C2{k});
        Adaptive1{k} = double(Adaptive1{k}).* double(Series{k*3-2,1});
        temp1A = [k*ones(size(Series_plane1{k}(:))), ii,jj,Adaptive1{k}(:)];
        GolgiA = [GolgiA;temp1A];
        
        T2 = adaptthresh(imadjust(double(Series_plane3{k})/65535),0.35, 'NeighborhoodSize', 15, 'Statistic', 'gaussian');
        Adaptive2{k} = imbinarize(imadjust(double(Series_plane3{k})/65535),T2);
        Adaptive2{k} = bwareaopen(Adaptive2{k},15);
        %Adaptive2{k} = imclearborder(Adaptive2{k});
        Adaptive2cl{k} = xor(Adaptive2{k},  bwareaopen(Adaptive2{k},500));
        %Adaptive2cl{k} = imclearborder(Adaptive2cl{k});
        C2{k} = imfuse(imadjust(double(Series_plane3{k})/65535),Adaptive2{k},...
            'falsecolor','Scaling','joint','ColorChannels',[1 2 0]);
        imshow(C2{k});
        C3{k} = imfuse(imadjust(double(Series_plane3{k})/65535),Adaptive2cl{k},...
            'falsecolor','Scaling','joint','ColorChannels',[1 2 0]);
        imshow(C3{k});
        Adaptive2{k} = double(Adaptive2{k}).* double(Series{k*3,1});
        Adaptive2cl{k} = double(Adaptive2cl{k}).* double(Series{k*3,1});
        temp2A = [k*ones(size(Series_plane1{k}(:))), ii,jj,Adaptive2{k}(:)];
        temp2B = [k*ones(size(Series_plane1{k}(:))), ii,jj,Adaptive2cl{k}(:)];
        CadA = [CadA;temp2A];
        CadAcl = [CadAcl;temp2B];     
        
        temp3 = [k*ones(size(Series_plane1{k}(:))), ii,jj,double(Series_plane3{k}(:))];
        Cadall = [Cadall; temp3];
        temp4 = [k*ones(size(Series_plane1{k}(:))), ii,jj,double(Series_plane1{k}(:))];
        Golgiall = [Golgiall; temp4];
    end
    
    close all;