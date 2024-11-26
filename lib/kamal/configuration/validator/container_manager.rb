class Kamal::Configuration::Validator::ContainerManager < Kamal::Configuration::Validator
  VALID_MANAGERS = %w[docker podman]

  def validate!
    unless config.nil?
      super

      if (VALID_MANAGERS.exclude?(config["manager"]))
        error "Invalid manager: #{config["manager"]}"
      end
    end
  end
end
