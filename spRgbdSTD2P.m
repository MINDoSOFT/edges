% Demo for RGBD Structured Edge Detector (please see readme.txt first).

%% set opts for training (see edgesTrain.m)
opts=edgesTrain();                % default options (good settings)
opts.modelDir='models/';          % model will be in models/forest
opts.modelFnm='modelNyuRgbd';     % model name
opts.nPos=5e5; opts.nNeg=5e5;     % decrease to speedup training
opts.useParfor=0;                 % parallelize if sufficient memory
opts.fracFtrs=1/8;                % sample fewer ftrs since using depth
opts.bsdsDir='inputRgbd/';        % specify use of NYU data
opts.rgbd=2;                      % specify use of rgb+d images

outDir='outputRgbdSuperpixels/';             % specify output directory

%% train edge detector (~50m/8Gb per tree, proportional to nPos/nNeg)
tic, model=edgesTrain(opts); toc; % will load model if already trained

%% set detection parameters (can set after training)
model.opts.multiscale=0;          % for top accuracy set multiscale=1
model.opts.sharpen=2;             % for top speed set sharpen=0
model.opts.nTreesEval=4;          % for top speed set nTreesEval=1
model.opts.nThreads=4;            % max number threads for evaluation
model.opts.nms=0;                 % set to true to enable nms

%% set up opts for spDetect (see spDetect.m)
optsSP = spDetect;
optsSP.nThreads = 4;  % number of computation threads
optsSP.k = 512;       % controls scale of superpixels (big k -> big sp)
optsSP.alpha = .5;    % relative importance of regularity versus data terms
optsSP.beta = .9;     % relative importance of edge versus color terms
optsSP.merge = 0.01;     % set to small value to merge nearby superpixels at end

%% evaluate edge detector on NYUD (see edgesEval.m)
if(0), edgesEval( model, 'show',1, 'name','', 'maxDist',.011 ); end

%% detect edge and visualize results
exists_or_mkdir(outDir);
iDir=[opts.bsdsDir 'images/']; dDir=[opts.bsdsDir 'depth/'];
inFiles=dir(fullfile(iDir,'*.png')); 

for ii = 1 : length(inFiles)

  sMessage = sprintf('Calculating edges for file %d/%d', ii, length(inFiles));
  disp(sMessage)
  id=inFiles(ii).name;
  %I=single(imread(fullfile(iDir,id)))/255;
  %D=single(imread(fullfile(dDir,id)))/1e4;
  I=imread(fullfile(iDir,id));
  D=imread(fullfile(dDir,id));
  tic, E=edgesDetect(cat(3,I,D),model); toc
  % figure(1); im(I); figure(2); im(1-E);
  % imwrite(E, [outDir id]); % This way does not work with epicflow
  % Write the results as a binary file for epicflow
  splitId = strsplit(id,'.');
  sFilename = splitId{1};
  %fileID = fopen([outDir sFilename '.bin'],'w');
  %fwrite(fileID, E, 'float');
  %fclose(fileID);
  tic, [S,V] = spDetect(I,E,optsSP); toc
  %figure(1); im(I); figure(2); im(V);
  sp = S;
  save([outDir sFilename '_sp.mat'],'sp');

end

disp('All done')
