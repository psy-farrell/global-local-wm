library(reshape2)
library(plyr)
library(lme4)

kk <- read.table("GL2.csv", header=TRUE, sep=",")

tkk <- kk[(kk$Condition<6) | (kk$Condition==11),] # mostly typed analysis
#tkk <- kk[((kk$Condition>5) & (kk$Condition<11)) | (kk$Condition==12),] # mostly spoken analysis

df <- data.frame(subj = tkk$Participant, 
                     cond =tkk$Condition,
                     serpos = tkk$SerPos,
                     CLlocal = tkk$CLlocal,
                     CLglobal = tkk$CLglobal,
                     value = tkk$Correctness,
                    RT = tkk$SumRT,
                  RT1 = tkk$RT1)

# Filter out excluded participants (see MS for details)
df = df[df$subj !=2 &
          df$subj !=5 &
          df$subj !=8 &
          df$subj !=9 &
          df$subj !=35,]

#df <- melt(df, id.vars=c("subj","cond"),variable.name="serpos")

df$serposd <- df$serpos

if (max(df$cond)>11){ #it's mostly fast
  df$lag <- df$serposd-(df$cond-5)
} else {
  df$lag <- df$serposd-df$cond
}

df$lag[df$cond>10] <- -100

df$expcon <- df$lag * 0
df$expcon[df$cond<11] <- 1
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
lmlagcon <- glmer(value ~ as.factor(serpos) + factor(lag) +(1 | subj), data=dff, family=binomial,
                  control=glmerControl(optimizer="bobyqa"))
lmspci <- glmer(value ~ factor(serpos) + factor(expcon)*factor(serpos) +(1 | subj), data=dff, family=binomial,
             control=glmerControl(optimizer="bobyqa"))

anova(lm0,lmspc)
exp(-0.5*(BIC(lmspc)-BIC(lm0)))
anova(lmspc,lmd)
exp(-0.5*(BIC(lmd)-BIC(lmspc)))
anova(lmspc,lmspci)
exp(-0.5*(BIC(lmspci)-BIC(lmspc)))

summary(lmlagcon)

dff <- df[df$cond<11,]

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

#### effects of cognitive load
dff <- df
dff <- na.omit(dff) # need to do this because CLs have some missing values

lmspc <- glmer(value ~ as.factor(serpos) + (1 | subj), data=dff, family=binomial,
               control=glmerControl(optimizer="bobyqa"))
lmCLG <- glmer(value ~ as.factor(serpos) + CLglobal + (1 | subj), data=dff, family=binomial,
                   control=glmerControl(optimizer="bobyqa"))
lmCLL <- glmer(value ~ as.factor(serpos) +  CLlocal + (1 | subj), data=dff, family=binomial,
                      control=glmerControl(optimizer="bobyqa"))

anova(lmspc,lmCLG)
exp(-0.5*(BIC(lmCLG)-BIC(lmspc)))
anova(lmspc,lmCLL)
exp(-0.5*(BIC(lmCLL)-BIC(lmspc)))