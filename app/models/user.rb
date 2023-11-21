class User < ApplicationRecord
    attr_accessor :remember_token, :activation_token
    before_save :downcase_email
    before_create :create_activation_digest
    validates :name,  presence: true, length: {maximum: 50}
    VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\-.]+\.[a-z]+\z/i
    validates :email, presence: true, length: {maximum: 255},
                    format: { with: VALID_EMAIL_REGEX},
                    uniqueness: {case_sensitive: false}
    has_secure_password
    validates :password, length: {minimum: 6}, allow_nil: true

    # returns hash digest of the given string
    def User.digest(string)
        cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST : 
                                                        BCrypt::Engine.cost
        BCrypt::Password.create(string, cost: cost)
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
    def authenticated?(attribute, token)
        digest = self.send("#{attribute}_digest")
        return false if digest.nil?
        BCrypt::Password.new(digest).is_password?(token)
    end

    private

    # converts email to all lowercase
    def downcase_email
        self.email = email.downcase
    end

    # creates and assigns the activation token and digest
    def create_activation_digest
        self.activation_token = User.new_token
        self.activation_digest = User.digest(activation_token)
    end
end
