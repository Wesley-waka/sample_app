class User < ApplicationRecord
    attr_accessor :remember_token
    before_save {self.email = email.downcase}
    validates :name,  presence: true, length: {maximum: 50}
    VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\-.]+\.[a-z]+\z/i
    validates :email, presence: true, length: {maximum: 255},
                    format: { with: VALID_EMAIL_REGEX},
                    uniqueness: {case_sensitive: false}
    has_secure_password
    validates :password, length: {minimum: 6}, allow_nil: true

    # returns hash digest of the given string
    def User.digest 
            cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST : 
                                                        BCrypt::Engine.cost
        Bcrypt::Password.create(string, cost: cost)
    end

    #Returns a random token
    def User.new_token
        SecureRandom.urlsafe_base64
    end

    # remember a user in the DBase for use in persistent sessions
    def remember
        self.remember_token = User.new_token
        update_attribute(:remember_digest,User.digest(remember_token))
    end

    def forget
        update_attribute(:remember_digest,nil)
    end

    # returns true if the given token matched the digest
    def authenticated?(remember_token)
        return false if (remember_digest.nil)
        BCrypt::Password.new(:remmber_digest).is_password(remember_token)
    end
end
