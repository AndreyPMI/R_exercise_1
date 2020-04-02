
library('RCurl')
library('XML') # разбор XML-файлов
library('rjson') # чтение формата JSON
library('rvest') # работа с DOM сайта
library('dplyr') # инструменты трансформирования данных
#выбираем данные 
fileURL <- "https://market.yandex.ru/catalog--smartfony/16814639/list?hid=91491&glfilter=16816262%3A16816264&local-offers-first=0&onstock=1&viewtype=list"
html <-getURL(fileURL)
doc <- htmlParse(html)
rootNode <- xmlRoot(doc)
fileURL2 <- "https://market.yandex.ru/catalog--smartfony/16814639/list?hid=91491&glfilter=16816262%3A16816264&local-offers-first=0&onstock=1&viewtype=list&page=2"
html2 <-getURL(fileURL2)
doc2 <- htmlParse(html2)
rootNode2 <- xmlRoot(doc2)
#находим класс отвечающий за модель
m <- xpathSApply(rootNode, '//h3[@class="n-snippet-card2__title"]/a',
                 xmlValue)
m2 <- xpathSApply(rootNode2, '//h3[@class="n-snippet-card2__title"]/a',xmlValue)
Mod <- c(m,m2)
#находим класс отвечающий за цену 
p <- xpathSApply(rootNode, '//div[@class="price"]', xmlValue)
p2 <- xpathSApply(rootNode, '//div[@class="price"]', xmlValue)
Pr <- c(p,p2)
#за рейтенг
r <- xpathSApply(rootNode, '//div[@class="n-snippet-card2__header-stickers"]', xmlValue)
r2 <- xpathSApply(rootNode2, '//div[@class="n-snippet-card2__header-stickers"]', xmlValue)
Rat <- c(r,r2)

#за остальные хар-ки и выбираем, хоть что-то читаемое 
t <- xpathSApply(rootNode, '//ul[@class="n-snippet-card2__desc n-snippet-card2__desc_type_list"]', xmlValue)
t <- gsub('^.*(Android [0-9][.][0-9]).*$','\\1',t)
t2 <- xpathSApply(rootNode2,  '//ul[@class="n-snippet-card2__desc n-snippet-card2__desc_type_list"]', xmlValue)
t2 <- gsub('^.*(Android [0-9][.][0-9]).*$','\\1',t2)
tr <- c(t,t2)

#оставляем остальное в общем списке
tv <- xpathSApply(rootNode, '//ul[@class="n-snippet-card2__desc n-snippet-card2__desc_type_list"]', xmlValue)
tv <- sub('Android ...','' , tv)
tv2 <- xpathSApply(rootNode2, '//ul[@class="n-snippet-card2__desc n-snippet-card2__desc_type_list"]', xmlValue)
tv2 <- sub('Android ...','' , tv2)
trv <- c(tv,tv2)


#запихиваем все в таблицу 
DF.price <- data.frame(Model = Mod, Price = Pr, Rank = Rat,V_Android=tr,
                       characteristics = trv,stringsAsFactors = F)
# просмотр результата, чтобы все работало как надо
dim(DF.price) # размерность
str(DF.price) # структура
#теперь когда все хорошо, открываем доступ в удобном формате для пользователя 
write.csv(DF.price, file = './DF_price.csv', row.names = F)
