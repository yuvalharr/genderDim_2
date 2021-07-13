library(data.table)
library(ggplot2)
theme_set(theme_bw())
library(rjson)
library(ez)
library(plyr)
library(Hmisc)


# Open data ----
#first exp
#setwd ("C:/Users/User/Desktop/GenderDim_Analysis/Data") #lab pc
setwd ("C:/Users/yuval/Desktop/lab/data/data") #laptop
dataFrom <- '20180725'
brms2 <- fread(paste(dataFrom, 'brms.csv', sep= ''))
quest2 <- fread(paste(dataFrom, 'questionnaire.csv', sep= ''))
event2 <- fread(paste(dataFrom, 'eventdata.csv', sep= ''))
jsevent2 <- fread(paste(dataFrom, 'jseventdata.csv', sep= ''))

#second exp
setwd ("C:/Users/yuval/Desktop/lab/data2/220919") #laptop

temp = list.files(pattern="*.csv") # makes a list of all csv file names in current dir
allData = rbindlist(lapply(temp, fread), fill = T) # reads all csv files to one dt
brms = allData[trial_type == 'bRMS',]
quest = allData[trial_type != 'bRMS',]

#combine both brms
#brms <- rbind(brms,brms2, fill = T)
#quest <- rbind(quest, quest2, fill = T)


#event <- fread(paste(dataFrom, 'eventdata.csv', sep= ''))     #no use for now
#jsevent <- fread(paste(dataFrom, 'jseventdata.csv', sep= '')) #no use for now

female_params <- fread('../faces/300female_coord_allparams.csv')  #remember to remove '../' if needed
male_params <- fread('../faces/300male_coord_allparams.csv')
social_dims <- fread('../faces/si-genders.csv')

yanivs_face_params <- fread(paste('../faces/oosterhof_todorov_300_faces_component_values.csv', sep= ''))
yanivs_face_params <- yanivs_face_params[,1:50]
yanivs_dims <- fread(paste('../faces/yaniv_dims_priority_trust_dom.csv', sep= ''))
yanivs_raw_dims <- fread(paste('../faces/yanivs_raw_social_dims.csv', sep= ''))

# Prepare data ----
brms$rt <- as.numeric(brms$rt)
brms$uniqueid <- factor(brms$uniqueid)
brms[, stim_gender := factor(substring(stimulus, 18,18))]
summary(brms)

brms2$rt <- as.numeric(brms2$rt)
brms2$uniqueid <- factor(brms2$uniqueid)
brms2[, stim_gender := factor(substring(stimulus, 18,18))]
summary(brms2)

# Discard training trials
brms <- brms[!(is.na(trial))]
brms2 <- brms2[!(is.na(trial))]


# Keep only subjects who completed the task
trialCount <- brms[, .(trials = .N), by = uniqueid]
trialCount <- trialCount[trials >= 200]
brms <- brms[uniqueid %in% trialCount$uniqueid]
quest <- quest[uniqueid %in% trialCount$uniqueid]
#event <- event[uniqueid %in% trialCount$uniqueid]
#jsevent <- jsevent[uniqueid %in% trialCount$uniqueid]

trialCount2 <- brms2[, .(trials = .N), by = uniqueid]
trialCount2 <- trialCount2[trials >= 200]
brms2 <- brms2[uniqueid %in% trialCount2$uniqueid]
quest2 <- quest2[uniqueid %in% trialCount2$uniqueid]
#event <- event[uniqueid %in% trialCount$uniqueid]
#jsevent <- jsevent[uniqueid %in% trialCount$uniqueid]

# Extract demographics ----
# Get only questions
dems <- subset(quest, grepl("survey", trial_type, fixed = TRUE))

dems2 <- subset(quest2, grepl("survey", trial_type, fixed = TRUE))

# Fix for JSON parsing
dems$responses <- gsub('\"\"', '\"', dems$responses)
dems$responses <- gsub(':\"}', ':\"\"}', dems$responses)

dems2$responses <- gsub('\"\"', '\"', dems2$responses)
dems2$responses <- gsub(':\"}', ':\"\"}', dems2$responses)

# Parse JSON responses
dems <- dems[, .(age = as.numeric(fromJSON(responses[internal_node_id == '0.0-11.0'])$Q0),
                 attn_deficit = fromJSON(responses[internal_node_id == '0.0-11.0'])$Q1,
                 gender = fromJSON(responses[internal_node_id == '0.0-12.0'])$Q0,
                 hand = fromJSON(responses[internal_node_id == '0.0-12.0'])$Q1,
                 native = fromJSON(responses[internal_node_id == '0.0-12.0'])$Q2,
                 fluency = as.numeric(fromJSON(responses[internal_node_id == '0.0-13.0'])),
                 strategy = fromJSON(responses[internal_node_id == '0.0-14.0'])$Q0,
                 sexuality = fromJSON(responses[internal_node_id == '0.0-15.0'])$Q0,
                 attracted = fromJSON(responses[internal_node_id == '0.0-15.0'])$Q1),
             #q1 = fromJSON(responses[question == 'q1'])$Q0,
             #q2 = fromJSON(responses[question == 'q2'])$Q0,
             #q3 = fromJSON(responses[question == 'q3'])$Q0,
             #q4 = fromJSON(responses[question == 'q4'])$Q0,
             #q5 = fromJSON(responses[question == 'q5'])$Q0,
             #q6 = fromJSON(responses[question == 'q6'])$Q0),
             by = .(uniqueid)]
#dems[!(is.na(driving_ability_text)), c('driving_ability', 'accidents_driver') := 
#       list(as.numeric(fromJSON(driving_ability_text)), as.numeric(fromJSON(accidents_driver_text))), 
#     by = uniqueid]

dems2 <- dems2[, .(age = as.numeric(fromJSON(responses[internal_node_id == '0.0-10.0'])$Q0),
                   attn_deficit = fromJSON(responses[internal_node_id == '0.0-10.0'])$Q1,
                   gender = fromJSON(responses[internal_node_id == '0.0-11.0'])$Q0,
                   hand = fromJSON(responses[internal_node_id == '0.0-11.0'])$Q1,
                   native = fromJSON(responses[internal_node_id == '0.0-11.0'])$Q2,
                   fluency = as.numeric(fromJSON(responses[internal_node_id == '0.0-12.0'])),
                   strategy = fromJSON(responses[internal_node_id == '0.0-13.0'])$Q0,
                   sexuality = fromJSON(responses[internal_node_id == '0.0-14.0'])$Q0,
                   attracted = fromJSON(responses[internal_node_id == '0.0-14.0'])$Q1),
               #q1 = fromJSON(responses[question == 'q1'])$Q0,
               #q2 = fromJSON(responses[question == 'q2'])$Q0,
               #q3 = fromJSON(responses[question == 'q3'])$Q0,
               #q4 = fromJSON(responses[question == 'q4'])$Q0,
               #q5 = fromJSON(responses[question == 'q5'])$Q0,
               #q6 = fromJSON(responses[question == 'q6'])$Q0),
               by = .(uniqueid)]
