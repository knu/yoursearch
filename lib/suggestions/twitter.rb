class Suggestions::Twitter < Suggestions
  ENGINE_NAME     = 'twitter'
  ENGINE_TITLE    = 'All-in-One Twitter'
  ENGINE_ICON_URI = URI('https://twitter.com/favicon.ico')

  SITE_URI = URI('https://twitter.com/')
  SEARCH_URI = SITE_URI + 'search'
  TOPSY_URI = URI('http://topsy.com/s')

  def initialize(keyword, lang: nil)
    super

    case keyword
    when /\Auser:\s+(\w+)\z/
      add_user($1)
    when /\Asearch(?:\[(\w+)\])?:\s+(.*)/m
      add_query($2, lang: $1)
    when /\Atopsy(?:\[(\w+)\])?:\s+(.*)/m
      add_topsy_query($2, lang: $1)
    else
      add_user(keyword) if /\A\w+\z/ === keyword
      add_query(keyword)
      add_topsy_query(keyword)
      langs.each { |lang|
        add_query(keyword, lang: lang)
        add_topsy_query(keyword, lang: lang)
      }
    end
  end

  def add_user(keyword)
    screen_name = keyword[/\A@?(\w+)/, 1]
    add("user: #{keyword}", "Show Twitter user: @#{screen_name}", user_uri(screen_name))
  end

  def add_query(keyword, lang: nil)
    if lang
      add("search[#{lang}]: #{keyword}",
          "Search Twitter for: #{keyword} [#{lang}]",
          search_uri(keyword, lang: lang))
    else
      add("search: #{keyword}",
          "Search Twitter for: #{keyword}",
          search_uri(keyword))
    end
  end

  def add_topsy_query(keyword, lang: nil)
    if lang
      add("topsy[#{lang}]: #{keyword}",
          "Search Topsy for: #{keyword} [#{lang}]",
          topsy_uri(keyword, lang: lang))
    else
      add("topsy: #{keyword}",
          "Search Topsy for: #{keyword}",
          topsy_uri(keyword))
    end
  end

  private

  def user_uri(screen_name)
    SITE_URI + screen_name
  end

  def search_uri(query, lang: nil)
    query = "lang:#{lang} #{query}" if lang
    SEARCH_URI + '?q=%s' % escape(query)
  end

  def topsy_uri(query, lang: nil)
    if lang
      TOPSY_URI + '?q=%s&language=%s' % [escape(query), escape(lang)]
    else
      TOPSY_URI + '?q=%s' % escape(query)
    end
  end
end
