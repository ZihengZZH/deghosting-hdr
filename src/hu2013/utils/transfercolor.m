%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  function [ dstImg ] = transfercolor( srcImg, ppIMF )
%  
%  Color Transfer of srcImg, using piecewise imf function ppIMF
%  see computeimfhist.m or computeimfIRLS.m for for details about 
%  computing intensity mapping functions between imgs
%
%  copyRight @ junhu@cs.duke.edu
%   
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function [ dstImg ] = transfercolor( srcImg, ppIMF )

if ndims(srcImg) > 3 || ndims(srcImg) < 2
    error('intensitymapping: input img must be 2D or 3D');
end

if ~isa(srcImg, 'double') ...
        || min(srcImg(:)) < 0 || max(srcImg(:)) > 1 ...
    error('intensitymapping: input img must be double in the range[0 1]');    
end

if size(srcImg,3) ~= length(ppIMF)
    error('intensitymapping: input img must have consistent dim with intnesity mapping functions');
end

dstImg = nan(size(srcImg));
for ch = 1 : length(ppIMF)
    dstImg(:,:,ch) = ppval(ppIMF{ch}, srcImg(:,:,ch));
end

dstImg( dstImg > 1 )    = 1;
dstImg( dstImg < 0 )    = 0;
dstImg( isnan(srcImg) ) = NaN;

end

