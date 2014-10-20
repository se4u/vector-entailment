function [ modelState ] = TrainOnDataset(CostGradFunc, trainingData, testDatasets, modelState, hyperParams, options, filename)

N = length(trainingData);
numBatches = ceil(N/options.miniBatchSize);
randomOrder = randperm(N);

for batchNo = 0:(numBatches-1)
    beginMiniBatch = (batchNo * options.miniBatchSize+1);
    endMiniBatch = (batchNo+1) * options.miniBatchSize;

    % Don't bother with the last few examples if they don't make up a full minibatch. 
    % They'll be reshuffled in the next pass.
    if endMiniBatch > N
        return
    end

    batchInd = randomOrder(beginMiniBatch:endMiniBatch);
    batch = trainingData(batchInd);

    [ cost, grad ] = CostGradFunc(modelState.theta, modelState.thetaDecoder, batch, modelState.constWordFeatures, hyperParams);
    modelState.sumSqGrad = modelState.sumSqGrad + grad.^2;

    % Do an AdaGrad-scaled parameter update
    adaEps = 0.001;
    modelState.theta = modelState.theta - modelState.lr * (grad ./ (sqrt(modelState.sumSqGrad) + adaEps));
    modelState.step = modelState.step + 1;
    modelState.lastHundredCosts(mod(modelState.step, 100) + 1) = cost(1);

    modelState = TestAndLog(CostGradFunc, modelState, options, trainingData, ...
        hyperParams, testDatasets);
end

end