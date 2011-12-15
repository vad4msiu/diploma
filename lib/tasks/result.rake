# encoding: UTF-8
desc "Result"
task :result => :environment do
  eq = 50  
  %w(shingle super-shingle mega-shingle min-hash i-match long-sent).each do |algorithm|
    a = 0
    b = Report.where("algorithm=? and similarity>=?", algorithm, eq)
    b.each do |report|      
      if report.similarity != 0.0 && report.serialized_object.matched_documents.map(&:id).include?(report.document.id)
        a += 1 
      end
    end
    puts "#{algorithm}: полнота #{b.count / 100.0}, точность #{a / b.count.to_f}"
  end
end
