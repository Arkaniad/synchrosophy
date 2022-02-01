# frozen_string_literal: true

module IssueSync
  class Config
    attr_accessor :services, :repositories
    
    def initialize(services:, repositories:)
      @services = services
      @repositories = repositories
    end
  end

  class ServiceConfig
    attr_accessor :type, :credentials

    def initialize(type:, credentials:)
      @type = type
      @name = name
      @credentials = credentials
    end
  end

  class RepositoryConfig
    attr_accessor :name, :source, :target

    def initialize(name:, source:, target:)
      @name = name
      @source = source
      @target = target
    end
  end

  class RepositorySource
    attr_accessor :type, :path

    def initialize(type:, path:)
      @type = type
      @name = name
      @path = path
    end
  end

  class RepositoryTarget
    attr_accessor :type, :path

    def initialize(type:, path:)
      @type = type
      @name = name
      @path = path
    end
  end
end
