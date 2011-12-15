namespace :rewrite_documents do
  desc "RewriteDocument create report"
  task :create_report => :environment do
    offset = (ENV["OFFSET"] || 0).to_i
    index = offset + 1
    puts "All number documents #{RewriteDocument.count - offset}"
    time_all = Benchmark.realtime do
      # i-match
      %w(shingle super-shingle mega-shingle long-sent min-hash).each do |algorithm|
        Report.where(:algorithm => algorithm).destroy_all  
        RewriteDocument.order(:id).offset(offset).each do |rewrite_document|
          # puts "#{index} => Process document id: #{rewrite_document.id}"
          # document = Document.new(:content => rewrite_document.content)
          # document.build_shingle_signatures
          # document.build_min_hash_signatures

          # shingle super-shingle mega-shingle long-sent min-hash
          time = Benchmark.realtime do            
            document = Document.new(:content => rewrite_document.content)
            report = Report.new(:algorithm => algorithm, 
                                :document_id => rewrite_document.document_id,
                                :rewrite_document_id => rewrite_document.id)
            report.generate_and_save :document => document
          end
          # puts "----#{algorithm}, #{time}"
          # index += 1
        end
      end
    end

    puts "Total time #{time_all}"
  end
end