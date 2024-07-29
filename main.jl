using HTTP
using LightXML
using Dates
using Logging
using Telegram, Telegram.API
using DotEnv

DotEnv.load!()

tg = TelegramClient(ENV["TELEGRAM_TOKEN"], chat_id=ENV["CHAT_ID"])

@enum SiteType begin
    New
    Old
    BackNew
    BackBU
end

struct Site
    url::String
    type::SiteType
end

const CHECK_INTERVAL = Minute(10)
const DOMAINS = [
    Site("https://chinadeal.ru", New),
    Site("https://autosalon-samara63.ru", New),
    Site("https://tc-at.store/api/site/brands/", BackNew),
    Site("https://tc-at.store/api/site/brands/kia", BackNew),
    Site("https://tc-at.store/api/site/brands/kia/models/", BackNew),
    Site("https://tc-at.store/api/site/brands/kia/models/picanto", BackNew),
    Site("https://tc-at.store/api/site/brands/kia/models/picanto/cars/632", BackNew),
    Site("https://tc-at.store/api/site/attributes", BackNew),
    Site("https://seasides.ru/api/site/brands/", BackNew),
    Site("https://seasides.ru/api/site/brands/kia", BackNew),
    Site("https://seasides.ru/api/site/brands/kia/models/", BackNew),
    Site("https://seasides.ru/api/site/brands/kia/models/picanto", BackNew),
    Site("https://seasides.ru/api/site/brands/kia/models/picanto", BackNew),
    Site("https://seasides.ru/api/site/brands/kia/models/picanto/cars/632", BackNew),
    Site("https://seasides.ru/api/site/attributes", BackNew),
]



function check_status(url::String)::Tuple{Bool,Int}
    status = 0
    try
        r = HTTP.get(url, connect_timeout=10, readtimeout=30)
        global status = r.status
        return r.status == 200, r.status
    catch e
        @error "Error checking status for $url: $e"
        return false, status
    end
end

function get_file_content(url::String)::String
    try
        r = HTTP.request("GET", url; connect_timeout=10, readtimeout=30)
        return String(r.body)
    catch e
        @error "Error fetching content from $url: $e"
        return ""
    end
end

function parse_sitemap(document::String)::Vector{String}
    try
        xdoc = parse_string(document)
        xroot = root(xdoc)
        ces = get_elements_by_tagname(xroot, "url")

        links = String[]
        for el in ces
            priority_el = find_element(el, "priority")
            priority = priority_el === nothing ? 1.0 : parse(Float64, content(priority_el))
            if priority <= 0.9
                break
            end
            location = content(find_element(el, "loc"))
            push!(links, location)
        end

        free(xdoc)
        return links
    catch e
        @error "Error parsing sitemap: $e"
        return String[]
    end
end

function validate_xml_feed(doc::String)::Tuple{String,Bool}
    try
        parse_string(doc)
        return "", false
    catch e
        return string(e), true
    end
end

function send_telegram_message(message::String)
    @info "Sending Telegram message: $message"
    sendMessage(text=message, chat_id=ENV["CHAT_ID"])
end

function check_site(site::Site)
    @info "Checking site: $(site.url)"

    res, status = check_status(site.url)
    if !res
        send_telegram_message("ERROR status: $status on: $(site.url)")
    end

    if site.type in [BackNew, BackBU]
        return  # Skip sitemap and feed checks for BackNew and BackBU sites
    end

    sitemap_content = get_file_content(site.url * "/sitemap.xml")
    if isempty(sitemap_content)
        send_telegram_message("ERROR: Unable to fetch sitemap for $(site.url)")
        return
    end

    sitemap_links = parse_sitemap(sitemap_content)
    if isempty(sitemap_links)
        send_telegram_message("ERROR: Invalid or empty sitemap for $(site.url)")
    end

    for link in sitemap_links
        @info "Checking site: $(link)"
        res, status = check_status(link)
        if !res
            send_telegram_message("ERROR $status on: $link")
        end
    end

    feed_content = get_file_content(site.url * "/feed.xml")
    if !isempty(feed_content)
        error_message, has_error = validate_xml_feed(feed_content)
        if has_error
            send_telegram_message("ERROR: Invalid XML feed for $(site.url): $error_message")
        end
    else
        send_telegram_message("ERROR: Unable to fetch feed.xml for $(site.url)")
    end
end

function main()
    while true
        for domain in DOMAINS
            check_site(domain)
        end
        sleep(CHECK_INTERVAL)
    end
end

main()