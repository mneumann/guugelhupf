while line = gets
  a = line.split(/\s+/)
  next if a.size != 4
  puts a[2]
end
