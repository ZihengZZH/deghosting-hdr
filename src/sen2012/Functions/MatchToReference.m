function [alignedVotedImages alignedImages H] = MatchToReference(targets, sourcePyramids, sourceMaskPyramids, alphaPyramid, alphaPlusPyramid, alphaMinusPyramid, vMaxPyramid, vMinPyramid, iterStep, expoTimes, lowHoleMaskPyramid, highHoleMaskPyramid, curRefImgNum, indImgs)
%%% This code does lines 2 to 15 of Algorithm 1 in the paper



%%% Declaring global variables -------------------
global maxIter;
global numScales;
global outFinalDir;
global DSMethod;
global saveIntermediateResults;
global completenessFac;
global isMask;
global vMin;
global vMax;
global winIter;
global winFac;
%%% ----------------------------------------------

%%% Parameters initializations -------------------------
messageLengthScale = 0;
messageLengthInScale = 0;
numImages = size(sourcePyramids, 2);
targets{curRefImgNum} = sourcePyramids{curRefImgNum}{numScales}{1};
doCompleteness = true;

% Defining the window size for the first scale
[h w ~] = size(sourcePyramids{1}{numScales}{1});
if (1 > winIter * numScales)
    winSize = [];
else
    winSize = [round(winFac*sqrt(h*w)) round(winFac*sqrt(h*w))];
end

% Required to be initialized for the first iteration
ann = cell(1, numImages);
bnn = cell(1, numImages);
for i = 1 : numImages
    if (i ~= curRefImgNum)
        ann{i} = cell(1, size(sourcePyramids{i}{numScales},2));
        bnn{i} = cell(1, size(sourcePyramids{i}{numScales},2));
    end
end
% ------------------------------------------------------


%%% -----------------------------------------------------

