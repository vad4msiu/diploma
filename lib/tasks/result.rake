# encoding: UTF-8
desc "Result"
task :result => :environment do
  eq = 70
  sim_threshold = 80
  # shingle super-shingle mega-shingle min-hash long-sent
  %w(shingle super-shingle mega-shingle min-hash long-sent).each do |algorithm|
    %w(sinomizer_60 sinomizer_40 sinomizer_20 sinomizer_5 shuffle_paragraphs shuffle_sentences).each do |rewrite_type|
      a = 0
      b = Report.joins(:rewrite_document).where('"rewrite_documents"."rewrite_type" = ? and "reports"."algorithm"=? and "reports"."similarity">=?', rewrite_type, algorithm, eq)
      b.each do |report|
        if report.rewrite_document.sim > sim_threshold && report.serialized_object.matched_documents.map(&:id).include?(report.document_id)
          a += 1
          a -= 1 if (algorithm == 'long-sent' || algorithm == 'i-match') && report.serialized_object.matched_documents.size > 1
        end        
      end
      puts "#{algorithm}: полнота #{b.count / 100.0}, точность #{a / b.count.to_f} (#{rewrite_type})"
    end
  end
end
