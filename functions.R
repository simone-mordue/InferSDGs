
# all functions for using MALLET's topic-inference functionality: given an
# existing topic model, estimate topic proportions for new documents


read_inferencer <- function (in_file) {
  J("cc.mallet.topics.TopicInferencer")$read(
    new(J("java.io.File"), in_file)
  )
}


infer_topics <- function (inferencer, instances,
                          n_iterations=100,
                          sampling_interval=10, # aka "thinning"
                          burn_in=10,
                          random_seed=NULL) {
  
  iter <- instances$iterator()
  n_iterations <- as.integer(n_iterations)
  sampling_interval <- as.integer(sampling_interval)
  burn_in <- as.integer(burn_in)
  if (!is.null(random_seed)) {
    inferencer$setRandomSeed(as.integer(random.seed))
  }
  
  doc_topics <- vector("list", instances$size())
  for (j in 1:instances$size()) {
    inst <- .jcall(iter, "Ljava/lang/Object;", "next")
    doc_topics[[j]] <- inferencer$getSampledDistribution(inst,
                                                         n_iterations, sampling_interval, burn_in)
  }
  
  do.call(rbind, doc_topics)
}



compatible_instances <- function (ids, texts, instances) {
  mallet_pipe <- instances$getPipe()
  
  new_insts <- .jnew("cc/mallet/types/InstanceList",
                     .jcast(mallet_pipe, "cc/mallet/pipe/Pipe"))
  
  J("cc/mallet/topics/RTopicModel")$addInstances(new_insts, ids, texts)
  
  new_insts
}

