# read in data files
messages =read.csv("/home/dheerajvc/takehome/data/messages.csv")
purchases =read.csv("/home/dheerajvc/takehome/data/purchases.csv")
users =read.csv("/home/dheerajvc/takehome/data/users.csv")

#dots are a problem in sqldf
names(users) <- c("user_id","signup_date")
names(purchases) <- c("user_id","purchase_date","purchase_count")
names(messages) <- c("user_id","message_date","message_count")

#convert the strng dates to date format
messages$message_date <- as.Date(as.character(messages$message_date))
purchases$purchase_date <- as.Date(as.character(purchases$purchase_date))
users$signup_date <- as.Date(as.character(users$signup_date))

library("sqldf")
# num users
numusers <- sqldf("select count(distinct user_id)  from users") #24049

#  num users purch in first 90 days
purchase_before90days <- sqldf("select users.user_id,min(purchases.purchase_date) as earliest_purch_date from users join purchases 
            on users.user_id = purchases.user_id where purchases.purchase_date-users.signup_date <=90
            group by users.user_id")  #10284

#num users who purchased in the first 90 days received a message after their sign up date but before their first purchase 
purchase_before90_gotmsg <- sqldf("select distinct a.user_id from purchase_before90days as a join messages on a.user_id = messages.user_id 
      where earliest_purch_date>message_date ") #3441

# users who recvd msg in first 90 days
mess_recvd_90days <- sqldf("select users.user_id,sum(message_count) as nummsg  from users join messages 
            on users.user_id = messages.user_id where message_date-users.signup_date <=90
            group by users.user_id") #23564

# users who made a purchase between 91 to 180 days
purch_90_180days <- sqldf("select users.user_id,sum(purchase_count) as numpurch  from users left outer join purchases
            on users.user_id = purchases.user_id where purchase_date-users.signup_date between 91 and 180
            group by users.user_id") #408

# users who recvd a message before 90 days, no purchase between 91 to 180 days
mess_recvd_90days_nopurch <- sqldf("select a.* from  mess_recvd_90days as a left outer join purch_90_180days
            on a.user_id = purch_90_180days.user_id where purch_90_180days.user_id is null")

# users who recvd a message before 90 days, purchase between 91 to 180 days
mess_recvd_90days_purch <- sqldf("select a.* from  mess_recvd_90days as a  join purch_90_180days
            on a.user_id = purch_90_180days.user_id")

# 2sample t test to see if the mean num of messages recvd are statistically different
t.test(mess_recvd_90days_nopurch$nummsg,mess_recvd_90days_purch$nummsg, var.equal=TRUE, paired=FALSE)

# Two Sample t-test
# 
# data:  mess_recvd_90days_nopurch$nummsg and mess_recvd_90days_purch$nummsg
# t = -7.4908, df = 23562, p-value = 7.088e-14
# alternative hypothesis: true difference in means is not equal to 0
# 95 percent confidence interval:
#   -11.976188  -7.008564
# sample estimates:
#   mean of x mean of y 
# 40.86302  50.35539 

# test out auc for num msgs
library("ROCR")

mess_recvd_90days_nopurch$val = 0
mess_recvd_90days_purch$val = 1

# combine datasets
combined_msgdata <- rbind(mess_recvd_90days_nopurch,mess_recvd_90days_purch)

pred <- prediction(combined_msgdata$nummsg,combined_msgdata$val)

performance(pred,"auc")

# AUC = 60% (better than random)


