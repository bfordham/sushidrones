require 'mongo'

class Database
  def connect
    db = Mongo::Connection.new.db("drones", :pool_size => 5, :timeout => 5)
    return db
  end
end
