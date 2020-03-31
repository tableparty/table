module FlashesHelper
  def flash_icon(style)
    case style
    when "alert"
      inline_svg_tag("icons/exclamation-outline.svg", class: "text-gray-500")
    when "error"
      inline_svg_tag("icons/close.svg", class: "text-red-500")
    when "notice"
      inline_svg_tag("icons/information-outline.svg", class: "text-blue-500")
    when "success"
      inline_svg_tag("icons/checkmark.svg", class: "text-green-500")
    else
      inline_svg_tag("icons/information-outline.svg", class: "text-gray-500")
    end
  end
end
