class ProxyController < ApplicationController

  def highlighter
    file = open params[:url]
    puts '----'
    puts file.inspect
    puts '----'
    render :inline => file.read
  end

end