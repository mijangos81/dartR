ped <- function(df_ped,
                n_loc=loci_number){
  # if(msats==2){ #if the neutral locus is biallelic, it is not deleted from the ped file 
    chromosome1 <- df_ped[3]
    chromosome2 <- df_ped[4]
  # }else{ #if the neutral locus has more than 2 alleles it is deleted from the ped file 
  #   chromosome1 <- gsub("[-^1-9]", "0", df_ped[3])
  #   chromosome2 <- gsub("[-^1-9]", "0", df_ped[4])
  # }
  split_seqs <- strsplit(c(chromosome1, chromosome2), split = "")
  genotypes <- as.data.frame(matrix(nrow =n_loc,ncol =2 ))
  genotypes$V1 <- split_seqs[[1]]
  genotypes$V2 <- split_seqs[[2]]
  genotypes_final <- paste0(paste(genotypes[,1],genotypes[,2]),collapse = " ")
  return(genotypes_final)
}

delta <- function(a, b, c) {
  # # Constructing delta
  b ^ 2 - 4 * a * c
}

q_equilibrium <- function(a, b, c) {
  # Constructing Quadratic Formula
  x_1 = (-b + sqrt(delta(a, b, c))) / (2 * a)
  return(x_1)
}

migration <- function(population1, population2, generation,pop_size = population_size,trans_gen=transfer_each_gen,male_tran=maletran,female_tran=femaletran,n_transfer=number_transfers) {
  if (generation != 1 & generation %% trans_gen == 0) {
    if(n_transfer == 1){
         if (male_tran) {
      malepoptran <- sample(c(1:(pop_size / 2)), size = 1)
      temppop1 <- population1[malepoptran,]
      temppop2 <- population2[malepoptran,]
      population2[malepoptran,] <- temppop1
      population1[malepoptran,] <- temppop2
    }
    if (female_tran) {
      fempoptran <-
        sample(c(((
          pop_size / 2
        ) + 1):pop_size), size = 1)
      temppop1 <- population1[fempoptran,]
      temppop2 <- population2[fempoptran,]
      population2[fempoptran,] <- temppop1
      population1[fempoptran,] <- temppop2
    }
    }
    if (n_transfer >= 2) {
         size_malepoptran <- ceiling(n_transfer/2)
    size_femalepoptran <- floor(n_transfer/2)
    if (male_tran) {
      malepoptran <- sample(c(1:(pop_size / 2)), size = size_malepoptran)
      temppop1 <- population1[malepoptran,]
      temppop2 <- population2[malepoptran,]
      population2[malepoptran,] <- temppop1
      population1[malepoptran,] <- temppop2
    }
    if (female_tran) {
      fempoptran <- sample(c(((pop_size / 2) + 1):pop_size), size = size_femalepoptran)
      temppop1 <- population1[fempoptran,]
      temppop2 <- population2[fempoptran,]
      population2[fempoptran,] <- temppop1
      population1[fempoptran,] <- temppop2
    }
    }
    # if necessary flip transfer
    if (n_transfer == 1) {
      male_tran <- !male_tran
      female_tran <- !female_tran
    }
  }
  return (list(population1, population2, male_tran, female_tran))
}

selection_fun <- function(offspring,reference_pop,sel_model=natural_selection_model) {
  offspring$fitness <- apply(offspring, 1, fitness, ref = reference_pop)
  if (sel_model=="absolute"){
  offspring$random_deviate <- runif(nrow(offspring),min = 0, max=genetic_load)
  offspring$alive <- offspring$fitness > offspring$random_deviate 
  offspring <- offspring[which(offspring$alive == TRUE), ]
   }
   if (sel_model=="relative"){
      fitnes_proportion <- sum(offspring$fitness)
      offspring$relative_fitness <- offspring$fitness / fitnes_proportion
      offspring$relative_fitness[offspring$relative_fitness<0] <- 0 
     }
  return(offspring)
}

