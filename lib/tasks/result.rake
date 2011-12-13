# encoding: UTF-8
desc "Result"
task :result => :environment do
  eq = 50  
  %w(shingle super-shingle mega-shingle min-hash i-match long-sent).each do |algorithm|
    a = 0
    b = Report.where("algorithm=? and similarity>=?", algorithm, eq).count
    Report.where("algorithm=?", algorithm).each do |report|
      a += 1 if report.serialized_object.matched_documents.map(&:id).include? report.rewrite_document.document.id
    end
    puts "#{algorithm}: полнота #{b}, точность #{a}"
  end
end