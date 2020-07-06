class NormalizeMapCoordinates < ActiveRecord::Migration[6.0]
  def change
    Map.all.find_each do |map|
      map.x = map.x / map.zoom_amount
      map.y = map.y / map.zoom_amount
      map.save
    end
  end
end
