library(reshape2)
library(plyr)
library(lme4)

kk<- read.table("rawdata.dat")

####[1 2 3 4 5 11]; % mostly slow analysis
####[6 7 8 9 10 12]; % mostly fast analysis

# Comment and uncomment as needed
#tkk <- kk[(kk[,3]<6) | (kk[,3]==11),] # mostly slow analysis
tkk <- kk[((kk[,3]>5) & (kk[,3]<11)) | (kk[,3]==12),] # mostly fast analysis

df <- data.frame(subj = tkk[,1], 
                 cond = tkk[,3],
                 s1 = tkk[,4],
                 s2 = tkk[,5],
                 s3 = tkk[,6],
                 s4 = tkk[,7],
                 s5 = tkk[,8])

df <- melt(df, id.vars=c("subj","cond"),variable.name="serpos")

df$serposd <- rep(0,length(df$serpos))
df$serposd[df$serpos=="s1"] <- 1
df$serposd[df$serpos=="s2"] <- 2
df$serposd[df$serpos=="s3"] <- 3
df$serposd[df$serpos=="s4"] <- 4
df$serposd[df$serpos=="s5"] <- 5

if (max(df$cond)>11){ #it's mostly fast
  df$lag <- df$serposd-(df$cond-5)
} else {
  df$lag <- df$serposd-df$cond
}

df$lag[df$cond>10] <- -100 # assign control data an arbitrary lag value. We make it negative
                    # so that entering lag as contrast with all data compares all experimental
                    # lags to control data

df$expcon <- df$lag * 0
df$expcon[df$cond<11] <- 1

dff <- df

lm0 <- glmer(value ~ (1 | subj), data=dff, family=binomial,
             control=glmerControl(optimizer="bobyqa"))
lmspc <- glmer(value ~ as.factor(serpos) + (1 | subj), data=dff, family=binomial,
               control=glmerControl(optimizer="bobyqa"))
lmd <- glmer(value ~ as.factor(serpos) + factor(expcon) +(1 | subj), data=dff, family=binomial,
             control=glmerControl(optimizer="bobyqa"))
lmlagcon <- glmer(value ~ as.factor(serpos) + factor(lag) +(1 | subj), data=dff, family=binomial,
                  control=glmerControl(optimizer="bobyqa"))

anova(lm0,lmspc)
exp(-0.5*(BIC(lmspc)-BIC(lm0)))
anova(lmspc,lmd)
exp(-0.5*(BIC(lmd)-BIC(lmspc)))

summary(lmlagcon)

dff <- df[df$cond<11,]
# lm2 <- glmer(value ~ as.factor(serpos) + factor(expcon) + (1 | subj), data=dff, family=binomial,
#              control=glmerControl(optimizer="bobyqa"))
# lm3 <- glmer(value ~ as.factor(serpos) + as.factor(lag) + (1 | subj), data=dff, family=binomial,
#              control=glmerControl(optimizer="bobyqa"))

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