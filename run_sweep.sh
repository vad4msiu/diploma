#!/bin/bash

# echo 'rewrite'
# echo "100" 
# rake db:drop db:create RAILS_ENV=production --trace &&
# psql -U postgres diploma_production < backup/DEFAULT_SHINGLE_LENGTH_6.backup &&
# rake documents:rewrite RAILS_ENV=production --trace &&
# rake rewrite_documents:create_report RAILS_ENV=production --trace &&
# /Library/PostgreSQL/9.1/bin/pg_dump -U postgres diploma_production > backup/100_100_REWRITE_SHINGLE_LENGTH_6.backup
# 
# echo "60"
# rake db:drop db:create RAILS_ENV=production --trace &&
# psql -U postgres diploma_production < backup/DEFAULT_SHINGLE_LENGTH_6.backup &&
# rake documents:rewrite CONTENT_LENGTH=60 RAILS_ENV=production --trace &&
# rake rewrite_documents:create_report RAILS_ENV=production --trace &&
# /Library/PostgreSQL/9.1/bin/pg_dump -U postgres diploma_production > backup/100_60_REWRITE_SHINGLE_LENGTH_6.backup
# 
# echo "40"
# rake db:drop db:create RAILS_ENV=production --trace &&
# psql -U postgres diploma_production < backup/DEFAULT_SHINGLE_LENGTH_6.backup &&
# rake documents:rewrite CONTENT_LENGTH=40 RAILS_ENV=production --trace &&
# rake rewrite_documents:create_report RAILS_ENV=production --trace &&
# /Library/PostgreSQL/9.1/bin/pg_dump -U postgres diploma_production > backup/100_40_REWRITE_SHINGLE_LENGTH_6.backup
# 
# echo "20"
# rake db:drop db:create RAILS_ENV=production --trace &&
# psql -U postgres diploma_production < backup/DEFAULT_SHINGLE_LENGTH_6.backup &&
# rake documents:rewrite CONTENT_LENGTH=20 RAILS_ENV=production --trace &&
# rake rewrite_documents:create_report RAILS_ENV=production --trace &&
# /Library/PostgreSQL/9.1/bin/pg_dump -U postgres diploma_production > backup/100_20_REWRITE_SHINGLE_LENGTH_6.backup
# 
# echo "5"
# rake db:drop db:create RAILS_ENV=production --trace &&
# psql -U postgres diploma_production < backup/DEFAULT_SHINGLE_LENGTH_6.backup &&
# rake documents:rewrite CONTENT_LENGTH=5 RAILS_ENV=production --trace &&
# rake rewrite_documents:create_report RAILS_ENV=production --trace &&
# /Library/PostgreSQL/9.1/bin/pg_dump -U postgres diploma_production > backup/100_5_REWRITE_SHINGLE_LENGTH_6.backup
# 
# echo 'alphabetic'
# rake db:drop db:create RAILS_ENV=production --trace &&
# psql -U postgres diploma_production < backup/DEFAULT_SHINGLE_LENGTH_6.backup &&
# rake documents:alphabetic RAILS_ENV=production --trace &&
# rake rewrite_documents:create_report RAILS_ENV=production --trace &&
# /Library/PostgreSQL/9.1/bin/pg_dump -U postgres diploma_production > backup/100_ALPHABETIC_SHINGLE_LENGTH_6.backup

echo 'shuffle_sentences'
rake db:drop db:create RAILS_ENV=production --trace &&
psql -U postgres diploma_production < backup/DEFAULT_SHINGLE_LENGTH_6.backup &&
rake documents:shuffle_sentences RAILS_ENV=production --trace &&
rake rewrite_documents:create_report RAILS_ENV=production --trace &&
/Library/PostgreSQL/9.1/bin/pg_dump -U postgres diploma_production > backup/100_SHUFFLE_SENTENCES_SHINGLE_LENGTH_6.backup

echo 'shuffle_paragraphs'
rake db:drop db:create RAILS_ENV=production --trace &&
psql -U postgres diploma_production < backup/DEFAULT_SHINGLE_LENGTH_6.backup &&
rake documents:shuffle_paragraphs RAILS_ENV=production --trace &&
rake rewrite_documents:create_report RAILS_ENV=production --trace &&
/Library/PostgreSQL/9.1/bin/pg_dump -U postgres diploma_production > backup/100_SHUFFLE_PARAGRAPHS_SHINGLE_LENGTH_6.backup