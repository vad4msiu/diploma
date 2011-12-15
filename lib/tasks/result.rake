# encoding: UTF-8
desc "Result"
task :result => :environment do
  eq = 70
  sim_threshold = 80
  # shingle super-shingle mega-shingle min-hash long-sent
  %w(shingle super-shingle mega-shingle min-hash long-sent).each do |algorithm|
    %w(sinomizer_60 sinomizer_40 sinomizer_20 sinomizer_5 shuffle_paragraphs shuffle_sentences).each do |rewrite_type|
      a = 0.0
      b = 0.0
      q = Report.joins(:rewrite_document).where('"rewrite_documents"."rewrite_type" = ? and "reports"."algorithm"=? and "reports"."similarity">=?', rewrite_type, algorithm, eq)
      q.each do |report|
        if report.rewrite_document.sim > sim_threshold && report.serialized_object.matched_documents.map(&:id).include?(report.document_id)
          a += 1
          a -= 1 if (algorithm == 'long-sent' || algorithm == 'i-match') && report.serialized_object.matched_documents.size > 5
        else
          b += 1
        end        
      end
      c = Report.joins(:rewrite_document).where('"rewrite_documents"."rewrite_type" = ? and "reports"."algorithm"=? and "rewrite_documents"."sim">=?', rewrite_type, algorithm, sim_threshold).count - a
      puts "#{algorithm}: полнота #{a / (a + c)}, точность #{a / (a + b)} (#{rewrite_type})"
    end
  end
end
