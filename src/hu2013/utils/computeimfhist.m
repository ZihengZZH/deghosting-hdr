%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  function [ ppIMF ] = computeimfhist( srcImg, refImg, viz )
%  
%  'Determining the camera response from images: what is knowable?'
%  by Grossberg, M.D and Nayar, S.K 
%  
%  if viz is true, display the result
%
%  copyRight @ junhu@cs.duke.edu
%   
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [ ppIMF ] = computeimfhist( srcImg, refImg, viz )

if ~isequalsize(srcImg, refImg)
    error('computeimf: input imgs are different sizes/dims');
elseif ndims(srcImg) > 3 || ndims(srcImg) < 2 || ...
       ndims(refImg) > 3 || ndims(refImg) < 2
    error('computeimf: input imgs must be 2D or 3D');
end

if ~isa(srcImg, 'double') || ~isa(refImg, 'double') ...
        || min(srcImg(:)) < 0 || max(srcImg(:)) > 1 ...
        || min(refImg(:)) < 0 || max(refImg(:)) > 1 ...
    error('computeimf: input imgs must be double in the range[0 1]');    
end

if ~exist('viz', 'var')
    viz = false;
end

nChannel = size(srcImg,3);
bins     = 0:1/255:1;

for iCh = 1:nChannel
    
    srcSubCh = srcImg(:,:,iCh);
    refSubCh = refImg(:,:,iCh);
    
    srcCul = cumsum(histc(srcSubCh(:), bins));
    refCul = cumsum(histc(refSubCh(:), bins));
     
    srcSample = samplecul(srcCul);
    refSample = samplecul(refCul);
    
    x = bins(srcSample);
    y = bins(refSample); 
    
    % Removing flat samples and imf Fitting using Cubic Hermite Poly 
    % Two extra samples (-.1,-.1) (1.1,1.1) for a better global shape 
    ex      = [x(1:end), x(end-1)];
    inds    = (ex(1:end-1) ~= ex(2:end));        
    xSample = x(inds);
    ySample = y(inds);
    xSample = [-.1, xSample(:)', 1.1];    
    ySample = [-.1, ySample(:)', 1.1];
    
    ppIMF{iCh} = pchip(xSample, ySample);
    
    % Visualization
    if viz
        scatterHist = [refSubCh(:),srcSubCh(:)];
        figure, imagesc( log(1 + hist3(scatterHist,{bins, bins})) );
        axis xy;
        hold on; plot(255*(0:.01:1), 255 * ppval(ppIMF{iCh},0:.01:1));
    end
    
end

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function sample = samplecul(cul, nsample)
% 
% given a Cumulative histogram cul, finding 
% all sample j, which satisfies
% cul(j) = i/nsample, where i is an integer 
% less than nsample
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function sample = samplecul(cul, nSample)

if ~exist('nSample', 'var')
    nSample = 50;
end

sample  = zeros(nSample-1,1);
iSample = 1;
ratio   = 1/nSample;
nTotal  = cul(end,1);

for i = 1 : size(cul,1)
    count = cul(i);
    while count > nTotal * ratio && count <= nTotal
        sample(iSample) = i;
        iSample         = iSample + 1;
        ratio           = ratio + 1/nSample;
    end           
end

for i = iSample : nSample-1
    sample(i) = sample(i-1);
end

end
