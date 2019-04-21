clear;

warning('off','all');
addpath('utils');
addpath('patchmatch-2.1');
patha = 'Data';

firstdir = dir(patha);
for indx = 3:size(firstdir,1)

    subpatha = [patha '/' firstdir(indx).name];    
    subdir   = dir(subpatha);
    
    close all;
    clear im;
 
    count = 0;    
    for inds = 3:length(subdir)
        
        [~,~,extension] = fileparts(subdir(inds).name);
        extension = upper(extension);
        
        switch extension
            case {'.PNG', '.BMP', '.JPG', '.TIF', '.TIFF'}                

                 count           = count + 1;
                 imgStack{count} = imread([subpatha '/' subdir(inds).name]);
                 
                 if max(size(imgStack{count})) > 1600
                     ratio           = max(size(imgStack{count},1), ...
                                       size(imgStack{count},2)) / 1600;
                     imgStack{count} = imresize(imgStack{count}, 1/ratio);                                      
                 end
                 
                 if isimg(imgStack{count})
                     
                     if isa(imgStack{count}, 'uint16')
                         imgStack{count} = uint8( double(imgStack{count}) * 255 / (2^16 - 1));                         
                     elseif isa(imgStack{count}, 'double')
                         imgStack{count} = uint8( imgStack{count} * 255);                         
                     end
                     
                 else
                     error('Invalid Img Type!');
                 end
                 
            otherwise
        end
        
    end
    
    N                  = numel(imgStack);   
    uv                 = cell(N,1);
    latentImgs         = cell(N,1);
    ppIMFs             = cell(N,1);
    invppIMFs          = cell(N,1);    
    
    idxRef             = ceil(count/2);    
    latentImgs{idxRef} = imgStack{idxRef};    
    idxPostRef         = idxRef + 1;
    idxPreRef          = idxRef - 1;
    keepRun            = true;
    
    tic;        
    
    while keepRun

        if idxPreRef >= 1
            idxRef = idxPreRef + 1;
            idxSrc = idxPreRef;
            
            fprintf(1, 'Processing img %d and img %d : Finish 0/6', idxRef, idxSrc);
            
            tempSrc   = imgStack{idxSrc};
            tempRef   = latentImgs{idxRef};
            [uv{idxSrc}, latentImgs{idxSrc}, ppIMFs{idxSrc}, invppIMFs{idxSrc}] ...
                      = computemultiscale(tempSrc,tempRef);            
            idxPreRef = idxPreRef - 1;
        end           
        
        fprintf('\n');
        
        if idxPostRef <= N
            idxRef = idxPostRef - 1;
            idxSrc = idxPostRef;
            
            fprintf(1, 'Processing img %d and img %d : Finish 0/6', idxRef, idxSrc);            
            
            tempSrc    = imgStack{idxSrc};
            tempRef    = latentImgs{idxRef};            
            [uv{idxSrc}, latentImgs{idxSrc}, ppIMFs{idxSrc}, invppIMFs{idxSrc}] ...
                       = computemultiscale(tempSrc,tempRef);        
            idxPostRef = idxPostRef + 1;
        end                  
              
        fprintf('\n');        
                                                                                                
        if idxPreRef < 1 && idxPostRef > N
            keepRun = false;
        end
    end                     

    toc;
    
    save([firstdir(indx).name datestr(clock)  '.mat'], ...
        'uv', 'latentImgs', 'ppIMFs', 'invppIMFs', 'imgStack');

end
