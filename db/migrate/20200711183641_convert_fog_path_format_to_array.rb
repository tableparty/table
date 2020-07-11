class ConvertFogPathFormatToArray < ActiveRecord::Migration[6.0]
  def up
    FogArea.find_each do |fog_area|
      segments = fog_area.path.split(" ").reduce([]) do |items, value|
        if ("a".."z").cover?(value.downcase)
          items << [value]
        else
          items[-1] << value
        end
        items
      end

      json_path = segments.map do |segment|
        next if segment[0].casecmp("z").zero?

        { x: segment[1].to_i, y: segment[2].to_i }
      end.compact.to_json

      fog_area.update_attribute(:path, json_path)
    end
  end

  def down
    FogArea.find_each do |fog_area|
      svg_path = JSON.parse(fog_area.path).map.with_index do |segment, index|
        "#{index.zero? ? 'M' : 'L'} #{segment['x']} #{segment['y']}"
      end.join(" ") + " Z"

      fog_area.update_attribute(:path, svg_path)
    end
  end
end
