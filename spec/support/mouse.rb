def click_and_move_map(map, from:, to:)
  dispatch_event(
    map_element(map),
    "this",
    mouse_event("mousedown", screen_x: from[:x], screen_y: from[:y])
  )
  dispatch_event(
    page,
    "document",
    mouse_event("mousemove", screen_x: to[:x], screen_y: to[:y])
  )
  dispatch_event(page, "document", "new MouseEvent('mouseup')")
end

def alt_click_at(element, x:, y:)
  dispatch_event(
    element,
    "this",
    mouse_event(
      "mousedown",
      client_x: x,
      client_y: y,
      alt_key: true
    )
  )
end

def shift_click_at(element, x:, y:)
  dispatch_event(
    element,
    "this",
    mouse_event(
      "mousedown",
      client_x: x,
      client_y: y,
      shift_key: true
    )
  )
end

def shift_click(element)
  dispatch_event(
    element,
    "this",
    mouse_event(
      "click",
      shift_key: true
    )
  )
end

def mouse_move_to(x:, y:)
  dispatch_event(
    page,
    "document",
    mouse_event(
      "mousemove",
      client_x: x,
      client_y: y
    )
  )
end

def mouse_release
  dispatch_event(
    page,
    "document",
    mouse_event(
      "mouseup"
    )
  )
end

def middle_of(element)
  relative_position_of(element, x: 0.5, y: 0.5)
end

def relative_position_of(element, x:, y:)
  {
    x: element.native.location.x + element.native.size.width * x,
    y: element.native.location.y + element.native.size.height * y
  }
end

def map_element(map)
  find(".current-map[data-map-id='#{map.id}'][data-map-id='#{map.id}']")
end

def click_and_move_token(token, by:)
  element = token_element(token)
  page.execute_script("window.tempDataTransfer = new DataTransfer()")
  dispatch_event(
    element,
    "this",
    drag_event(
      "dragstart",
      client_x: element.native.location.x,
      client_y: element.native.location.y
    )
  )
  dispatch_event(
    element,
    "this",
    drag_event(
      "drag",
      client_x: by[:x] + element.native.location.x,
      client_y: by[:y] + element.native.location.y
    )
  )
  dispatch_event(
    element.ancestor("[data-controller~='map']"),
    "this",
    drag_event(
      "dragover",
      client_x: by[:x] + element.native.location.x,
      client_y: by[:y] + element.native.location.y
    )
  )
  dispatch_event(
    element,
    "this",
    drag_event(
      "drag",
      client_x: by[:x] + element.native.location.x,
      client_y: by[:y] + element.native.location.y
    )
  )
  dispatch_event(
    element,
    "this",
    drag_event(
      "dragend",
      client_x: element.native.location.x,
      client_y: element.native.location.y
    )
  )
  page.execute_script("delete window.tempDataTransfer")
end

def dispatch_event(node, element, event)
  node.execute_script("#{element}.dispatchEvent(#{event})")
end

def drag_event(event, options)
  js_event(
    "MouseEvent",
    event,
    options.merge(data_transfer: "window.tempDataTransfer")
  )
end

def mouse_event(event, options = {})
  js_event("MouseEvent", event, options)
end

def js_event(type, event, options)
  camelized_options = options
    .deep_transform_keys { |key| key.to_s.camelize(:lower) }
    .map { |key, value| "#{key}: #{value}" }
    .join(",")

  <<~JS
    new #{type}(
      '#{event}',
      {
        #{camelized_options}
      }
    )
  JS
end
