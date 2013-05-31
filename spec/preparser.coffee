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
    it 'should produce a statement array', ->
      statements = parser.parse source
      chai.expect(statements).to.be.an 'array'
    it 'should include a single CSS part into the array', ->
      chai.expect(statements.length).to.equal 1
      chai.expect(statements[0]).to.be.an 'array'
      chai.expect(statements[0][0]).to.equal 'css'

  describe 'with a simple CCSS rule', ->
    source = """
    #box1.width >= #box2.width;
    """
    statements = null
    it 'should produce a statement array', ->
      statements = parser.parse source
      chai.expect(statements).to.be.an 'array'
    it 'should include a single CCSS part into the array', ->
      chai.expect(statements.length).to.equal 1
      chai.expect(statements[0]).to.be.an 'array'
      chai.expect(statements[0][0]).to.equal 'ccss'

  describe 'with a simple VFL rule', ->
    source = """
    @-gss-horizontal |-[#box1]-[#button1]-| in(#dialog);
    """
    statements = null
    it 'should produce a statement array', ->
      statements = parser.parse source
      chai.expect(statements).to.be.an 'array'
    it 'should include a single VFL part into the array', ->
      chai.expect(statements.length).to.equal 1
      chai.expect(statements[0]).to.be.an 'array'
      chai.expect(statements[0][0]).to.equal 'vfl'
