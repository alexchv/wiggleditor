class ProxyController < ApplicationController

  def highlighter
    require 'open-uri'
    file = open(params[:url], 'User-Agent' => 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_10_3) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/43.0.2357.134 Safari/537.36')

    html_content = file.read

    nokogiri_doc = Nokogiri::HTML(html_content)

    # fix relative css paths
    stylesheets = nokogiri_doc.search('link[rel="stylesheet"]')

    stylesheets.each do |stylesheet|
      next if validate_uri(stylesheet['href'])
      stylesheet['href'] = [params[:url], stylesheet['href']].join
    end

    # fix relative images paths
    images = nokogiri_doc.search('img')

    images.each do |image|
      next if validate_uri(image['src'])
      image['src'] = [params[:url].gsub('https', 'http'), image['src']].join
    end

    # fix style background
    background_images = nokogiri_doc.search('[style]')
    ulr_regexp = /url\((.+)\)/
    background_images.each{ |n|
      if n['style'][ulr_regexp, 1]
        n['style'] = n['style'].gsub(n['style'][ulr_regexp, 1], params[:url].gsub('https', 'http') + n['style'][ulr_regexp, 1]) unless validate_uri(n['style'][ulr_regexp, 1])
      end
    }

    # remove js scripts
    # scripts = nokogiri_doc.search('script')
    # scripts.each { |script| script.remove }

    render :inline => nokogiri_doc.to_html
  end

  private

  def validate_uri(path)
    URI.parse(path).host.present?
  rescue => e
    puts e.message
    true
  end

end