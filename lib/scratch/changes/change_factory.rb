require "scratch/changes/playlist_delete"
require "scratch/changes/playlist_add"
require "scratch/changes/song_add"

module Scratch
  module Changes
    class ChangeFactory
      def self.get(change)
        case(change["action"])
        when "add_playlist"
          PlaylistAdd.new(change)
        when "add_song"
          SongAdd.new(change)
        when "remove_playlist"
          PlaylistDelete.new(change)
        end
      end
    end
  end
end