#dems[!(is.na(driving_ability_text)), c('driving_ability', 'accidents_driver') := 
#       list(as.numeric(fromJSON(driving_ability_text)), as.numeric(fromJSON(accidents_driver_text))), 
#     by = uniqueid]

dems$uniqueid <- factor(dems$uniqueid)
dems$hand <- factor(dems$hand)
dems$driver <- factor(dems$driver)
dems$gender <- factor(dems$gender)
dems$native <- factor(dems$native)
dems$sexuality <- factor(dems$sexuality)
dems$attracted <- factor(dems$attracted)
dems$question <- factor(dems$question)

dems2$uniqueid <- factor(dems2$uniqueid)
dems2$hand <- factor(dems2$hand)
dems2$driver <- factor(dems2$driver)
dems2$gender <- factor(dems2$gender)
dems2$native <- factor(dems2$native)
dems2$sexuality <- factor(dems2$sexuality)
dems2$attracted <- factor(dems2$attracted)
dems2$question <- factor(dems2$question)

#dems[, z_death_penalty := scale(-1 * politics_death_penalty)]
#dems[, z_environment := scale(-1 * politics_environment)]
#dems[, z_iraq := scale(politics_iraq)]
#dems[, z_gays := scale(politics_gays)]
#dems[, z_guns := scale(politics_guns)]
#dems[, z_stemcells := scale(politics_stemcells)]
#dems[, z_abortion := scale(politics_abortion)]
#dems[, z_affirmative_action := scale(politics_affirmative_action)]

#dems$politics_overall_avg <- dems[, .((politics_iraq + politics_gays + politics_guns + politics_stemcells + politics_abortion +
#                                politics_affirmative_action - politics_death_penalty - politics_environment) / 8)]

#dems$politics_z_avg <- dems[, .((z_iraq + z_gays + z_guns + z_stemcells + z_abortion +
#                                         z_affirmative_action + z_death_penalty + z_environment) / 8)]

#combine experiments

common_cols <- intersect(colnames(brms), colnames(brms2))
brms <- rbind(
  subset(brms, select = common_cols), 
  subset(brms2, select = common_cols)
)

common_cols <- intersect(colnames(dems), colnames(dems2))
dems <- rbind(
  subset(dems, select = common_cols), 
  subset(dems2, select = common_cols)
)

summary(dems)
summary(brms)
sd(dems$age, na.rm = TRUE) #age sd

ggplot(dems, aes(x = age)) +
  geom_histogram(bins = 15)

# Clean brms data ----
# Keep only trials with good animation
brms <- brms[bProblem == 0 & sProblem < 5]

# drop subjects that have less then 160 good animation trials
trialCount <- brms[, .(trials = .N), by = uniqueid]
trialCount <- trialCount[trials >= 160]
brms <- brms[uniqueid %in% trialCount$uniqueid]

# Keep only correct trials
brms <- brms[acc == 1]

# Exclude short trials
brms <- brms[rt > 200]

# Exclude long trials
brms <- brms[rt < 15000]

#ggplot(brms, aes(x = rt)) +
#  geom_histogram(bins = 50) +
#  facet_wrap('uniqueid', scales = 'free_x')

# Exclude outlier trials per subject

brms[, zrt := scale(rt), by = uniqueid]  #ask yaniv: should i scale again after removing extreme z scores?
brms <- brms[abs(zrt) < 3]
#brms[, zrt := scale(rt), by = uniqueid] #another scale after removal- not used in this exp.

#ggplot(brms, aes(x = rt)) +
#  geom_histogram(bins = 50) +
#  facet_wrap('uniqueid', scales = 'free_x')

# Plot BTs ----

mBT <- brms[, .(BT = mean(rt)), by = uniqueid]
ggplot(mBT, aes(x = BT)) +
  geom_histogram(bins = 15)

mBT <- merge(mBT, dems)

ggplot(mBT, aes(x = age, y = BT)) +
  geom_point() +
  geom_smooth(method='lm')+
  labs(x = "participant age", y = "average BT")

cor.test(mBT$BT, mBT$age)


#ggplot(mBT, aes(x = politics_z_avg, y = BT)) +
# geom_point() +
#geom_smooth(method='lm')

#cor.test(mBT$BT, mBT$politics_z_avg)


#ggplot(mBT, aes(x = age, y = politics_z_avg)) +
# geom_point() +
#geom_smooth(method='lm')

# cor.test(mBT$age, mBT$politics_z_avg)


ggplot(mBT[, .(BT = mean(BT),
               se = sd(BT) / sqrt(.N)), 
           by = gender], aes(x = gender, y = BT, ymin = BT - se, ymax = BT + se)) +
  geom_pointrange(size = 1) +
  labs(x = "participants gender", y = "average BT", tag = "a")

t.test(BT ~ gender, mBT)

# Plot Faces ----

# check that there are enough trials for each face
stimuluscount <- brms[, .(trials = .N), by = stimulus]
stimuluscount <- stimuluscount[order(trials)]

ggplot(stimuluscount, aes(x = trials)) +
  geom_histogram(bins = 30)


#make 'stimuli' D.T for faces. **ask yaniv if there is a need to make the collumns factors with levels.**
stimuli <- brms[,.(mean_BT = mean(rt)), by = stimulus]
mZT <- brms[,.(mean_Z = mean(zrt)), by = stimulus]
stimuli <- merge(stimuli, mZT)
stimuli <- merge(stimuli, stimuluscount)
stimuli <- stimuli[order(mean_BT)]

ggplot(stimuli, aes(x = mean_BT)) +
  geom_histogram(bins = 50)  #how many faces have each mean_BT?

stimuli_gender <- brms[,.(stimulus_id = substring(stimulus,18,21)), by = stimulus]   #add id num for each face
stimuli_gender <- stimuli_gender[, .(stim_gender = substring(stimulus,18,18), stimulus_id), by = stimulus]  #add stim_gender

stimuli <- merge(stimuli_gender, stimuli)


stimuli$stim_gender <- as.factor(stimuli$stim_gender)
stimuli$stimulus_id <- as.factor(stimuli$stimulus_id)

#check for global differences between male and female stimuli
levels(stimuli$stim_gender) <- c(levels(stimuli$stim_gender), "Female", "Male") 
stimuli$stim_gender[stimuli$stim_gender == "m"] <- "Male"
stimuli$stim_gender[stimuli$stim_gender == "f"] <- "Female"

ggplot(stimuli[, .(mean_BT = mean(mean_BT),
                   se = sd(mean_BT) / sqrt(.N)), 
               by = stim_gender], aes(x = stim_gender, y = mean_BT, ymin = mean_BT - se, ymax = mean_BT + se)) +
  geom_pointrange(size = 1) +
  labs(x = "stimuli gender", y = "average BT", tag = "b")

