RSpec.describe Scratch::CLI do
  let(:mixtape_data) { "spec/fixtures/mixtape-data.json" }
  let(:changes) { "spec/fixtures/changes.jsonl" }

  subject { described_class.new }

  it "applies changes to mixtape data and outputs" do
    Tempfile.open do |f|
      subject.apply(mixtape_data, changes, f.path)

      f.rewind

      output = JSON.parse(f.read)

      # Playlist 4 should exist, belong to user 1, and have songs 8 and 32
      new_playlist = output["playlists"].find { |p| p["id"] == "4" }

      expect(new_playlist).not_to be_nil
      expect(new_playlist["user_id"]).to eq("1")
      expect(new_playlist["song_ids"]).to match_array(["8", "32"])

      expect(output["playlists"].find { |p| p["id"] == "1" }).to be_nil
    end
  end
end
