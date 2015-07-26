class ProxyController < ApplicationController

  def highlighter
    file = open params[:url]
    render :inline => file.read
  end

end