# -*- encoding : utf-8 -*-
# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

if User.count == 0
  u = User.new(email: "vad4msiu@gmail.com")
  u.role = :admin
  u.password = "qweqwe"
  u.save!
  
  u = User.new(email: "qwe@qwe.com")
  u.role = :teacher
  u.password = "qweqwe"
  u.save!
  
end

