b0<-1.5
b1<-.8

x<- rnorm(100, 0, 1)

y<- rnorm(100, b0 + b1*x, .1)
plot(y~x)
summary(lm(y~x))

res<-NA

for(i in 1:1000){
  res[i]<-rnorm(1, b0 + b1*x, .1 )
  
}


hist(res)
