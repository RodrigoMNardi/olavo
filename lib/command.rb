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

module Lib
  class Command
    def initialize(name, file)
      @file = file
      @name = name
      action_load
    end

    def reload
      puts '===> Reloading Lib::Command'
      action_load
    end

    def has_command?(phrase)
      validate(phrase){return true}
    end

    def cmd_exec(phrase)
      validate(phrase){|cmd| return @actions.send(cmd)}
    end

    private

    def validate(phrase)
      cmd = phrase.split(/\s+/)
      return false unless cmd.size == 2
      if @name.match(/#{cmd.first}/) and @actions.respond_to? cmd.last.to_sym
        yield cmd.last.to_sym
      end
      false
    end

    def action_load
      buffer = "module Lib\nclass Action\n"
      YAML.load_file(@file).each_pair do |method, code|
        buffer += "def #{method}\n"
        buffer += code
        buffer += "end\n"
        buffer += "\n"
      end
      buffer += "end\n"
      buffer += "end\n"
      File.open('lib/actions.rb', 'w'){|f| f.write(buffer)}
      load 'lib/actions.rb'
      @actions = Lib::Action.new
    end
  end
end