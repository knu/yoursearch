require 'bundler'
Bundler.require

require 'dotenv'
Dotenv.load

require 'sinatra/json'

$LOAD_PATH.unshift(File.expand_path('lib', File.dirname(__FILE__)))

require 'suggestions'

set :search_languages, ENV['SEARCH_LANGUAGES'].to_s.split(/,/i) ||
                       ENV['LANG'].to_s[/\A[a-z]{2}/]

set :erubis, escape_html: true
set :json_content_type, 'application/x-suggestions+json; charset=UTF-8'

helpers do
  def app_base_uri
    URI(request.base_url) + "#{ENV['RAILS_RELATIVE_URL_ROOT']}/"
  end

  def engine_xml_url(engine)
    (app_base_uri + '%s.xml' % engine.name).to_s
  end
end

set :views, File.expand_path('views', File.dirname(__FILE__))

get '/' do
  @engines = Suggestions.engines.values
  erb :'index.html'
end

get '/:engine.?:format?' do
  if @engine = Suggestions.engines[params[:engine]]
    case params[:format]
    when 'xml'
      content_type 'application/opensearchdescription+xml; charset=UTF-8'
      halt(erb :'engine.xml')
    else
      halt(erb :'engine.html')
    end
  end

  error 404
end

get '/search/:engine.?:format?' do
  keyword = params[:q] || ''

  if @engine = Suggestions.engines[params[:engine]]
    @suggestions = @engine.new(keyword, lang: Array(settings.search_languages))
  else
    status 404
    case params[:format]
    when 'json'
      halt json([])
    else
      halt 'not found'
    end
  end

  case params[:format]
  when 'json'
    json @suggestions
  else
    if url = @suggestions.destination_url
      redirect url
    else
      error 404
    end
  end
end
