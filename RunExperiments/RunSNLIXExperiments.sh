# USAGE:
# ./RunALCIRExperiments.sh train-snli-test-snli # This is already trained.
# ./RunALCIRExperiments.sh train-dpr-test-dpr
# ./RunSNLIXExperiments.sh train-fnplus-test-fnplus
# ./RunSNLIXExperiments.sh train-sprl-test-sprl
# ./RunSNLIXExperiments.sh train-snli.sprl-test-snli
# ./RunSNLIXExperiments.sh train-snli.dpr-test-snli
# ./RunSNLIXExperiments.sh train-snli.fnplus-test-snli
# ./RunSNLIXExperiments.sh train-snli.sprl.dpr.fnplus-test-snli
# This can be put on q by replacing ./ by fq
# fq is an alias ='qsub -V -j y -l mem_free=5G,hostname=a14 -cwd '

set -e
export COMMON="cd /home/prastog3/projects/lexical_replacement_as_entailment/submodule/vector-entailment; lambda = 0.0001; dim = 100; embDim = 300; topDepth = 3; penultDim = 200; dropout = [0.9, 0.9]; composition = -1; wordsource = 3; loadwords=true; warning('off', 'MATLAB:catenate:DimensionMismatch')"
export COMMON2="TrainModel('', 1, @SNLI, expName, dataflag, embDim, dim, topDepth, penultDim, lambda, composition, dropout(1), dropout(2), wordsource, 1, 5, 5, loadwords);"
export DATAFLAG=${1-train-dpr-test-dpr}
export MATLABCMD="${COMMON}; dataflag='${DATAFLAG}'; expName='/export/a14/prastog3/lrae/exp-${DATAFLAG}'; ${COMMON2}"
echo $MATLABCMD
matlab -r "${MATLABCMD}"
