class Suggestions::GitHub < Suggestions
  ENGINE_NAME     = 'github'
  ENGINE_TITLE    = 'All-in-One GitHub'
  ENGINE_ICON_URI = URI('https://github.com/favicon.ico')

  SITE_URI = URI('https://github.com/')
  SEARCH_URI = SITE_URI + 'search'

  TYPES = %w[Users Repositories Code Issues]

  def initialize(keyword, lang: nil)
    super

    case keyword
    when /\Auser:\s+([\w\-]+)\z/
      add_user($1)
    when /\Arepo:\s+([\w\-]+\/[\w\-]+)\z/
      add_repo($1)
    when /\A(#{Regexp.union(TYPES.map(&:downcase))}):\s+(.*)/mo
      add_query($2, type: $1.capitalize)
    when /\Asearch:\s+(.*)/m
      add_query($1)
    else
      add_user(keyword) if /\A[\w\-]+\z\/?/ === keyword
      add_repo(keyword) if /\A[\w\-]+\/[\w\-]+\z/ === keyword
      add_query(keyword)
      add_query(keyword, type: 'Repositories')
      add_query(keyword, type: 'Users')
      add_query(keyword, type: 'Code')
      add_query(keyword, type: 'Issues')
    end
  end

  def add_user(keyword)
    add("user: #{keyword}", "Show GitHub user: @#{keyword.chomp('/')}", user_uri(keyword))
  end

  def add_repo(keyword)
    add("repo: #{keyword}", "Show GitHub repo: @#{keyword}", repo_uri(keyword))
  end

  def add_query(keyword, type: nil)
    if type
      add("#{type.downcase}: #{keyword}", "Search GitHub #{type.downcase} for: #{keyword}", search_uri(keyword, type: type))
    else
      add("search: #{keyword}", "Search GitHub for: #{keyword}", search_uri(keyword))
    end
  end

  private

  def user_uri(user)
    SITE_URI + user
  end

  def repo_uri(user_repo)
    SITE_URI + user_repo
  end

  def search_uri(query, type: nil)
    if type
      SEARCH_URI + '?q=%s&type=%s' % [escape(query), escape(type)]
    else
      SEARCH_URI + '?q=%s' % escape(query)
    end
  end
end
