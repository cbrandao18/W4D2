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
        
    has_many :visits,        
        primary_key: :id,
        foreign_key: :shortened_url_id,
        class_name: 'Visit'

    has_many :visitors,
        Proc.new { distinct },
        through: :visits,
        source: :users

    def num_clicks
        visits.count
    end

    def num_uniques
        #visitors.count
        visits.select('user_id').distinct.count
    end
    
    def num_recent_uniques
        old_time = 10000.minutes.ago
        #curr_time = Time.now
        visits.select('user_id').where('created_at > ?', old_time).count
        # visits.select('user_id').where('created_at BETWEEN ? AND ?', old_time, curr_time).count
    end
end
