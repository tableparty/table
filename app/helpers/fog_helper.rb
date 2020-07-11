module FogHelper
  def serialize_fog_areas(fog_areas)
    safe_join(
      [
        "[",
        safe_join(
          fog_areas.map do |fog_area|
            safe_join(
              [
                "{ \"id\": \"#{fog_area.id}\", \"path\": ",
                fog_area.path,
                " }"
              ]
            )
          end, ", "
        ),
        "]"
      ]
    )
  end
end
