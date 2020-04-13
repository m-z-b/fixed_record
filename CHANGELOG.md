# Gem fixed_record Changelog

## 0.6.1
* Fixed bug which resulted in the module Enumerable being included
  in class _Class_, resulting in very confusing errors when using
  RSpec feature specifications in programs using the gem.

## 0.6.0
* Internal refactoring - after reading _Metaprogramming Ruby_!
* Added size and length methods

## 0.5.0
* Added class method `valid_names` to return valid names in records
* Documented class method `filename`
* Add instance method `present?` to test if a value was supplied for an  optional field

## 0.4.4
* Syntax Errors in YAML file now reported as ArgumentError

## 0.4.1
* Bump rake version due to security issue

## 0.4.0
* Add support for a singleton record for general parameter access

## 0.3.0
* Add optional required and optional arguments to specify required and optional fields respectively

## 0.2.0
* Add support for a Hash of Hashes in the YAML file, and for
accessing records by key. 
* Added CHANGELOG.md

## 0.1.x
* Initial release
