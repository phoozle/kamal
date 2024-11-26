class Kamal::Commands::Builder::Local < Kamal::Commands::Builder::Base
  def create
    container_manager :buildx, :create, "--name", builder_name, "--driver=#{driver}" unless docker_driver?
  end

  def remove
    container_manager :buildx, :rm, builder_name unless docker_driver?
  end

  private
    def builder_name
      "kamal-local-#{driver}"
    end
end
