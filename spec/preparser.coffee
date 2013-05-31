if typeof process is 'object' and process.title is 'node'
  chai = require 'chai' unless chai
  parser = require '../lib/gss-preparser'
else
  parser = require 'gss-preparser'

describe 'GSS preparser', ->
  it 'should provide a parse method', ->
    chai.expect(parser.parse).to.be.a 'function'

  describe 'with simple CSS rule', ->
    source = """
    h1 {
      color: red;
    }
    """
    statements = null
    it 'should produce a statement JSON object', ->
      statements = parser.parse source
      chai.expect(statements).to.be.an 'object'
