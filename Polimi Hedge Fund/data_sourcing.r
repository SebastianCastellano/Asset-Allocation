library(quantmod)

getSymbols('AAPL')
aaplDiv <- getDividends('AAPL')
getSplits('AAPL')
getFinancials('AAPL')

getSymbols('^GSPC') # S&P500
getSymbols('^RUT') # Russel2000
getSymbols('^STOXX50E') #Euro stoxx 50
getSymbols('CL=F') # crude oil
getSymbols('GC=F') # gold
getSymbols('IEAG.AS') #iShares ??? Aggregate Bond UCITS ETF EUR (Dist) (IEAG.AS) WARNING! NAs, distributions
getDividends('IEAG.AS')
getSymbols('TLT') #iShares 20+ Year Treasury Bond ETF (TLT)
getSymbols('EUR=X')

getMetals('gold', from='2010-01-01')


library(Quandl)

gold <- Quandl('BUNDESBANK/BBK01_WT5511')






























