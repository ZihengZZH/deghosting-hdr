function holeMask = GetSourceHoleMask(input)

global patch_w;

holeMask = padarray(input, [floor(patch_w/2) floor(patch_w/2)], 0, 'post');
holeMask = holeMask(ceil(patch_w/2):end, ceil(patch_w/2):end, :);
holeMask = repmat(sum(holeMask,3),[1,1,3]);
holeMask = 1 - double(holeMask > 0);