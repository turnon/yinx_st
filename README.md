# YinxSt

Generate report of statistics for my evernote. [Demo](whispering-fortress-75887.herokuapp.com)

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'yinx_st'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install yinx_st

## Usage

`my_db_url` should contain table adapts to `yinx_sql/json_batch`

```ruby
YinxSt.fetch(my_db_url).last_n_days(28)
```

