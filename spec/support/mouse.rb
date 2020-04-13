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

def token_element(token)
  find(".token[data-token-id='#{token.id}']")
end

def dispatch_event(node, element, event)
  node.execute_script("#{element}.dispatchEvent(#{event})")
end

def drag_event(event, client_x:, client_y:)
  <<~JS
    new DragEvent(
      '#{event}',
      {
        clientX: #{client_x},
        clientY: #{client_y},
        dataTransfer: window.tempDataTransfer
      }
    )
  JS
end

def mouse_event(event, screen_x:, screen_y:)
  "new MouseEvent('#{event}', { screenX: #{screen_x}, screenY: #{screen_y} })"
end
