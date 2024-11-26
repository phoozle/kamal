class Kamal::Commands::Proxy < Kamal::Commands::Base
  delegate :argumentize, :optionize, to: Kamal::Utils

  def run
    container_manager \
      :run,
      "--name", container_name,
      "--network", "kamal",
      "--detach",
      "--restart", "unless-stopped",
      "--volume", "kamal-proxy-config:/home/kamal-proxy/.config/kamal-proxy",
      "\$\(#{get_boot_options.join(" ")}\)",
      config.proxy_image
  end

  def start
    container_manager :container, :start, container_name
  end

  def stop(name: container_name)
    container_manager :container, :stop, name
  end

  def start_or_run
    combine start, run, by: "||"
  end

  def info
    container_manager :ps, "--filter", "name=^#{container_name}$"
  end

  def version
    pipe \
      container_manager(:inspect, container_name, "--format '{{.Config.Image}}'"),
      [ :cut, "-d:", "-f2" ]
  end

  def logs(timestamps: true, since: nil, lines: nil, grep: nil, grep_options: nil)
    pipe \
      container_manager(:logs, container_name, ("--since #{since}" if since), ("--tail #{lines}" if lines), ("--timestamps" if timestamps), "2>&1"),
      ("grep '#{grep}'#{" #{grep_options}" if grep_options}" if grep)
  end

  def follow_logs(host:, timestamps: true, grep: nil, grep_options: nil)
    run_over_ssh pipe(
      container_manager(:logs, container_name, ("--timestamps" if timestamps), "--tail", "10", "--follow", "2>&1"),
      (%(grep "#{grep}"#{" #{grep_options}" if grep_options}) if grep)
    ).join(" "), host: host
  end

  def remove_container
    container_manager :container, :prune, "--force", "--filter", "label=org.opencontainers.image.title=kamal-proxy"
  end

  def remove_image
    container_manager :image, :prune, "--all", "--force", "--filter", "label=org.opencontainers.image.title=kamal-proxy"
  end

  def cleanup_traefik
    chain \
      container_manager(:container, :stop, "traefik"),
      combine(
        container_manager(:container, :prune, "--force", "--filter", "label=org.opencontainers.image.title=Traefik"),
        container_manager(:image, :prune, "--all", "--force", "--filter", "label=org.opencontainers.image.title=Traefik")
      )
  end

  def ensure_proxy_directory
    make_directory config.proxy_directory
  end

  def remove_proxy_directory
    remove_directory config.proxy_directory
  end

  def get_boot_options
    combine [ :cat, config.proxy_options_file ], [ :echo, "\"#{config.proxy_options_default.join(" ")}\"" ], by: "||"
  end

  def reset_boot_options
    remove_file config.proxy_options_file
  end

  private
    def container_name
      config.proxy_container_name
    end
end
