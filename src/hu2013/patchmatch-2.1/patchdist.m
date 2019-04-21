%function D = patchdist(A, B, ann, [algo='cpu'], [patch_w=7],
%
%
%Input image A,B are hxwx3, floats in [0, 1] or uint8.
%Input fields are:
% ann = nnmex(A, B)
%
%Options are:
%algo             - One of 'cpu', 'cputiled'
%patch_w          - Width (and height) of patch, currently support sizes up to 32
%bmask            - B mask image, votes made only where mask is zero
%                   (affects both 'coherence' and 'completeness'
%bweight          - B weight image, weights are 32 bit floats, and
%                   correspond to the *center* of the patch
%coherence_weight - Weight multiplier for coherence
%complete_weight  - Weight multiplier for completeness
%amask            - A mask image, votes made only where mask is zero
%                   (affects only 'coherence')
%aweight          - A weight image, if not given uses inverse mapping
%                   and B weight image. Corresponds to the *center* of the
%                   patch.
%A0               - Initial guess for A. It is used as default in regions
%                   with no votes - outside the output mask 'amask' and
%                   with no votes from the input.
%
%NOTE: all NN fields and masks correspond to the upper-left corner of the
%patches, and the field indeces are in C coordinates (start with [0,0]),
%wheras the weight maps correspond to the *center* of the patch.
%
%
%------------------------------------------------------------------------%