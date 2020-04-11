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
      name: "Dragon of Icespire Peak",
      user: dm
    )

    [
      {
        name: "Dwarven Excavation",
        image_filename: "dwarven-excavation.jpg"
      },
      {
        name: "Umbrage Hill",
        image_filename: "umbrage-hill.jpg"
      },
      {
        name: "Gnomengarde",
        image_filename: "gnomengarde.jpg"
      }
    ].each do |details|
      map = campaign.maps.find_or_create_by(
        name: details[:name]
      ) do |map_record|
        map_record.image.attach(
          io: File.open(
            Rails.root.join("spec/fixtures/files/#{details[:image_filename]}")
          ),
          filename: details[:image_filename]
        )
      end
      map.center_image
      [
        "Jormund",
        "Olokas",
        "Tanpos",
        "Thoduhr",
        "Uxil",
        "Yenkas"
      ].each do |name|
        map.tokens.find_or_create_by(
          name: name
        ) do |token|
          token.x = (100..500).to_a.sample
          token.y = (100..500).to_a.sample
          token.image.attach(
            io: File.open(
              Rails.root.join("spec/fixtures/files/#{name.downcase}.jpeg")
            ),
            filename: "#{name.downcase}.jpeg"
          )
        end
      end
    end
  end
end
