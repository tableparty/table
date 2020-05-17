require "rails_helper"

RSpec.describe Token, type: :model do
  describe "associations" do
    it { is_expected.to belong_to(:map) }
    it { is_expected.to belong_to(:tokenable).optional(true) }
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
      token = described_class.new(name: "Token Name", tokenable: character)

      expect(token.name).to eq "Token Name"
    end

    it "returns the tokenable's name if not overridden" do
      character = build(:character, name: "Character Name")
      token = described_class.new(name: "", tokenable: character)

      expect(token.name).to eq "Character Name"
    end
  end

  describe "#size" do
    it "returns the token's size if overridden" do
      character = build(:creature, size: :large)
      token = described_class.new(size: :tiny, tokenable: character)

      expect(token.size).to eq "tiny"
    end

    it "returns the tokenable's name if not overridden" do
      character = build(:creature, size: :large)
      token = described_class.new(size: nil, tokenable: character)

      expect(token.size).to eq "large"
    end
  end

  describe "#image" do
    it "returns the token's image if overridden" do
      character = create(
        :character,
        image: Rack::Test::UploadedFile.new("spec/fixtures/files/tanpos.jpeg")
      )
      token = create(
        :token,
        image: Rack::Test::UploadedFile.new("spec/fixtures/files/uxil.jpeg"),
        tokenable: character
      )

      expect(token.image.filename.to_s).to eq "uxil.jpeg"
    end

    it "returns the tokenable's name if not overridden" do
      character = create(
        :character,
        image: Rack::Test::UploadedFile.new("spec/fixtures/files/tanpos.jpeg")
      )
      token = create(
        :token,
        image: nil,
        tokenable: character
      )

      expect(token.image.filename.to_s).to eq "tanpos.jpeg"
    end
  end

  describe "copy_on_place?" do
    it "returns true if no identifier and tokenable copy_on_place" do
      token = described_class.new(tokenable: Creature.new)

      expect(token).to be_copy_on_place
    end

    it "returns false if no identifier and tokenable not copy_on_place" do
      token = described_class.new(tokenable: Character.new)

      expect(token).not_to be_copy_on_place
    end

    it "returns false if identifier and tokenable copy_on_place" do
      token = described_class.new(identifier: "1", tokenable: Creature.new)

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
