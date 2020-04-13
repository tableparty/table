FactoryBot.define do
  factory :campaign do
    name { "Dragon of Icespire Peak" }
    user
  end

  factory :character do
    transient do
      image_name { "uxil.jpeg" }
    end

    campaign
    sequence(:name) { |n| "Uxil#{n}" }
    image do
      Rack::Test::UploadedFile.new("spec/fixtures/files/#{image_name}")
    end
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
    sequence(:name) { |n| "Uxil#{n}" }
    x { rand(100) }
    y { rand(100) }
    stashed { true }
    image do
      Rack::Test::UploadedFile.new("spec/fixtures/files/#{image_name}")
    end
  end

  factory :user do
    sequence(:name) { |n| "Dungeon Master#{n}" }
    sequence(:email) { |n| "user-#{n}@thoughtbot.com" }
    password { "password" }
  end
end
