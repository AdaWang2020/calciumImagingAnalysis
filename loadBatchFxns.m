function loadBatchFxns()
	% Loads the necessary directories to have the batch functions present.
	% Biafra Ahanonu
	% started: 2013.12.24 [08:46:11]

	% add controller directory and subdirectories to path
	pathList = genpath(pwd);
	pathListArray = strsplit(pathList,pathsep);
	pathFilter = cellfun(@isempty,regexpi(pathListArray,[filesep '.git']));
	% pathFilter = cellfun(@isempty,regexpi(pathListArray,[filesep 'docs']));
	pathListArray = pathListArray(pathFilter);

	if verLessThan('matlab','9.0')
		pathFilter = cellfun(@isempty,regexpi(pathListArray,[filesep 'cnmfe']));
		pathFilter1 = cellfun(@isempty,regexpi(pathListArray,[filesep 'cnmf_original']));
		pathFilter2 = cellfun(@isempty,regexpi(pathListArray,[filesep 'cnmf_current']));
		pathListArray = pathListArray(pathFilter&pathFilter1&pathFilter2);
	else
		matchIdx = contains(pathListArray,{[filesep 'cnmfe'],[filesep 'cnmf_original'],[filesep 'cnmf_current']});
		pathListArray = pathListArray(~matchIdx);
	end

	pathList = strjoin(pathListArray,pathsep);
	addpath(pathList);

	% EM analysis path
	% addpath(genpath(['..' filesep 'Lacey']));
	% add path for Miji, change as needed
	pathtoMiji = '\Fiji.app\scripts\';
	if exist(pathtoMiji,'dir')~=0
		addpath(pathtoMiji);
		fprintf('Added Miji to path: %s.\n',pathtoMiji)
	else
		clear pathtoMiji;
	end

	loadLocalFunctions = ['private' filesep 'settings' filesep 'privateLoadBatchFxns.m'];
	if exist(loadLocalFunctions,'file')~=0
		run(loadLocalFunctions);
		addpath(pathtoMiji);
		fprintf('Added Miji to path: %s.\n',pathtoMiji)
	else
		% create privateLoadBatchFxns.m
	end
	% cnmfVersionDirLoad('none');
end