# encoding: UTF-8
namespace :"i-match" do
  desc "I-Match перевычесление сигнатру."
  task :"re-create" => :environment do
    IMatchSignature.destroy_all
    Document.all.each do |document|
      document.create_i_match_signatures
    end
  end
end