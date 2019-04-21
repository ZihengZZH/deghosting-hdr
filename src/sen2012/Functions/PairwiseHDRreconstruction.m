function [alignedVotedImages alignedImages H] = PairwiseHDRreconstruction(inputLDRs, inputLDRsPyramid, iterStep, resizeFac, expoTimes)

%%% Declaring global variables ------------------
global numScales;
global DSMethod;
global refImgNum;
global vMin;
global vMax;
global isMask;
%%% --------------------------------------------



%%% Initialization ------------------------------
numImages = size(inputLDRs, 2);

alignedVotedImages = cell(1, numImages);

% In the case we have only two images, these variables have to be
% initialized.
alignedImages{1} = inputLDRs{refImgNum};
alignedVotedImages{refImgNum} = inputLDRs{refImgNum};

% These data are necessary for HDR merge after the pairwise matchings.
% They can be initialized here.
status = CheckStatus(numImages);
alpha = GetAlpha(inputLDRs{refImgNum}, status);
alphaPlus = double(inputLDRs{refImgNum} < vMin);
alphaMinus = double(inputLDRs{refImgNum} > vMax);
%%% --------------------------------------------------------------

index = 0;
while(index + refImgNum < numImages || refImgNum - index > 1)
    
    %%% The case we have three images to match at the beginning
    if(1 + refImgNum <= numImages && refImgNum - 1 >= 1 && index == 0)
        
        % Set the current reference image
        curRefImgNum = refImgNum;
        
        curRefImg = inputLDRs{curRefImgNum};
        
        % The indices of images being processed here
        indImgs = curRefImgNum-1:curRefImgNum+1;
        
        %%% Initialization -----------------------
        fprintf('Preparing initial required pyramids ...');
        [alphaPyramid alphaPlusPyramid alphaMinusPyramid maxPyramid minPyramid lowHoleMaskPyramid highHoleMaskPyramid targets sourcePyramids sourceMaskPyramids] = Initialization(curRefImg, inputLDRsPyramid, resizeFac, expoTimes, curRefImgNum, indImgs);
        fprintf(repmat('\b', 1, 3));
        fprintf('Done\n\n');
        %%% --------------------------------------        
        
        fprintf('Started matching images %d and %d to %d\n', refImgNum-1, refImgNum+1, refImgNum);
        
        %%% Match ref+1 and ref-1 to the reference image.
        [tmpVoted,~,~] = MatchToReference(targets, sourcePyramids, sourceMaskPyramids, alphaPyramid, alphaPlusPyramid, alphaMinusPyramid, maxPyramid, minPyramid, iterStep, expoTimes(indImgs), lowHoleMaskPyramid, highHoleMaskPyramid, 2, indImgs);
        %%% ------------------------------------------------
        
        % Filling alignedVotedImages with the calculated aligned images 
		% after finishing each pairwise matching.
        alignedVotedImages(indImgs) = tmpVoted;
        
        %%% Performing HDR merge on the voted images to get the new target
        %%% for the next pairwise matching. This is final HDR merge, so no 
		%%% consistency check is performed.
        Htilde = HDRmerge(tmpVoted, alphaPlus, alphaMinus, expoTimes(indImgs), 2);
        Href = LDRtoHDR(tmpVoted{2}, expoTimes(curRefImgNum));
        H = AlphaBlend(Href, Htilde, alpha);
        alignedImages = ExtractTargets(tmpVoted{2}, H, expoTimes(indImgs), 2, true);
        %%% ------------------------------------------------
        
        fprintf('Finished matching images %d and %d to %d\n\n', refImgNum-1, refImgNum+1, refImgNum);
        %%% End of the case having three images at the beginning
        
    else
        
        if (refImgNum-index > 1)
            
            % Set the current reference image
            curRefImgNum = refImgNum-index;
            
            curRefImg = alignedImages{1};
            
            % The indices of images being processed here
            indImgs = curRefImgNum-1:curRefImgNum;            
            
            %%% This is necessary because we need to update the new target
            %%% image in the pyramid
            for i = 1 : numScales
                inputLDRsPyramid{i}{curRefImgNum} = max(0,min(1, imresize(curRefImg,1/resizeFac^(i-1),DSMethod)));
            end
            
            %%% Initialization -----------------------
            fprintf('Preparing initial required pyramids ...');
            [alphaPyramid alphaPlusPyramid alphaMinusPyramid maxPyramid minPyramid lowHoleMaskPyramid highHoleMaskPyramid targets sourcePyramids sourceMaskPyramids] = Initialization(curRefImg, inputLDRsPyramid, resizeFac, expoTimes, curRefImgNum, indImgs, 'low');
            fprintf(repmat('\b', 1, 3));
            fprintf('Done\n\n');
            %%% --------------------------------------
            
            if (sum(1 - lowHoleMaskPyramid{1}(:)) ~= 0 || ~isMask)
                fprintf('Started matching image %d to %d\n', refImgNum-1-index, refImgNum-index);
                [tmpVoted, ~, ~] = MatchToReference(targets, sourcePyramids, sourceMaskPyramids, alphaPyramid, alphaPlusPyramid, alphaMinusPyramid, maxPyramid, minPyramid, iterStep, expoTimes(indImgs), lowHoleMaskPyramid, highHoleMaskPyramid, 2, indImgs);

                alignedVotedImages{curRefImgNum-1} = tmpVoted{1};
                fprintf('Finished matching image %d to %d\n\n', refImgNum-1-index, refImgNum-index);
            else
                fprintf('There is not any invalid information in image %d\n\n', refImgNum-index);
                alignedVotedImages{curRefImgNum-1} = LDRtoLDR(curRefImg, expoTimes(curRefImgNum), expoTimes(curRefImgNum-1));
            end
        end
        
        if (refImgNum+index < numImages)
            
            % Set the current reference image
            curRefImgNum = refImgNum+index;
            
            curRefImg = alignedImages{end};
            
            % The indices of images being processed here
            indImgs = curRefImgNum:curRefImgNum+1;
            
            %%% This is necessary because we need to update the new target
            %%% image in the pyramid
            for i = 1 : numScales
                inputLDRsPyramid{i}{curRefImgNum} = max(0,min(1, imresize(curRefImg,1/resizeFac^(i-1),DSMethod)));
            end
            
            %%% Initialization -----------------------
            fprintf('Preparing initial required pyramids ...');
            [alphaPyramid alphaPlusPyramid alphaMinusPyramid maxPyramid minPyramid lowHoleMaskPyramid highHoleMaskPyramid targets sourcePyramids sourceMaskPyramids] = Initialization(curRefImg, inputLDRsPyramid, resizeFac, expoTimes, curRefImgNum, indImgs, 'high');
            fprintf(repmat('\b', 1, 3));
            fprintf('Done\n\n');
            %%% --------------------------------------
            
            if (sum(1 - highHoleMaskPyramid{1}(:)) ~= 0 || ~isMask)
                fprintf('Started matching image %d to %d\n', refImgNum+1+index, refImgNum+index);
                [tmpVoted, ~, ~] = MatchToReference(targets, sourcePyramids, sourceMaskPyramids, alphaPyramid, alphaPlusPyramid, alphaMinusPyramid, maxPyramid, minPyramid, iterStep, expoTimes(indImgs), lowHoleMaskPyramid, highHoleMaskPyramid, 1, indImgs);

                alignedVotedImages{curRefImgNum+1} = tmpVoted{2};
                fprintf('Finished matching image %d to %d\n\n', refImgNum+1+index, refImgNum+index);
            else
                fprintf('There is not any invalid information in image %d\n\n', refImgNum+index);
                alignedVotedImages{curRefImgNum+1} = LDRtoLDR(curRefImg, expoTimes(curRefImgNum), expoTimes(curRefImgNum+1));
            end
        end
        
        indImgs = max(refImgNum-1-index, 1) : min(refImgNum+1+index, numImages);
        
        %%% Performing HDR merge on the voted images to get the new target
        %%% for the next pairwise matching, if any. This is final HDR
        %%% merge, so no consistency check is performed.
        Htilde = HDRmerge(alignedVotedImages(indImgs), alphaPlus, alphaMinus, expoTimes(indImgs), find(indImgs == refImgNum));
        Href = LDRtoHDR(alignedVotedImages{refImgNum}, expoTimes(refImgNum));
        H = AlphaBlend(Href, Htilde, alpha);
        alignedImages = ExtractTargets(alignedVotedImages{refImgNum}, H, expoTimes(indImgs), find(indImgs == refImgNum), true);        
    end
    
    index = index + 1;
end
