function status = CheckStatus(numImages)

%%% if there is not any image brighter or darker than the reference image
%%% the alpha function does not need to drop from both sides.

global refImgNum;

if (refImgNum == 1)
    status = 'high';
elseif (refImgNum == numImages)
    status = 'low';
else
    status = 'both';
end