# this is the function to calculate fitness
fitness <- function(df_fitness, 
                    ref) {
  #remove neutral loci from chromosomes
  chromosome1 <- gsub("[-^1-9]", "0", df_fitness[3])
  chromosome2 <- gsub("[-^1-9]", "0", df_fitness[4])
  split_seqs <- strsplit(c(chromosome1, chromosome2), split = "")
  ref$hom <- (split_seqs[[1]] == split_seqs[[2]] & split_seqs[[1]] == "a")
  ref$het_chr1 <- (split_seqs[[1]] == "a" & split_seqs[[2]] == "A")
  ref$het_chr2 <- (split_seqs[[1]] == "A" & split_seqs[[2]] == "a")
  ref$hom <- as.numeric(ref$hom)
  sum_hom <- sum(as.numeric(ref$hom))
  ref$het_chr1 <- as.numeric(ref$het_chr1)
  ref$het_chr2 <- as.numeric(ref$het_chr2)
  ref$het_sel_chr1 <- ref$h * ref$s * ref$het_chr1
  ref$het_sel_chr2 <- ref$h * ref$s * ref$het_chr2
  ref$hom_sel <- ref$s * ref$hom 
    ref$tot_sel <- ref$het_sel_chr1 + ref$het_sel_chr2 + ref$hom_sel
   ref$fitness <- 1 - (ref$tot_sel) 
  # keeping only loci with NS
  deleterious <- ref[ref$fitness<1,]
      net_fitness <- prod(deleterious$fitness)
  
  return(net_fitness)
}

reproduction <- function(pop, 
                         pop_number,
                         pop_size = population_size,
                         num_off=number_offspring,
                         r_map_1 = recombination_map,
                         n_loc=loci_number) {
  parents_matrix <- as.data.frame(matrix(nrow = pop_size / 2, ncol = 2))
  # select males and females that are mating with each other - males column 1 females column 2
  # 20% of males do not mate, 30% mate once, 30% mate twice and 20% mate three times according to
  # Markow & Sawka 1992
  male_pool <- sample(rownames(pop[1:(pop_size / 2), ]), size = pop_size / 2)
  no_mating <- sample(male_pool, size = (pop_size / 2) * 0.2)
  one_mating <- sample(male_pool[!male_pool %in% no_mating], size = (pop_size / 2) * 0.3)
  two_matings <- sample(male_pool[!male_pool %in% c(no_mating, one_mating)], size = (pop_size /2) * 0.3)
  three_matings <- sample(male_pool[!male_pool %in% c(no_mating, one_mating, two_matings)], size = (pop_size / 2) * 0.2)
  mating_males <- c(one_mating, rep(two_matings, times = 2),rep(three_matings, times = 3))
  parents_matrix[, 1] <- sample(mating_males, size = pop_size / 2)
  parents_matrix[, 2] <- sample(rownames(pop[((pop_size / 2) + 1):pop_size, ]), size =pop_size / 2)
  offspring <- NULL
  for (parent in 1:dim(parents_matrix)[1]) {
    pairing_offspring <- rnbinom(1, size = var_off, mu = num_off)
    offspring_temp <- as.data.frame(matrix(nrow = pairing_offspring, ncol = 6))
    if (pairing_offspring < 1) {
      next
    }
    offspring_temp[, 1] <- sample(c("Male", "Female"), size = pairing_offspring, replace = TRUE) # sex
    offspring_temp[, 2] <- pop_number # source population
    male_chromosomes <- list(pop[parents_matrix[parent, 1], 3], pop[parents_matrix[parent, 1], 4])
    female_chromosomes <- list(pop[parents_matrix[parent, 2], 3], pop[parents_matrix[parent, 2], 4])
    for (offs in 1:pairing_offspring) {
        males_recom_events <- rpois(1,r_event)
        females_recom_events <- rpois(1,r_event)
        #recombination in males
        if (recom == TRUE & r_males == TRUE & males_recom_events > 1){
          for (event in males_recom_events){male_chromosomes<-recomb(male_chromosomes[[1]],male_chromosomes[[2]],r_map = r_map_1,loci=n_loc)}
          offspring_temp[offs, 3] <- male_chromosomes[[sample(c(1, 2), 1)]]
        }else{offspring_temp[offs, 3] <- male_chromosomes[[sample(c(1, 2), 1)]]}
      #recombination in females
        if (recom == TRUE & females_recom_events > 1){
          for (event in females_recom_events){female_chromosomes<-recomb(female_chromosomes[[1]],female_chromosomes[[2]],r_map = r_map_1,loci=n_loc)}
      offspring_temp[offs, 4] <- female_chromosomes[[sample(c(1, 2), 1)]]
        }else{offspring_temp[offs, 4] <- female_chromosomes[[sample(c(1, 2), 1)]]}
        }
    offspring_temp[, 5] <- parents_matrix[parent, 1] #id father
    offspring_temp[, 6] <- parents_matrix[parent, 2] #id mother
    offspring <- rbind(offspring, offspring_temp)
    }
  return(offspring)
}

