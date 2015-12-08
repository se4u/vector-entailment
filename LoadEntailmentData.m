% Want to distribute this code? Have other questions? -> sbowman@stanford.edu
function data = LoadEntailmentData(filename, wordMap, labelMap, hyperParams, fragment, labelIndex)
% Load one file of sentence pair data.

if hyperParams.useTrees
    typeSig = '-trees';
elseif hyperParams.useLattices
    typeSig = '-lats';
else
    typeSig = ['-seqs-par' num2str(hyperParams.parensInSequences)];
end

if fragment
    % Check whether we already loaded this file
    [pathname, filenamePart, ext] = fileparts(filename);
    listing = dir([pathname, '/pp-', filenamePart, ext,'-final-', hyperParams.vocabName, typeSig, '*']);
    if length(listing) > 0
        Log(hyperParams.statlog, ['File ', filename, ' was already processed.']);
        return
    end
elseif ~hyperParams.ignorePreprocessedFiles
    % Check whether we already loaded this file
    [pathname, filenamePart, ext] = fileparts(filename);
    listing = dir([pathname, '/pp-', filenamePart, ext, '-full-', hyperParams.vocabName, typeSig, '*']);
    if length(listing) > 0
        Log(hyperParams.statlog, ['File ', filename, ' was already processed. Loading.']);
        try
            d = load([pathname, '/', listing(1).name],'-mat');
            data = d.data;
            return
        catch
            Log(hyperParams.statlog, 'Problem loading preprocessed data. Will reprocess raw file.');
        end
    end
end

fid = fopen(filename);
C = textscan(fid,'%s','delimiter',sprintf('\n'));
fclose(fid);

% Parse the file
nextItemNo = 1;
maxLine = min(length(C{1}), hyperParams.lineLimit);

% Initialize the data array
rawData = repmat(struct('label', 0, 'leftText', '', 'rightText', ''), maxLine, 1);

% Which nextItemNo was the last to be included in the last MAT file.
lastSave = 0;

% Iterate over examples
tic
for line = (lastSave + 1):maxLine
    if mod(line , 10000) == 0
        disp(['processed ' num2str(line) ' lines in ' num2str(toc) ' seconds.' ]);
        tic;
    end
    if ~isempty(C{1}{line})
        splitLine = textscan(C{1}{line}, '%s', 'delimiter', '\t');
        splitLine = splitLine{1};

        % Skip commented and unlabeled lines
        if (splitLine{1}(1) ~= '%') && (splitLine{1}(1) ~= '-') && (size(splitLine, 1) >= 3) && labelMap{labelIndex}.isKey(splitLine{1})
            rawData(nextItemNo - lastSave).label = [ labelMap{labelIndex}(splitLine{1}); labelIndex ];
            rawData(nextItemNo - lastSave).leftText = splitLine{2};
            rawData(nextItemNo - lastSave).rightText = splitLine{3};
            nextItemNo = nextItemNo + 1;
        elseif splitLine{1}(1) ~= '-'
            disp(['Skipped line: ' C{1}{line}]);
        end
    end
    if (mod(nextItemNo - 1, 10000) == 0 && nextItemNo > 0 && fragment)
        message = ['Lines loaded: ', num2str(nextItemNo), '/~', num2str(maxLine)];
        Log(hyperParams.statlog, message);
        data = ProcessAndSave(rawData, wordMap, lastSave, nextItemNo, filename, hyperParams, fragment, typeSig);
        lastSave = nextItemNo - 1;
    end
end
disp('Finished Processing the lines');
if fragment
    data = ProcessAndSave(rawData, wordMap, lastSave, nextItemNo, [filename, '-final'], hyperParams, fragment, typeSig);
else
    fprintf(1, 'Started the Process and Save Procedure. \n');
    tic;
    data = ProcessAndSave(rawData, wordMap, lastSave, nextItemNo, [filename, '-full'], hyperParams, fragment, typeSig);
    fprintf(1, 'Finished the Process and Save thing in %d seconds \n', toc);
end

end

function [ data ] = ProcessAndSave(rawData, wordMap, lastSave, nextItemNo, filename, hyperParams, fragment, typeSig)
    numElements = nextItemNo - (lastSave + 1);
    tic
    if hyperParams.useTrees
        data = repmat(struct('label', 0, 'left', Tree(), 'right', Tree()), numElements, 1);
        parfor dataInd = 1:numElements
            data(dataInd).left = Tree.makeTree(rawData(dataInd).leftText, wordMap);
            data(dataInd).right = Tree.makeTree(rawData(dataInd).rightText, wordMap);
            data(dataInd).label = rawData(dataInd).label;
        end
    elseif hyperParams.useLattices
        data = repmat(struct('label', 0, 'left', Lattice(), 'right', Lattice()), numElements, 1);
        parfor dataInd = 1:numElements
            data(dataInd).left = Lattice.makeLattice(rawData(dataInd).leftText, wordMap, hyperParams.gpu, hyperParams.gpu && ~hyperParams.largeVocabMode);
            data(dataInd).right = Lattice.makeLattice(rawData(dataInd).rightText, wordMap, hyperParams.gpu, hyperParams.gpu && ~hyperParams.largeVocabMode);
            data(dataInd).label = rawData(dataInd).label;
        end
    else
        data = repmat(struct('label', 0, 'left', Sequence(), 'right', Sequence()), numElements, 1);
        parfor dataInd = 1:numElements
            data(dataInd).left = Sequence.makeSequence(rawData(dataInd).leftText, wordMap, ...
                hyperParams.parensInSequences, hyperParams.gpu && ~hyperParams.largeVocabMode);

            data(dataInd).right = Sequence.makeSequence(rawData(dataInd).rightText, wordMap, ...
                hyperParams.parensInSequences, hyperParams.gpu && ~hyperParams.largeVocabMode);
            data(dataInd).label = rawData(dataInd).label;
        end
    end
    fprintf(1, 'Finished Constructing Sequence from data in %d seconds \n', toc);
    if ~hyperParams.ignorePreprocessedFiles
        [pathname, filenamePart, ext] = fileparts(filename);
        nameToSave = [pathname, '/pp-', filenamePart, ext, '-', hyperParams.vocabName, typeSig, '-', num2str(nextItemNo), '.mat'];
        listing = dir(nameToSave);
        % Double check that a file hasn't been written while we were processing.
        if isempty(listing)
            try
                save(nameToSave, 'data', '-v7.3');
            catch
                Log(hyperParams.statlog, 'Problem saving.');
            end
        end
    end
end
