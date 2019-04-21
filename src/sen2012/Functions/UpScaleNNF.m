function upScaledNNF = UpScaleNNF(NNF, h, w, curRefImgNum)

global patch_w;

numSourceImgs = size(NNF, 2);
upScaledNNF = cell(1, numSourceImgs);

for i = 1 : numSourceImgs
    if (i ~= curRefImgNum)
        numSources = size(NNF{i}, 2);
        for j = 1 : numSources
            upScaledNNF{i}{j} = int32(round(upscaleNN(single(NNF{i}{j}), single(zeros(h, w)), patch_w, h, w)));
        end
    end
end