module Jiralicious
  class BasicSession < Session
    def before_request
      self.class.basic_auth(Jiralicious.username, Jiralicious.password)
    end
  end
end