for k = 1 : numScales

    if (k > completenessFac * numScales)
        doCompleteness = false;
    end
    
    %%% writing the progress information -------------
    fprintf(repmat('\b', 1, messageLengthScale + messageLengthInScale)); 
    messageLengthScale = fprintf('Scale %d/%d\n', k, numScales);
    %%% ----------------------------------------------
    
    NumIterThisScale = maxIter - (k - 1) * iterStep;
    messageLengthInScale = 0;
    startTime = clock;
    
    for j = 1 : NumIterThisScale
        rs_max = [];
        
        %%% The whole search and vote process for all the images in
        %%% iteration j. Lines 5 to 8 of Algorithm 1 in the paper.
        for i = 1 : numImages
            
            if (i ~= curRefImgNum)
                if (i > curRefImgNum)
                    [ann{i} bnn{i} targets{i}] = SearchAndVote(targets{i}, sourcePyramids{i}{numScales-k+1}, sourceMaskPyramids{i}{numScales-k+1}, ann{i}, bnn{i}, rs_max, doCompleteness, highHoleMaskPyramid{numScales-k+1}, winSize);
                else
                    [ann{i} bnn{i} targets{i}] = SearchAndVote(targets{i}, sourcePyramids{i}{numScales-k+1}, sourceMaskPyramids{i}{numScales-k+1}, ann{i}, bnn{i}, rs_max, doCompleteness, lowHoleMaskPyramid{numScales-k+1}, winSize);
                end
                if (saveIntermediateResults)
                    outPath = sprintf('%s/Intermediate/%d/Img-%04d-Iter-%04d.png', outFinalDir, indImgs(i), k, j);
                    imwrite(targets{i}, outPath);
                end
            end
        end
        %%% ---------------------------------------------
        
        %%% Performing HDRmerge. Lines 10 to 13 of Algorithm 1 in the
        %%% paper.
        if (j ~= NumIterThisScale)
            [Htilde Hplus Hminus] = HDRmerge(targets, alphaPlusPyramid{numScales-k+1}, alphaMinusPyramid{numScales-k+1}, expoTimes, curRefImgNum);
            Href = LDRtoHDR(targets{curRefImgNum}, expoTimes(curRefImgNum));
            H = AlphaBlend(Href, Htilde, alphaPyramid{numScales-k+1});
            H = ConsistencyCheck(Href, H, Hplus, Hminus, vMaxPyramid{numScales-k+1}, vMinPyramid{numScales-k+1}, expoTimes(curRefImgNum));
            targets = ExtractTargets(targets{curRefImgNum}, H, expoTimes, curRefImgNum, false);
        end
        %%% ---------------------------------------------

        %%% writing the progress information ------------
        fprintf(repmat('\b', 1, messageLengthInScale)); 
        messageLengthInScale = fprintf('Iteration %d/%d, finishing in %s\n', j, NumIterThisScale, Sec2Str((NumIterThisScale/j-1)*etime(clock, startTime)));
        %%% ---------------------------------------------

    end
    
    if (k ~= numScales)
        %%% In this part of the code, data is prepared to go one scale up
        
        
        [h w ~] = size(sourcePyramids{curRefImgNum}{numScales - k}{1}(:, :, 1));
        
        if (k+1 > winIter * numScales)
            winSize = [];
        else
            winSize = [round(winFac*sqrt(h*w)) round(winFac*sqrt(h*w))];
        end
        
        %%% Upsampling all the targets images. The reference image is
        %%% directly read from the pyramid.
        for i = 1 : numImages
            if (i == curRefImgNum)
                targets{i} = sourcePyramids{curRefImgNum}{numScales - k}{1};
            else
                targets{i} = max(0,min(1, imresize(targets{i}, [h w], DSMethod)));
            end
        end
        %%% ---------------------------------------------
        
        %%% HDR merge of the upsampled targets and getting new targets
        [Htilde Hplus Hminus] = HDRmerge(targets, alphaPlusPyramid{numScales-k}, alphaMinusPyramid{numScales-k}, expoTimes, curRefImgNum);
        Href = LDRtoHDR(targets{curRefImgNum}, expoTimes(curRefImgNum));
        H = AlphaBlend(Href, Htilde, alphaPyramid{numScales-k});
        H = ConsistencyCheck(Href, H, Hplus, Hminus, vMaxPyramid{numScales-k}, vMinPyramid{numScales-k}, expoTimes(curRefImgNum));
        targets = ExtractTargets(targets{curRefImgNum}, H, expoTimes, curRefImgNum, false);
        %%% ---------------------------------------------
        
        %%% Upsampling the NNFs from previous scale to be used in the
        %%% current scale
        ann = UpScaleNNF(ann, h, w, curRefImgNum);
        if (doCompleteness)
            bnn = UpScaleNNF(bnn, h, w, curRefImgNum);
        end
        %%% ---------------------------------------------
        
        %%% Performing search and vote on the new targets with rs_max = 0.
        %%% This means that search is done only with propagation and no
        %%% random search is done. This ensures that we do not deviate a lot
        %%% from the previous calculated NNF.
        rs_max = 0;
        for i = 1 : numImages
            if (i ~= curRefImgNum)
                if (i > curRefImgNum)
                    [ann{i} bnn{i} targets{i}] = SearchAndVote(targets{i}, sourcePyramids{i}{numScales-k}, sourceMaskPyramids{i}{numScales-k}, ann{i}, bnn{i}, rs_max, doCompleteness, highHoleMaskPyramid{numScales-k}, winSize);
                else
                    [ann{i} bnn{i} targets{i}] = SearchAndVote(targets{i}, sourcePyramids{i}{numScales-k}, sourceMaskPyramids{i}{numScales-k}, ann{i}, bnn{i}, rs_max, doCompleteness, lowHoleMaskPyramid{numScales-k}, winSize);
                end
            end
        end
        %%% ---------------------------------------------
        
        %%% HDR merge of the new targets ----------------
        [Htilde Hplus Hminus] = HDRmerge(targets, alphaPlusPyramid{numScales-k}, alphaMinusPyramid{numScales-k}, expoTimes, curRefImgNum);
        Href = LDRtoHDR(targets{curRefImgNum}, expoTimes(curRefImgNum));
        H = AlphaBlend(Href, Htilde, alphaPyramid{numScales-k});
        H = ConsistencyCheck(Href, H, Hplus, Hminus, vMaxPyramid{numScales-k}, vMinPyramid{numScales-k}, expoTimes(curRefImgNum));
        targets = ExtractTargets(targets{curRefImgNum}, H, expoTimes, curRefImgNum, false);
        %%% ---------------------------------------------
    
    else
        
        %%% When the code gets to here all the targets are finalized. So we
        %%% run final HDR merge on them which does not perform the
        %%% consistency check.
        Htilde = HDRmerge(targets, alphaPlusPyramid{1}, alphaMinusPyramid{1}, expoTimes, curRefImgNum);
        Href = LDRtoHDR(targets{curRefImgNum}, expoTimes(curRefImgNum));
        H = AlphaBlend(Href, Htilde, alphaPyramid{1});
        alignedImages = ExtractTargets(targets{curRefImgNum}, H, expoTimes, curRefImgNum, true);

        alignedVotedImages = targets;
        
        %%% If mask is being used, the voted images have some holes in
        %%% them. Here we grab information of those holes from the
        %%% reference image.
        if(isMask)
            refImg = sourcePyramids{curRefImgNum}{1}{1};
            for i = 1 : numImages
                if (i ~= curRefImgNum)
                    if (i > curRefImgNum)
                        indValids = (refImg > vMin);
                        alignedVotedImages{i}(indValids) = LDRtoLDR(refImg(indValids), expoTimes(curRefImgNum), expoTimes(i));
                    else
                        indValids = (refImg < vMax);
                        alignedVotedImages{i}(indValids) = LDRtoLDR(refImg(indValids), expoTimes(curRefImgNum), expoTimes(i));
                    end
                end
            end
        end
        %%% ---------------------------------------------
        
    end
end








