require 'redis'

class Database

    def self.store(key, value)
      connection.set(key, value)
    end

    def self.read(key)
      val = connection.get(key)
      if val
        val.to_f
      end
    end

    private
    def self.connection
      @@redis ||= Redis.new(:url => (ENV['REDIS_URL'] || 'redis://127.0.0.1:6379'))
    end

end