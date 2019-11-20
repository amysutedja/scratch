require "scratch/changes/change_factory"
require "json"

module Scratch
  class MixtapeManager
    attr_accessor :users, :songs, :playlists

    def initialize(input)
      data = JSON.parse(input)

      @users = data["users"].to_h { |u| [u["id"], u] }
      @songs = data["songs"].to_h { |s| [s["id"], s] }
      @playlists = data["playlists"].to_h { |p| [p["id"], p] }
    end

    def apply(change)
      Changes::ChangeFactory.get(change).apply(self)
    end

    def apply_json_lines(changefile)
      File.open(changefile, "r").each_line do |l|
        change = JSON.load(l)

        apply(change)
      end
    end

    def write_json
      JSON.dump({
        "users" => users.values,
        "playlists" => playlists.values,
        "songs" => songs.values,
      })
    end

    def write_file(file)
      file.write(write_json)
    end

    def get_playlist_sequence
      @playlist_sequence ||= playlists.keys.map(&:to_i).max

      @playlist_sequence += 1

      @playlist_sequence.to_s
    end
  end
end
