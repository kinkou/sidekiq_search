# frozen_string_literal: true

paths = [
  './spec/support/jobs/*.rb'
]

paths.map { Dir.glob(_1) }.flatten.each { require(_1) }
