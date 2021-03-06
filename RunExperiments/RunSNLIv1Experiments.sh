# TrainModel(pretrainingFilename, fold, ConfigFn, varargin)
# TrainModel('', 1, SNLI, ...)
# expName : just a name of the xperiment.
# lambda : the regularization constant.
# composition == -1
# 	hyperParams.useTrees = 0;
#	hyperParams.useThirdOrderComposition = 0;
#	hyperParams.useThirdOrderMerge = 0;
#	hyperParams.useSumming = 1;
# gc :  means gradient clipping.
# lstminit : lstm initialization.
export EXPNAME=snli-v1-trial4
export DATAFLAG=snli-v1 # Determines The train - dev - test files used.
export WORDSOURCE=3 # Determines the embeddings used.
export LOADWORDS=true # Should I load word embeddings?

# SNLI(expName, dataflag, embDim, dim, topDepth, penultDim, lambda, ...
#      composition, dropout(1), dropout(2), wordsource, 1, 5, 5)
# SNLI(expName, dataflag, embDim, dim, topDepth, penultDim, lambda, ...
#      composition, bottomDropout, topDropout, wordsource, dataPortion, gc, lstminit);
# FAST debug options.
# export DATAFLAG=toydata
# export LOADWORDS=false

export MATLABCMD="cd /home/prastog3/projects/lexical_replacement_as_entailment/submodule/vector-entailment; lambda = 0.0001; dim = 100; embDim = 300; topDepth = 3; penultDim = 200; dropout = [0.9, 0.9]; composition = -1; wordsource = ${WORDSOURCE}; dataflag='${DATAFLAG}'; expName='${EXPNAME}'; loadwords=${LOADWORDS}; warning('off', 'MATLAB:catenate:DimensionMismatch'); dbstop if error; TrainModel('', 1, @SNLI, expName, dataflag, embDim, dim, topDepth, penultDim, lambda, composition, dropout(1), dropout(2), wordsource, 1, 5, 5, loadwords);"
echo $MATLABCMD
matlab -r "${MATLABCMD}"
