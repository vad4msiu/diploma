namespace :documents do
  desc "Rewrite documents"
  task :shuffle_sentences => :environment do
    offset = (ENV["OFFSET"] || 0).to_i
    index = offset + 1
    puts "All number documents #{Document.count - offset}"
    time_all = Benchmark.realtime do
      Document.order(:id).offset(offset).each do |document|
        puts "#{index} => Process document id: #{document.id}"
        document.rewrite_document.create(:content => document.shuffle_sentences)
        index += 1
      end
    end

    puts "Total time #{time_all}"
  end
end