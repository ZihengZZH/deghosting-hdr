function WriteFinalResults(alignedVotedImages, H, totalTime, sceneName)

global outFinalDir;
global maxImVal;
global type;

numImages = size(alignedVotedImages, 2);

save([outFinalDir,'/Timing'], 'totalTime');
hdrwrite(H, [outFinalDir,sprintf('/%s.hdr', sceneName)]);

for i = 1 : numImages
    if (strcmp(type, 'uint8'))
        imwrite(uint8(alignedVotedImages{i}*(maxImVal)), [outFinalDir,sprintf('/%s-l%d.tif', sceneName, i)]);
    elseif (strcmp(type, 'uint16'))
        imwrite(uint16(alignedVotedImages{i}*(maxImVal)), [outFinalDir,sprintf('/%s-l%d.tif', sceneName, i)]);
    end
end