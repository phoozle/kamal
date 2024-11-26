class Kamal::Configuration::ContainerManager
  include Kamal::Configuration::Validation

  attr_reader :container_manager_config

  def initialize(config:)
    @container_manager_config = config.raw_config.container_manager || {}

    validate! container_manager_config, with: Kamal::Configuration::Validator::ContainerManager
  end

  def manager
    container_manager_config["manager"]
  end

  def docker?
    manager == "docker"
  end

  def podman?
    manager == "podman"
  end
end
