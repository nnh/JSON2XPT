test <- data.frame(matrix(rep(NA, 12), nrow=4))
test$X1 <- 'a'
test$X2 <- 1
test$X3 <- 'bbb'
haven::write_xpt(test, path="//aronas/Datacenter/Users/ohtsuka/2019/20200316/test/test/haven_v8_test/test_r.xpt", version=8, name="test")

