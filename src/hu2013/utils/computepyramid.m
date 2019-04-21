function [ pyrImg ] = computepyramid( inputImg, nLevel, ...
    filterKernel, sampleRatio )

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  compute img pyramid
%  [ pyrImg ] = computepyramid( inputImg, nLevel, filterKernel, sampleRatio)
%  
%  nLevel:          pyramid level, default value 5
%  filterKernel:    filter kernel, default Gaussian kernel
%  sampleRatio:     downsample ratio, default .5    
%
%  pyrImg:          output pyramid in a cell struct 
%
%  copyright @ junhu@cs.duke.edu
%  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if ~exist('nLevel', 'var')
    nLevel = 5;
end

if ~exist('sampleRatio', 'var')
    sampleRatio = .5;
end

if ~exist('filterKernel', 'var')
    % Default Gaussian Kernel
    factor = sqrt(2);
    smooth_sigma = sqrt(1/sampleRatio)/factor;
    filterKernel = fspecial('gaussian', 2*round(1.5*smooth_sigma) +1, smooth_sigma);
end

pyrImg   = cell(nLevel,1);
tmp = inputImg;
pyrImg{1}= tmp;

% Get version information (from http://www.mathworks.com/matlabcentral/fileexchange/17285)
v = sscanf (version, '%d.%d.%d') ; v = 10.^(0:-1:-(length(v)-1)) * v ;

for iLevel = 2:nLevel
    
    minValue = min(tmp(:));
    maxValue = max(tmp(:));
    
    % Kernel filtering
    tmp = imfilter(tmp, filterKernel, 'corr', 'symmetric', 'same');
    sizeImg  = round([size(tmp,1) size(tmp,2)] * sampleRatio);
    
    % IMRESIZE changes default algorithm since version 7.4 (R2007a)
    if v > 7.3
        tmp = imresize(tmp, sizeImg, 'bilinear', 'Antialiasing', false);   % better than 'nearest'
        
    else
        tmp = imresize(tmp, sizeImg, 'bilinear', 0); % Disable antialiasing, old version for cluster
    end
    
    % Thresholding to the valid range
    tmp( tmp < minValue ) = minValue;
    tmp( tmp > maxValue ) = maxValue;
    
    pyrImg{iLevel} = tmp;
end

end

