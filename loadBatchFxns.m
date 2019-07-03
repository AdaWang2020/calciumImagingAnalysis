function loadBatchFxns()
	% Loads the necessary directories to have the batch functions present.
	% Biafra Ahanonu
	% started: 2013.12.24 [08:46:11]

	% Disable the handle graphics warning "The DrawMode property will be removed in a future release. Use the SortMethod property instead." from being displayed. Comment out this line for debugging purposes as needed.
	warning('off','MATLAB:hg:WillBeRemovedReplaceWith')

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
		pathFilter3 = cellfun(@isempty,regexpi(pathListArray,[filesep 'cvx_rd']));
		pathListArray = pathListArray(pathFilter&pathFilter1&pathFilter2&pathFilter3);
	else
		matchIdx = contains(pathListArray,{[filesep 'cnmfe'],[filesep 'cnmf_original'],[filesep 'cnmf_current'],[filesep 'cvx_rd']});
		pathListArray = pathListArray(~matchIdx);
	end

	pathList = strjoin(pathListArray,pathsep);
	addpath(pathList);

	% add path for Miji, change as needed
	pathtoMiji = '\Fiji.app\scripts\';
	if exist(pathtoMiji,'dir')~=0
		onPath = subfxnCheckPath(pathtoMiji);
		if onPath==1
			fprintf('Miji already in PATH: %s.\n',pathtoMiji)
		else
			addpath(pathtoMiji);
			fprintf('Added default Miji to path: %s.\n',pathtoMiji)
		end
		try
			currP=pwd;Miji;cd(currP);MIJ.exit;
		catch err
			disp(repmat('@',1,7))
			disp(getReport(err,'extended','hyperlinks','on'));
			disp(repmat('@',1,7))
			manageMiji('startStop','start');
			manageMiji('startStop','exit');
		end
		% % Get Miji properly loaded in the path if not already
		% if exist('MIJ','class')==0
		% 	resetMiji;
		% end
	else
		clear pathtoMiji;
	end

	loadLocalFunctions = ['private' filesep 'settings' filesep 'privateLoadBatchFxns.m'];
	if exist(loadLocalFunctions,'file')~=0
		run(loadLocalFunctions);
		onPath = subfxnCheckPath(pathtoMiji);
		if exist(pathtoMiji,'dir')==7
			if onPath==1
				fprintf('Miji already in PATH: %s.\n',pathtoMiji)
			else
				addpath(pathtoMiji);
				fprintf('Added private Miji to path: %s.\n',pathtoMiji)
			end
		else
			fprintf('No folder at specified path, retry! %s.\n',pathtoMiji)
		end
		try
			currP=pwd;Miji;cd(currP);MIJ.exit;
		catch err
			disp(repmat('@',1,7))
			disp(getReport(err,'extended','hyperlinks','on'));
			disp(repmat('@',1,7))
			manageMiji('startStop','start');
			manageMiji('startStop','exit');
		end
		% % Get Miji properly loaded in the path
		% if exist('Miji.m')==2&&exist('MIJ','class')==0
		% 	resetMiji;
		% else
		% end
	else
		% create privateLoadBatchFxns.m
	end
	% cnmfVersionDirLoad('none');
end
function onPath = subfxnCheckPath(thisRootPath)
	pathCell = regexp(path, pathsep, 'split');
			if verLessThan('matlab','9.0')
				matchIdx = ~cellfun(@isempty,regexpi(pathCell,thisRootPath));
				% pathListArray = pathListArray(pathFilter&pathFilter1&pathFilter2);
			else
				matchIdx = contains(pathCell,thisRootPath);
			end
	onPath = any(matchIdx);
end