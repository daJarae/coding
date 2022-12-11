#DS summary (webpage or course material)



#------------- CH2 R basics ----------------

library(dslabs)
data(murders)

class(murders) #data.frame
str(murders)   #string X (structure)
names(murders) #var names
class(murders$region) #factor - useful for categ
levels(murders$region) #categ unique

#categ var order by other num var
region <- murders$region
value <- murders$total
region <- reorder(region, value, FUN = sum)

a=c(1,2,3,2,1)
b=c(1,2,3,4,5)
order(a,b) #order idx by a then b

#unlike df, list can have vars with diffrent length
l=list(name = "John Doe",
     student_id = c(1234,1111))
l2=list("John Doe", 1234) #without var name

l$name
l[["name"]]

#matrix
matrix(1:12,4,3)[1,1:3]
matrix(1:12,4,3,byrow=T)[1,1:3]

#vector also can have names 
v=c(a=1,b=2,c=3)
v[c(1,3)]
v[2:3]
v["a"] #like df in Python.

#seq
seq(1,3,0.5)

#coerce
as.numeric("3")
as.character(1)

#2.9---------

#sort
sort(murders$total)[1:5]

x=c(1,4,2,3) #1>3>4>2
idx=order(x) #save "asc order" index to call ith x
idx
x[idx]

#rank (useful when ranks visually unclear)
rk=rank(x) 
rk

#idx vs rank:
#ids = idx of ith smallest x for ith rank
#rk = each rank for ith x


#max and which.max
murders$state[which.max(murders$total)] #easily shown

#indexing
ind=murders$population>5000000
murders$state[ind]
sum(ind) #their nums!

ind=which(murders$population>5000000) #same

#match: useful for idx search by categ
ind=match(c("New York", "Florida", "Texas"), murders$state)
ind=which(murders$state%in%c("New York", "Florida", "Texas"))
murders$state[ind] #works samely

#%in% - "Is it included in df?"
c("Boston","Dakota") %in% murders$state

#with & plot
with(murders,plot(population,total))
with(murders,hist(population))
murders$rate <- with(murders, total/population*100000)
with(murders,boxplot(rate~region))

x=matrix(1:120, 12, 10)
x
image(x) #!??!



#----------- CH3 Programming basics -------------



#conditional
a=0
if(a!=0){print(1/a)} else{print("no!")}
a=c(0,2,4)
z=ifelse(a>0,1/a,NA) #<NA!
sum(is.na(z))

#logical?
z=c(T,F,T)
any(z)
all(z)
identical(c(1,2),c(1,2))
identical(c(1,2),c(1,'2')) #False.

#kable (clean table)
tmp=data.frame(a=a,ans1=1/a,ans2=NA)
knitr::kable(tmp) #can use here

#user function
p2=function(x){ifelse(x>0,x+2,0)} #no "return"
p2(2)
p2(1:5)

#for loop (not frequently used in R)
x=vector(length=5)
for(n in 1:5){x[n]=n*n}
plot(1:5,x)

#sapply: "Funtional" (help operate each element)
sapply(x,p2)

#apply
df=data.frame(matrix(1:12,3,4))
df
apply(df,1,max) #"max" of each row
apply(df,2,min) #"min" of each col

#replicate (really "replicate".)
replicate(3, 1:5)

#also:
#lapply, tapply, mapply, vapply, replicate




#------------- CH4 Tidyverse ----------------

library(tidyverse)
#data be reshaped into "tidy" format to optimally use tidyverse
#tidy: if matched each row-observation / each col-variables (not necessary: unique by "id")

data(co2)
head(co2) #not tidy - have to be wrangled -> each co2 observation have one row


#mutate / filter/ select
data(murders)
murders=mutate(murders,rate=total/population*100000,rank=rank(-rate)) #rank: desc!
head(murders) 
filter(murders,rate<3&state=="New York")         #data, condition
select(murders,state,region,rate) #data,vars~