stimuli$stim_gender[stimuli$stim_gender == "Male"] <- "m"
stimuli$stim_gender[stimuli$stim_gender == "Female"] <- "f"

t.test(mean_BT ~ stim_gender, stimuli)


#global correlation between BT and dominance/trustworthiness
#ggplot(stimuli, aes(x = Power, y = mean_BT)) +
#geom_point() +
#geom_smooth(method='lm')


#cor.test(stimuli$mean_BT, stimuli$Power)

#ggplot(stimuli, aes(x = Valence, y = mean_BT)) +
#geom_point() +
# geom_smooth(method='lm')


#cor.test(stimuli$mean_BT, stimuli$Valence)


#merge female and male stimuli to one df
stimuli$stim_gender <- NULL
stimuli_F <- stimuli[1:300]   ###remember to return to 1:300 !!!!
stimuli_F[, stimulus_id := factor(substring(stimulus_id, 2,4))]

stimuli_M <- stimuli[301:600]  ### remember to return to 301:600!!!!!!!!!
stimuli_M[, stimulus_id := factor(substring(stimulus_id, 2,4))]


stimuli <- merge(stimuli_F, stimuli_M, by = "stimulus_id")
colnames(stimuli) <- gsub('.x','.F',names(stimuli))
colnames(stimuli) <- gsub('.y','.M',names(stimuli))

#by group correlation between BT and dominance/trustworthiness

brms <- merge(brms, dems[ , c("uniqueid", "gender")], by = "uniqueid") #add participants gender to brms

#fXf
fXf_brms <- brms[gender == "Female" & stim_gender == "f",]
fXf_stimuli <- fXf_brms[,.(fXf_mBT = mean(rt)), by = stimulus]
fXf_mZ <- fXf_brms[,.(fXf_mean_Z = mean(zrt)), by = stimulus]
fXf_stimuli <- merge(fXf_stimuli, fXf_mZ)
fXf_stimuli[, stimulus_id := factor(substring(stimulus, 19,21))]
stimuli <- merge(stimuli, fXf_stimuli[ , c("stimulus_id", "fXf_mBT","fXf_mean_Z")], by = "stimulus_id", all.x = TRUE)

vec_factor <- as.factor(sample(c(0,1), replace=T, size=198))
brms$factor<-vec_factor[rleid(brms$uniqueid)]

group0Xf_brms <- brms[stim_gender == "f" & factor == 0,]
group0Xf_stimuli <- group0Xf_brms[,.(group0Xf_mBT = mean(rt)), by = stimulus]
group0Xf_mZ <- group0Xf_brms[,.(group0Xf_mean_Z = mean(zrt)), by = stimulus]
group0Xf_stimuli <- merge(group0Xf_stimuli, group0Xf_mZ)
group0Xf_stimuli[, stimulus_id := factor(substring(stimulus, 19,21))]
stimuli <- merge(stimuli, group0Xf_stimuli[ , c("stimulus_id", "group0Xf_mBT","group0Xf_mean_Z")], by = "stimulus_id", all.x = TRUE)

group1Xf_brms <- brms[stim_gender == "f" & factor == 1,]
group1Xf_stimuli <- group1Xf_brms[,.(group1Xf_mBT = mean(rt)), by = stimulus]
group1Xf_mZ <- group1Xf_brms[,.(group1Xf_mean_Z = mean(zrt)), by = stimulus]
group1Xf_stimuli <- merge(group1Xf_stimuli, group1Xf_mZ)
group1Xf_stimuli[, stimulus_id := factor(substring(stimulus, 19,21))]
stimuli <- merge(stimuli, group1Xf_stimuli[ , c("stimulus_id", "group1Xf_mBT","group1Xf_mean_Z")], by = "stimulus_id", all.x = TRUE)

#ggplot(stimuli, aes(x = Power, y = fXf_mBT)) +
# geom_point() +
#geom_smooth(method='lm')


#cor.test(stimuli$fXf_mBT, stimuli$Power)

#ggplot(stimuli, aes(x = Valence, y = fXf_mBT)) +
# geom_point() +
#geom_smooth(method='lm')


#cor.test(stimuli$fXf_mBT, stimuli$Valence)

#ggplot(stimuli, aes(x = Power, y = fXf_mean_Z)) +
# geom_point() +
#geom_smooth(method='lm')


# cor.test(stimuli$fXf_mean_Z, stimuli$Power)

#ggplot(stimuli, aes(x = Valence, y = fXf_mean_Z)) +
# geom_point() +
#geom_smooth(method='lm')


#cor.test(stimuli$fXf_mean_Z, stimuli$Valence)

#mXf
mXf_brms <- brms[gender == "Male" & stim_gender == "f",]
mXf_stimuli <- mXf_brms[,.(mXf_mBT = mean(rt)), by = stimulus]
mXf_mZ <- mXf_brms[,.(mXf_mean_Z = mean(zrt)), by = stimulus]
mXf_stimuli <- merge(mXf_stimuli, mXf_mZ)
mXf_stimuli[, stimulus_id := factor(substring(stimulus, 19,21))] 
stimuli <- merge(stimuli, mXf_stimuli[ , c("stimulus_id", "mXf_mBT", "mXf_mean_Z")], by = "stimulus_id", all.x = TRUE)

#ggplot(stimuli, aes(x = Power, y = mXf_mBT)) +
# geom_point() +
#geom_smooth(method='lm')

#cor.test(stimuli$mXf_mBT, stimuli$Power)

#ggplot(stimuli, aes(x = Valence, y = mXf_mBT)) +
# geom_point() +
#geom_smooth(method='lm')

#cor.test(stimuli$mXf_mBT, stimuli$Valence)

#ggplot(stimuli, aes(x = Power, y = mXf_mean_Z)) +
# geom_point() +
#geom_smooth(method='lm')

#cor.test(stimuli$mXf_mean_Z, stimuli$Power)

#ggplot(stimuli, aes(x = Valence, y = mXf_mean_Z)) +
# geom_point() +
#geom_smooth(method='lm')

#cor.test(stimuli$mXf_mean_Z, stimuli$Valence)

#mXm
mXm_brms <- brms[gender == "Male" & stim_gender == "m",]
mXm_stimuli <- mXm_brms[,.(mXm_mBT = mean(rt)), by = stimulus]
mXm_mZ <- mXm_brms[,.(mXm_mean_Z = mean(zrt)), by = stimulus]
mXm_stimuli <- merge(mXm_stimuli, mXm_mZ)
mXm_stimuli[, stimulus_id := factor(substring(stimulus, 19,21))]
stimuli <- merge(stimuli, mXm_stimuli[ , c("stimulus_id", "mXm_mBT", "mXm_mean_Z")], by = "stimulus_id", all.x = TRUE)

