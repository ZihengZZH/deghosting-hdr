function [uv, latentImg, ppIMF, invppIMF] ...
    = computemultiscale(src, ref)

% Construct image pyramid, using filter setting in Bruhn et al in "Lucas/Kanade.." (IJCV2005') page 218
pyramid_spacing = 2; 
pyramid_levels  = 1 + ceil( log(min(size(src, 1), size(src,2))/32) ...
    / log(pyramid_spacing) ); 
factor            = sqrt(2);  
smooth_sigma      = sqrt(pyramid_spacing)/factor; 
f                 = fspecial('gaussian', 2*round(1.5*smooth_sigma) +1, smooth_sigma);
pyramidSrc    = computepyramid(src, pyramid_levels, f, 1/pyramid_spacing);
pyramidRef    = computepyramid(ref, pyramid_levels, f, 1/pyramid_spacing);

% Init NNF 
patchSize = 10;
[uv]      = computehisteqnnf(pyramidRef{pyramid_levels}, pyramidSrc{pyramid_levels});
uv(:,:,1) = padarray(uv(1:end-patchSize,1:end-patchSize,1), ...
    [patchSize, patchSize], 'replicate', 'post'); 
uv(:,:,2) = padarray(uv(1:end-patchSize,1:end-patchSize,2), ...
    [patchSize, patchSize], 'replicate', 'post'); 

% Init IMF and inverse IMF
ppIMF    = computeimfhist(im2double(pyramidRef{1}), im2double(pyramidSrc{1}));
invppIMF = computeimfhist(im2double(pyramidSrc{1}), im2double(pyramidRef{1}));

itersPerLevel = 2;
maxIters = itersPerLevel*pyramid_levels+1;

% Iterate through all pyramid levels
for iLevel = pyramid_levels:-1:1
    
    % Upsample NNF/Flow
    newSize = [size(pyramidSrc{iLevel}, 1) size(pyramidSrc{iLevel}, 2)];    
    ratio = newSize(1) / size(uv,1);
    u     = imresize(uv(:,:,1), newSize, 'bilinear')*ratio;
    v     = imresize(uv(:,:,2), newSize, 'bilinear')*ratio;
    uv   = cat(3, u, v);
    
    [h, w, ~] = size(uv);
    clear X Y Z;
    [X,Y]    = meshgrid(0:w-1, 0:h-1);
    Z(:,:,1) = int32(X);
    Z(:,:,2) = int32(Y);         
    
    % compute mask for non-clipped regions
    if ppval(ppIMF{1}, .5) > .5
        maskNotClippIMFedPixels = im2double(pyramidRef{iLevel}) > .02;
    else
        maskNotClippIMFedPixels = im2double(pyramidRef{iLevel}) < .98;
    end

    % compute mask for clipped regions
    maskClippIMFedPixels = ~maskNotClippIMFedPixels;
    se = strel('square',2);
    maskClippIMFedPixels = imdilate(maskClippIMFedPixels, se);
        
    % compute weight
    mask = maskNotClippIMFedPixels(:,:,1) ...\
        & maskNotClippIMFedPixels(:,:,2) ...\
        & maskNotClippIMFedPixels(:,:,3);
    D = double(bwdist(mask));
    dist_weight = (1.3*ones(size(D))).^(-D);
    dist_weight = max(dist_weight, 1.3^(-20));
   
    intensityMappedRef = transfercolor(im2double(pyramidRef{iLevel}), ppIMF);
    intensityMappedSrc = transfercolor(im2double(pyramidSrc{iLevel}), invppIMF);
    
    % Init latentImg using upsampled uv if exists
    if iLevel ~= pyramid_levels

        % Weight function indicates the confidence in mapping uv
        % see Eqn.(7) in the paper
        
        % Not Clipped Pixels
        distForward = double(patchdist(intensityMappedRef, ...
            im2double(pyramidSrc{iLevel}), uv + Z,  [], patchSize));
        distValid   = distForward(1:end-patchSize,1:end-patchSize);
        sigma    = prctile(distValid(:), 75);
        variance = 2*sigma^2;
        distForward     = circshift(distForward, [floor(patchSize/2) floor(patchSize/2)]);
        weightUVForward = exp(-distForward.^2/variance);
        weightUVForward = weightUVForward.*(weightUVForward > .6065);
        
        % Clipped Pixels        
        distBackward = double(patchdist(im2double(pyramidRef{iLevel}), ...
            intensityMappedSrc, uv + Z,  [], patchSize));
        distValid    = distBackward(1:end-patchSize,1:end-patchSize);
        sigma    = prctile(distValid(:), 75);
        variance = 2*sigma^2;
        distBackward     = circshift(distBackward, [floor(patchSize/2) floor(patchSize/2)]);
        weightUVBackward = exp(-distBackward.^2/variance);
        weightUVBackward = weightUVBackward.*(weightUVBackward > .6065);
        
        mask     = double(maskClippIMFedPixels(:,:,1));
        weightUV = weightUVBackward.*mask + (1-mask).*weightUVForward;
        weightUV = weightUV.*dist_weight;
    
        latentImg = im2double(votemex(im2double(pyramidSrc{iLevel}), ...
            uv + Z,[],[],patchSize,[],[],[],[],[],weightUV));        
        latentImg(maskNotClippIMFedPixels) = intensityMappedRef(maskNotClippIMFedPixels);
                
    else
        latentImg = intensityMappedRef;
    end
    
    uvPrior = zeros(size(uv,1), size(uv,2), 3);
    uvPrior(:,:,1:2) = uv + Z;
    uvPrior(:,:,3)   = patchdist(im2uint8(latentImg), pyramidSrc{iLevel}, ...
        int32(uv) + Z,  [], patchSize);
    uvPrior = int32(uvPrior);    
    
    [uv, latentImg, ppIMF, invppIMF] = ...\
        computesinglescale(pyramidSrc{iLevel}, pyramidRef{iLevel}, min(30,maxIters), ...\
        uv, intensityMappedRef, intensityMappedSrc, latentImg, ppIMF,invppIMF, ...\
        dist_weight, maskClippIMFedPixels, patchSize, uvPrior);
    
    maxIters = maxIters-itersPerLevel;        
    fprintf(1, '\b\b\b%d/%d', pyramid_levels-iLevel+1, pyramid_levels);
end

end

