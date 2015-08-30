#
#  Copyright (c) 2015, Rodrigo Mello Nardi
#  All rights reserved.
#  
#  Redistribution and use in source and binary forms, with or without
#  modification, are permitted provided that the following conditions are met:
#  
#  1. Redistributions of source code must retain the above copyright notice, this
#     list of conditions and the following disclaimer. 
#  2. Redistributions in binary form must reproduce the above copyright notice,
#     this list of conditions and the following disclaimer in the documentation
#     and/or other materials provided with the distribution.
#  
#  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
#  ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
#  WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
#  DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR
#  ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
#  (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
#  LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
#  ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
#  (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
#  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#  
#  The views and conclusions contained in the software and documentation are those
#  of the authors and should not be interpreted as representing official policies, 
#  either expressed or implied, of the FreeBSD Project.
#
require 'yaml'
module Lib
  class Dictionary
    def initialize(dict_filename)
      @dict_filename = dict_filename
      @dict = YAML.load_file(dict_filename)
    end

    def reload
      puts '===> Reloading Lib::Dictionary'
      @dict = YAML.load_file(@dict_filename)
    end

    def to_learn?(phrase)
      (phrase.match(/^@\p{Word}+\s*=\s*/))? true : false
    end

    def is_learned?(phrase)
      (phrase.match(/@\p{Word}+/))? true : false
    end

    def reference_quote(phrase)
      return nil unless has_chapter? :reference
      puts phrase.scan(/@\p{Word}+/).inspect
      phrase.scan(/@\p{Word}+/).each do |word|
        word = word.sub('@', '')
        next unless has_section?(:reference, word)
        return read_dictionary(:reference, word)
      end
      false
    end

    def bad_word_quote(phrase)
      return nil unless has_chapter? :bad_word
      phrase.scan(/\p{Word}+/).each do |word|
        next unless has_section?(:bad_word, word)
        return read_dictionary(:bad_word, word)
      end
      false
    end

    def random_quote
      read_dictionary(:random)
    end

    def learned_quote(phrase)
      if has_chapter? :learned
        word = phrase.match(/@\p{Word}+/)[0]
        word = word.sub('@', '')
        puts "learned_quote(#{word})"
        quote = read_dictionary(:learned, word)
        return quote unless quote.nil?
      end

      if has_chapter? :learned_complain
        read_dictionary(:learned_complain)
      end
    end

    def learn_new_quote(phrase)
      word, quote = phrase.split(/\s*=\s*/)
      word = word.sub('@', '')
      puts "Inserting #{word}"
      if has_chapter? :learned
        if @dict[:learned].is_a? Hash
          @dict[:learned][word] = quote
        else
          @dict[:learned] = {word => quote}
        end
      else
        @dict[:learned] = {word => quote}
      end

      File.open(@dict_filename, 'w') {|f| f.write(@dict.to_yaml)}

      if has_chapter? :learned_confirm
        read_dictionary(:learned_confirm)
      end
    end

    #
    # YAML FILE
    # :greeting: Hi, folks!
    # or
    # :greeting:
    # - Hi, folks!
    # - Hello there
    # - Morning
    #
    def greeting
      read_dictionary(:greeting)
    end

    private

    def has_chapter?(chapter)
      @dict.has_key? chapter
    end

    def has_section?(chapter, section)
      return false unless has_chapter? chapter
      @dict[chapter].has_key? section
    end

    def read_dictionary(chapter, section=nil)
      return nil unless @dict.has_key? chapter
      return nil unless section.nil? or @dict[chapter].has_key? section

      if section
        if @dict[chapter][section].is_a? Array
          index  = rand(@dict[chapter][section].size)
          answer = @dict[chapter][section][index]
        else
          answer = @dict[chapter][section]
        end
      else
        if @dict[chapter].is_a? Array
          index  = rand(@dict[chapter].size)
          answer = @dict[chapter][index]
        else
          answer = @dict[chapter]
        end
      end
      answer
    end
  end
end
