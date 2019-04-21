%function [ init_uv, dist] = compute_patchflow_base_histeq(src, ref, lambda, truncated_d, uv0)
function  [uv, dist] = computehisteqnnf(imgA, imgB)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  compute dense NNF for hist equalized images  
%  
%  [uv, dist] = computehisteqnnf(A, B)
%
%  uv:   NNF from A to B, A[i,j] matches with B[p,q], 
%        uv[i,j] = [p,q] - [i,j] 
%
%  dist: similarity distance between patch centerd at A[i,j] 
%        and patch centered at B[p,q],
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


if ~exist('imgB', 'var') || ~exist('imgA', 'var');
    error('No enough inputs');    
end 


if ~(isa(imgA, 'uint8') || isa(imgA, 'uint16') || isa(imgA, 'double')) || ...
        ~(isa(imgB, 'uint8') || isa(imgA, 'uint16') || isa(imgB, 'double'))
    error('imgA and imgB must be image for the current version');
end

if ~isa(imgA, 'double')
    imgA = im2double(imgA);    
end

if ~isa(imgB, 'double')
    imgB = im2double(imgB);    
end

[h, w, ~] = size(imgA);

if ~exist('uv0', 'var') 
    [X,Y] = meshgrid(0:w-1, 0:h-1);
    uv0(:,:,1) = int32(X);
    uv0(:,:,2) = int32(Y);
end 

histeqImgA = histeq(rgb2gray(imgA));
histeqImgB = histeq(rgb2gray(imgB));

histeqImgA = repmat(histeqImgA, [1 1 3]);
histeqImgB = repmat(histeqImgB, [1 1 3]);

cores = 4;
uv    = nnmex(im2uint8(histeqImgA), im2uint8(histeqImgB), 'cpu', ...
    [], [], [], [], [], [], cores, [], [], [], [], [], [], ...
    [], uv0, .01, 25);

dist = double(uv(:,:,3,1));
uv   = uv(:,:,1:2,1) - uv0;

end

