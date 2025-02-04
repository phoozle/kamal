class Kamal::Commands::Builder::Base < Kamal::Commands::Base
  class BuilderError < StandardError; end

  ENDPOINT_DOCKER_HOST_INSPECT = "'{{.Endpoints.docker.Host}}'"

  delegate :argumentize, to: Kamal::Utils
  delegate \
    :args, :secrets, :dockerfile, :target, :arches, :local_arches, :remote_arches, :remote,
    :cache_from, :cache_to, :ssh, :provenance, :sbom, :driver, :docker_driver?,
    to: :builder_config

  def clean
    send("#{config.container_manager.manager}_clean")
  end

  def docker_clean
    docker :image, :rm, "--force", config.absolute_image
  end

  def podman_clean
    podman :image, :rm, "--force", config.absolute_image
  end

  def push
    send("#{config.container_manager.manager}_push")
  end

  def docker_push
    docker :buildx, :build,
      "--push",
      *platform_options(arches),
      *([ "--builder", builder_name ] unless docker_driver?),
      *build_options,
      build_context
  end

  def podman_push
    combine \
      podman(:buildx, :build,
        *platform_options(arches),
        *build_options,
        build_context
      ),
      podman(:push, config.absolute_image)
  end

  def pull
    send("#{config.container_manager.manager}_pull")
  end

  def docker_pull
    container_manager :pull, config.absolute_image
  end

  def podman_pull
    podman :pull, config.absolute_image
  end

  def info
    send("#{config.container_manager.manager}_info")
  end

  def docker_info
    combine \
      docker(:context, :ls),
      docker(:buildx, :ls)
  end

  def podman_info
    podman :version
  end

  def inspect_builder
    docker :buildx, :inspect, builder_name unless podman? || docker_driver?
  end

  def build_options
    [ *build_tags, *build_cache, *build_labels, *build_args, *build_secrets, *build_dockerfile, *build_target, *build_ssh, *builder_provenance, *builder_sbom ]
  end

  def build_context
    config.builder.context
  end

  def validate_image
    pipe \
      container_manager(:inspect, "-f", "'{{ .Config.Labels.service }}'", config.absolute_image),
      any(
        [ :grep, "-x", config.service ],
        "(echo \"Image #{config.absolute_image} is missing the 'service' label\" && exit 1)"
      )
  end

  def first_mirror
    docker(:info, "--format '{{index .RegistryConfig.Mirrors 0}}'")
  end

  private
    def build_tags
      [ "-t", config.absolute_image, "-t", config.latest_image ]
    end

    def build_cache
      if cache_to && cache_from
        [ "--cache-to", cache_to,
          "--cache-from", cache_from ]
      end
    end

    def build_labels
      argumentize "--label", { service: config.service }
    end

    def build_args
      argumentize "--build-arg", args, sensitive: true
    end

    def build_secrets
      argumentize "--secret", secrets.keys.collect { |secret| [ "id", secret ] }
    end

    def build_dockerfile
      if Pathname.new(File.expand_path(dockerfile)).exist?
        argumentize "--file", dockerfile
      else
        raise BuilderError, "Missing #{dockerfile}"
      end
    end

    def build_target
      argumentize "--target", target if target.present?
    end

    def build_ssh
      argumentize "--ssh", ssh if ssh.present?
    end

    def builder_provenance
      argumentize "--provenance", provenance unless provenance.nil?
    end

    def builder_sbom
      argumentize "--sbom", sbom unless sbom.nil?
    end

    def builder_config
      config.builder
    end

    def platform_options(arches)
      argumentize "--platform", arches.map { |arch| "linux/#{arch}" }.join(",") if arches.any?
    end
end
