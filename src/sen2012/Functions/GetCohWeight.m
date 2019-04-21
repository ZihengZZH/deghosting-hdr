function cohWeight = GetCohWeight(ann)

global patch_w;

cohWeight = unweigthCohMex(single(ann), patch_w);
cohWeight = uint8(repmat(cohWeight*255,[1 1 3]));