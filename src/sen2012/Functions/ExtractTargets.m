function target = ExtractTargets(Reference, H, expoTimes, curRefImgNum, isFinal)

numImages = size(expoTimes, 1);

%%% Extracting LDR images from the calculated H ------------
target = cell(1, numImages);
for i = 1 : numImages
    if (i == curRefImgNum && ~isFinal)
        target{i} = Reference;
    else
        target{i} = HDRtoLDR(H, expoTimes(i));
    end
end
%%% ---------------------------------------------------------