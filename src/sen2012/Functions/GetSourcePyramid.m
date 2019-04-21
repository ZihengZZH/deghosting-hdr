function [sourcePyramid sourceMaskPyramid] = GetSourcePyramid(inputLDRsPyramid, expoTimes, curRefImgNum, indCurImgs)

global numScales;
global DSMethod;
global vMin;
global vMax;
global isMBDS;

% Number of all the source images
numSourceImgs = size(expoTimes, 1);

% Number of output images
numImgs = length(indCurImgs);

sourcePyramid = cell(1, numImgs);

% This mask is used for the completeness direction to mask out the regions that
% are not useful.
sourceMaskPyramid = cell(1, numImgs);

for i = indCurImgs
    
    if (i < curRefImgNum)
        if (isMBDS)
            % Only the images darker than the current image have valid
            % information
            inds = i : -1: 1;
        else
            inds = i;
        end
        for j = inds
            sourceMaskAux = double(inputLDRsPyramid{1}{i} > max(LDRtoLDR(vMax, expoTimes(curRefImgNum), expoTimes(i)), vMin));
            sourceMaskPyramid{i-indCurImgs(1)+1}{1}{i-j+1} = GetSourceHoleMask(sourceMaskAux);
            for k = 1 : numScales
                sourcePyramid{i-indCurImgs(1)+1}{k}{i-j+1} = LDRtoLDR(inputLDRsPyramid{k}{j}, expoTimes(j), expoTimes(i));
                if (k ~= 1)
                    sourceMaskPyramid{i-indCurImgs(1)+1}{k}{i-j+1} = GetSourceHoleMask(max(0,min(1, imresize(sourceMaskAux, size(sum(inputLDRsPyramid{k}{j},3)), DSMethod))));
                end
            end
        end
    elseif (i > curRefImgNum)
        if (isMBDS)
            % Only the images brighter than the current image have valid
            % information
            inds = i : numSourceImgs;
        else
            inds = i;
        end
        
        for j = inds
            sourceMaskAux = double(inputLDRsPyramid{1}{i} < min(LDRtoLDR(vMin, expoTimes(curRefImgNum), expoTimes(i)), vMax));
            sourceMaskPyramid{i-indCurImgs(1)+1}{1}{j} = GetSourceHoleMask(sourceMaskAux);
            for k = 1 : numScales
                sourcePyramid{i-indCurImgs(1)+1}{k}{j-i+1} = LDRtoLDR(inputLDRsPyramid{k}{j}, expoTimes(j), expoTimes(i));
                if (k ~= 1)
                    sourceMaskPyramid{i-indCurImgs(1)+1}{k}{j-i+1} = GetSourceHoleMask(max(0,min(1, imresize(sourceMaskAux, size(sum(inputLDRsPyramid{k}{j},3)), DSMethod))));
                end
            end
        end
    else
        for k = 1 : numScales
            sourcePyramid{i-indCurImgs(1)+1}{k}{1} = inputLDRsPyramid{k}{curRefImgNum};
        end
    end
end

