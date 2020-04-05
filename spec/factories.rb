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

    after(:create, &:center_image)
  end

  factory :token do
    transient do
      image_name { "uxil.jpeg" }
    end

    map
    name { "Uxil" }
    x { rand(100) }
    y { rand(100) }
    image do
      Rack::Test::UploadedFile.new("spec/fixtures/files/#{image_name}")
    end
  end
end
