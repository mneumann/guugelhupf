require "dbm"
db = DBM.new "test"
p db.to_hash
p db.methods
