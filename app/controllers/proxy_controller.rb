class ProxyController < ApplicationController
  require 'open-uri'

  def highlighter
    @user_agent = 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_10_3) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/43.0.2357.134 Safari/537.36'

    nokogiri_doc = Nokogiri::HTML(get_webpage_content.read)

    # fix js
    scripts = nokogiri_doc.search('script')
    scripts.each do |script|
      next if validate_uri(script['src'])
      script['src'] = [params[:url], script['src']].join
    end

    # fix relative css paths
    stylesheets = nokogiri_doc.search('link[rel="stylesheet"]')
    stylesheets.each do |stylesheet|
      next if validate_uri(stylesheet['href'])
      stylesheet['href'] = [params[:url], '/', stylesheet['href']].join
    end

    # add polymer js -------
    # <link rel="import" href="components/polymer/polymer.html">
    # bower_components/polymer
    # polymer_js = Nokogiri::XML::Node.new('link', nokogiri_doc)
    # polymer_js['rel'] = 'import'
    # polymer_js['href'] = "http://wiggle-beta.herokuapp.com/proxy?url=#{[params[:url], '/bower_components/polymer/polymer.html'].join}"
    # nokogiri_doc.search('head').first.add_next_sibling(polymer_js)

    # fix import html path
    stylesheets = nokogiri_doc.search('link[rel="import"]')
    stylesheets.each do |import|
      next if validate_uri(import['href'])
      # import['href'] = [params[:url], import['href']].join
      import['href'] = "http://wiggle-beta.herokuapp.com/proxy?url=#{[params[:url], import['href']].join}"
    end
    # ------------

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

    # add element mouseover script
    mouseover_js = Nokogiri::XML::Node.new('script', nokogiri_doc)
    mouseover_js['src'] = 'http://wiggle-beta.herokuapp.com/mo_highlight.js'
    nokogiri_doc.search('body').first.add_next_sibling(mouseover_js)

    render :inline => nokogiri_doc.to_html
  end

  private

    def get_webpage_content
      open(params[:url], 'User-Agent' => @user_agent)
    rescue => e
      if e.message.include?('redirection forbidden')
        if params[:url].include?('https')
          params[:url].gsub!('https', 'http')
        else
          params[:url].gsub!('http', 'https')
        end
        return open(params[:url], 'User-Agent' => @user_agent)
      end
    end

    def validate_uri(path)
      URI.parse(path).host.present?
    rescue => e
      puts e.message
      true
    end

end