#pipe: can use with same first argument
16%>%sqrt()
16|>sqrt() #works same
mutate(murders,rate=total/population*100000,rank=rank(-rate))|>select(rate,rank)|>head()
filter(murders,rate<3&state=="New York")|>select(rate,rank) #so the result itself can come first.

library(dplyr)
library(dslabs)
data(heights)
heights|>filter(sex=="Female")|>summarize(avg=mean(height),sd=sd(height)) #easily written report.


#"average murder rate"
x=murders|>summarize(avg=sum(total)/sum(population)*100000) #can save.
class(x) #df
class(x['avg']) #df
class(x|>pull(avg)) #numeric! wunderbar~*.


#group_by & summarize *both class: ~ "tbl" ~
heights|>group_by(sex) #not useful until applying "summarize"
heights|>group_by(sex)|>summarize(avg=mean(height))


#sort: arrange & top_n
heights|>arrange(desc(height))|>head() #asc default
heights|>top_n(5,height) #height then sex


#tibble
class(murders[,4])
class(as_tibble(murders)[,4]) #useful when df as input required.
#unlike df, tbl's subsets are also tbl
#tbl can have complex object like c(mean,median,sd) <function~. yes.

tibble(names=c("a","b","c"),func=c(mean,sd,median))
#data.frame(names=c("a","b","c"),func=c(mean,sd,median)) - Error


#how to call first argument in pipe? '.' said to be used... like |>.$var


#purrr! - similar to sapply but better interact with tidyverse
library(purrr)
df=tibble(X=c(1,2,3),Y=c(3,4,6))
map(df,max) #class: list
map_dbl(df,max) #class: numeric
map_df(df,max) #tibble


#case_when : useful making new var from categ
x=c(-2,-1,0,1,2)
case_when(x<0~"N",x>=0~"P?",x==0~"Z",) #case_when : if elif... else + [] in Python
#use T~ instead "else"
murders|>mutate(group=case_when(abb%in%c("ME","NH")~"1",abb%in%c("WA","OR")~"2",T~"3"))|>group_by(group)|>summarize(rate=sum(total)/sum(population)*10^5)


#between : mask
between(1:4, 2,3) #T/F, class:logical




#------------- CH5 Import ----------------

#copy and save file from dslabs package
dir=system.file("extdata",package="dslabs") #sub directory / full path before it relevant to package
file.copy(file.path(dir,"murders.csv"),"murders.csv") #TRUE only for the first copy
#can import file easily after that..
dat=read_csv("murders.csv")
dat

list.files(path=dir)
list.files() #file in working directory
getwd() #setwd() #working directory


#read_ : txt>table( ),delim(defined by user), csv>csv(,)&csv2(;), tsv>tsv
#or can use readxl package (functions: read_excel, read_xls, read_xlsx)
#string of url can be used as filepath

#quick check before loading all
read_lines("murders.csv",n_max=3)
scan(file.path(dir,"murders.csv"),sep=",",what="c") #shows every element

#download.file(url,filename) < copy as local file

#R-based functions (read_table/csv/delim): stringAsFactors=F default now. (so class of vars are not factor)




#------------- CH6 ggplot2 ----------------
library(dslabs)
library(ggplot2)
data(murders)
ggplot(data=murders)+geom_point(aes(population/10^6,total))+geom_text(aes(population/10^6,total,label=abb)) #label inside aes
ggplot(data=murders)+geom_point(aes(population/10^6,total))+geom_text(aes(population/10^6,total,label=abb),nudge_x=1.5) #text moved

#|> used
murders|>ggplot(aes(population/10^6,total,label=abb))+geom_point(size=3)+geom_text(nudge_x=1.5)
grid=murders|>ggplot(aes(population/10^6,total,label=abb)) #size essential
grid+geom_point(size=1)+geom_text(aes(10,800,label="text like this"))

