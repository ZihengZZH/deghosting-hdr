function [alignedVotedImages alignedImages H] = GenerateHDR(inputLDRs, expoTimes, sceneName)

%%% Declaring global variables -----------------
global minImgSize;
global maxIter;
global minIter;
global numScales;
global DSMethod;
global isPairwise;
%%% --------------------------------------------

tic;

%%% Initializing the values --------------------
[h w ~] = size(inputLDRs{1});
minSizeDim = min(h, w);

if (numScales ~= 1)
    resizeFac = (minSizeDim/minImgSize).^(1/(numScales-1));
else
    resizeFac = 1;
end

iterStep = floor((maxIter - minIter) / (numScales - 1));
if (isnan(iterStep) || iterStep == inf)
    iterStep = 0;
end
%%% --------------------------------------------

%%% Generating multi-scale Images --------------
fprintf('Generating input pyramids ...');
inputLDRsPyramid = cell(numScales, 1);
for i = 1 : numScales
    inputLDRsPyramid{i} = cellfun(@(x)max(0,min(1, imresize(x,1/resizeFac^(i-1),DSMethod))), inputLDRs, 'UniformOutput', false);
end
fprintf(repmat('\b', 1, 3));
fprintf('Done\n');
%%% --------------------------------------------

if (isPairwise)
    [alignedVotedImages alignedImages H] = PairwiseHDRreconstruction(inputLDRs, inputLDRsPyramid, iterStep, resizeFac, expoTimes);
else
    [alignedVotedImages alignedImages H] = GeneralHDRreconstruction(inputLDRs, inputLDRsPyramid, iterStep, resizeFac, expoTimes);
end

totalTime = toc;

%%% Writing out all the results
WriteFinalResults(alignedVotedImages, H, totalTime, sceneName);

