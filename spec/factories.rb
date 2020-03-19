FactoryBot.define do
  factory :campaign do
    name { "Dragon of Icespire Peak" }
  end

  factory :map do
    campaign
    name { "Dwarven Excavation" }
    image do
      Rack::Test::UploadedFile.new("spec/fixtures/files/dwarven-excavation.jpg")
    end
  end
end
