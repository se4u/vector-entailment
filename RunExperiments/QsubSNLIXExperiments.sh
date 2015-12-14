# V is for verbose
# j y means merge stdout and stderr
myqsub () { qsub -V -j y -l mem_free=20G,hostname=$1 -cwd RunSNLIXExperiments.sh ${2-train-dpr-test-dpr} ; }

# myqsub a15 train-snli-test-snli
# myqsub a15 train-dpr-test-dpr
myqsub a11 train-fnplus-test-fnplus
myqsub a12 train-sprl-test-sprl
# myqsub a13 train-snli.sprl-test-snli
# myqsub a15 train-snli.dpr-test-snli
# myqsub a17 train-snli.fnplus-test-snli
# myqsub a18 train-snli.sprl.dpr.fnplus-test-snli
