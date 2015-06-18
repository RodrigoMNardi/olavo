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
class Olavo
  attr_reader :channel, :name
  VERSION = 0.1 

  def initialize(name, dict_filename)
    @name          = name
    @dict          = Lib::Dictionary.new(dict_filename)
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

    bad_word = @dict.bad_word_quote(phrase)
  end

  def reload(bot)
    @dict = YAML.load_file(@dict_filename)
    bot.msg @channel, access_dict(:reboot)
    @reload += 1
    if @reload >= 3
      bot.msg @channel, access_dict(:reboot_try)
      @reload = 0
    end
  end

  private

  def random_quote
    rand(20) == 2
  end

  def send_message(message)
    @bot.msg @channel, message
  end
end
