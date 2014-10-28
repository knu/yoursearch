require 'base64'
require 'rack/utils'
require 'uri'

class Suggestions
  def initialize(keyword, lang: nil)
    @output = [
      keyword,
      @terms = [],
      @descriptions = [],
      @urls = []
    ]
    @langs = Array(lang)
  end

  attr_accessor :langs

  def size
    @terms.size
  end

  def empty?
    size.zero?
  end

  def destination_url
    @urls.first
  end

  include Enumerable

  def each
    size.times { |i|
      yield [@terms[i], @descriptions[i], @urls[i]]
    }
    self
  end

  def add(term, description = nil, url = nil)
    @terms << term.to_s
    @descriptions << description.to_s
    @urls << url.to_s
    self
  end

  def as_json
    @output
  end

  def to_json
    as_json.to_json
  end

  HTTP = Faraday.new { |builder|
    builder.use FaradayMiddleware::FollowRedirects
    builder.request :url_encoded
    builder.adapter Faraday.default_adapter
  }

  private

  def escape(string)
    Rack::Utils.escape_path(string)
  end

  Engine = Struct.new(:class, :name, :title, :icon_uri)
  class Engine
    def new(*args)
      self[:class].new(*args)
    end

    def icon
      @icon ||= 'data:image/x-icon;base64,' << Base64.strict_encode64(HTTP.get(icon_uri).body)
    end
  end

  class << self
    def inherited(subclass)
      subclass.const_set(:HTTP, HTTP)
      (@subclasses ||= []) << subclass
      @engines = nil
    end

    def engines
      @engines ||= {}.tap { |engines|
        @subclasses.each { |subclass|
          engines[subclass::ENGINE_NAME] = Engine.new(
            subclass,
            subclass::ENGINE_NAME,
            subclass::ENGINE_TITLE,
            subclass::ENGINE_ICON_URI,
          )
        }
      }
    end
  end
end

require 'suggestions/twitter'
require 'suggestions/github'
require 'suggestions/rubygems'
require 'suggestions/wikipedia'