#ggplot(stimuli, aes(x = Power, y = mXm_mBT)) +
# geom_point() +
#geom_smooth(method='lm')


#cor.test(stimuli$mXm_mBT, stimuli$Power)

#ggplot(stimuli, aes(x = Valence, y = mXm_mBT)) +
# geom_point() +
#geom_smooth(method='lm')


#cor.test(stimuli$mXm_mBT, stimuli$Valence)

#ggplot(stimuli, aes(x = Power, y = mXm_mean_Z)) +
# geom_point() +
#geom_smooth(method='lm')


#cor.test(stimuli$mXm_mean_Z, stimuli$Power)

#ggplot(stimuli, aes(x = Valence, y = mXm_mean_Z)) +
# geom_point() +
#geom_smooth(method='lm')


#cor.test(stimuli$mXm_mean_Z, stimuli$Valence)

#fXm
fXm_brms <- brms[gender == "Female" & stim_gender == "m",]
fXm_stimuli <- fXm_brms[,.(fXm_mBT = mean(rt)), by = stimulus]
fXm_mZ <- fXm_brms[,.(fXm_mean_Z = mean(zrt)), by = stimulus]
fXm_stimuli <- merge(fXm_stimuli, fXm_mZ)
fXm_stimuli[, stimulus_id := factor(substring(stimulus, 19,21))]
stimuli <- merge(stimuli, fXm_stimuli[ , c("stimulus_id", "fXm_mBT", "fXm_mean_Z")], by = "stimulus_id", all.x = TRUE)

#ggplot(stimuli, aes(x = Power, y = fXm_mBT)) +
# geom_point() +
#geom_smooth(method='lm')


#cor.test(stimuli$fXm_mBT, stimuli$Power)

#ggplot(stimuli, aes(x = Valence, y = fXm_mBT)) +
# geom_point() +
#geom_smooth(method='lm')


#cor.test(stimuli$fXm_mBT, stimuli$Valence)

#ggplot(stimuli, aes(x = Power, y = fXm_mean_Z)) +
# geom_point() +
#geom_smooth(method='lm')


# cor.test(stimuli$fXm_mean_Z, stimuli$Power)

#ggplot(stimuli, aes(x = Valence, y = fXm_mean_Z)) +
# geom_point() +
#geom_smooth(method='lm')


#cor.test(stimuli$fXm_mean_Z, stimuli$Valence)


# reverse correlation ----

female_params <- female_params[2:301,2:51]
male_params <- male_params[2:301,2:51]

### Define dimension extraction procedure as a function
extractDimension <- function(x, faces = faces, result = "dimension") {
  
  completeVector <- complete.cases(x)
  faces <- faces[completeVector]
  x <- x[completeVector]
  faces <- data.matrix(faces) # Make face data frame into a matrix easy to work with
  
  # Subtract the mean from Its
  x <- x - mean(x)
  # Create the weighted average
  Dim <- x %*% faces
  
  # Normalize
  Dim <- t(Dim / sqrt(sum(Dim^2)))
  
  # Return diemsnion, or dimension scores (computed as projection of each face on dimension)
  return(switch(result, scores = drop(faces %*% Dim), dimension = Dim))
  
}

### Define function that returns faces scores on a given dimension
# (used to get scores of faces unrelated to the dimension extraction procedure)
facesScoresOnDim <- function(faces = faces, dimension = dimension) {
  
  faces <- data.matrix(faces) # Make face data frame into a matrix easy to work with
  
  # Return diemsnion, or dimension scores (computed as projection of each face on dimension)
  return(scores = drop(faces %*% dimension))
  
}


fXm_dim <- extractDimension(stimuli[,fXm_mean_Z], male_params)
fXf_dim <- extractDimension(stimuli[,fXf_mean_Z], female_params)
mXm_dim <- extractDimension(stimuli[,mXm_mean_Z], male_params)
mXf_dim <- extractDimension(stimuli[,mXf_mean_Z], female_params)
bothXm_dim <- extractDimension(stimuli[,mean_Z.M], male_params)
bothXf_dim <- extractDimension(stimuli[,mean_Z.F], female_params)

fXm_dim_sc <- extractDimension(stimuli[,fXm_mean_Z], male_params, result = "scores")
fXf_dim_sc <- extractDimension(stimuli[,fXf_mean_Z], female_params, result = "scores")
mXm_dim_sc <- extractDimension(stimuli[,mXm_mean_Z], male_params, result = "scores")
mXf_dim_sc <- extractDimension(stimuli[,mXf_mean_Z], female_params, result = "scores")
bothXm_dim_sc <- extractDimension(stimuli[,mean_Z.M], male_params, result = "scores")
bothXf_dim_sc <- extractDimension(stimuli[,mean_Z.F], female_params, result = "scores")


### check correlation with dimensions----

social_dims <- social_dims[,1:51]

trust_fXm <- social_dims[1,2:51]
dom_fXm <- social_dims[2,2:51]
trust_fXf <- social_dims[3,2:51]
dom_fXf <- social_dims[4,2:51]
trust_mXm <- social_dims[5,2:51]
dom_mXm <- social_dims[6,2:51]
trust_mXf <- social_dims[7,2:51]
dom_mXf <- social_dims[8,2:51]
trust_bothXm <- social_dims[9,2:51]
dom_bothXm <- social_dims[10,2:51]
trust_bothXf <- social_dims[11,2:51]
dom_bothXf <- social_dims[12,2:51]

# short dims
short_trust_fXm <- social_dims[1,2:26]
short_dom_fXm <- social_dims[2,2:26]
short_trust_fXf <- social_dims[3,2:26]
short_dom_fXf <- social_dims[4,2:26]
short_trust_mXm <- social_dims[5,2:26]
short_dom_mXm <- social_dims[6,2:26]
short_trust_mXf <- social_dims[7,2:26]
short_dom_mXf <- social_dims[8,2:26]
short_trust_bothXm <- social_dims[9,2:26]
short_dom_bothXm <- social_dims[10,2:26]
short_trust_bothXf <- social_dims[11,2:26]
short_dom_bothXf <- social_dims[12,2:26]

short_fXm_dim <- fXm_dim[1:25]
short_fXf_dim <- fXf_dim[1:25]
short_mXm_dim <- mXm_dim[1:25]
short_mXf_dim <- mXf_dim[1:25]
short_bothXf_dim <- bothXf_dim[1:25]
short_bothXm_dim <- bothXm_dim[1:25]


#by groups
cor.test(as.numeric( dom_fXm), (fXm_dim))
cor.test(as.numeric( trust_fXm), (fXm_dim))
cor.test(as.numeric( dom_fXf), (fXf_dim))
cor.test(as.numeric( trust_fXf), (fXf_dim))
cor.test(as.numeric( dom_mXm), (mXm_dim))
cor.test(as.numeric( trust_mXm), (mXm_dim))
cor.test(as.numeric( dom_mXf), (mXf_dim))
cor.test(as.numeric( trust_mXf), (mXf_dim))

