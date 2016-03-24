library(reshape2)
library(plyr)
library(lme4)

tkk<- read.table("correctnessGL3.dat")

df <- data.frame(subj = tkk[,1], 
                     cond = tkk[,2],
                     s1 = tkk[,3],
                     s2 = tkk[,4],
                     s3 = tkk[,5],
                     s4 = tkk[,6],
                     s5 = tkk[,7])


# uncomment to check excluding these makes no difference
#badSs10 <- c(24-9,30-9,33-9) # using 10% performance cutoff
#Ssfilt <- sapply(df$subj, FUN = function(x) any(x==badSs5))
#df <- df[Ssfilt==FALSE,]

df <- melt(df, id.vars=c("subj","cond"),variable.name="serpos")

df$serposd <- rep(0,length(df$serpos))
df$serposd[df$serpos=="s1"] <- 1
df$serposd[df$serpos=="s2"] <- 2
df$serposd[df$serpos=="s3"] <- 3
df$serposd[df$serpos=="s4"] <- 4
df$serposd[df$serpos=="s5"] <- 5

df$lag <- df$serposd*0
for (cond in 1:4){
  dpos1 <- df$serposd-rep(cond,length(df$lag))
  dpos2 <- df$serposd-rep(cond+1,length(df$lag))
  df$lag[df$cond==cond & dpos1>0] <- pmin(dpos1[df$cond==cond & dpos1>0],
                                          dpos2[df$cond==cond & dpos1>0])
  df$lag[df$cond==cond & dpos1<=0] <- pmax(dpos1[df$cond==cond & dpos1<=0],
                                           dpos2[df$cond==cond & dpos1<=0])
}

df$lag[df$cond>4] <- -100

df$expcon <- df$lag * 0
df$expcon[df$cond<5] <- 1

df$lagf <- as.character(df$lag)
df$lagf[df$serposd==df$cond] <- "0-1"
df$lagf[df$serposd==(df$cond+1)] <- "0-2"
df$lagf[df$lagf=="-100"] <- "_control"
df$lagf <- factor(df$lagf)

##### we still have each row as an individual response; fit multilevel model now
##using "bobyqa" optimizer as ran in to issues identified at following link
### http://stackoverflow.com/questions/21344555/convergence-error-for-development-version-of-lme4

dff <- df

lm0 <- glmer(value ~ (1 | subj), data=dff, family=binomial,
             control=glmerControl(optimizer="bobyqa"))
lmspc <- glmer(value ~ as.factor(serpos) + (1 | subj), data=dff, family=binomial,
               control=glmerControl(optimizer="bobyqa"))
lmd <- glmer(value ~ as.factor(serpos) + factor(expcon) +(1 | subj), data=dff, family=binomial,
             control=glmerControl(optimizer="bobyqa"))
lmlagcon <- glmer(value ~ as.factor(serpos) + lagf +(1 | subj), data=dff, family=binomial,
                  control=glmerControl(optimizer="bobyqa"))

summary(lmlagcon) # this is z-tests for exp-control comparison as function of lag (nominal)

anova(lm0,lmspc)
exp(-0.5*(BIC(lmspc)-BIC(lm0)))
anova(lmspc,lmd)
exp(-0.5*(BIC(lmd)-BIC(lmspc)))

dff <- df[df$cond<5,]
lmspc <-  glmer(value ~ as.factor(serpos) + (1 | subj), data=dff, family=binomial,
                control=glmerControl(optimizer="bobyqa"))
lmlagb <- glmer(value ~ as.factor(serpos) + lag + I(lag^2) + (1 | subj), data=dff, family=binomial,
                control=glmerControl(optimizer="bobyqa"))
lmlag <- glmer(value ~ as.factor(serpos) + lag + (1 | subj), data=dff, family=binomial,
               control=glmerControl(optimizer="bobyqa"))
lmlag2 <- glmer(value ~ as.factor(serpos) +  I(lag^2) + (1 | subj), data=dff, family=binomial,
                control=glmerControl(optimizer="bobyqa"))

anova(lmspc,lmlag)
exp(-0.5*(BIC(lmlag)-BIC(lmspc)))
anova(lmspc,lmlag2)
exp(-0.5*(BIC(lmlag2)-BIC(lmspc)))
anova(lmlag2,lmlagb)