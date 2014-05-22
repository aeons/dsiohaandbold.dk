require 'i18n'
I18n.enforce_available_locales = false
require 'date'
require 'slugify'

LOCALE = :da

module Filters
  def array_to_sentence(array)
    connector = "og"
    case array.length
    when 0
      ""
    when 1
      array[0].to_s
    when 2
      "#{array[0]} #{connector} #{array[1]}"
    else
      "#{array[0...-1].join(', ')} #{connector} #{array[-1]}"
    end
  end

  def positive_plus(input)
    input = "+#{input}" if input > 0
    input
  end

  def to_datetime(input)
    DateTime.parse(input)
  end

  # https://github.com/gacha/gacha.id.lv/blob/master/_plugins/i18n_filter.rb
  # Example:
  #   {{ post.date | localize: "%d.%m.%Y" }}
  #   {{ post.date | localize: ":short" }}
  def localize(input, format=nil)
    load_translations
    format = (format =~ /^:(\w+)/) ? $1.to_sym : format
    I18n.l(input, :locale => LOCALE, :format => format)
  end

  def load_translations
    unless I18n::backend.instance_variable_get(:@translations)
      I18n.backend.load_translations(Dir[File.join(File.dirname(__FILE__),'/*.yml')])
      I18n.locale = LOCALE
    end
  end

  def slugify(input)
    input.slugify
  end
end

Liquid::Template.register_filter(Filters)
