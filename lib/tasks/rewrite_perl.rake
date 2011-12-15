namespace :documents do
  desc "Rewrite documents"
  task :rewrite => :environment do
    offset = (ENV["OFFSET"] || 0).to_i
    # content_length = (ENV["CONTENT_LENGTH"] || 100).to_i
    index = offset + 1
    sim_threshold = 80
    RewriteDocument.destroy_all
    puts "All number documents #{Document.count - offset}"
    time_all = Benchmark.realtime do
      Document.order(:id).offset(offset).each do |document|
        puts "#{index} => Process document id: #{document.id}"
        d_filename = "./documents/origin/#{document.id}.txt"
        f = File.new(d_filename, 'w')
        f.write(document.content)
        f.close
        [60, 40, 20, 5].each do |content_length|
          rd = document.rewrite_documents.create(:content => document.rewrite(:content_length => content_length),
                                          :rewrite_type => "sinomizer_#{content_length}")
          rd_filename = "./documents/rewrite/sinomizer_#{content_length}_#{document.id}_#{rd.id}.txt"
          f = File.new(rd_filename, 'w')
          f.write(rd.content)
          f.close
          sim = `perl similarity.pl #{d_filename} #{rd_filename}`.to_f
          rd.sim_perl = sim
          puts "#{sim} sinomizer_#{content_length}"
          rd.duplicate = sim > sim_threshold ? true : false
          rd.save!          
        end
        rd = document.rewrite_documents.create(:content => document.alphabetic,
                                        :rewrite_type => "alphabetic")
        rd_filename = "./documents/rewrite/alphabetic_#{document.id}_#{rd.id}.txt"
        f = File.new(rd_filename, 'w')
        f.write(rd.content)
        f.close
        sim = `perl similarity.pl #{d_filename} #{rd_filename}`.to_f
        puts "#{sim} alphabetic"
        rd.sim_perl = sim
        rd.duplicate = sim > sim_threshold ? true : false
        rd.save!

        rd = document.rewrite_documents.create(:content => document.shuffle_paragraphs,
                                        :rewrite_type => "shuffle_paragraphs")
        rd_filename = "./documents/rewrite/shuffle_paragraphs_#{document.id}_#{rd.id}.txt"
        f = File.new(rd_filename, 'w')
        f.write(rd.content)
        f.close
        sim = `perl similarity.pl #{d_filename} #{rd_filename}`.to_f
        puts "#{sim} shuffle_paragraphs"
        rd.sim_perl = sim
        rd.duplicate = sim > sim_threshold ? true : false
        rd.save!
        
        rd = document.rewrite_documents.create(:content => document.shuffle_sentences,
                                        :rewrite_type => "shuffle_sentences")
        rd_filename = "./documents/rewrite/shuffle_sentences_#{document.id}_#{rd.id}.txt"
        f = File.new(rd_filename, 'w')
        f.write(rd.content)
        f.close
        sim = `perl similarity.pl #{d_filename} #{rd_filename}`.to_f
        puts "#{sim} shuffle_sentences"
        rd.sim_perl = sim
        rd.duplicate = sim > sim_threshold ? true : false
        rd.save!        
        index += 1
      end
    end

    puts "Total time #{time_all}"
  end
end