#by groups (short)
cor.test(as.numeric( short_dom_fXm), (short_fXm_dim))
cor.test(as.numeric( short_trust_fXm), (short_fXm_dim))
cor.test(as.numeric( short_dom_fXf), (short_fXf_dim))
cor.test(as.numeric( short_trust_fXf), (short_fXf_dim))
cor.test(as.numeric( short_dom_mXm), (short_mXm_dim))
cor.test(as.numeric( short_trust_mXm), (short_mXm_dim))
cor.test(as.numeric( short_dom_mXf), (short_mXf_dim))
cor.test(as.numeric( short_trust_mXf), (short_mXf_dim))

#by stimulus gender only
cor.test(as.numeric( dom_bothXm), (bothXm_dim))
cor.test(as.numeric( trust_bothXm), (bothXm_dim))
cor.test(as.numeric( dom_bothXf), (bothXf_dim))
cor.test(as.numeric( trust_bothXf), (bothXf_dim))

#by stimulus gender only (short)
cor.test(as.numeric( short_dom_bothXm), (short_bothXm_dim))
cor.test(as.numeric( short_trust_bothXm), (short_bothXm_dim))
cor.test(as.numeric( short_dom_bothXf), (short_bothXf_dim))
cor.test(as.numeric( short_trust_bothXf), (short_bothXf_dim))

#check cor between priority dim and bt's
fXf_mZ <- fXf_mZ[order(stimulus)]
fXf_mZ <- cbind(fXf_mZ, fXf_dim_sc)
fXm_mZ <- fXm_mZ[order(stimulus)]
fXm_mZ <- cbind(fXm_mZ, fXm_dim_sc)
mXf_mZ <- mXf_mZ[order(stimulus)]
mXf_mZ <- cbind(mXf_mZ, mXf_dim_sc)
mXm_mZ <- mXm_mZ[order(stimulus)]
mXm_mZ <- cbind(mXm_mZ, mXm_dim_sc)
bothXm_mZ <- data.table(cbind(bothXm_dim_sc,bothXm_mean_Z = stimuli[,mean_Z.M ]))
bothXf_mZ <- data.table(cbind(bothXf_dim_sc,bothXf_mean_Z = stimuli[,mean_Z.F ]))


cor.test(fXf_dim_sc, fXf_mZ[,fXf_mean_Z])
ggplot(fXf_mZ, aes(x = fXf_mean_Z, y = fXf_dim_sc)) +
  geom_point() +
  geom_smooth(method='lm')

cor.test(fXm_dim_sc, fXm_mZ[,fXm_mean_Z])
ggplot(fXm_mZ, aes(x = fXm_mean_Z, y = fXm_dim_sc)) +
  geom_point() +
  geom_smooth(method='lm')

cor.test(mXf_dim_sc, mXf_mZ[,mXf_mean_Z])
ggplot(mXf_mZ, aes(x = mXf_mean_Z, y = mXf_dim_sc)) +
  geom_point() +
  geom_smooth(method='lm')

cor.test(mXm_dim_sc, mXm_mZ[,mXm_mean_Z])
ggplot(mXm_mZ, aes(x = mXm_mean_Z, y = mXm_dim_sc)) +
  geom_point() +
  geom_smooth(method='lm')

cor.test(bothXm_dim_sc, bothXm_mZ[,bothXm_mean_Z])
ggplot(bothXm_mZ, aes(x = bothXm_mean_Z, y = bothXm_dim_sc)) +
  geom_point() +
  geom_smooth(method='lm')

cor.test(bothXf_dim_sc, bothXf_mZ[,bothXf_mean_Z])
ggplot(bothXf_mZ, aes(x = bothXf_mean_Z, y = bothXf_dim_sc)) +
  geom_point() +
  geom_smooth(method='lm')


### check dimensions correlations with Yanivs----
yanivs_priority <- as.matrix(yanivs_dims[,2])
yanivs_trust <- as.matrix(yanivs_dims[,3])
yanivs_dom <- as.matrix(yanivs_dims[,4])
yanivs_raw_trust <- as.matrix(yanivs_raw_dims[,2])
yanivs_raw_dom <- as.matrix(yanivs_raw_dims[,3])

### check how yanivs priority dimension explaines BTs in each group

yaniv_fXm_dim_sc <- facesScoresOnDim(faces = male_params, dimension = yanivs_priority)
yaniv_mXm_dim_sc <- facesScoresOnDim(faces = male_params, dimension = yanivs_priority)
yaniv_fXf_dim_sc <- facesScoresOnDim(faces = female_params, dimension = yanivs_priority)
yaniv_mXf_dim_sc <- facesScoresOnDim(faces = female_params, dimension = yanivs_priority)

cor.test(yaniv_fXm_dim_sc, fXm_mZ[,fXm_mean_Z])
p1 <- ggplot(fXm_mZ, aes(x = fXm_mean_Z, y = yaniv_fXm_dim_sc)) +
  geom_point() +
  geom_smooth(method='lm')
cor.test(yaniv_mXm_dim_sc, mXm_mZ[,mXm_mean_Z])
p2 <- ggplot(mXm_mZ, aes(x = mXm_mean_Z, y = yaniv_mXm_dim_sc)) +
  geom_point() +
  geom_smooth(method='lm')
cor.test(yaniv_fXf_dim_sc, fXf_mZ[,fXf_mean_Z])
p3 <- ggplot(fXf_mZ, aes(x = fXf_mean_Z, y = yaniv_fXf_dim_sc)) +
  geom_point() +
  geom_smooth(method='lm')
cor.test(yaniv_mXf_dim_sc, mXf_mZ[,mXf_mean_Z])
p4 <- ggplot(mXf_mZ, aes(x = mXf_mean_Z, y = yaniv_mXf_dim_sc)) +
  geom_point() +
  geom_smooth(method='lm')

library(gridExtra)
grid.arrange(p1, p2, p3, p4, nrow = 2)

### check how face scores according to each group correlate with other the other groups' face scores
library(corrplot)

face_scores_combined <- cbind(fXf_dim_sc, fXm_dim_sc, mXf_dim_sc, mXm_dim_sc, bothXm_dim_sc, bothXf_dim_sc, yaniv_fXf_dim_sc, yaniv_fXm_dim_sc, yaniv_mXf_dim_sc, yaniv_mXm_dim_sc)
plot <- rcorr(face_scores_combined)
corrplot(plot$r, type = "upper", 
         tl.col = "black", tl.srt = 45)

cor.test(mXm_dim_sc, fXm_dim_sc)
ggplot(,aes(x = fXm_dim_sc, y = mXm_dim_sc)) +
  geom_point() +
  geom_smooth(method='lm')
