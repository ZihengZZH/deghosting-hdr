clear; clc; close all; warning off;

path(path, 'MexFiles');
path(path, 'Functions');

%%% Declaring global variables ---------------------
global refImgNum;   % Reference image number
%%% ------------------------------------------------

%%% Parameters and input initialization ------------

% The name of the scene to be processed
sceneName = 'FeedingTime';
% sceneName = 'BabyOnGrass';
% sceneName = 'SantasLittleHelper';
% sceneName = 'ChristmasRider';
% sceneName = 'PianoMan';
% sceneName = 'HighChair';
% sceneName = 'LadyEating';
% sceneName = 'BabyAtWindow';


%%% We support 3 quality modes from 'normal' (fastest/lowest quality) to  
%%% 'high' (slowest/best quality):

% profile = 'normal';
profile = 'medium';
% profile = 'high';

outFinalFolder = 'Results';
inputSceneFolder = 'Scenes';
%%% ------------------------------------------------

InitParams(profile);

% The reference image number can be set here. If this is empty, the middle
% image is used as reference.
refImgNum = [];

%---------- Load the images and make the output directories ----------
fprintf('**********************************\n');
fprintf('Working on the "%s" dataset\n', sceneName);

fprintf('Loading input images ...');
[inputLDRs, exposureTimes, numImages] = ReadSceneFiles(inputSceneFolder, sceneName, outFinalFolder, profile);
fprintf(repmat('\b', 1, 3));
fprintf('Done\n');
fprintf('Total number of images: %d\n\n', numImages);
%---------------------------------------------------------------------

[alignedVotedImages, alignedImages, HDR] = GenerateHDR(inputLDRs, exposureTimes, sceneName);

fprintf('Finished working on the "%s" dataset\n\n', sceneName);

warning on;
