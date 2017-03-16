[![MIT licensed](https://img.shields.io/badge/license-MIT-blue.svg)](MIT-LICENSE)
[![Gem Version](https://badge.fury.io/rb/sqlogger.svg)](https://badge.fury.io/rb/sqlogger)
[![Build Status](https://travis-ci.org/metalels/sqlogger.svg?branch=master)](https://travis-ci.org/metalels/sqlogger)
[![Code Climate](https://codeclimate.com/github/metalels/sqlogger/badges/gpa.svg)](https://codeclimate.com/github/metalels/sqlogger)
[![Test Coverage](https://codeclimate.com/github/metalels/sqlogger/badges/coverage.svg)](https://codeclimate.com/github/metalels/sqlogger/coverage)
[![Issue Count](https://codeclimate.com/github/metalels/sqlogger/badges/issue_count.svg)](https://codeclimate.com/github/metalels/sqlogger)

# Sqlogger
Collect 'ActiveRecord sql query' to monitoring system(s) for development.

<img src="sqlogger_elasticsearch.png" width="580" alt="send sql-log to elasticsearch">

## Dependency
Currently supports Rails **3.1.0** and **upper**.  
Tested minor version between **3.1.0** and **5.1.0beta1**

## Installation
Add this line to your application's Gemfile:
**recommend to use development only**

```ruby
gem 'sqlogger', group: :development
```

And then execute in Rails Project root directory:
```bash
$ bundle
$ rake sqlogger:install
```

## Usage
edit sqlogger setting file in *config/initializers/sqlogger.rb*.

## Contributing
git-flow.

