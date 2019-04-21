function ann = MinNNF(A, B, PrevANN, rs_max, hardHoleMask, winSize)

global cores;
global algo;

ann = int32(zeros(size(PrevANN)));

annTmp1 = nnmex(A, B, algo, [], [], rs_max, [], [], [], cores, hardHoleMask, winSize, PrevANN);
annTmp2 = nnmex(A, B, algo, [], [], rs_max, [], [], [], cores, hardHoleMask, winSize);

[~, ind] = min(cat(3, annTmp1(:,:,3), annTmp2(:,:,3)), [], 3);

ann(repmat(ind == 1, [1,1,3])) = annTmp1(repmat(ind == 1, [1,1,3]));
ann(repmat(ind == 2, [1,1,3])) = annTmp2(repmat(ind == 2, [1,1,3]));