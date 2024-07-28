import HTTP, EzXML
#= 
Every 10 minutes, it should go through a list of domains, check every path (maybe read sitemap) 
If anywhere it founds an error code, the telegram bot will message me about it in the format 
>> ERROR 404 on: chinadea.ru/cars/manjaro
=#


const ten_minutes_in_secs = 600
domains = [
    "https://chinadeal.ru",
    "https://autosalon-samara63.ru"
]

for domain in domains
    r = HTTP.request("GET", domain)
    status = r.status

    if status != 200
        # println("RESPONSE FROM $domain: $status")
        # TODO: Message on telegram bot
    end
end

function check_domain(domain::String)::Int
    r = HTTP.request("GET", domain)
end

# function get_sitemap(domain::String)

# sleep(ten_minutes_in_secs)