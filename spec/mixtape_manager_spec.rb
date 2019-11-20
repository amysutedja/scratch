RSpec.describe Scratch::MixtapeManager do
  let(:mixtape_data) { "spec/fixtures/mixtape-data.json" }

  subject { described_class.new(File.read(mixtape_data))}

  describe "#initialize" do
    it "loads a file" do
      expect(subject.users.count).to eq(7)
      expect(subject.playlists.count).to eq(3)
      expect(subject.songs.count).to eq(40)
    end
  end

  describe "#apply" do
    context "when adding playlist" do
      let(:add_playlist) do
        {
          "action" => "add_playlist",
          "user_id" => "1",
          "song_id" => "8",
        }
      end

      it "applies an add_playlist change" do
        subject.apply(add_playlist)

        expect(subject.playlists.count).to eq(4)
        expect(subject.playlists.values.last["user_id"]).to eq(add_playlist["user_id"])
        expect(subject.playlists.values.last["song_ids"]).to include(add_playlist["song_id"])
      end

      it "generates a playlist with a unique id" do
        subject.apply(add_playlist)

        expect(subject.playlists.keys).to include("4")
        expect(subject.playlists.keys).not_to include("5")

        subject.apply(add_playlist)

        expect(subject.playlists.keys).to include("5")
      end

      it "throws for invalid user" do
        add_playlist["user_id"] = "-1"

        expect { subject.apply(add_playlist) }.to raise_error(Scratch::Error)
      end

      it "throws for invalid song" do
        add_playlist["song_id"] = "-1"

        expect { subject.apply(add_playlist) }.to raise_error(Scratch::Error)
      end
    end

    context "when deleting playlist" do
      let(:delete_playlist) do
        {
          "action" => "remove_playlist",
          "playlist_id" => "2",
        }
      end

      it "applies a delete_playlist change" do
        subject.apply(delete_playlist)

        expect(subject.playlists.count).to eq(2)
        expect(subject.playlists.keys).not_to include(delete_playlist["playlist_id"])
      end

      it "throws for invalid playlist" do
        delete_playlist["playlist_id"] = "-1"

        expect { subject.apply(delete_playlist) }.to raise_error(Scratch::Error)
      end
    end

    context "when adding song" do
      let(:add_song) do
        {
          "action" => "add_song",
          "playlist_id" => "3",
          "song_id" => "30",
        }
      end

      it "applies an add_song change" do
        subject.apply(add_song)

        expect(subject.playlists[add_song["playlist_id"]]["song_ids"]).to include(add_song["song_id"])
      end

      it "does not add a duplicate song to a playlist" do
        subject.apply(add_song)
        subject.apply(add_song)

        expect(subject.playlists[add_song["playlist_id"]]["song_ids"]).to match_array(["7", "12", "13", "16", "2", "30"])
      end

      it "throws for invalid playlist" do
        add_song["playlist_id"] = "-1"

        expect { subject.apply(add_song) }.to raise_error(Scratch::Error)
      end

      it "throws for invalid song" do
        add_song["song_id"] = "-1"

        expect { subject.apply(add_song) }.to raise_error(Scratch::Error)
      end
    end
  end

  describe "#write_file" do
    it "outputs to a file" do
      io = StringIO.new

      subject.write_file(io)

      io.rewind

      input, output = JSON.parse(File.read(mixtape_data)), JSON.parse(io.read)
      result = JsonCompare.get_diff(input, output)

      expect(result).to be_empty
    end
  end
end
