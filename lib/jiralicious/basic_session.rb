module Jiralicious
  ##
  # The BasicSesion class extends the default Session class by forcing
  # basic_auth to be fired prior to any other action.
  #
  class BasicSession < Session
    ##
    # Fires off the basic_auth with the local username and password.
    #
    def before_request
      self.class.basic_auth(Jiralicious.username, Jiralicious.password)
    end
  end
end
