namespace :dev do
  desc "Sample data for local development environment"
  task prime: :environment do
    dm = User.find_or_initialize_by(
      email: "jdbann@icloud.com",
      name: "John Bannister"
    )
    unless dm.persisted?
      dm.password = "prime"
      dm.save
    end

    campaign = Campaign.find_or_create_by(
      name: "Rosewood Street Sewers",
      user: dm
    )

    [
      "Thief",
      "Wizard",
      "Archer"
    ].each do |name|
      campaign.characters.find_or_create_by(name: name) do |character|
        character.image.attach(
          io: File.open(
            Rails.root.join("spec/fixtures/files/#{name.downcase}.jpg")
          ),
          filename: "#{name.downcase}.jpg"
        )
      end
    end

    [
      {
        name: "Map",
        image_filename: "map.jpg"
      }
    ].each do |details|
      map = campaign.maps.find_or_create_by(
        name: details[:name],
        grid_size: 43
      ) do |map_record|
        map_record.image.attach(
          io: File.open(
            Rails.root.join("spec/fixtures/files/#{details[:image_filename]}")
          ),
          filename: details[:image_filename]
        )
      end
      SetupMap.call(map: map)
    end
  end
end
