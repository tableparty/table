namespace :dev do
  desc "Sample data for local development environment"
  task prime: :environment do
    campaign = Campaign.find_or_create_by(name: "Dragon of Icespire Peak")

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
    ].map do |details|
      campaign.maps.find_or_create_by(
        name: details[:name]
      ) do |map|
        map.image.attach(
          io: File.open(
            Rails.root.join("spec/fixtures/files/#{details[:image_filename]}")
          ),
          filename: details[:image_filename]
        )
      end
      Map.all.each(&:center_image)
    end
  end
end
