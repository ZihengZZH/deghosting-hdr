function [uv, latentImg, ppIMF, invppIMF] = computesinglescale...
    (src, ref, maxIters, ...\
    uv, intensityMappedRef, intensityMappedSrc, latentImg, ppIMF, invppIMF, ...\
    dist_weight, maskClippedPixels, patchSize, uvPrior)


if ~exist('ref', 'var') || ~exist('src', 'var');
    error('src and ref must be provided to init_patchflow');    
end 


if ~(isa(src, 'uint8') || isa(src, 'double')) || ~(isa(ref, 'uint8') || isa(ref, 'double'))
    error('src and ref must be image for the current version');
end

if ~isa(src, 'double')
    src = im2double(src);    
end

if ~isa(ref, 'double')
    ref = im2double(ref);    
end

if ~exist('maxIters', 'var')
    maxIters = 3;
end 
    
if ~exist('patchSize', 'var')
    patchSize = 10;
end 

% Temporay Variables
[h, w, ~] = size(src);
[X,Y] = meshgrid(0:w-1, 0:h-1);
Z(:,:,1) = int32(X);
Z(:,:,2) = int32(Y);

intensityMappedRefDx =  convn(padarray(intensityMappedRef,[0 1], 'circular','post'), [1,-1], 'valid');
intensityMappedRefDy =  convn(padarray(intensityMappedRef,[1 0], 'circular','post'), [1;-1], 'valid');
srcDx =  convn(padarray(src,[0 1], 'circular','post'), [1,-1], 'valid');
srcDy =  convn(padarray(src,[1 0], 'circular','post'), [1;-1], 'valid');

fKernel    = ones(patchSize,patchSize);
fKernelMag = conv2(ones(size(ref,1), size(ref,2)), fKernel,'same');

for iter = 1 : maxIters
    
    % Update NNF/flow 
    ann = nnmex(im2uint8(latentImg),im2uint8(src), 'cpu', patchSize, ...
        [], [], [], [], [], 4, [], [], uvPrior);
    uvPrior = ann;
    uv = ann(:,:,1:2,1) - Z;
    uv(:,:,1) = padarray(uv(1:end-patchSize,1:end-patchSize,1), ...
        [patchSize, patchSize], 'replicate', 'post');
    uv(:,:,2) = padarray(uv(1:end-patchSize,1:end-patchSize,2), ...
        [patchSize, patchSize], 'replicate', 'post');
    
    % Weight function indicates the confidence in mapping uv 
    % see Eqn.(7) in the paper    
    
    % Not Clipped Pixels
    distForward = double(ann(:,:,3));
    distValid   = distForward(1:end-patchSize,1:end-patchSize);
    sigma    = prctile(distValid(:), 75);
    variance = 2*sigma^2;
    distForward     = circshift(distForward, [floor(patchSize/2) floor(patchSize/2)]);
    weightUVForward = exp(-distForward.^2/variance);
    weightUVForward = weightUVForward.*(weightUVForward > .6065);    
    
    % Clipped Pixels
    distBackward = double(patchdist(ref, intensityMappedSrc, uv + Z,  [], patchSize));
    distValid    = distBackward(1:end-patchSize,1:end-patchSize);
    sigma    = prctile(distValid(:), 75);
    variance = 2*sigma^2;
    distBackward     = circshift(distBackward, [floor(patchSize/2) floor(patchSize/2)]);
    weightUVBackward = exp(-distBackward.^2/variance);
    weightUVBackward = weightUVBackward.*(weightUVBackward > .6065);
    
    mask = double(maskClippedPixels(:,:,1));
    weightUV = weightUVBackward.*mask + (1-mask).*weightUVForward;    
    weightUV = weightUV.*dist_weight;
    
    % Compute warped src
    warpedSrc   = im2double(votemex(src, uv + Z,[],[],patchSize, ...
        [],[],[],[],[], weightUV));
    warpedSrcDx = im2double(votemex(srcDx, uv + Z,[],[],patchSize, ...
        [],[],[],[],[], weightUV));
    warpedSrcDy = im2double(votemex(srcDy, uv + Z,[],[],patchSize, ...
        [],[],[],[],[], weightUV));
    
    % Weight function indicates the quality of IMF
    weightIMF = eps*double(maskClippedPixels) + 1*double(~maskClippedPixels);
    
    % Merging two weight functions
    weightUV  = conv2(weightUV, fKernel,'same')./fKernelMag;
    weightUV  = repmat(weightUV, [1 1 3]);
    weightSum = weightIMF + weightUV;    
    weightIMF = weightIMF./weightSum;
    weightUV  = weightUV./weightSum;
    
    % Update Latent Image, See Eqn.(5) in the paper
    tempLatentImg   = weightIMF.*intensityMappedRef + weightUV.*warpedSrc;
    tempLatentImgDx = weightIMF.*intensityMappedRefDx + weightUV.*warpedSrcDx;
    tempLatentImgDy = weightIMF.*intensityMappedRefDy + weightUV.*warpedSrcDy;    
    
    latentImg = solvescreenedpossion(tempLatentImg,tempLatentImgDx,tempLatentImgDy,.5);
    idx = latentImg > 1;
    latentImg(idx) = 1;
    idx = latentImg < 0;
    latentImg(idx) = 0;
   
end

% Update IMF
ppIMF    = computeimfIRLS(latentImg, ref);
invppIMF = computeimfIRLS(ref, latentImg);

end
