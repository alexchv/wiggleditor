class ProxyController < ApplicationController

  def highlighter
    require 'open-uri'
    file = open(params[:url], 'User-Agent' => 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_10_3) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/43.0.2357.134 Safari/537.36')

    html_content = file.read

    nokogiri_doc = Nokogiri::HTML(html_content)

    # fix relative css paths
    stylesheets = nokogiri_doc.search('link[rel="stylesheet"]')

    stylesheets.each do |stylesheet|
      stylesheet_path = URI.parse(stylesheet['href'])
      next if stylesheet_path.host.present?
      stylesheet['href'] = [params[:url], stylesheet['href']].join
    end

    # fix relative images paths
    images = nokogiri_doc.search('img')

    images.each do |image|
      image_path = URI.parse(image['src'])
      next if image_path.host.present?
      image['src'] = [params[:url], image['src']].join
    end

    # remove js scripts
    scripts = nokogiri_doc.search('script')
    scripts.each { |script| script.remove }

    render :inline => nokogiri_doc.to_html
  end

end