cor.test(mXm_dim_sc, fXf_mZ[,fXf_mean_Z])
ggplot(fXf_mZ, aes(x = fXf_mean_Z, y = mXm_dim_sc)) +
  geom_point() +
  geom_smooth(method='lm')

###find cor between the 4 priority dimensions + yanivs dimension
priority_dims_merged <- cbind(fXf_dim, fXm_dim, mXf_dim, mXm_dim, bothXm_dim, bothXf_dim, yanivs_priority)
colnames(priority_dims_merged) <- c('fXf','fXm', 'mXf', 'mXm','bothXm', 'bothXf', 'yaniv')
rcorr(priority_dims_merged)

###find cor between the different social dimensions + yanivs
doms_merged <- cbind(as.numeric(dom_fXf),as.numeric(dom_fXm), as.numeric(dom_mXf), as.numeric(dom_mXm), as.numeric(dom_bothXm), as.numeric(dom_bothXf), yanivs_dom, yanivs_raw_dom)
colnames(doms_merged) <- c('fXf','fXm', 'mXf', 'mXm', 'bothXm', 'bothXf', 'yaniv', 'yaniv raw')
rcorr(doms_merged)

trusts_merged <- cbind(as.numeric(trust_fXf),as.numeric(trust_fXm), as.numeric(trust_mXf),as.numeric(trust_mXm), as.numeric(trust_bothXm), as.numeric(trust_bothXf), yanivs_trust, yanivs_raw_trust)
colnames(trusts_merged) <- c('fXf','fXm', 'mXf', 'mXm', 'bothXm', 'bothXf', 'yaniv', 'yaniv raw')
rcorr(trusts_merged)

###find cor between yaniv priority dimension and my dominance and trustworthiness dimensions
temp1 <- cor.test(as.numeric( dom_fXm), (yanivs_priority))
temp2 <- cor.test(as.numeric( trust_fXm), (yanivs_priority))
temp3 <- cor.test(as.numeric( dom_fXf), (yanivs_priority))
temp4 <- cor.test(as.numeric( trust_fXf), (yanivs_priority))
temp5 <- cor.test(as.numeric( dom_mXm), (yanivs_priority))
temp6 <- cor.test(as.numeric( trust_mXm), (yanivs_priority))
temp7 <- cor.test(as.numeric( dom_mXf), (yanivs_priority))
temp8 <- cor.test(as.numeric( trust_mXf), (yanivs_priority))
temp9 <- cor.test(as.numeric( dom_bothXm), (yanivs_priority))
temp10 <- cor.test(as.numeric( trust_bothXm), (yanivs_priority))
temp11 <- cor.test(as.numeric( dom_bothXf), (yanivs_priority))
temp12 <- cor.test(as.numeric( trust_bothXf), (yanivs_priority))


yaniv_w_yuval_socials <- data.table(
  'social Dimension' = c('dominance', 'trust'),
  fxm = c(temp1$estimate,temp2$estimate),
  fxf = c(temp3$estimate,temp4$estimate),
  mxm = c(temp5$estimate,temp6$estimate),
  mxf = c(temp7$estimate,temp8$estimate),
  bothXm = c(temp9$estimate,temp10$estimate),
  bothXf = c(temp11$estimate,temp12$estimate)
  
)
yaniv_w_yuval_socials

###find cor between yuval priority dimension and yanivs dominance and trustworthiness dimensions
temp1 <- cor.test(as.numeric( fXm_dim), (yanivs_dom))
temp2 <- cor.test(as.numeric( fXm_dim), (yanivs_trust))
temp3 <- cor.test(as.numeric( fXf_dim), (yanivs_dom))
temp4 <- cor.test(as.numeric( fXf_dim), (yanivs_trust))
temp5 <- cor.test(as.numeric( mXm_dim), (yanivs_dom))
temp6 <- cor.test(as.numeric( mXm_dim), (yanivs_trust))
temp7 <- cor.test(as.numeric( mXf_dim), (yanivs_dom))
temp8 <- cor.test(as.numeric( mXf_dim), (yanivs_trust))

yuval_w_yaniv_socials <- data.table(
  'social Dimension' = c('dominance', 'trust'),
  fxm = c(temp1$estimate,temp2$estimate),
  fxf = c(temp3$estimate,temp4$estimate),
  mxm = c(temp5$estimate,temp6$estimate),
  mxf = c(temp7$estimate,temp8$estimate)
  
)
yuval_w_yaniv_socials

###find cor between yuval priority dimension and yanivs raw dominance and trustworthiness dimensions
temp1 <- cor.test(as.numeric( fXm_dim), (yanivs_raw_dom))
temp2 <- cor.test(as.numeric( fXm_dim), (yanivs_raw_trust))
temp3 <- cor.test(as.numeric( fXf_dim), (yanivs_raw_dom))
temp4 <- cor.test(as.numeric( fXf_dim), (yanivs_raw_trust))
temp5 <- cor.test(as.numeric( mXm_dim), (yanivs_raw_dom))
temp6 <- cor.test(as.numeric( mXm_dim), (yanivs_raw_trust))
temp7 <- cor.test(as.numeric( mXf_dim), (yanivs_raw_dom))
temp8 <- cor.test(as.numeric( mXf_dim), (yanivs_raw_trust))

yuval_w_yaniv_raw_socials <- data.table(
  'social Dimension' = c('dominance', 'trust'),
  fxm = c(temp1$estimate,temp2$estimate),
  fxf = c(temp3$estimate,temp4$estimate),
  mxm = c(temp5$estimate,temp6$estimate),
  mxf = c(temp7$estimate,temp8$estimate)
  
)
yuval_w_yaniv_raw_socials

### Load required libraries
#library(reshape)
library(psych)
#library(plyr)
#library(ggplot2)
#library(ggm)

### Create correlation table
ct.priority_dims_merged <- corr.test(priority_dims_merged)

### Plot priority heatmap
# Convert to long format
heatmap <- data.frame(ct.priority_dims_merged$r)
heatmap$name <- rownames(heatmap)
heatmap <- melt(heatmap, id.vars = 'name')
heatmap$name <- factor(heatmap$name, levels = rev(c('fXf', 'fXm','mXf',
                                                    'mXm', 'bothXm', 'bothXf', 'yaniv')))

# Round r values to 2 digits
heatmap$label <- sprintf("%0.2f", round(heatmap$value,2))

