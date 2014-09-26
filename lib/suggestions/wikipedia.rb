class Suggestions::Wikipedia < Suggestions
  ENGINE_NAME     = 'wikipedia'
  ENGINE_TITLE    = 'Wikipedia Universal'
  ENGINE_ICON_URI = URI('https://en.wikipedia.org/favicon.ico')

  TIMEOUT = 0.450

  def initialize(keyword, lang: nil)
    super

    self.langs << 'en' << 'ja' if langs.empty?

    case keyword
    when /\A([a-z]{2,3}):\s+(.*)/m
      add_word($2, lang: $1)
    else
      {}.tap { |hash|
        limit =
          case nlangs = langs.size
          when 1, 2, 3
            6 / nlangs
          else
            1
          end

        langs.map { |lang|
          Thread.start {
            begin
              response = HTTP.get { |request|
                request.url search_uri(keyword, lang: lang)
                request.options.timeout = TIMEOUT
              }
              if response.success?
                hash[lang] = JSON.parse(response.body)[1].take(limit)
              end
            rescue Faraday::TimeoutError
            end
          }
        }.each(&:join)

        langs.each { |lang|
          words = hash[lang] or next
          words.each { |word|
            add_word(word, lang: lang)
          }
        }
      }
    end
  end

  def add_word(word, lang: 'en')
    add("#{lang}: #{word}", "Wikipedia [#{lang}]: #{word}", word_uri(word, lang: lang))
  end

  private

  def search_uri(keyword, lang: 'en')
    URI('http://%s.wikipedia.org/w/api.php?action=opensearch&search=%s' % [
          escape(lang), escape(keyword)
        ])
  end

  def word_uri(word, lang: 'en')
    URI('https://%s.wikipedia.org/wiki/%s' % [
          escape(lang), escape(word)
        ])
  end
end
