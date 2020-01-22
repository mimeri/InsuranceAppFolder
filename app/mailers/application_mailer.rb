class ApplicationMailer < ActionMailer::Base
  # rescue_from EOFError, IOError, TimeoutError, Errno::ECONNRESET, Errno::ECONNABORTED, Errno::EPIPE, Errno::ETIMEDOUT, Net::SMTPAuthenticationError, Net::SMTPServerBusy, Net::SMTPSyntaxError, Net::SMTPUnknownError, OpenSSL::SSL::SSLError do |exception|
  #   raise "Error encountered sending email. Reason: #{exception}."
  # end
end
