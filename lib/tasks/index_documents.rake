require 'find'
require 'digest/md5'
require 'benchmark'
# require 'ruby-prof'

namespace :documents do
  desc "Import documents and create shingles from DIR"
  task :import => :environment do
    # RubyProf.start
    if ENV["DIR"]
      index = 1
      time_all = Benchmark.realtime do
        Find.find(ENV["DIR"]) do |file_path|
          if FileTest.file?(file_path)
            begin
              time = Benchmark.realtime do
                Document.create :content => File.read(file_path)
              end
              puts "#{index} => Process file #{file_path}, #{time}"
            rescue Exception => e
              puts "#{index} => Error: #{e}\n#{e.backtrace.join('\n')}"
            end
            
            index += 1
          end
        end
      end
      
      puts "Total time #{time_all}"
    end

    # results = RubyProf.stop
    # 
    # File.open "tmp/profile-flat.txt", 'w' do |file|
    #  RubyProf::FlatPrinter.new(results).print(file)
    # end
    # 
    # 
    # File.open "tmp/profile-graph.html", 'w' do |file|
    #  RubyProf::GraphHtmlPrinter.new(results).print(file)
    # end
    # 
    # File.open "tmp/profile.dot", 'w' do |file|
    #  RubyProf::DotPrinter.new(results).print(file)
    # end
  end
end