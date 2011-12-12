namespace :rewrite_documents do
  desc "RewriteDocument create report"
  task :create_report => :environment do
    offset = ENV["OFFSET"].to_i || 0
    index = offset
    puts "All number documents #{RewriteDocument.count - offset}"
    time_all = Benchmark.realtime do
      RewriteDocument.order(:id).offset(offset).each do |rewrite_document|
        time = Benchmark.realtime do          
          rewrite_document.build_report(:algorithm => 'shingle')
          rewrite_document.report.generate_and_save :content => rewrite_document.content
          index += 1
        end
        puts "#{index} => Process document id: #{rewrite_document.id}, #{time}"
      end
    end

    puts "Total time #{time_all}"
  end
end