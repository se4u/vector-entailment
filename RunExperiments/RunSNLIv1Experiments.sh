# SNLI(expName, dataflag, embDim, dim, topDepth, penultDim, lambda, composition, dropout(1), dropout(2), wordsource, 1, 5, 5)
# SNLI(expName, dataflag, embDim, dim, topDepth, penultDim, lambda, composition, bottomDropout, topDropout, wordsource, dataPortion, gc, lstminit)

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
# Move -> Truncate -> Tokenize and lowercase -> Make vocabulary.
# for f in snli_1.0_[td].txt; do mv $f $f.orig; done
# for f in snli_1.0_[td]*orig; do awk -F'\t' '{print $1, "\t", $6, "\t", $7}' $f > ${f%.orig}.truncated; done
# for f in snli_1.0_*truncated; do cat $f | python -c 'from rasengan import *; tknzr = get_tokenizer(); process_columns(lambda x:(" ".join(tknzr(x))).lower(), 2, 3, ifs="\t")' > ${f%.truncated} ; done
# cat snli_1.0_[dt]*.txt | awk -F'\t' '{if(NR>1){print $2; print $3}}' | python -c 'from rasengan import pipeline_dictionary; pipeline_dictionary()' > snli_1.0_words.txt
export EXPNAME=snli-v1-trial1
export DATAFLAG=snli-v1 # Determines The train - dev - test files used.
export WORDSOURCE=4 # Determines the embeddings used.
export LOADWORDS=false # Should I load word embeddings?
echo 'REMEMBER TO SET LOADWORDS TO TRUE !!!!!!!!'
export MATLABCMD="cd /home/prastog3/projects/lexical_replacement_as_entailment/submodule/vector-entailment; lambda = 0.0001; dim = 100; embDim = 300; topDepth = 3; penultDim = 200; dropout = [0.9, 0.9]; composition = -1; wordsource = ${WORDSOURCE}; dataflag='${DATAFLAG}'; expName='${EXPNAME}'; loadwords=${LOADWORDS}; dbstop if error; TrainModel('', 1, @SNLI, expName, dataflag, embDim, dim, topDepth, penultDim, lambda, composition, dropout(1), dropout(2), wordsource, 1, 5, 5, loadwords);"
echo $MATLABCMD
matlab -r "${MATLABCMD}"
