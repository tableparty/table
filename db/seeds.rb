DEMO_SECRET = ENV.fetch("DEMO_SECRET")

demo_user = User.find_or_initialize_by(
  email: "#{DEMO_SECRET}@example.com",
  name: "Demo"
)
unless demo_user.persisted?
  demo_user.password = DEMO_SECRET
  demo_user.save!
end

campaign = demo_user.campaigns.find_or_create_by!(
  name: "Homepage Demo"
)

map = campaign.maps.find_or_initialize_by(name: "Demo Map")
map.image.attach(
  io: File.open(
    Rails.root.join("spec/fixtures/files/map.jpg")
  ),
  filename: "map.jpg"
)
map.update(x: 504, y: 528, zoom: 3, grid_size: 65)
map.reload.image.analyze
campaign.update(current_map: map)

[
  {
    name: "Wahab",
    filename: "archer.jpg",
    x: 476,
    y: 269
  },
  {
    name: "Leah",
    filename: "thief.jpg",
    x: 386,
    y: 448
  },
  {
    name: "Najal",
    filename: "wizard.jpg",
    x: 478,
    y: 451
  }
].each do |attributes|
  character = campaign.characters.find_or_initialize_by(name: attributes[:name])
  character.image.attach(
    io: File.open(
      Rails.root.join("spec/fixtures/files/#{attributes[:filename]}")
    ),
    filename: attributes[:filename]
  )
  token = map.tokens.find_or_create_by!(token_template: character)
  token.update(
    stashed: false,
    x: attributes[:x],
    y: attributes[:y],
    map: map
  )
end

[
  {
    name: "Bone Collector",
    filename: "skeleton.jpg",
    positions: [
      { x: 292, y: 220 },
      { x: 201, y: 312 },
      { x: 294, y: 452 }
    ]
  }
].each do |attributes|
  creature = campaign.creatures.find_or_initialize_by(name: attributes[:name])
  creature.image.attach(
    io: File.open(
      Rails.root.join("spec/fixtures/files/#{attributes[:filename]}")
    ),
    filename: attributes[:filename]
  )
  map.tokens.where(token_template: creature).destroy_all
  attributes[:positions].each_with_index do |position, index|
    map.tokens.create!(
      token_template: creature,
      stashed: false,
      x: position[:x],
      y: position[:y],
      identifier: index + 1,
      map: map
    )
  end
end
