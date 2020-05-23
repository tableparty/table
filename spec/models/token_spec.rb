require "rails_helper"

RSpec.describe Token, type: :model do
  describe "associations" do
    it { is_expected.to belong_to(:map) }
    it { is_expected.to belong_to(:token_template).optional(true) }
    it { is_expected.to have_one(:image_attachment) }
    it { is_expected.to have_one(:image_blob) }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of :name }
    it { is_expected.to validate_presence_of :image }

    it do
      expect(described_class.new).to(
        validate_inclusion_of(:size).in_array(Token::SIZES.keys).allow_blank
      )
    end
  end

  describe "#name" do
    it "returns the token's name if overridden" do
      character = build(:character, name: "Character Name")
      token = described_class.new(name: "Token Name", token_template: character)

      expect(token.name).to eq "Token Name"
    end

    it "returns the token_template's name if not overridden" do
      character = build(:character, name: "Character Name")
      token = described_class.new(name: "", token_template: character)

      expect(token.name).to eq "Character Name"
    end
  end

  describe "#size" do
    it "returns the token's size if overridden" do
      character = build(:creature, size: :large)
      token = described_class.new(size: :tiny, token_template: character)

      expect(token.size).to eq "tiny"
    end

    it "returns the token_template's name if not overridden" do
      character = build(:creature, size: :large)
      token = described_class.new(size: nil, token_template: character)

      expect(token.size).to eq "large"
    end
  end

  describe "#image" do
    it "returns the token's image if overridden" do
      character = create(
        :character,
        image: Rack::Test::UploadedFile.new("spec/fixtures/files/archer.jpg")
      )
      token = create(
        :token,
        image: Rack::Test::UploadedFile.new("spec/fixtures/files/thief.jpg"),
        token_template: character
      )

      expect(token.image.filename.to_s).to eq "thief.jpg"
    end

    it "returns the token_template's name if not overridden" do
      character = create(
        :character,
        image: Rack::Test::UploadedFile.new("spec/fixtures/files/archer.jpg")
      )
      token = create(
        :token,
        image: nil,
        token_template: character
      )

      expect(token.image.filename.to_s).to eq "archer.jpg"
    end
  end

  describe "copy_on_place?" do
    it "returns true if no identifier and token_template copy_on_place" do
      token = described_class.new(token_template: Creature.new)

      expect(token).to be_copy_on_place
    end

    it "returns false if no identifier and token_template not copy_on_place" do
      token = described_class.new(token_template: Character.new)

      expect(token).not_to be_copy_on_place
    end

    it "returns false if identifier and token_template copy_on_place" do
      token = described_class.new(identifier: "1", token_template: Creature.new)

      expect(token).not_to be_copy_on_place
    end
  end

  describe "#size_scale" do
    it "return the scale number corresponding the token's size" do
      token = described_class.new(size: "large")

      expect(token.size_scale).to eq Token::SIZES["large"]
    end
  end
end
