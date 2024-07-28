import HTTP
#= 
Every 10 minutes, it should go through a list of domains, check every path (maybe read sitemap) 
If anywhere it founds an error code, the telegram bot will message me about it in the format 
>> ERROR 404 on: chinadea.ru/cars/manjaro
=#

r = HTTP.request("GET", "http://httpbin.org/ip")
println(r.status)
println(String(r.body))