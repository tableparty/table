def click_and_move_map(map, from:, to:)
  dispatch_event(
    map_element(map),
    "this",
    mouse_event("mousedown", screenX: from[:x], screenY: from[:y])
  )
  dispatch_event(
    page,
    "document",
    mouse_event("mousemove", screenX: to[:x], screenY: to[:y])
  )
  dispatch_event(page, "document", "new MouseEvent('mouseup')")
end

def map_element(map)
  find(".current-map[data-map-id='#{map.id}'][data-map-id='#{map.id}']")
end

def dispatch_event(node, element, event)
  node.execute_script("#{element}.dispatchEvent(#{event})")
end

def mouse_event(event, screenX:, screenY:)
  "new MouseEvent('#{event}', { screenX: #{screenX}, screenY: #{screenY} })"
end
