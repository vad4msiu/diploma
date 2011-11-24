require 'find'
require 'digest/md5'
# require 'ruby-prof'

namespace :documents do
  desc "Import documents and create shingles from DIR"
  task :import => :environment do
    # RubyProf.start
    SHINGLE_LENGTH = ENV["SHINGLE_LENGTH"] || 9
    if ENV["DIR"]
      Find.find(ENV["DIR"]) do |file_path|
        if FileTest.file?(file_path)
          puts "Processed file #{file_path}"
          begin
            Document.create :content => File.open(file_path).read
          rescue Exception => e
            puts "Error: #{e}\n#{e.backtrace.join('\n')}"
          end                
        end
      end
    end

    # results = RubyProf.stop
    #
    # File.open "tmp/profile-graph.html", 'w' do |file|
    #  RubyProf::GraphHtmlPrinter.new(results).print(file)
    # end
  end
end