module Scratch
  module Changes
    class SongAdd
      attr_accessor :change

      def initialize(change_json)
        @change = change_json
      end

      def apply(mixtape_manager)
        fail Scratch::Error, "Invalid playlist" unless mixtape_manager.users[change["playlist_id"]]
        fail Scratch::Error, "Invalid song" unless mixtape_manager.songs[change["song_id"]]

        songs = Set.new(mixtape_manager.playlists[change["playlist_id"]]["song_ids"])
        songs << change["song_id"]
        mixtape_manager.playlists[change["playlist_id"]]["song_ids"] = songs.to_a
      end
    end
  end
end
