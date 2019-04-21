new_a = zeros(size(a));
flow = zeros(size(a));
[h,w,~] = size(a);

for j = 1:h
    for i = 1:w
        newi = ann1(j,i,1,1) + 1;
        newj = ann1(j,i,2,1) + 1;
        new_a(j,i,:) = b(newj,newi,:);
        %flow(j,i,1) = newj - j;
        %flow(j,i,2) = newi - i;
    end
end

figure, imshow(uint8(new_a));
%figure, imagesc(flow(:,:,1));
%%
dist = 100;
out = int32(dist*randi([-1, 1], h, w, 2));
ann_prior = ann1(:,:,1:2,1) + out;

T = ann1(:,:,1);
max_Tx = max(T(:));
min_Tx = min(T(:));
T = ann_prior(:,:,1);
inds = T < min_Tx;
T(inds) = min_Tx;
inds = T > max_Tx;
T(inds) = max_Tx;
ann_prior(:,:,1) = T;

T = ann1(:,:,2);
max_Tx = max(T(:));
min_Tx = min(T(:));
T = ann_prior(:,:,2);
inds = T < min_Tx;
T(inds) = min_Tx;
inds = T > max_Tx;
T(inds) = max_Tx;
ann_prior(:,:,2) = T;


figure, imagesc(ann_prior(:,:,1));
%%
ann1 = nnmex(a,b,[], [], [], [], [], [], [], 2, [], [], [], [], [], [], [], []);