class Kamal::Commands::Registry < Kamal::Commands::Base
  delegate :registry, to: :config

  def login
    container_manager \
      :login,
      registry.server,
      "-u", sensitive(Kamal::Utils.escape_shell_value(registry.username)),
      "-p", sensitive(Kamal::Utils.escape_shell_value(registry.password))
  end

  def logout
    container_manager :logout, registry.server
  end
end
