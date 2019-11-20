require "scratch/version"
require "scratch/mixtape_manager"
require "thor"

module Scratch
  class Error < StandardError; end

  class CLI < Thor
    desc "apply", "Apply changes to mixtape data and output results"
    def apply(data, changefile, output)
      mixtape_manager = Scratch::MixtapeManager.new(File.read(data))

      mixtape_manager.apply_json_lines(changefile)

      File.open(output, "w") do |f|
        mixtape_manager.write_file(f)
      end
    end
  end
end