#scale
p_t_=murders|>ggplot(aes(population/10^6,total,label=abb))+geom_point(size=3)+geom_text(nudge_x=1.5)
#scaling selection by trans=""
p_t_+scale_x_continuous(trans="log10")++scale_y_continuous(trans="log10") #to move text: nudge_x > 0.05

#another way of scaling&labs&title
p=murders|>ggplot(aes(population/10^6,total,label=abb))+geom_point(size=3)+geom_text(nudge_x=0.05)+
  scale_x_log10()+scale_y_log10()+xlab("here")+ylab("here")+ggtitle("here!")

#color=blue
murders|>ggplot(aes(population/10^6,total,label=abb))+geom_point(size=3,color="blue")+geom_text(nudge_x=0.05)+
  scale_x_log10()+scale_y_log10()+xlab("here")+ylab("here")+ggtitle("here!")

#color=categ
murders|>ggplot(aes(population/10^6,total,label=abb))+geom_point(aes(col=region),size=3)+geom_text(nudge_x=0.05)+
  scale_x_log10()+scale_y_log10()+xlab("here")+ylab("here")+ggtitle("here!")

#add line with intercept=r
r=murders%>%summarize(rate=sum(total)/sum(population)*10^6)|>pull(rate)
murders|>ggplot(aes(population/10^6,total,label=abb))+geom_point(aes(col=region),size=3)+geom_text(nudge_x=0.05)+
  scale_x_log10()+scale_y_log10()+xlab("here")+ylab("here")+ggtitle("here!")+geom_abline(intercept=log10(r))

#altogether
library(ggthemes)
library(ggrepel) #line from text to dot far from it added

murders|>ggplot(aes(population/10^6,total,label=abb))+geom_point(aes(col=region),size=3)+geom_text(nudge_x=0.05)+
  scale_x_log10()+scale_y_log10()+xlab("here")+ylab("here")+ggtitle("here!")+geom_abline(intercept=log10(r),lty=2,color="darkgrey")+
  geom_text_repel()+scale_color_discrete(name="Region")+theme_economist()

#qplot (quick plot)
data(murders)
qplot(log10(murders$population),murders$total)

#gridExtra
library(gridExtra)
grid.arrange(qplot(x),qplot(x,y),ncol=2)


#------------- CH7 dist Viz ----------------

#bar by group
murders|>group_by(region)|>summarize(n=n())|>mutate(p=n/sum(n),region=reorder(region,p))|>
  ggplot(aes(x=region,y=p,fill=region))+geom_bar(stat="identity",show.legend=F)


h=heights|>filter(sex=="Male")|>ggplot(aes(height))

#cdf
ds_theme_set()
h+stat_ecdf()
#simple user f
F <- function(a) mean(x<=a)
#F(a)=pnorm(a,m,s)


#hist
h+geom_histogram(binwidth = 1,fill='orange',color="blue")

#smooth (change both adjust !)
h+geom_density(alpha=0.2,fill='orange',color=0,adjust=2)+geom_line(stat='density',adjust=2)

#part coloring (filling) #error caution...
d=with(heights,density(height[sex=="Male"])) #6 numbers
tmp=data.frame(height=d$x,density=d$y)
tmp
tmp|>ggplot(aes(height,density))+geom_line()+
  geom_area(aes(height,density),data=filter(tmp,between(height,65,68)),alpha=0.2,fill='red')

#stratified by fill
heights|>ggplot(aes(height,fill=sex))+
  geom_density(alpha=0.2,color=0)+geom_line(stat='density')

               
#pnorm,qnorm
pnorm(-1,1,2) #0.158  #cumulative p of -1 in norm(1,2)
qnorm(0.158,1,2) #-1

#quantile / percentile
quantile(1:10,seq(0,1,0.1))
qnorm(seq(0,1,0.1),1,2) #theoritical (need more dots)

#qplot = quick plot!
qplot(qnorm(seq(0,1,0.1)),quantile(-5:5,seq(0,1,0.1)))+geom_abline() #what..?? 
qplot(1:20,bins=5,color=I("black"),xlab="Population") #without I.. it is strange...

