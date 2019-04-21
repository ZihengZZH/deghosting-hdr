function [alignedVotedImages alignedImages H] = GeneralHDRreconstruction(inputLDRs, inputLDRsPyramid, iterStep, resizeFac, expoTimes)

%%% Declaring global variables ------------------
global refImgNum;
%%% --------------------------------------------

numImages = size(inputLDRs, 2);

%%% Generating initial data --------------------
fprintf('Preparing initial required pyramids ...');
status = CheckStatus(numImages);
[alphaPyramid alphaPlusPyramid alphaMinusPyramid vMaxPyramid vMinPyramid lowHoleMaskPyramid highHoleMaskPyramid targets sourcePyramids sourceMaskPyramids] = Initialization(inputLDRs{refImgNum}, inputLDRsPyramid, resizeFac, expoTimes, refImgNum, 1:numImages, status);
fprintf(repmat('\b', 1, 3));
fprintf('Done\n\n');
%%% ------------------------------------------------

%%% Match all the images to the reference image ----
[alignedVotedImages alignedImages H] = MatchToReference(targets, sourcePyramids, sourceMaskPyramids, alphaPyramid, alphaPlusPyramid, alphaMinusPyramid, vMaxPyramid, vMinPyramid, iterStep, expoTimes, lowHoleMaskPyramid, highHoleMaskPyramid, refImgNum, 1:numImages);
%%% ------------------------------------------------