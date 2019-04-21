function [alphaPyramid alphaPlusPyramid alphaMinusPyramid vMaxPyramid vMinPyramid lowHoleMaskPyramid highHoleMaskPyramid targets sourcePyramids sourceMaskPyramids] = Initialization(curRefImg, inputLDRsPyramid, resizeFac, expoTimes, curRefImgNum, indImgs, status)
%%% This code does line 1 in Algorithm 1 in the paper

%%% Declaring global variables ------------------
global numScales;
global vMax;
global vMin;
global isMask;
global DSMethod;
%%% ---------------------------------------------

if (~exist('status', 'var'))
    status = 'both';
end

numImages = length(indImgs);

%%% Computing initial guesses -----------------------------------------
targets = cell(1, numImages);
for i = indImgs
    if (i ~= curRefImgNum)
        targets{i-indImgs(1)+1} = LDRtoLDR(curRefImg, expoTimes(curRefImgNum), expoTimes(i));
        targets{i-indImgs(1)+1} = max(0,min(1, imresize(targets{i-indImgs(1)+1}, 1/resizeFac^(numScales-1), DSMethod)));
    end
end
%%% -------------------------------------------------------------------

%%% The rest of the code generate some pyramids which are required for the
%%% multi-scale approach.
alphaPyramid = cell(numScales, 1);
alphaPlusPyramid = cell(numScales, 1);
alphaMinusPyramid = cell(numScales, 1);
vMaxPyramid = cell(numScales, 1);
vMinPyramid = cell(numScales, 1);

% These are the masks on the reference image to speed up the search process.
% Only these regions are searched and voted
lowHoleMaskPyramid = cell(numScales, 1);
highHoleMaskPyramid = cell(numScales, 1);


%%% The finest scale is calculated separately to be used for other scales
alphaPyramid{1} = GetAlpha(curRefImg, status);
alphaPlusPyramid{1} = double(curRefImg < vMin);
alphaMinusPyramid{1} = double(curRefImg > vMax);

vMaxPyramid{1} = double(curRefImg > vMax);
vMinPyramid{1} = double(curRefImg < vMin);

if(isMask)
    lowHoleMaskPyramid{1} = GetHoleMask(vMaxPyramid{1});
    highHoleMaskPyramid{1} = GetHoleMask(vMinPyramid{1});
end
%%% -------------------------------------------------------------------

%%% Computing all the pyramids for other scales -----------------------
for i = 2 : numScales
    alphaPyramid{i} = max(0,min(1, imresize(alphaPyramid{1}, 1/resizeFac^(i-1), DSMethod)));
    alphaPlusPyramid{i} = max(0,min(1, imresize(alphaPlusPyramid{1}, 1/resizeFac^(i-1), DSMethod)));
    alphaMinusPyramid{i} = max(0,min(1, imresize(alphaMinusPyramid{1}, 1/resizeFac^(i-1), DSMethod)));
    
    vMaxPyramid{i} = max(0,min(1, imresize(vMaxPyramid{1}, 1/resizeFac^(i-1), DSMethod)));
    vMinPyramid{i} = max(0,min(1, imresize(vMinPyramid{1}, 1/resizeFac^(i-1), DSMethod)));
    
    if (isMask)
        lowHoleMaskPyramid{i} = GetHoleMask(vMaxPyramid{i});
        highHoleMaskPyramid{i} = GetHoleMask(vMinPyramid{i});
    end
    
    vMaxPyramid{i} = vMax * vMaxPyramid{i};
    vMinPyramid{i} = 1 - (1 - vMin) * vMinPyramid{i};
end

vMaxPyramid{1} = vMax * vMaxPyramid{1};
vMinPyramid{1} = 1 - (1 - vMin) * vMinPyramid{1};
%%% -------------------------------------------------------------------

%%% Generating pyramids of the source images --------------------------
[sourcePyramids sourceMaskPyramids] = GetSourcePyramid(inputLDRsPyramid, expoTimes, curRefImgNum, indImgs);
%%% -------------------------------------------------------------------