#qqplot: geom_qq()
params=heights|>filter(sex=="Male")|>summarize(mean=mean(height),sd=sd(height))
heights|>filter(sex=="Male")|>ggplot(aes(sample=height))+geom_qq(dparams=params)+geom_abline()

#image
x=expand.grid(x=1:12,y=1:10)|>mutate(z=1:120)
x|>ggplot(aes(x,y,fill=z))+geom_raster()+scale_fill_gradientn(colors=terrain.colors(11))

#pull
heights|>select(height)|>head()|>pull() #as vector, not tbl


#------------- CH8 gapminder ----------------


#------------- CH10 Probability ----------------

#sample
b=rep(c("0","1"),times=c(2,3)) #not change
e=replicate(10,sample(b,1)) #change
sample(b,10,replace=T) #change

#prop table
table(e)
prop.table(table(e)) #Errg..!

#paste (useful for some permt/comb) #selected like from zip(x,y)
paste(c(1,2),c(4,5)) 

#permutation
expand.grid(l=c("a","b","c","d"),n=1:12)
library(gtools)
permutations(3,3,v=1:5) #use 3 first items of v to make 3P3?

#combination
combinations(3,2) #3C2

#one card
suits=c("Diamonds", "Clubs", "Hearts", "Spades")
numbers=c("Ace", "Deuce", "Three", "Four", "Five",
             "Six", "Seven", "Eight", "Nine", "Ten",
             "Jack", "Queen", "King")
deck=expand.grid(number=numbers, suit=suits)
deck=paste(deck$number, deck$suit)

kings=paste("King",suits)
kings
mean(deck%in%kings) #P(one card from deck is king)

#first card and second card
sample(deck,2)
#or
hands=permutations(52,2,v=deck)
hands[,1][1]; hands[,2][1]
mean(hands[,1]%in%kings&hands[,2]%in%kings)/mean(hands[,1]%in%kings) #P(B|A)

#T or F
aces <- paste("Ace", suits)
facecard <- c("King", "Queen", "Jack", "Ten")
(hands[1] %in% aces & hands[2] %in% facecard) |
  (hands[2] %in% aces & hands[1] %in% facecard)


#Monty Hall Monte Carlo
B <- 10000
monty_hall <- function(strategy){
  doors <- as.character(1:3)
  prize <- sample(c("car", "goat", "goat"))
  prize_door <- doors[prize == "car"]
  my_pick <- sample(doors, 1)
  show <- sample(doors[!doors %in% c(my_pick, prize_door)],1)
  stick <- my_pick
  stick == prize_door
  switch <- doors[!doors%in%c(my_pick, show)]
  choice <- ifelse(strategy == "stick", stick, switch)
  choice == prize_door
}
stick <- replicate(B, monty_hall("stick"))
mean(stick)
switch <- replicate(B, monty_hall("switch"))
mean(switch)

#Birthday Monte Carlo
n <- 50
bdays <- sample(1:365, n, replace = TRUE)

any(duplicated(c(1,2,3,1,4,3,5))) # dup~ return F from second time

B <- 10000
same_birthday <- function(n){
  bdays <- sample(1:365, n, replace=TRUE)
  any(duplicated(bdays))
}
results <- replicate(B, same_birthday(50))
mean(results)

#see the graph of p as n changes
compute_prob <- function(n, B=10000){
  results <- replicate(B, same_birthday(n))
  mean(results)}
n <- seq(1,60)
prob <- sapply(n, compute_prob) #takes 2~3 sec 
qplot(n, prob) 

#...with the exact distribution derived from computation
exact_prob <- function(n){
  prob_unique <- seq(365,365-n+1)/365
  1 - prod( prob_unique)
}
eprob <- sapply(n, exact_prob)
qplot(n, prob) + geom_line(aes(n, eprob), col = "red")

#and can see from what n it is stabilized with some graph(not here)
