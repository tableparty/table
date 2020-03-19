FactoryBot.define do
  factory :campaign do
    name { "Dragon of Icespire Peak" }
  end

  factory :map do
    campaign
    name { "Dwarven Excavation" }
  end
end
