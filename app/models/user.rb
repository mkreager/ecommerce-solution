class User < ApplicationRecord
  has_many :albums
  validates :email, uniqueness: true, presence: true
  before_save :format_email

  def format_email
    self.email = self.email.delete(' ').downcase
  end

  def generate_login_token
    self.login_token = generate_token
    self.token_generated_at = Time.now.utc
    save!
  end
	
  def login_link
    ActionMailer::Base.default_url_options[:host] + "/auth?token=#{self.login_token}"
  end
	
  def login_token_expired?
    Time.now.utc > (self.token_generated_at + token_validity)
  end
	
  def expire_token!
    self.login_token = nil
    save!
  end
	
private
	
  def generate_token
    SecureRandom.hex(10)
  end
	
  def token_validity
    2.hours
  end
end
