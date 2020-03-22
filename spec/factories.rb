FactoryBot.define do
  factory :campaign do
    name { "Dragon of Icespire Peak" }
  end

  factory :map do
    transient do
      image_name { "small-map.jpg" }
    end

    campaign
    name { "Dwarven Excavation" }
    image do
      Rack::Test::UploadedFile.new("spec/fixtures/files/#{image_name}")
    end
  end
end
