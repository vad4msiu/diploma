#!/bin/bash

echo "100" &&
rake db:drop db:create RAILS_ENV=production --trace &&
psql -U postgres diploma_production < backup/default.backup &&
rake documents:rewrite RAILS_ENV=production --trace &&
rake rewrite_documents:create_report RAILS_ENV=production --trace &&
/Library/PostgreSQL/9.1/bin/pg_dump -U postgres diploma_production > backup/100_100_S.backup &&

echo "60" &&
rake db:drop db:create RAILS_ENV=production --trace &&
psql -U postgres diploma_production < backup/default.backup &&
rake documents:rewrite CONTENT_LENGTH=60 RAILS_ENV=production --trace &&
rake rewrite_documents:create_report RAILS_ENV=production --trace &&
/Library/PostgreSQL/9.1/bin/pg_dump -U postgres diploma_production > backup/100_60_S.backup &&

echo "40" &&
rake db:drop db:create RAILS_ENV=production --trace &&
psql -U postgres diploma_production < backup/default.backup &&
rake documents:rewrite CONTENT_LENGTH=40 RAILS_ENV=production --trace &&
rake rewrite_documents:create_report RAILS_ENV=production --trace &&
/Library/PostgreSQL/9.1/bin/pg_dump -U postgres diploma_production > backup/100_40_S.backup &&

echo "20" &&
rake db:drop db:create RAILS_ENV=production --trace &&
psql -U postgres diploma_production < backup/default.backup &&
rake documents:rewrite CONTENT_LENGTH=20 RAILS_ENV=production --trace &&
rake rewrite_documents:create_report RAILS_ENV=production --trace &&
/Library/PostgreSQL/9.1/bin/pg_dump -U postgres diploma_production > backup/100_20_S.backup &&

echo "5" &&
rake db:drop db:create RAILS_ENV=production --trace &&
psql -U postgres diploma_production < backup/default.backup &&
rake documents:rewrite CONTENT_LENGTH=5 RAILS_ENV=production --trace &&
rake rewrite_documents:create_report RAILS_ENV=production --trace &&
/Library/PostgreSQL/9.1/bin/pg_dump -U postgres diploma_production > backup/100_5_S.backup