# Plot
(p <- ggplot(heatmap, aes(x=variable, y=name))) +
  geom_tile(aes(fill=-value)) + geom_text(aes(label = label)) +
  scale_x_discrete('', labels=c('fXf' = 'fXf',
                                'fXm' = 'fXm',
                                'mXf' = 'mXf',
                                'mXm' = 'mXm',
                                'bothXm' = 'bothXm',
                                'bothXf' = 'bothXf',
                                'yaniv' = 'Yaniv'),
                   expand = c(0,0), position = "top") +
  scale_y_discrete('', labels=c('fXf' = 'fXf',
                                'fXm' = 'fXm',
                                'mXf' = 'mXf',
                                'mXm' = 'mXm',
                                'bothXm' = 'bothXm',
                                'bothXf' = 'bothXf',
                                'yaniv' = 'Yaniv'),
                   expand = c(0,0)) + theme(axis.ticks = element_blank(), 
                                            axis.text	= element_text(size=12),
                                            axis.text.x = element_text(angle = 45, hjust = 0)) +
  scale_fill_distiller("",palette = "RdYlBu", limits = c(-1,1)) +
  ggtitle("priority dimensions correlations")




### Create correlation table
ct.doms_merged <- corr.test(doms_merged)

### Plot dominance heatmap
# Convert to long format
heatmap <- data.frame(ct.doms_merged$r)
heatmap$name <- rownames(heatmap)
heatmap <- melt(heatmap, id.vars = 'name')
heatmap$name <- factor(heatmap$name, levels = rev(c('fXf', 'fXm','mXf',
                                                    'mXm', 'bothXm', 'bothXf', 'yaniv', 'yaniv raw')))

# Round r values to 2 digits
heatmap$label <- sprintf("%0.2f", round(heatmap$value,2))

# Plot
(p <- ggplot(heatmap, aes(x=variable, y=name))) +
  geom_tile(aes(fill=-value)) + geom_text(aes(label = label)) +
  scale_x_discrete('', labels=c('fXf' = 'fXf',
                                'fXm' = 'fXm',
                                'mXf' = 'mXf',
                                'mXm' = 'mXm',
                                'bothXm' = 'bothXm',
                                'yaniv' = 'Yaniv',
                                'yaniv raw' = 'Yaniv raw'),
                   expand = c(0,0), position = "top") +
  scale_y_discrete('', labels=c('fXf' = 'fXf',
                                'fXm' = 'fXm',
                                'mXf' = 'mXf',
                                'mXm' = 'mXm',
                                'bothXm' = 'bothXm',
                                'yaniv' = 'Yaniv',
                                'yaniv raw' = 'Yaniv raw'),
                   expand = c(0,0)) + theme(axis.ticks = element_blank(), 
                                            axis.text	= element_text(size=12),
                                            axis.text.x = element_text(angle = 45, hjust = 0)) +
  scale_fill_distiller("",palette = "RdYlBu", limits = c(-1,1), direction = -1) +
  ggtitle("power/dominance dimensions correlations")


### Create correlation table
ct.trusts_merged <- corr.test(trusts_merged)

### Plot trust heatmap
# Convert to long format
heatmap <- data.frame(ct.trusts_merged$r)
heatmap$name <- rownames(heatmap)
heatmap <- melt(heatmap, id.vars = 'name')
heatmap$name <- factor(heatmap$name, levels = rev(c('fXf', 'fXm','mXf',
                                                    'mXm', 'bothXm', 'bothXf', 'yaniv', 'yaniv raw')))

# Round r values to 2 digits
heatmap$label <- sprintf("%0.2f", round(heatmap$value,2))

# Plot
(p <- ggplot(heatmap, aes(x=variable, y=name))) +
  geom_tile(aes(fill=-value)) + geom_text(aes(label = label)) +
  scale_x_discrete('', labels=c('fXf' = 'fXf',
                                'fXm' = 'fXm',
                                'mXf' = 'mXf',
                                'mXm' = 'mXm',
                                'bothXm' = 'bothXm',
                                'bothXf' = 'bothXf',
                                'yaniv' = 'Yaniv',
                                'yaniv raw' = 'Yaniv raw'),
                   expand = c(0,0), position = "top") +
  scale_y_discrete('', labels=c('fXf' = 'fXf',
                                'fXm' = 'fXm',
                                'mXf' = 'mXf',
                                'mXm' = 'mXm',
                                'bothXm' = 'bothXm',
                                'bothXf' = 'bothXf',
                                'yaniv' = 'Yaniv',
                                'yaniv raw' = 'Yaniv raw'),
                   expand = c(0,0)) + theme(axis.ticks = element_blank(), 
                                            axis.text	= element_text(size=12),
                                            axis.text.x = element_text(angle = 45, hjust = 0)) +
  scale_fill_distiller("",palette = "RdYlBu", limits = c(-1,1), direction = -1) +
  ggtitle("valence/trustworthiness dimensions correlations")




#
cor.test(as.numeric( dom_fXm), (yanivs_priority))
cor.test(as.numeric( trust_fXm), (yanivs_priority))
cor.test(as.numeric( dom_fXf), (fXf_dim))
cor.test(as.numeric( trust_fXf), (fXf_dim))
cor.test(as.numeric( dom_mXm), (mXm_dim))
cor.test(as.numeric( trust_mXm), (mXm_dim))
cor.test(as.numeric( dom_mXf), (mXf_dim))
cor.test(as.numeric( trust_mXf), (mXf_dim))

#measures of stability of the data ----
###odd vs even trials
odds <-  brms[brms[,trial]%%2==1,]
evens <- brms[brms[,trial]%%2!=1,]

odds_mBT <- odds[, .(BT = mean(rt)), by = uniqueid]
evens_mBT <- evens[, .(BT = mean(rt)), by = uniqueid]

merged_mBT <- merge(odds_mBT, evens_mBT)

cor.test(merged_mBT$BT.x, merged_mBT$BT.y)

ggplot(merged_mBT, aes(x = BT.x, y = BT.y)) +
  geom_point() +
  geom_smooth(method='lm')+
  labs(x = "odd trials participant avarage BT", y = "even trials participant avarage BT")



# randomly generated priority dimension and how it correlates X 10000 ----


