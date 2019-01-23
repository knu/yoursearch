class Suggestions::Rubygems < Suggestions
  require 'suggestions/rubygems/entry'

  ENGINE_NAME     = 'rubygems'
  ENGINE_TITLE    = 'RubyGems'
  ENGINE_ICON_URI = URI('https://rubygems.org/favicon.ico')

  SITE_URI = URI('https://rubygems.org/')
  SEARCH_URI = SITE_URI + 'search'

  def initialize(keyword, lang: nil)
    super

    return if /[^\w\-]/ === keyword

    self.class.fetch_index if Entry.count.zero?

    Entry.where('name LIKE ? ESCAPE ?', keyword.gsub(/([_%=])/, '=\\1') + '%', '=').limit(5).each { |entry|
      add(entry.name, '', gem_uri(entry.name))
    }
  end

  private

  def gem_uri(name)
    SITE_URI + 'gems/' + escape(name)
  end

  class << self
    def fetch_index
      blob = HTTP.get(SITE_URI + 'latest_specs.4.8.gz').body
      tuples = Marshal.load(Gem::Util.gunzip(blob))

      Entry.import {
        tuples.each { |name, version|
          begin
            Entry.create(name: name)
          rescue ActiveRecord::RecordNotUnique
            # Multi-platform gems appear many times.
          end
        }
      }
    end
  end
end
