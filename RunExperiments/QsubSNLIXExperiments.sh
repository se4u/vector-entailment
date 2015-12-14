# V is for verbose
# j y means merge stdout and stderr
myqsub () { qsub -V -j y -l mem_free=20G,hostname=$1 -cwd RunSNLIXExperiments.sh ${2-train-dpr-test-dpr} ; }

# myqsub a15 train-snli-test-snli
# myqsub a15 train-dpr-test-dpr
# myqsub a11 train-fnplus-test-fnplus
# myqsub a12 train-sprl-test-sprl
# myqsub a13 train-snli.sprl-test-snli
# myqsub a15 train-snli.dpr-test-snli
# myqsub a17 train-snli.fnplus-test-snli
# myqsub a18 train-snli.sprl.dpr.fnplus-test-snli


# job-ID  prior   name       user         state submit/start at     queue
# -------------------------------------------------------------------------------
# 7051527 0.50984 RunSNLIXEx prastog3     r     12/14/2015 14:18:15 all.q@a11.
# 7051528 0.50984 RunSNLIXEx prastog3     r     12/14/2015 14:18:15 all.q@a12.
# 7051938 0.50255 RunSNLIXEx prastog3     r     12/14/2015 14:49:40 all.q@a13.
# 7051939 0.50255 RunSNLIXEx prastog3     r     12/14/2015 14:49:40 all.q@a15.
# 7051940 0.50255 RunSNLIXEx prastog3     r     12/14/2015 14:49:40 all.q@a17.
# 7051941 0.50255 RunSNLIXEx prastog3     r     12/14/2015 14:49:40 all.q@a18.
