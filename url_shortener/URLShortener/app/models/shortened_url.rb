# == Schema Information
#
# Table name: shortened_urls
#
#  id         :bigint           not null, primary key
#  long_url   :string           not null
#  short_url  :string           not null
#  user_id    :integer          not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class ShortenedURL < ActiveRecord::Base
    validates :long_url, :user_id, presence: true
    validates :short_url, presence: true, uniqueness: true

    def self.random_code
        shortened = SecureRandom::urlsafe_base64
        # while ShortenedURL.where(:short_url => exists?(shortened))
        while ShortenedURL.exists?(short_url: shortened)
            shortened = SecureRandom::urlsafe_base64
        end
        shortened
    end

    def self.short_from_long_url(user, l_url)
        new_short_url = ShortenedURL.random_code
        short_url_obj = ShortenedURL.create!(user_id: user.id, long_url: l_url, short_url: new_short_url)
    end

    belongs_to :submitter,
        primary_key: :id,
        foreign_key: :user_id,
        class_name: 'User'
end
