function [ann bnn votedImg] = SearchAndVote(target, source, mask, ann, bnn, rs_max, doCompleteness, hardHoleMask, winSize)

%%% Declaring global variables
global algo;
global cores;
global isMinNNF;
global cohFac;
%%% -------------------------

comFac = 1 - cohFac;
numSourceImgs = size(source, 2);

%%% Coherency search ----------
for i = 1 : numSourceImgs
    if (isMinNNF && ~isempty(ann{i}))
        ann{i} = MinNNF(target, source{i}, ann{i}, rs_max, hardHoleMask, winSize);
    else
        ann{i} = nnmex(target, source{i}, algo, [], [], rs_max, [], [], [], cores, hardHoleMask, winSize, ann{i});
    end
end

%%% Finding the best NNF with the smallest L2 distance
NNFdists = [];
for i = 1 : numSourceImgs
    NNFdists = cat(3, NNFdists, ann{i}(:, :, 3));
end

[~, Ind] = min(NNFdists, [], 3);

annForVote = ann;
for i = 1 : numSourceImgs
   annForVote{i}(logical(1-repmat(Ind == i, [1,1,3]))) = 9999; 
end
%%% ----------------------------

%%% Completeness Search ----------
if (doCompleteness)
    bnnForVote = cell(1, size(bnn,1));
    for i = 1 : numSourceImgs
        if (isMinNNF && ~isempty(bnn{i}))
            bnn{i} = MinNNF(source{i}, target, bnn{i}, rs_max, [], winSize);
        else
            bnn{i} = nnmex(source{i}, target, algo, [], [], rs_max, [], [], [], cores, [], winSize, bnn{i});
        end
        bnnForVote{i} = bnn{i};
        % Only votes for valid regions. mask == 1 --> invalid
        % if NNF has a value of 9999 it does not vote.
        bnnForVote{i}(mask{i} == 1) = 9999; 
    end
end
% --------------------------------    

% Get coherency weights ----------
cohWeight1 = cell(1, numSourceImgs);
for i = 1 : numSourceImgs
    cohWeight1{i} = GetCohWeight(ann{i});
end

if(doCompleteness)
    cohWeight2 = cell(1, numSourceImgs);
    for i = 1 : numSourceImgs
        cohWeight2{i} = GetCohWeight(bnn{i});
    end
end
% -------------------------------

%%% Voting process --------------
imgCoh = cell(1, numSourceImgs);
imgCom = cell(1, numSourceImgs);

totWeight = 0;
totImage = 0;

for i = 1 : numSourceImgs
    % Vote for the coherency direction
    [imgCoh{i}, ~] = votemex(source{i}, annForVote{i}, [], 'cpu', [], [], [], 1, 1, hardHoleMask, cohWeight1{i});
    totWeight = totWeight + cohFac * imgCoh{i}(:, :, 4);
    totImage = totImage + cohFac * imgCoh{i}(:, :, 1:3);
    
    % Vote for the completeness direction
    if (doCompleteness)
        [~, imgCom{i}] = votemex(source{i}, annForVote{i}, bnnForVote{i}, 'cpu', [], [], cohWeight2{i}, 0, 1, [], cohWeight1{i}); 
        totWeight = totWeight + comFac * imgCom{i}(:, :, 4)/(numSourceImgs);
        totImage = totImage + comFac * imgCom{i}(:, :, 1:3)/(numSourceImgs);
    end
end
%%% ----------------------------

votedImg = totImage./repmat(totWeight, [1,1,3]);
votedImg(repmat(totWeight, [1,1,3]) == 0) = 0;
