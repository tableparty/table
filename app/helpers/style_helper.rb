module StyleHelper
  def background_image(image)
    "background-image: url('#{j url_for image}');"
  end
end