cors <- numeric()
ps <- numeric()
sig_per_test <- numeric()
sig_15 <- numeric()
for (i in 1:10000) {
  rand_dim <- rnorm(50, mean = 0.00, sd = 0.15)
  sig <- numeric()
  
  cors <- c(cors, cor.test(as.numeric( dom_fXm), (rand_dim))$estimate)
  cors <- c(cors, cor.test(as.numeric( trust_fXm), (rand_dim))$estimate)
  cors <- c(cors, cor.test(as.numeric( dom_fXf), (rand_dim))$estimate)
  cors <- c(cors, cor.test(as.numeric( trust_fXf), (rand_dim))$estimate)
  cors <- c(cors, cor.test(as.numeric( dom_mXm), (rand_dim))$estimate)
  cors <- c(cors, cor.test(as.numeric( trust_mXm), (rand_dim))$estimate)
  cors <- c(cors, cor.test(as.numeric( dom_mXf), (rand_dim))$estimate)
  cors <- c(cors, cor.test(as.numeric( trust_mXf), (rand_dim))$estimate)
  
  ps <- c(ps, cor.test(as.numeric( dom_fXm), (rand_dim))$p.value)
  ps <- c(ps, cor.test(as.numeric( trust_fXm), (rand_dim))$p.value)
  ps <- c(ps, cor.test(as.numeric( dom_fXf), (rand_dim))$p.value)
  ps <- c(ps, cor.test(as.numeric( trust_fXf), (rand_dim))$p.value)
  ps <- c(ps, cor.test(as.numeric( dom_mXm), (rand_dim))$p.value)
  ps <- c(ps, cor.test(as.numeric( trust_mXm), (rand_dim))$p.value)
  ps <- c(ps, cor.test(as.numeric( dom_mXf), (rand_dim))$p.value)
  ps <- c(ps, cor.test(as.numeric( trust_mXf), (rand_dim))$p.value)
  
  sig <- c(sig, cor.test(as.numeric( dom_fXm), (rand_dim))$p.value)
  sig <- c(sig, cor.test(as.numeric( trust_fXm), (rand_dim))$p.value)
  sig <- c(sig, cor.test(as.numeric( dom_fXf), (rand_dim))$p.value)
  sig <- c(sig, cor.test(as.numeric( trust_fXf), (rand_dim))$p.value)
  sig <- c(sig, cor.test(as.numeric( dom_mXm), (rand_dim))$p.value)
  sig <- c(sig, cor.test(as.numeric( trust_mXm), (rand_dim))$p.value)
  sig <- c(sig, cor.test(as.numeric( dom_mXf), (rand_dim))$p.value)
  sig <- c(sig, cor.test(as.numeric( trust_mXf), (rand_dim))$p.value)
  sig_per_test <- c(sig_per_test, sum(sig < 0.05))
  sig_15 <- c(sig_15, sum(sig < 0.15))
}

hist(ps, breaks = 20)
hist(sig_15)
hist(sig_per_test)
count(sig_per_test > 2)

# swap face params for checking face correlation with BTs ----

### random swapping between all faces
r_list <- numeric()
r_list2 <- numeric()
original_params_BT <- cbind(male_params, BT = stimuli$fXm_mean_Z)
for (i in 1:1000) {
  swapped <- original_params_BT[sample(nrow(original_params_BT)),]
  male_params_swapped <- swapped[,1:50]
  BTs_swapped_order <- swapped[,BT]
  fXm_dim_sc_swapped <- extractDimension(stimuli[,fXm_mean_Z], male_params_swapped, result = "scores")
  r_list <- c(r_list, cor.test(fXm_dim_sc_swapped, fXm_mZ[,fXm_mean_Z])$estimate)
  r_list2 <- c(r_list2, cor.test(fXm_dim_sc_swapped, BTs_swapped_order)$estimate)
}

hist(r_list, main = "Histogram of explenatory power (Pearson's r)
of priority dimensions based on 1000
scrammbled face parameters")
hist(r_list2, main = "Histogram of explenatory power (Pearson's r)
of priority dimensions based on 1000
     scrammbled face parameters (with original BTs)")

# original priority dimension correlates with BTs 0.3685, and its on the ... percentile
perc.rank <- ecdf(r_list)
perc.rank(0.3685)

### swap between deciles of face similarity (represented here as distance on dominance dimension)
dominance_sc <- facesScoresOnDim(faces = male_params, dimension = t(dom_fXm)) # get each face's score on dominance dimension
male_params_indexed <- cbind(BT =stimuli[,fXm_mean_Z],dominance_sc, male_params)
by_similarity <- male_params_indexed[order(dominance_sc)] #order by dominance score

r_list <- numeric()
for (i in 1:1000) {
  
  by_similarity <- male_params_indexed[order(dominance_sc)] #order by dominance score
  ea <- nrow(by_similarity)/10
  # Deciles shifted by 5
  d <- rep(((1:10 + 4) %% 10) + 1, each=ea)
  # Random index within decile
  r <- c(replicate(10, sample(ea)))
  new_params <- cbind(by_similarity[,1], by_similarity[order(d, r), -1:-2]) #new table containing original face BTs along with the new face attributes
  male_params_swapped <- new_params[,2:51]
  
  fXm_dim_sc_swapped <- extractDimension(new_params[,BT], male_params_swapped, result = "scores")
  r_list <- c(r_list, cor.test(fXm_dim_sc_swapped, new_params[,BT])$estimate)
}

hist(r_list, main = "Histogram of explenatory power (Pearson's r)
of priority dimensions based on 1000
scrammbled face parameters between unfimiliar faces")


### swap between every two neighbor faces on dominance dimension

dominance_sc <- facesScoresOnDim(faces = male_params, dimension = t(dom_fXm)) # get each face's score on dominance dimension
male_params_indexed <- cbind(BT =stimuli[,fXm_mean_Z],dominance_sc, male_params)
by_similarity <- male_params_indexed[order(dominance_sc)] #order by dominance score

for (i in 1:1000) {
  by_similarity <- male_params_indexed[order(dominance_sc)] #order by dominance score
  male_params_swapped <- by_similarity[seq_len(nrow(by_similarity)) + c(1,-1),3:52]
  
  fXm_dim_sc_swapped <- extractDimension(by_similarity$BT, male_params_swapped, result = "scores")
  r_list <- c(r_list, cor.test(fXm_dim_sc_swapped, by_similarity$BT)$estimate)
}


r_list # no histogram - just one case

### swap inside deciles of face similarity (represented here as distance on dominance dimension)
dominance_sc <- facesScoresOnDim(faces = male_params, dimension = t(dom_fXm)) # get each face's score on dominance dimension
male_params_indexed <- cbind(BT = stimuli[,fXm_mean_Z],dominance_sc, male_params)
by_similarity <- male_params_indexed[order(dominance_sc)] #order by dominance score

r_list <- numeric()
for (i in 1:1000) {
  
  by_similarity <- male_params_indexed[order(dominance_sc)] #order by dominance score
  ea <- nrow(by_similarity)/10
  # Deciles shifted by 5
  d <- rep((1:10), each=ea)
  # Random index within decile
  r <- c(replicate(10, sample(ea)))
  new_params <- cbind(by_similarity[,1], by_similarity[order(d, r), -1:-2]) #new table containing original face BTs along with the new face attributes
  male_params_swapped <- new_params[,2:51]
  
  fXm_dim_sc_swapped <- extractDimension(new_params[,BT], male_params_swapped, result = "scores")
  r_list <- c(r_list, cor.test(fXm_dim_sc_swapped, new_params[,BT])$estimate)
}

hist(r_list, main = "Histogram of explenatory power (Pearson's r)
of priority dimensions based on 1000
scrammbled face parameters familiar faces")


# take 80% of trials from each participant, make priority dim,  ----
#and see how it predicts the other 20% dim and scores



