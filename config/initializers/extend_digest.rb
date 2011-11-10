# -*- encoding : utf-8 -*-
module Digest
  class RabinKarp
    def self.digest text, q = Fixnum::MAX
      hash = 0
      index = text.length - 1
      text.each_char do |char|
        hash += char.ord * 2 ** index
        index -= 1
      end
      hash % q      
    end
  end
end
