namespace :documents do
  desc "Rewrite documents"
  task :rewrite => :environment do
    offset = ENV["OFFSET"].to_i || 0
    index = offset
    puts "All number documents #{Document.count - offset}"
    time_all = Benchmark.realtime do
      Document.order(:id).offset(offset).each do |document|
        puts "#{index} => Process document id: #{document.id}"
        document.rewrite_documents.create(:content => document.rewrite)
        index += 1
      end
    end

    puts "Total time #{time_all}"
  end
end