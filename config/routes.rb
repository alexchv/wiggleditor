Rails.application.routes.draw do

  get 'proxy',    :to => 'proxy#highlighter'

end
