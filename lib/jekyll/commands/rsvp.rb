module Jekyll
  module Commands
    class Rsvp < Command
      def self.init_with_program(prog)
        prog.command(:rsvp) do |c|
          c.syntax 'rsvp URL'
          c.description 'Creates a new RSVP post in response to the given URL'

          options.each {|opt| c.option *opt }

          c.action { |args, options| process args, options }
        end
      end

      def self.options
        [
          ['layout', '-l LAYOUT', '--layout LAYOUT', "Specify the post layout"],
          ['force', '-f', '--force', 'Overwrite a post if it already exists'],
          ['date', '-d DATE', '--date DATE', 'Specify the post date']
        ]
      end

      def self.process(args = [], options = {})
        params = RsvpArgParser.new args, options
        params.validate!

        post = RsvpFileInfo.new params

        Compose::FileCreator.new(post, params.force?).create!
      end


      class RsvpArgParser < Compose::ArgParser
        def date
          options["date"].nil? ? Time.now : DateTime.parse(options["date"])
        end
        def url
          @args[0]
        end
        def type
          'html'
        end
      end

      class RsvpFileInfo < Compose::FileInfo
        attr_reader :url
        def initialize(params)
          @params = params
        end

        def resource_type
          'post'
        end

        def path
          "_posts/#{file_name}"
        end

        def file_name
          "#{_date_stamp}.#{params.type}"
        end

        def _date_stamp
          @params.date.strftime '%F-%H%M%S'
        end

        def content
          content = YAML.dump({
            "date" => params.date.strftime('%F %T %z'),
            "updated" => params.date.strftime('%F %T %z')
          })
          content += "---\n"
          content + <<-EOC
I am <data class="p-rsvp" value="yes">going</data>
to <a href="#{params.url}" class="u-in-reply-to">an Event</a>.
EOC
        end
      end
    end
  end
end
