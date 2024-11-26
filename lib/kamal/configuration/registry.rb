class Kamal::Configuration::Registry
  include Kamal::Configuration::Validation

  DEFAULT_REGISTRY = "docker.io"

  attr_reader :registry_config, :secrets

  def initialize(config:)
    @registry_config = config.raw_config.registry || {}
    @secrets = config.secrets
    validate! registry_config, with: Kamal::Configuration::Validator::Registry
  end

  def server
    registry_config["server"] || DEFAULT_REGISTRY
  end

  def username
    lookup("username")
  end

  def password
    lookup("password")
  end

  private
    def lookup(key)
      if registry_config[key].is_a?(Array)
        secrets[registry_config[key].first]
      else
        registry_config[key]
      end
    end
end