# this is the function for recombination
recomb <- function(r_chromosome1,r_chromosome2,r_map,loci){
    chiasma <- as.numeric(sample(row.names(r_map),size = 1,prob = r_map[, "c"]))
    if (chiasma < (loci + 1)) {
      split_seqs <- strsplit(c(r_chromosome1, r_chromosome2), split = "")
      r_chr1 <- paste0(c(split_seqs[[1]][1:chiasma], split_seqs[[2]][(chiasma + 1):loci]), collapse = "")
      r_chr2 <- paste0(c(split_seqs[[2]][1:chiasma], split_seqs[[1]][(chiasma + 1):loci]), collapse = "")
      return(list(r_chr1, r_chr2))
    } else{
      return(list(r_chromosome1, r_chromosome2))
    }
}

initialise <- function(pop_number,pop_size = population_size,refer=reference, n_l_loc = neutral_loci_location,exp_freq=experiment_freq,sim_type=simulation_type) {
  pop <- as.data.frame(matrix(ncol = 4, nrow = pop_size))
  pop[, 1] <- rep(c("Male", "Female"), each = pop_size / 2)
  pop[, 2] <- pop_number # second column stores population
  for (individual_pop in 1:pop_size) {
    chromosome1 <- paste0(mapply(sample_alleles, q = refer$q,  USE.NAMES = F),collapse = "")
    chromosome2 <- paste0(mapply(sample_alleles, q = refer$q,  USE.NAMES = F),collapse = "")
    for (element in n_l_loc) {
      substr(chromosome1, start = element, stop = element) <-
        sample(as.character(c(1:2)),size = 1,prob = c(rep(1 / 2, 2)))
      substr(chromosome2, start = element, stop = element) <-
        sample(as.character(c(1:2)), size = 1, prob = c(rep(1 / 2, 2)))
    }
    if(exp_freq == TRUE & sim_type=="fly"){
      counter_msats <- 1
    for (element in 1:length(loc_exp_loci_2)) {
      substr(chromosome1, start = as.numeric(loc_exp_loci_2[element]), stop = as.numeric(loc_exp_loci_2[element])) <- sample(as.character(c(1:length(msats_freq[[counter_msats]]))),size = 1,prob = msats_freq[[counter_msats]])
      substr(chromosome2, start = as.numeric(loc_exp_loci_2[element]), stop = as.numeric(loc_exp_loci_2[element])) <- sample(as.character(c(1:length(msats_freq[[counter_msats]]))),size = 1,prob = msats_freq[[counter_msats]])
      counter_msats <- counter_msats + 1
      }
    }
    pop[individual_pop, 3] <- chromosome1
    pop[individual_pop, 4] <- chromosome2
  }
  return(pop)
}

