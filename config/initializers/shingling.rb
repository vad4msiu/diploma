# -*- encoding : utf-8 -*-

class Shingling
  def initialize(content = '', options = {})
    @content = content
    @shingle_length = options[:shingle_length] || 5
    @stop_words = options[:stop_words] || []
    @downcase = options[:downcase] || false
    @replace_chars = options[:replace_chars] || {}
  end

  def shingles
    shingles = []
    each_shingles { |shingle| shingles << shingle }
  
    return shingles
  end

  def each_shingles
    word = ""
    char_flag = false
    shingle = []
    position_end_words = []
    position_start, position_end = 0, 0
    
    @content.each_char do |char|
      char = @replace_chars[char] if @replace_chars.key? char
      if char !~ /[А-ЯЁа-яё]/
        char_flag = true
      else
        if char_flag
          if !stop_word?(word) && word =~ /\S+/
            shingle << (@downcase ? Unicode::downcase(word) : word)
            word = ""
            position_end_words << position_end
            if shingle.size == @shingle_length
              yield(shingle.join(" "), position_start, position_end)
              position_start = position_end_words.shift
              shingle.shift
            end
          end
          char_flag = false
        end
        word << char
      end
      position_end += 1
    end        
  end

  private

  def stop_word? word
    @stop_words.include? word
  end  
end
