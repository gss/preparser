if typeof process is 'object' and process.title is 'node'
  chai = require 'chai' unless chai
  parser = require '../lib/gss-preparser'
else
  parser = require 'gss-preparser'

expect = chai.expect


test = (name,source,target) ->  
  statements = null  
  describe name, ->    
    it '/ should parse', ->
      #parser.constraintCount = 0
      #parser.blockCount = 0
      statements = parser.parse source
      expect(statements).to.be.an 'array'
    it '/ should parse correctly', ->
      expect(statements).to.eql target
  

describe 'GSS preparser ~', ->
  
  it 'should provide a parse method', ->
    expect(parser.parse).to.be.a 'function'
  
  describe "CSS", ->
  
    test 'with ruleset', 
      """
      h1 {
        color: red;
      }
      """, 
      [
        {
          type:'ruleset'
          selectors: ['h1']
          rules: [
            {
              type:'style', key:'color', val:'red'
            }
          ]
        }
      ]
      
    test 'with @import', 
      """
      @import url('bob.css') projection, tv;
      h1 {
        color: red;
      }
      """, 
      [
        {
          type:'directive'
          name: 'import'
          terms: "url('bob.css') projection, tv"
        }
        {
          type:'ruleset'
          selectors: ['h1']
          rules: [
            {
              type:'style', key:'color', val:'red'
            }
          ]
        }
      ]

    test 'with nested ruleset', 
      """
      .panel, poly-panel + #q22 {
        color: black;
        .button {
          color: white;
          display: block;
          
          /* blah blah */
          
          .icon {
            color: pink;
          }
          
        }
      }
      """, 
      [
        {
          type:'ruleset'
          selectors: ['.panel','poly-panel + #q22']
          rules: [
            { type:'style', key:'color', val: 'black' }
            {
              type:'ruleset'
              selectors: ['.button']
              rules: [
                { type:'style', key:'color', val: 'white' }
                { type:'style', key:'display', val: 'block' }
                {
                  type:'ruleset'
                  selectors: ['.icon']
                  rules: [
                    { type:'style', key:'color', val: 'pink' }
                  ]
                }
              ]
            }
          ]
        }
      ]
  
  ###
  describe "gss-prop", ->
    test 'with ruleset', 
      """
      h1 {
        -gss-translateY: 100px;
      }
      """, 
      [
        {
          type:'ruleset'
          selectors: ['h1']
          rules: [
            ['gss-prop','translateY','100px']
          ]
        }
      ]
  ###
  
  describe "CCSS", ->
        
    test 'with a simple CCSS rule',
      """
      #box1[width] >= #box2[width] !weak;
      """,
      [
        {type:'constraint', cssText:'#box1[width] >= #box2[width] !weak;'}
      ]
    
    test 'with a simple CCSS rule with an explicit id',
      """
      #box1[width] >= #box2[width] name(box-widths) !strong;
      """,
      [
        {type:'constraint', cssText:"#box1[width] >= #box2[width] name(box-widths) !strong;"}
      ]
  
    test 'CCSS with janky spaces', 
      """
    
      #ed[top] == 0;
        
        .box[width] >= 100 <= .box[height] name(box-size) !strong;
      
      """,
      [
        {type:'constraint', cssText:"#ed[top] == 0;"}
        {type:'constraint', cssText:".box[width] >= 100 <= .box[height] name(box-size) !strong;"}
      ]
  
    test 'with nesting', 
      """
      #main {        

          .post {
            height:== ::parent[height];
            height:>= ::parent[height] name(blah);
          }
        
      }
      """,
      [
        {
          type:'ruleset'
          selectors: ['#main']
          rules: [
            {
              type:'ruleset'
              selectors: ['.post']
              rules: [
                {type:'constraint', cssText:'::[height] == ::parent[height];'}
                {type:'constraint', cssText:'::[height] >= ::parent[height] name(blah);'}
              ]
            }
          ]
        }
      ]


    test 'with a CCSS stay rule',
      """
      @-gss-stay #box[width], [grid-height];
      """,
      [
        {type:'constraint', cssText:"@-gss-stay #box[width], [grid-height];"}
      ]
  
  
  
  describe "VFL", ->
  
    test 'with a simple VFL rule',
      """
      @horizontal |-[#box1]-[#button1]-| in(#dialog);
      """,
      [
        {
          type:'directive'          
          name: 'horizontal'
          terms: "|-[#box1]-[#button1]-| in(#dialog)"
        }
      ]
  
  describe 'with js layout hooks', ->
    source = """
    @for-each .box ``` function(el) { alert('do something!'); } ``` name(for-boom);
    @horizontal .box gap(10);
    """
    statements = null
    it 'should produce a statement array', ->
      statements = parser.parse source
      expect(statements).to.be.an 'array'
    it 'should include a single CSS part into the array', ->
      expect(statements).to.eql [
        {
          "type": "constraint",
          "cssText": "@for-each .box ``` function(el) { alert('do something!'); } ``` name(for-boom);"
        },
        {
          "type": "directive",
          "name": "horizontal",
          "terms": ".box gap(10)"
        }
      ]


  
  describe 'with chains', ->
    source = """
    @chain .big-boxes gap(+[199]!strong);
    """
    statements = null
    it 'should produce a statement array', ->
      statements = parser.parse source
      expect(statements).to.be.an 'array'
    it 'should include a single CSS part into the array', ->
      expect(statements).to.eql [
        {type:'constraint',cssText:'@chain .big-boxes gap(+[199]!strong);'}
      ]
  
  
  describe "End-to-End ~", ->
    
    test '@media w/ nesting', 
      """
      @media screen and (device-aspect-ratio: 16/9), screen and (device-aspect-ratio: 16/10) {
      h1[width] >= h2[width];
      h1 {
        @vertical .word;
        color: red;
        height:== ::parent[height];
      span, em {
        color: blue;
        [gap] >= ::window[width]/10;
      }
        }
      }
      @horizontal .thought in(.brain);
      """,
      [
        {
          type: "directive"
          name: 'media'
          terms: 'screen and (device-aspect-ratio: 16/9), screen and (device-aspect-ratio: 16/10)'
          rules: [
            {type:'constraint',cssText:"h1[width] >= h2[width];"}
            {
              type: "ruleset"
              selectors: ['h1']
              rules: [
                {type:'directive',name:"vertical",terms:".word"}
                {type:'style', key:'color', val: 'red'}
                {type:'constraint',cssText:'::[height] == ::parent[height];'}
                {                  
                  type: "ruleset"
                  selectors: ['span','em']
                  rules: [
                    {type:'style', key:'color', val: 'blue'}
                    {type:'constraint',cssText:'[gap] >= ::window[width]/10;'}
                  ]
                }
              ]
            }
          ]
        }
        {type:'directive',name:"horizontal",terms:".thought in(.brain)"}
      ]
    
    test '@if @else w/ nesting', 
      """
      
      @horizontal |-[#main]-[#side]-| in(::window) gap([col-size]);
      60 =< [col-size] <= ::window / 12;
      
      #main {        
        @if ::this[width] >= 960 {
          @vertical .post gap(40);
        } 
        @else ::this[width] > 700 {
          @vertical .post gap(20);
        }
        @else {
          @vertical .post gap(10);
          .post {
            height: <= ::window[height] / 2 !strong;
            font-size: 14px;
          }
        }
      }
      
      """,
      [
         {
            "type": "directive",
            "name": "horizontal",
            "terms": "|-[#main]-[#side]-| in(::window) gap([col-size])"
         },
         {
            "type": "constraint",
            "cssText": "60 =< [col-size] <= ::window / 12;"
         },
         {
            "type": "ruleset",
            "selectors": [
               "#main"
            ],
            "rules": [
               {
                  "type": "directive",
                  "name": "if",
                  "terms": "::this[width] >= 960",
                  "rules": [
                     {
                        "type": "directive",
                        "name": "vertical",
                        "terms": ".post gap(40)"
                     }
                  ]
               },
               {
                  "type": "directive",
                  "name": "else",
                  "terms": "::this[width] > 700",
                  "rules": [
                     {
                        "type": "directive",
                        "name": "vertical",
                        "terms": ".post gap(20)"
                     }
                  ]
               },
               {
                  "type": "directive",
                  "name": "else",
                  "terms": "",
                  "rules": [
                     {
                        "type": "directive",
                        "name": "vertical",
                        "terms": ".post gap(10)"
                     },
                     {
                        "type": "ruleset",
                        "selectors": [
                           ".post"
                        ],
                        "rules": [
                           {
                              "type": "constraint",
                              "cssText": "::[height] <= ::window[height] / 2 !strong;"
                           },
                           {
                              "type": "style",
                              "key": "font-size",
                              "val": "14px"
                           }
                        ]
                     }
                  ]
               }
            ]
         }
      ]
      

    test 'with mixed CSS, CCSS, VFL',
      """
      /* Here we define some constraints */
      #box1.width >= #box2.width;
      @horizontal |-[#box1]-[#button1]-| in(#dialog);
      /* And then we lay it all out */
      /* Finally, make it look nice */
      h1 {
        color: red;
      }
      """,
      [
        {type:'constraint',cssText:"#box1.width >= #box2.width;"}
        {type:'directive', name:'horizontal', terms:"|-[#box1]-[#button1]-| in(#dialog)"}
        {type:'ruleset', selectors:['h1'],rules:[{type:'style',key:'color',val:'red'}]}
      ]

    test 'with mixed CSS, CCSS, VFL. CSS first',
      """
      h1 {
        color: red;
      }
    
      /* Here we define some constraints */
    
      #box1.width >= #box2.width;
    
      /* And then we lay it all out */
    
            @horizontal |-[#box1]-[#button1]-| in(#dialog);

      """,
      [
        {type:'ruleset', selectors:['h1'],rules:[{type:'style',key:'color',val:'red'}]}
        {type:'constraint',cssText:"#box1.width >= #box2.width;"}
        {type:'directive', name:'horizontal', terms:"|-[#box1]-[#button1]-| in(#dialog)"}        
      ]
  
  
