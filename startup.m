function startup()
  if(~exist('utils', 'dir')), warning('Missing utils. You will need it for some fuctions. Get it from here: https://github.com/MINDoSOFT/utils/'); end
  if(~exist('toolbox', 'dir')), warning('Missing Piotr''s Computer Vision Matlab Toolbox. You will need it for some functions. Get it from here: https://github.com/MINDoSOFT/toolbox'); end

  addPath = {'utils', 'toolbox'};
  genPath = {'toolbox'};

  for i = 1:length(addPath),
    addpath(addPath{i});
  end

  for i = 1:length(genPath),
    addpath(genpath_exclude(genPath{i}, '.git'));
  end
  startup_utils;
  startup_toolbox;
  fprintf('startup done\n');
end
