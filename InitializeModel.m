% Want to distribute this code? Have other questions? -> sbowman@stanford.edu
function [ theta, thetaDecoder, separateWordFeatures ] = InitializeModel(wordMap, hyperParams)
% Initialize the learned parameters of the model. 

assert(~(hyperParams.lstm && hyperParams.useThirdOrderComposition), 'RNTN and LSTM units are mutually exclusive.')
assert(~(hyperParams.lstm && hyperParams.eyeScale), 'Eye initialization cannot be used with LSTM units.')

vocabLength = size(wordMap, 1);
DIM = hyperParams.dim;
EMBDIM = hyperParams.embeddingDim;
PENULT = hyperParams.penultDim;
TOPD = hyperParams.topDepth;
NUMTRANS = hyperParams.useEmbeddingTransform;

if hyperParams.useSumming
    NUMCOMP = 0;
elseif ~hyperParams.untied
    NUMCOMP = 1;
else
    % Partial support for syntactic untying.
    NUMCOMP = 3;
end

% Randomly initialize softmax layer
softmaxMatrix = InitializeNNLayer(PENULT, sum(hyperParams.numLabels), 1, 1, 1, hyperParams.gpu);

mergeMatrix = InitializeNNLayer(DIM * 2, PENULT, 1, hyperParams.NNinitType, 1, hyperParams.gpu);

% Randomly initialize tensor parameters
if ~hyperParams.sentenceClassificationMode
    if hyperParams.useThirdOrderMerge
        mergeMatrices = InitializeNTNLayer(DIM, PENULT, hyperParams.NTNinitType, hyperParams.gpu) .* hyperParams.tensorScale;
        mergeMatrix = mergeMatrix .* (1 - hyperParams.tensorScale);
    else
        mergeMatrices = fZeros([0, 0, PENULT], hyperParams.gpu);
    end
else
    mergeMatrices = [];
    mergeMatrix = [];
end

if hyperParams.lstm
    compositionMatrix = InitializeLSTMLayer(DIM, NUMCOMP, hyperParams.LSTMinitType, hyperParams.useLattices || hyperParams.useTrees, hyperParams.gpu);
else
    compositionMatrix = InitializeNNLayer(DIM * 2, DIM, NUMCOMP, hyperParams.NNinitType, 1, hyperParams.gpu);
end
  
if hyperParams.eyeScale > 0 && ~hyperParams.lstm
    for i = 1:NUMCOMP
        compositionMatrix(:, end - (2 * DIM) + 1:end, i) = compositionMatrix(:, end - (2 * DIM) + 1:end, i) .* (1 - hyperParams.eyeScale) + [eye(DIM) eye(DIM)] .* hyperParams.eyeScale;
    end
end

if hyperParams.useThirdOrderComposition && ~hyperParams.useLattices
    if hyperParams.tensorScale > 0
        compositionMatrices = InitializeNTNLayer(DIM, DIM, hyperParams.NTNinitType, hyperParams.gpu) .* hyperParams.tensorScale;
        compositionMatrix = compositionMatrix .* (1 - hyperParams.tensorScale);
    else
        compositionMatrices = InitializeNTNLayer(DIM, DIM, hyperParams.NTNinitType, hyperParams.gpu);
    end
    scoringVector = [];
elseif hyperParams.useLattices
    % To keep stacking and unstacking simple, we overload this parameter name for the 
    % connection chosing layer in the lattice model.

    % This is not a proper NN layer - just a filter that will be .*'d with a clump of features and summed.
    compositionMatrices = InitializeNNLayer((2 * hyperParams.latticeConnectionContextWidth * DIM) + 3, ...
        hyperParams.latticeConnectionHiddenDim, 1, hyperParams.NNinitType, 0, hyperParams.gpu);
    scoringVector = InitializeNNLayer(hyperParams.latticeConnectionHiddenDim, 1, 1, hyperParams.NNinitType, ...
        1, hyperParams.gpu);
else
    compositionMatrices = [];
    scoringVector = [];
end

classifierExtraMatrix = InitializeNNLayer(PENULT, PENULT, TOPD - 1, hyperParams.NNinitType, 1, hyperParams.gpu);

  
if NUMTRANS > 0
    assert(NUMTRANS == 1, 'Currently, we do not support more than one embedding transform layer.');
    embeddingTransformMatrix = InitializeNNLayer(EMBDIM, DIM, NUMTRANS, hyperParams.NNinitType, 1, hyperParams.gpu);
else
    embeddingTransformMatrix = [];
end
  
if (nargout < 3) && hyperParams.largeVocabMode
    % Transfer learning - this will just be overwritten.
    wordFeatures = [];
elseif hyperParams.loadWords
    Log(hyperParams.statlog, 'Loading the vocabulary.')
    tic
    wordFeatures = InitializeVocabFromFile(wordMap, hyperParams.vocabPath, ...
                                           hyperParams);
    Log(hyperParams.statlog, ['Finished Loading the vocabulary in ' ...
                        num2str(toc) 'seconds']);
else
    % Randomly initialize the words
    wordFeatures = fNormrnd(0, 1, [EMBDIM, vocabLength], hyperParams.gpu, hyperParams.gpu && hyperParams.largeVocabMode);
    if ~hyperParams.trainWords
        Log(hyperParams.statlog, 'Warning: Word vectors are randomly initialized and not trained.');     
    end
end

if ~hyperParams.trainWords || hyperParams.largeVocabMode
    % Move the initialized word features into separateWordFeatures
    separateWordFeatures = wordFeatures;
    wordFeatures = [];
else
    separateWordFeatures = [];
end


% Pack up the parameters.
[ theta, thetaDecoder ] = param2stack(mergeMatrices, mergeMatrix, ...
    softmaxMatrix, wordFeatures, compositionMatrices, ...
    compositionMatrix, scoringVector, classifierExtraMatrix, embeddingTransformMatrix);

end

