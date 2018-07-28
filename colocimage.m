C = struct([]);
Ccl = struct([]);
ResultA = struct([]);
ResultAcl = struct([]);
Adaptive3 = struct([]);

for k=1:seriesCount
    clear A Acl;
    
    A = Signal_cad(Signal_cad(:,1)==k,:);
    ResultA{k} = zeros(ix, iy);
    for l=1:size(A,1)
        ResultA{k}(A(l,2),A(l,3))=1;
    end
    ResultA{k} = bwareaopen(ResultA{k},15);
    
    Acl = Signal_cadcl(Signal_cadcl(:,1)==k,:);
    ResultAcl{k} = zeros(ix, iy);
    for l=1:size(Acl,1)
        ResultAcl{k}(Acl(l,2),Acl(l,3))=1;
    end
    ResultAcl{k} = bwareaopen(ResultAcl{k},15);
    
    T3 = adaptthresh(imadjust(double(Series_plane1{k})/65535),0.5, 'NeighborhoodSize', 15, 'Statistic', 'mean');
    Adaptive3{k} = imbinarize(imadjust(double(Series_plane1{k})/65535),T3);
    Adaptive3{k} = bwareaopen(Adaptive3{k},15);
    
    C{k} = imfuse(ResultA{k},Adaptive3{k},'falsecolor','Scaling','joint','ColorChannels',[1 2 0]);
    Ccl{k} = imfuse(ResultAcl{k},Adaptive3{k},'falsecolor','Scaling','joint','ColorChannels',[1 2 0]);
    
end