class ProxyController < ApplicationController

  def highlighter
    require 'open-uri'
    file = open params[:url]
    puts '----'
    puts file.inspect
    puts '----'
    render :inline => file.read
  end

end