module Bundler
  class CLI::Lock
    attr_reader :options

    def initialize(options)
      @options = options
    end

    def run
      unless Bundler.default_gemfile
        Bundler.ui.error "Unable to find a Gemfile to lock"
        exit 1
      end

      print = options[:print]
      ui = Bundler.ui
      Bundler.ui = UI::Silent.new if print

      gems = options[:update]
      Bundler::Fetcher.disable_endpoint = options["full-index"]

      if gems && !gems.empty?
        definition = Bundler.definition(:gems => gems)
      else
        definition = Bundler.definition(true)
      end

      definition.resolve_remotely! unless options[:local]

      if print
        puts definition.to_lock
      else
        file = options[:lockfile]
        file = file ? File.expand_path(file) : Bundler.default_lockfile
        puts "Writing lockfile to #{file}"
        definition.lock(file)
      end

      Bundler.ui = ui
    end
  end
end
