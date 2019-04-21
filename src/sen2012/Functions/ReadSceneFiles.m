function [inputImgs exposureTimes numImages] = ReadSceneFiles(inputSceneFolder, sceneName, outFinalFolder, profile)

%%% Declaring global parameters ----------------------
global outFinalDir;
global refImgNum;
global maxImVal;    
global type;
global saveIntermediateResults;
%%% --------------------------------------------------

outFinalDir = [outFinalFolder, '/', sceneName, '_', profile];
inputFolder = sprintf('%s/%s', inputSceneFolder, sceneName);

expoFileName = dir([inputFolder, '/*.txt']);
listOfFiles = dir([inputFolder, '/*.tif']);     % Right now only gets tif as input

numImages = size(listOfFiles, 1);

if (numImages < 2)
    error('Number of input images should be greater than 1');
end

mkdir(outFinalDir);

inputImgs = cell(1, numImages);
for i = 1 : numImages
    Path = sprintf('%s/%s', inputFolder, listOfFiles(i).name);
    inputImgs{i} = imread(Path);

    type = class(inputImgs{i});
    if (strcmp(type, 'uint8'))
        maxImVal = 255;
    elseif (strcmp(type, 'uint16'))
        maxImVal = 2^16 - 1;
    end

    inputImgs{i} = single(inputImgs{i})/maxImVal;
end

Path = sprintf('%s/%s', inputFolder, expoFileName.name);

fid = fopen(Path);
exposureTimes = 2.^cell2mat(textscan(fid, '%f'));   % convert exposure value to exposure time (2^exposureValue = exposureTime)
fclose(fid);

if (length(exposureTimes) ~= numImages)
    error('Number of exposure times does not match the number of images');
end

if (isempty(refImgNum))
    refImgNum = ceil((numImages / 2) + 0.5);
end

if (saveIntermediateResults)
    for i = 1 : numImages
        if (i ~= refImgNum)
            outEachImgDir = sprintf('%s/Intermediate/%d', outFinalDir, i);
            mkdir(outEachImgDir);
        end
    end
end