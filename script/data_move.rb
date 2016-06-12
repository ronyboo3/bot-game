
yesterday = (Time.now - 1).strftime("%m%d")

`mkdir /home/tanase/pad/data/#{yesterday}`
`mv /home/tanase/pad/data/*.bin /home/tanase/pad/data/#{yesterday}/`
