module Scratch
  module Changes
    class PlaylistAdd
      attr_accessor :change

      def initialize(change_json)
        @change = change_json
      end

      def apply(mixtape_manager)
        fail Scratch::Error, "Invalid user" unless mixtape_manager.users[change["user_id"]]
        fail Scratch::Error, "Invalid song" unless mixtape_manager.songs[change["song_id"]]

        next_playlist_id = mixtape_manager.get_playlist_sequence

        mixtape_manager.playlists[next_playlist_id] =
          {
            "id" => next_playlist_id,
            "user_id" => change["user_id"],
            "song_ids" => [change["song_id"]],
          }
      end
    end
  end
end
