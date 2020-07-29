FactoryBot.define do
  factory :campaign do
    name { "Dragon of Icespire Peak" }
    user
  end

  factory :character do
    transient do
      image_name { "thief.jpg" }
    end

    campaign
    sequence(:name) { |n| "Uxil#{n}" }
    image do
      Rack::Test::UploadedFile.new("spec/fixtures/files/#{image_name}")
    end
  end

  factory :creature do
    transient do
      image_name { "thief.jpg" }
    end

    campaign
    sequence(:name) { |n| "Orc#{n}" }
    image do
      Rack::Test::UploadedFile.new("spec/fixtures/files/#{image_name}")
    end
  end

  factory :fog_area do
    map
    id { SecureRandom.uuid } # For attributes_for calls as declared by JS
    path { [{ x: 10, y: 10 }].to_json }
  end

  factory :map do
    transient do
      image_name { "small-map.jpg" }
    end

    campaign
    name { "Dwarven Excavation" }
    grid_size { 50 }
    image do
      Rack::Test::UploadedFile.new("spec/fixtures/files/#{image_name}")
    end

    after(:create, &:center_image)

    trait :current do
      after(:create) do |map|
        map.campaign.update(current_map: map)
      end
    end
  end

  factory :token do
    transient do
      image_name { "thief.jpg" }
    end

    map
    sequence(:name) { |n| "Uxil#{n}" }
    x { rand(100) }
    y { rand(100) }
    stashed { true }
    size { "medium" }
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
