module ModalHelper
  def modal(content)
    content_tag :div, "data-controller": "modal", class: "modal__background" do
      content_tag :div, class: "modal", data: { target: "modal.container" } do
        content
      end
    end
  end
end
