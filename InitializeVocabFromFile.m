function [ vocab, fullVocab, fullWordmap ] = InitializeVocabFromFile(wordMap, loc, hyperParams)
% Initialize the embedding matrix from an existing vector source.

% This will only initialize words that are specified in wordMap.
% If a word is in wordMap but not in the initialization fine, it will be initialized randomly.

wordlist = wordMap.keys();
disp(length(wordlist));
% Load a vector file.
assert(~isempty(loc), 'You must specify a word vector source to use loadWords.');
fid = fopen(loc);
words = textscan(fid,'%s %*[^\n]'); % Use the first column.
words = words{1};
fclose(fid);
fullVocab = dlmread(loc, ' ', 0, 1); 

fullWordmap = containers.Map(words,2:length(words) + 1);

vocab = fNormrnd(0, 1, [size(fullVocab, 2), size(wordlist, 2)], hyperParams.gpu, hyperParams.gpu && hyperParams.largeVocabMode);

% Rescale the loaded vectors into the same neighborhood as the random ones.
loadScale = 1 / std(fullVocab(:));

for wordlistIndex = 1:length(wordlist)
    if fullWordmap.isKey(wordlist{wordlistIndex})
        loadedIndex = fullWordmap(wordlist{wordlistIndex});
    elseif fullWordmap.isKey(strrep(wordlist{wordlistIndex}, '_', '-'))
        loadedIndex = fullWordmap(strrep(wordlist{wordlistIndex}, '_', '-'));
    elseif strcmp(wordlist{wordlistIndex}, 'n''t') && isempty(loc)
        loadedIndex = fullWordmap('not');
    else
        loadedIndex = 0;
    end
    if loadedIndex > 0
        % Copy in the loaded vector
        vocab(:, wordMap(wordlist{wordlistIndex})) = fullVocab(loadedIndex, :)' .* loadScale;
    end % Else: We keep the randomly initialized entry
end

end
