module Lib
class Action
def holiday
require 'time_difference'
start_time = Time.now
end_time = Time.new(2015,10,15)
general = TimeDifference.between(start_time, end_time).in_general
["Deadline in 15/10/2015",
"#{general[:months]} month(s), #{general[:weeks]} week(s), #{general[:days]} day(s), #{general[:hours]} hour(s), #{general[:minutes]} minute(s) and #{general[:seconds]} second(s)" ]
end

end
end