sample_alleles <- function(alleles = c("a", "A"), q) {
  sample(alleles, size = 1, prob = c(q, 1 - q))
}

reproduction_2 <- function(pop,
                           pop_number,
                           pop_size = population_size,
                           var_off=variance_offspring,
                           num_off=number_offspring,
                           r_event=recom_event,
                           recom=recombination,
                           r_males=recombination_males,
                           r_map_1 = recombination_map,
                           n_loc=loci_number) {
  parents_matrix <- as.data.frame(matrix(nrow = pop_size / 2, ncol = 2))
  # select males and females that are mating with each other - males column 1 females column 2
  # 20% of males do not mate, 30% mate once, 30% mate twice and 20% mate three times according to
  # Markow & Sawka 1992
  male_pool <- sample(rownames(pop[1:(pop_size / 2), ]), size = pop_size / 2)
  # no_mating <- sample(male_pool, size = (pop_size / 2) * 0.2)
  # one_mating <- sample(male_pool[!male_pool %in% no_mating], size = (pop_size / 2) * 0.3)
  # two_matings <- sample(male_pool[!male_pool %in% c(no_mating, one_mating)], size = (pop_size /2) * 0.3)
  # three_matings <- sample(male_pool[!male_pool %in% c(no_mating, one_mating, two_matings)], size = (pop_size / 2) * 0.2)
  # mating_males <- c(one_mating, rep(two_matings, times = 2),rep(three_matings, times = 3))
  parents_matrix[, 1] <- sample(male_pool, size = pop_size / 2)
  parents_matrix[, 2] <- sample(rownames(pop[((pop_size / 2) + 1):pop_size, ]), size =pop_size / 2)
  offspring <- NULL
  for (parent in 1:dim(parents_matrix)[1]) {
    pairing_offspring <-  rnbinom(1, size = var_off, mu = num_off)
    offspring_temp <- as.data.frame(matrix(nrow = pairing_offspring, ncol = 6))
    if (pairing_offspring < 1) {
      next
    }
    offspring_temp[, 1] <- sample(c("Male", "Female"), size = pairing_offspring, replace = TRUE) # sex
    offspring_temp[, 2] <- pop_number # source population
    male_chromosomes <- list(pop[parents_matrix[parent, 1], 3], pop[parents_matrix[parent, 1], 4])
    female_chromosomes <- list(pop[parents_matrix[parent, 2], 3], pop[parents_matrix[parent, 2], 4])
    for (offs in 1:pairing_offspring) {
        males_recom_events <- rpois(1,r_event)
        females_recom_events <- rpois(1,r_event)
        #recombination in males
        if (recom == TRUE & r_males == TRUE & males_recom_events > 1){
          for (event in males_recom_events){male_chromosomes<-recomb(male_chromosomes[[1]],male_chromosomes[[2]],r_map = r_map_1,loci=n_loc)}
          offspring_temp[offs, 3] <- male_chromosomes[[sample(c(1, 2), 1)]]
        }else{offspring_temp[offs, 3] <- male_chromosomes[[sample(c(1, 2), 1)]]}
      #recombination in females
        if (recom == TRUE & females_recom_events > 1){
          for (event in females_recom_events){female_chromosomes<-recomb(female_chromosomes[[1]],female_chromosomes[[2]],r_map = r_map_1,loci=n_loc)}
      offspring_temp[offs, 4] <- female_chromosomes[[sample(c(1, 2), 1)]]
        }else{offspring_temp[offs, 4] <- female_chromosomes[[sample(c(1, 2), 1)]]}
        }
    offspring_temp[, 5] <- parents_matrix[parent, 1] #id father
    offspring_temp[, 6] <- parents_matrix[parent, 2] #id mother
    offspring <- rbind(offspring, offspring_temp)
    }
  return(offspring)
}


