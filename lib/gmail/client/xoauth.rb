require 'gmail_xoauth'

module Gmail
  module Client
    class XOAuth < Base
      attr_reader :token
      attr_reader :secret
      attr_reader :two_legged
      attr_reader :consumer_key
      attr_reader :consumer_secret

      def initialize(username, options={})
        @token           = options.delete(:token)
        @secret          = options.delete(:secret)
        @two_legged      = options.delete(:two_legged)
        @consumer_key    = options.delete(:consumer_key)
        @consumer_secret = options.delete(:consumer_secret)
       
        super(username, options)
      end

      def login(raise_errors=false)
        if @two_legged
          puts 'using 2lo'
          @imap and @logged_in = (login = @imap.authenticate('XOAUTH', username,
            :two_legged      => two_legged,
            :token           => token,
            :token_secret    => secret
          )) && login.name == 'OK'
        else
          puts 'using 3lo'
          @imap and @logged_in = (login = @imap.authenticate('XOAUTH', username,
            :consumer_key    => consumer_key,
            :consumer_secret => consumer_secret,
            :token           => token,
            :token_secret    => secret
          )) && login.name == 'OK'
        end
      rescue
        raise_errors and raise AuthorizationError, "Couldn't login to given GMail account: #{username}"        
      end

      def smtp_settings
        [:smtp, {
           :address => GMAIL_SMTP_HOST,
           :port => GMAIL_SMTP_PORT,
           :domain => mail_domain,
           :user_name => username,
           :password => {
             :consumer_key    => consumer_key,
             :consumer_secret => consumer_secret,
             :token           => token,
             :token_secret    => secret
           },
           :authentication => :xoauth,
           :enable_starttls_auto => true
         }]
      end
    end # XOAuth

    register :xoauth, XOAuth
  end # Client
end # Gmail
