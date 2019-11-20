module Scratch
  module Changes
    class PlaylistDelete
      attr_accessor :change

      def initialize(change_json)
        @change = change_json
      end

      def apply(mixtape_manager)
        fail Scratch::Error, "Invalid playlist" unless mixtape_manager.playlists[change["playlist_id"]]

        mixtape_manager.playlists.delete(change["playlist_id"])
      end
    end
  end
end
