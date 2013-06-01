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
      chai.expect(statements[0].length).to.equal 2
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
      chai.expect(statements[0].length).to.equal 2
      chai.expect(statements[0][0]).to.equal 'ccss'

  describe 'with a CCSS stay rule', ->
    source = """
    @-gss-stay #box[width], [grid-height];
    """
    statements = null
    it 'should produce a statement array', ->
      statements = parser.parse source
      chai.expect(statements).to.be.an 'array'
    it 'should include a single CCSS part into the array', ->
      chai.expect(statements.length).to.equal 1
      chai.expect(statements[0]).to.be.an 'array'
      chai.expect(statements[0].length).to.equal 2
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
      chai.expect(statements[0].length).to.equal 2
      chai.expect(statements[0][0]).to.equal 'vfl'

  describe 'with a simple GTL rule', ->
    source = """
    @-gss-layout "frontpageLayout" {
      grid: "aaab"
            "aaab"
            "cccc";
      place-a: "#box1" "#box1";
    }
    """
    statements = null
    it 'should produce a statement array', ->
      statements = parser.parse source
      chai.expect(statements).to.be.an 'array'
    it 'should include a single GTL part into the array', ->
      chai.expect(statements.length).to.equal 1
      chai.expect(statements[0]).to.be.an 'array'
      chai.expect(statements[0].length).to.equal 2
      chai.expect(statements[0][0]).to.equal 'gtl'

  describe 'with mixed CSS, CCSS, VFL, and GTL', ->
    source = """
    /* Here we define some constraints */
    #box1.width >= #box2.width;
    @-gss-horizontal |-[#box1]-[#button1]-| in(#dialog);
    /* And then we lay it all out */
    @-gss-layout "frontpageLayout" {
      grid: "aaab"
            "aaab"
            "cccc";
      place-a: "#box1" "#box1";
    }
    /* Finally, make it look nice */
    h1 {
      color: red;
    }
    """
    statements = null
    it 'should produce a statement array', ->
      statements = parser.parse source
      chai.expect(statements).to.be.an 'array'
    it 'it should include four statements', ->
      chai.expect(statements.length).to.equal 4
    it 'the first one should be CCSS', ->
      chai.expect(statements[0]).to.be.an 'array'
      chai.expect(statements[0].length).to.equal 2
      chai.expect(statements[0][0]).to.equal 'ccss'
    it 'the second one should be VFL', ->
      chai.expect(statements[1]).to.be.an 'array'
      chai.expect(statements[1].length).to.equal 2
      chai.expect(statements[1][0]).to.equal 'vfl'
    it 'the third one should be GTL', ->
      chai.expect(statements[2]).to.be.an 'array'
      chai.expect(statements[2].length).to.equal 2
      chai.expect(statements[2][0]).to.equal 'gtl'
    it 'the fourth one should be CSS', ->
      chai.expect(statements[3]).to.be.an 'array'
      chai.expect(statements[3].length).to.equal 2
      chai.expect(statements[3][0]).to.equal 'css'

  describe 'with mixed CSS, CCSS, VFL, and GTL. CSS first', ->
    source = """
    h1 {
      color: red;
    }
    /* Here we define some constraints */
    #box1.width >= #box2.width;
    @-gss-horizontal |-[#box1]-[#button1]-| in(#dialog);
    /* And then we lay it all out */
    @-gss-layout "frontpageLayout" {
      grid: "aaab"
            "aaab"
            "cccc";
      place-a: "#box1" "#box1";
    }
    """
    statements = null
    it 'should produce a statement array', ->
      statements = parser.parse source
      chai.expect(statements).to.be.an 'array'
    it 'it should include four statements', ->
      chai.expect(statements.length).to.equal 4
    it 'the first one should be CSS', ->
      chai.expect(statements[0]).to.be.an 'array'
      chai.expect(statements[0].length).to.equal 2
      chai.expect(statements[0][0]).to.equal 'css'
    it 'the second one should be CCSS', ->
      chai.expect(statements[1]).to.be.an 'array'
      chai.expect(statements[1].length).to.equal 2
      chai.expect(statements[1][0]).to.equal 'ccss'
    it 'the third one should be VFL', ->
      chai.expect(statements[2]).to.be.an 'array'
      chai.expect(statements[2].length).to.equal 2
      chai.expect(statements[2][0]).to.equal 'vfl'
    it 'the fourth one should be GTL', ->
      chai.expect(statements[3]).to.be.an 'array'
      chai.expect(statements[3].length).to.equal 2
      chai.expect(statements[3][0]).to.equal 'gtl'
