def have_map_with_data(map, attribute, value)
  have_css(
    ".current-map[data-map-id='#{map.id}'][data-#{attribute}='#{value}']"
  )
end
