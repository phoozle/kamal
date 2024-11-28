module Kamal::Commands::App::Images
  def list_images
    container_manager :image, :ls, config.repository
  end

  def remove_images
    container_manager :image, :prune, "--all", "--force", *image_filter_args
  end

  def tag_latest_image
    container_manager :tag, config.absolute_image, config.latest_image
  end
end
