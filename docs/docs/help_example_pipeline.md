# Example `calciumImagingAnalysis` pipeline via the command line.

Below is an example `cacliumImagingAnalysis` pipeline using the command line for those that do not want to use the class or want to create their own custom batch analyses. It assumes you have already run `example_downloadTestData` to download the example test data.

Can also access by typing `edit ciapkg.demo.cmdLinePipeline` into the command line.

```MATLAB
% Running calciumImagingAnalysis command line

%% Load movie to analyze
inputMovie = loadMovieList('data\2014_04_01_p203_m19_check01\concat_recording_20140401_180333.h5');
```
```MATLAB
%% Visualize slice of the movie
playMovie(inputMoevie(:,:,1:500));
```
```MATLAB
%% Downsample input movie if need to
inputMovieD = downsampleMovie(inputMovie,'downsampleDimension','space','downsampleFactor',4);
playMovie(inputMovie,'extraMovie',inputMovieD);
```
```MATLAB
%% Remove stripes from movie if needed
% Show full filter sequence for one frame
sopts.stripOrientation = 'both';
sopts.meanFilterSize = 1;
sopts.freqLowExclude = 10;
sopts.bandpassType = 'highpass';
removeStripsFromMovie(inputMovie(:,:,1),'options',sopts,'showImages',1);
% Run on the entire movie
removeStripsFromMovie(inputMovie,'options',sopts);
```
```MATLAB
%% Get coordinates to crop
[cropCoords] = getCropCoords(squeeze(inputMovie(:,:,1)));
toptions.cropCoords = cropCoords;
```
```MATLAB
%% Motion correction
% Or have turboreg run manual correction
toptions.cropCoords = 'manual';
toptions.turboregRotation = 0;
toptions.removeEdges = 1;
toptions.pxToCrop = 10;
% Pre-motion correction
	toptions.complementMatrix = 1;
	toptions.meanSubtract = 1;
	toptions.meanSubtractNormalize = 1;
	toptions.normalizeType = 'matlabDisk';
% Spatial filter
	toptions.normalizeBeforeRegister = 'divideByLowpass';
	toptions.freqLow = 0;
	toptions.freqHigh = 7;
[inputMovie2, ~] = turboregMovie(inputMovie,'options',toptions);
```
```MATLAB
%% Compare raw and motion corrected movies
playMovie(inputMovie,'extraMovie',inputMovie2);
```
```MATLAB
%% Run dF/F
inputMovie3 = dfofMovie(single(inputMovie2),'dfofType','dfof');
```
```MATLAB
%% Run temporal downsampling
inputMovie3 = downsampleMovie(inputMovie3,'downsampleDimension','time','downsampleFactor',4);
```
```MATLAB
%% Final check of movie before cell extraction
playMovie(inputMovie3);
```
```MATLAB
%% Run PCA-ICA cell extraction
nPCs = 300; nICs = 225;
[PcaOutputSpatial, PcaOutputTemporal, PcaOutputSingularValues, PcaInfo] = run_pca(inputMovie3, nPCs, 'movie_dataset_name','/1');
[IcaFilters, IcaTraces, IcaInfo] = run_ica(PcaOutputSpatial, PcaOutputTemporal, PcaOutputSingularValues, size(inputMovie3,1), size(inputMovie3,2), nICs, 'output_units','fl','mu',0.1,'term_tol',5e-6,'max_iter',1e3);
IcaTraces = permute(IcaTraces,[2 1]);
```
```MATLAB
%% Save outputs to NWB format
saveNeurodataWithoutBorders(IcaFilters,{IcaTraces},'pcaica','pcaica.nwb');
```
```MATLAB
%% Run cell extraction using matrix
[outImages, outSignals, choices] = signalSorter(IcaFilters,IcaTraces,'inputMovie',inputMovie3);
```
```MATLAB
%% Run signal sorting using NWB
[outImages, outSignals, choices] = signalSorter('pcaica.nwb',[],'inputMovie',inputMovie3);
```
```MATLAB
%% Plot results of sorting
figure;
subplot(1,2,1);imagesc(max(IcaFilters,[],3));axis equal tight; title('Raw filters')
subplot(1,2,2);imagesc(max(outImages,[],3));axis equal tight; title('Sorted filters')
```
```MATLAB
%% Create an overlay of extraction outputs on the movie and signal-based movie
[inputMovieO] = createImageOutlineOnMovie(inputMovie3,IcaFilters,'dilateOutlinesFactor',0);
[signalMovie] = createSignalBasedMovie(IcaTraces,IcaFilters,'signalType','peak');
```
```MATLAB
%% Play all three movies
% Normalize all the movies
movieM = cellfun(@(x) normalizeVector(x,'normRange','zeroToOne'),{inputMovie3,inputMovieO,signalMovie},'UniformOutput',false);
playMovie(cat(2,movieM{:}));
```