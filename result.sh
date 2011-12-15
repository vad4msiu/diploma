echo "40"
rake db:drop db:create RAILS_ENV=production &&
psql -U postgres diploma_production < backup/100_40_REWRITE_SHINGLE_LENGTH_9_new.backup > /dev/null &&
rake result RAILS_ENV=production

echo "20"
rake db:drop db:create RAILS_ENV=production &&
psql -U postgres diploma_production < backup/100_20_REWRITE_SHINGLE_LENGTH_9_new.backup > /dev/null &&
rake result RAILS_ENV=production

echo "5"
rake db:drop db:create RAILS_ENV=production &&
psql -U postgres diploma_production < backup/100_5_REWRITE_SHINGLE_LENGTH_9_new.backup > /dev/null &&
rake result RAILS_ENV=production

# echo 'alphabetic'
# rake db:drop db:create RAILS_ENV=production &&
# psql -U postgres diploma_production < backup/100_ALPHABETIC_SHINGLE_LENGTH_9_new.backup > /dev/null &&
# rake result RAILS_ENV=production

echo 'shuffle_sentences'
rake db:drop db:create RAILS_ENV=production &&
psql -U postgres diploma_production < backup/100_SHUFFLE_SENTENCES_SHINGLE_LENGTH_9_new.backup > /dev/null &&
rake result RAILS_ENV=production

echo 'shuffle_paragraphs'
rake db:drop db:create RAILS_ENV=production &&
psql -U postgres diploma_production < backup/100_SHUFFLE_PARAGRAPHS_SHINGLE_LENGTH_9_new.backup > /dev/null &&
rake result RAILS_ENV=production