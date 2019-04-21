function InitParams(profile)

%%% DO NOT CHANGE ANY PARAMETER, UNLESS YOU KNOW EXACTLY WHAT EACH
%%% PARAMETER DOES.

%%% Declaring global variables -----------------------
global patch_w;                 % patch size
global minImgSize;              % lowest scale resolution size for min(w, h)
global maxIter;                 % number of iterations at the coarsest scale
global minIter;                 % minimum number of iterations at the finest scale
global numScales;               % number of scales (distributed logarithmically)
global DSMethod;                % downsampling method
global saveIntermediateResults; % set true to save intermediate results
global vMax;                    % valid color values are between vMin and vMax
global vMin;                    % 
global SEDilate;                % structure element used for dilating masks
global cores;                   % number of cores for multi-core processing (PatchMatch)
global algo;                    % PatchMatch algorithm type
global gamma;                   % gamma value used to tonemap the input images. We use gamma = 2.2.
global winIter;                 % a value between 0 to 1 which defines the percentage of scales where we do "limited search" (coarsest)
global winFac;                  % in case we use "limited search", winFac*sqrt(height*width) is the size of the search window
global cohFac;                  % weight of patches for the Coherency direction (in BDS). The weight for Completeness is 1-cohFac.

global isMask;                  % if true, search only in the invalid regions of reference (valid regions are not synthesized for more speed)
global isMBDS;                  % if true, MBDS with all images is performed, otherwise only one source is used at a time.
global completenessFac;         % a value between 0 to 1 which defines what percentage of scales do Completeness (coarsest)
global isPairwise;              % If true, the pairwise matching will be done. Otherwise, all the N sources will 
                                % be optimized together.
global isMinNNF;                % if true, MinNNF function will be called during the search process to avoid trapping into local minimum.

%%% ------------------------------------------------

%%% Parameters initialization ----------------------
patch_w = 7;
minImgSize = 35;
maxIter = 50;
minIter = 5;
numScales = 10;
DSMethod = 'lanczos3';
vMax = 0.9;
vMin = 0.1;
SEDilate = strel('square', patch_w);
cores = 8;
if cores == 1
    algo = 'cpu';
else
    algo = 'cputiled';
end

gamma = 2.2;    % Do not change this number for the datasets in this package
winIter = 0.15;
winFac = 0.1;

cohFac = 0.7;

saveIntermediateResults = false;
isPairwise = true;

if (strcmp(profile, 'normal'))
    isMask = true;
    isMBDS = false;
    completenessFac = 0.5;
elseif (strcmp(profile, 'medium'))
    isMask = false;
    isMBDS = false;
    completenessFac = 0.5;
elseif (strcmp(profile, 'high'))
    isMask = false;
    isMBDS = true;
    completenessFac = 1;
end

isMinNNF = false;

%%% -----------------------------------------