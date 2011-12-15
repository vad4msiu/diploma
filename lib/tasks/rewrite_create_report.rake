namespace :rewrite_documents do
  desc "RewriteDocument create report"
  task :create_report => :environment do
    offset = (ENV["OFFSET"] || 0).to_i
    index = offset + 1
    puts "All number documents #{RewriteDocument.count - offset}"
    time_all = Benchmark.realtime do
      RewriteDocument.order(:id).offset(offset).each do |rewrite_document|
        puts "#{index} => Process document id: #{rewrite_document.id}"
        # document = Document.new(:content => rewrite_document.content)
        # document.build_shingle_signatures
        # document.build_min_hash_signatures

        %w(shingle super-shingle mega-shingle min-hash i-match long-sent).each do |algorithm|
          time = Benchmark.realtime do            
            document = Document.new(:content => rewrite_document.content)
            report = Report.new(:algorithm => algorithm, :document_id => rewrite_document.document_id)
            report.generate_and_save :document => document
          end
          puts "----#{algorithm}, #{time}"
        end
        index += 1
      end
    end

    puts "Total time #{time_all}"
  end
end