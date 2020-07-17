require_relative './spec_helper'
require 'letter_avatar_app'
require 'digest'

describe LetterAvatarApp do
  include Rack::Test::Methods

  def app
    LetterAvatarApp
  end

  shared_examples "a successful request" do
    it "is successful" do
      expect(response.status).to eq(200)
    end

    it "returns a PNG" do
      expect(response['Content-Type']).to eq("image/png")
    end

    it "is a reasonable size" do
      expect(response['Content-Length'].to_i).to be_between(100, 30_000)
    end

    it "actually is a PNG" do
      expect(image).to be_a(ChunkyPNG::Image)
    end
  end

  let(:response) { get url, params }
  let(:params)   { {} }
  let(:image)    { ChunkyPNG::Image.from_blob(response.body) }

  %w{/wyzzle /letter /letter/foo}.each do |path|
    context path do
      let(:url) { path }

      it "returns a 404" do
        expect(response.status).to eq(404)
      end
    end
  end

  context "root" do
    let (:url) { "/" }

    it "returns a short informative paragraph" do
      expect(response.status).to eq(200)
      expect(response['Content-Type']).to eq("text/html")
      expect(response.body).to match('Discourse Letter Avatar Service')
    end
  end

  context "dnt policy" do
    let (:url) { "/.well-known/dnt-policy.txt" }

    it "returns a valid policy file" do
      expect(response.status).to eq(200)
      expect(response['Content-Type']).to eq("text/plain")
      # we got to match something in https://www.eff.org/files/dnt-policies.json
      expect(Digest::SHA1.hexdigest(response.body)).to eq('a18e8dba6848d3fc241b03b88291cb75a3cfec3b')
    end
  end

  context "valid letter" do
    let(:url) { "/letter/q/A1B2C3/50.png" }

    context "with a hex colour" do

      it_behaves_like "a successful request"

      it "returns an image with the default height" do
        expect(image.height).to eq(50)
      end

      it "returns an image with the default width" do
        expect(image.width).to eq(50)
      end

      it "has a non-standard background" do
        # we compensate for compression shifting pallette a bit
        expect(image[0, 0]).to be_between(2712847359, 2864434431)
      end
    end

  end

  context "valid number" do
    let(:url) { "/letter/8/123456/25.png" }

    context "with a hex colour" do
      it_behaves_like "a successful request"
    end
  end
end
