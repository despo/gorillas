require 'sinatra/base'
require 'haml'
require 'coffee-script'

module Gorillas
  class App < Sinatra::Base

    set :haml, :format => :html5
    set :views, "#{Dir.pwd}/views"
    set :public_folder, "#{Dir.pwd}/public"

    get '/' do
      haml :index
    end

    get "/gorillas.js" do
      content_type "text/javascript"
      coffee :gorillas
    end

    get "/style.css" do
      scss :style
    end
  end
end
