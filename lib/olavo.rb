# encoding: utf-8
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

require 'logger'
require 'lib/dictionary'
require 'lib/command'
class Olavo
  attr_reader :channel, :name
  VERSION = 0.1 

  def initialize(name, dict_filename, action_filename)
    @name          = name
    @dict          = Lib::Dictionary.new(dict_filename)
    @commands      = Lib::Command.new(@name, action_filename)
    @channel       = nil
    @reload        = 0
    @logger        = Logger.new(STDOUT)
    @silence       = false
  end

  def set_channel(name)
    @channel = name
  end

  def set_bot(bot)
    @bot = bot
  end

  def greeting
    send_message(@dict.greeting)
  end

  def action(phrase)
    direct_events(phrase)
    random_events(phrase)
  end

  def reload(channel, message)
    if message.match(/^\s*reload\s*$/)
      @dict.reload
      @commands.reload
      @bot.msg channel, 'Bot reloaded'
    end
  end

  private

  def direct_events(phrase)
    if @commands.has_command? phrase
      response = @commands.cmd_exec(phrase)
      send_message(response) if response.is_a? String
      if response.is_a? Array
        response.each{|message| send_message(message)}
      end
      return
    end

    if @dict.to_learn? phrase
      send_message(@dict.learn_new_quote(phrase))
      return
    end

    if @dict.is_learned? phrase
      send_message(@dict.learned_quote(phrase))
      return
    end

    reference = @dict.reference_quote(phrase)
    if reference
      send_message(reference)
      return
    end
  end

  def random_events(phrase)
    return unless can_i_say?

    bad_word = @dict.bad_word_quote(phrase)
    if bad_word
      send_message(bad_word)
      return
    end

    send_message(random_quote)
  end

  def random_quote
    (can_i_say?)? @dict.random_quote : nil
  end

  def send_message(message)
    @bot.msg @channel, message
  end

  def can_i_say?
    (rand(20) == 1)? true : false
  end
end
