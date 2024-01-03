# frozen_string_literal: true

module Configem
  VERSION = "1.0.7"

  class << self
    def included(base)
      base.extend(ClassMethods)
    end

    def extended(base)
      base.extend(ClassMethods)
    end

    def prepended(base)
      base.extend(ClassMethods)
    end
  end

  module ClassMethods
    def config
      @config ||= Configuration.new
    end

    def configure
      yield config
    end
  end

  class Configuration
    def method_missing(method, *args)
      singleton_class.class_eval { attr_accessor "#{method.to_s.delete("=")}" }
      send(method, args[0])
    end
  end
end
