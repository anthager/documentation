# Copyright Yahoo. Licensed under the terms of the Apache 2.0 license. See LICENSE in the project root.

require 'json'
require 'nokogiri'
require 'kramdown/parser/kramdown'

module Jekyll

    class VespaIndexGenerator < Jekyll::Generator
        priority :lowest

        def generate(site)
            namespace = site.config["search"]["namespace"]
            operations = []
            site.pages.each do |page|
                next if page.path.start_with?("css/") ||
                        page.url.start_with?("/redirects.json") ||
                        is_empty(page)
                if page.data["index"]
                    text = extract_text(page)
                    outlinks = extract_links(page)
                    headers = extract_headers(page)
                    url = page.url
                    url += 'index.html' if url[-1, 1] == '/'
                    if outlinks && !outlinks.empty?
                        operations.push({
                            :put => "id:"+namespace+":doc::"+namespace+url,
                            :fields => {
                                :path => url,
                                :namespace => namespace,
                                :title => page.data["title"],
                                :content => text,
                                :term_count => text.split.length(),
                                :last_updated => Time.now.to_i,
                                :outlinks => extract_links(page),
                                :headers => headers
                            }
                        })
                    else
                        operations.push({
                            :put => "id:"+namespace+":doc::"+namespace+url,
                            :fields => {
                                :path => url,
                                :namespace => namespace,
                                :title => page.data["title"],
                                :content => text,
                                :term_count => text.split.length(),
                                :last_updated => Time.now.to_i,
                                :headers => headers
                            }
                        })
                    end
                end
            end

            json = JSON.pretty_generate(operations)
            File.open(namespace + "_index.json", "w") { |f| f.write(json) }
        end

        def is_empty(page)
            # The generated client-side redirects should not be indexed -
            # they have no title and node content
            return page.content == "" && !page.data["title"]
        end

        def get_doc(page)
            if page.name[page.name.rindex('.')+1..-1] == "md"
                doc = Nokogiri::HTML(Kramdown::Document.new(page.content).to_html)
            else
                doc = Nokogiri::HTML(page.content)
            end
        end

        def extract_text(page)
            doc = get_doc(page)
            doc.search('th,td').each{ |e| e.after "\n" }
            doc.search('style').each{ |e| e.remove }
            content = doc.xpath("//text()").to_s
            return strip_liquid(content.gsub("\r"," ").gsub("\n"," "))
        end

        def extract_links(page)
            doc = get_doc(page)
            links = doc.css('a').map { |link| link['href'] || ""}
            links.reject{ |l| l.empty? }.map{ |l| l }
        end

        def extract_headers(page)
            doc = get_doc(page)
            headers = doc.css('h1,h2,h3,h4').map { |header| header.content.gsub("\r"," ").gsub("\n"," ") || ""}
            headers.reject{ |h| h.empty? }.map{ |h| h }
        end

        def strip_liquid(text)
            return text.gsub(/\{%\s*include\s*(deprecated|important|note|query|warning).html\s*content=\s*(\"|\p{Pi}|\p{Pf}|')/, "")
                       .gsub(/\{%\s*highlight\s*\w*/, "")
                       .gsub(/\{%\s*endhighlight/, "")
                       .gsub(/\{%\s*(raw|endraw)/, "")
                       .gsub(/(\"|\p{Pi}|\p{Pf}|')*\s*%}/, "")
        end

    end

end
