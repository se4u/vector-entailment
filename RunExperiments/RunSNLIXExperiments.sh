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
# SNLI(expName, dataflag, embDim, dim, topDepth, penultDim, lambda, ...
#      composition, dropout(1), dropout(2), wordsource, 1, 5, 5)
# SNLI(expName, dataflag, embDim, dim, topDepth, penultDim, lambda, ...
#      composition, bottomDropout, topDropout, wordsource, dataPortion, gc, lstminit);
# FAST debug options.
# export DATAFLAG=toydata
# export LOADWORDS=false
set -ex
export COMMON="cd /home/prastog3/projects/lexical_replacement_as_entailment/submodule/vector-entailment; lambda = 0.0001; dim = 100; embDim = 300; topDepth = 3; penultDim = 200; dropout = [0.9, 0.9]; composition = -1; wordsource = 3; loadwords=true; warning('off', 'MATLAB:catenate:DimensionMismatch')"
export COMMON2="TrainModel('', 1, @SNLI, expName, dataflag, embDim, dim, topDepth, penultDim, lambda, composition, dropout(1), dropout(2), wordsource, 1, 5, 5, loadwords);"

export DATAFLAG=${1:train-dpr-test-dpr}
export MATLABCMD="${COMMON}; dataflag='${DATAFLAG}'; expName='/export/a14/prastog3/lrae/exp-${DATAFLAG}'; ${COMMON2}"
echo $MATLABCMD
echo matlab -r "${MATLABCMD}"
