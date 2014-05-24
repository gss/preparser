if window?
  parser = require 'gss-preparser'
else
  chai = require 'chai' unless chai
  parser = require '../lib/gss-preparser'

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

canParse = (name,source) ->  
  statements = null  
  describe name, ->    
    it '/ should parse', ->
      #parser.constraintCount = 0
      #parser.blockCount = 0
      statements = parser.parse source
      expect(statements).to.be.an 'array'


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
      
    test 'with adv ruleset', 
      """
      html [strange=true] * > .box {
        color: red;
      }
      """, 
      [
        {
          type:'ruleset'
          selectors: ['html [strange=true] * > .box']
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
    
    test 'with a simple CCSS rule',
      """
      (section.section div:not(.b))[x] == (section.section div:not(.a))[x] == [x];
      """,
      [
        {type:'constraint', cssText:'(section.section div:not(.b))[x] == (section.section div:not(.a))[x] == [x];'}
      ]    
    
    test 'with a simple CCSS rule and function',
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
    
    test 'contextual w/ left-handed ::',
      """
        selector {
            width: == ::[intrinsic-width];
            width : == ::[intrinsic-width];
            ::[width] == ::[intrinsic-width];
        }
      """,
      [
        {
          type:'ruleset'
          selectors: ['selector']
          rules: [
            {type:'constraint', cssText:'::[width] == ::[intrinsic-width];'}
            {type:'constraint', cssText:'::[width] == ::[intrinsic-width];'}
            {type:'constraint', cssText:'::[width] == ::[intrinsic-width];'}
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
                {type:'style', key:'color', val:'red'}
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
    
    
    test '@if @else w/ nesting & virtuals', 
      """
      
      @horizontal |-["main"]-["side"]-| in("window") gap("col"[size]);
      60 =< "col"[size] <= "window" / 12;
      
      "main" {        
        @if "this"[width] >= 960 {
          @vertical .post gap(40);
        } 
        @else {
          "post" {
            height: <= "window"[height] / 2 !strong;
            font-size: 14px;
          }
        }
      }
      
      """,
      [
         {
            "type": "directive",
            "name": "horizontal",
            "terms": '|-["main"]-["side"]-| in("window") gap("col"[size])'
         },
         {
            "type": "constraint",
            "cssText": '60 =< "col"[size] <= "window" / 12;'
         },
         {
            "type": "ruleset",
            "selectors": [
               '"main"'
            ],
            "rules": [
               {
                  "type": "directive",
                  "name": "if",
                  "terms": '"this"[width] >= 960',
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
                  "terms": "",
                  "rules": [
                     {
                        "type": "ruleset",
                        "selectors": [
                           '"post"'
                        ],
                        "rules": [
                           {
                              "type": "constraint",
                              'cssText': '::[height] <= "window"[height] / 2 !strong;'
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
      
      
    test '@if @else w/ nesting & ', 
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
      
  
  
  describe "Can parse...", ->
    
    simple = '"box"[right] == "box2"[left];'
    canParse simple, simple  
    
    
    canParse "VGL",
      """
        @grid-template simple "ab";
      """
    
    canParse "mixed",    
      """
      @horizontal [#b1][#b2];
    
      #box[right] == #box2[left];
    
      #main {
      
        line-height: >= [col-size];
      
        @if [target] >= 960 {      
          width: == [big];
        }
        @else [target] >= 500 {      
          width: == [med];
        }
        @else {      
          right: == ::window[left];
        }
        
      }
      
      """

    canParse "small dump", 
      """
      [md] * 4 == [w] - [ogap] * 2 !require;
      ([md] * 4) / 2 == ([w] - [ogap] * 2) / 2 !require;
      """
    
    canParse "big dump", 
      """
      
      .asterisk { 
        color: hsl(190,100%,50%); 
      }
      
      .dot[width] == 2 == .dot[height];
      .dot[border-radius] == 1;
      @horizontal .dot-row1 gap([plan-width]-2);
      @horizontal .dot-row2 gap([plan-width]-2);
      @horizontal .dot-row3 gap([plan-width]-2);
      @horizontal .dot-row4 gap([plan-width]-2);
      @horizontal .dot-row5 gap([plan-width]-2);
      @horizontal .dot-row6 gap([plan-width]-2);
      .dot-first[center-x] == #p1[left];
      .dot-row1[center-y] == #p-r1[top];
      .dot-row2[center-y] == #p-r2[top];
      .dot-row3[center-y] == #p-r3[top];
      .dot-row4[center-y] == #p-r4[top];
      .dot-row5[center-y] == #p-r5[top];
      .dot-row6[center-y] == #p-r5[bottom];
      
      .asterisk { 
        color: hsl(190,100%,50%); 
      }
      
      [grid] == 36;
      [grid2] == 72;
    
      [hgap] == [grid2];
    
      [leftline]  == #wiz-scope[left] + [grid2];
      [rightline] == #wiz-scope[right] - [grid2];
    
      /* panel */
        [panel-width] ==[grid2] * 9 !strong;
        [panel-height] >= 620 !strong;
        .admin-bg[width] == [panel-width] + 20;
        .admin-bg[height] == [panel-height] + 20;
        .admin-panel[width] == [panel-width];
        .admin-panel[height] == [panel-height];
        .admin-panel[center-x] == ::window[center-x] !strong;
        .admin-panel[top] == [grid2] * 2 !strong;
        .admin-bg[center-x] == ::window[center-x] !strong;
        .admin-bg[top] == 125 !strong;
      
    
      /* header */
        .admin-header[center-x] == #wiz-scope[center-x] !strong;        
        /*.admin-header[height] == .admin-header[intrinsic-height];  bug when display:none */
        .admin-header[height] == [grid2] * 2;
        .admin-header[width] <= 500;
    
    
      /* sections */    
    
        @vertical |[#admin-header-signup]-[#wiz-section-top][#wiz-section-mid][#wiz-section-bot]-120-| 
          gap([grid2]) in(#wiz-scope);
    
        @horizontal |[.wiz-section]|
           in(#wiz-scope);
         
        .wiz-section[height] >= [grid2];
         
        .sup-circ[width] == .sup-circ[height]        
          == 2;
        1 == .sup-circ[border-radius];
        
        .sup-circ {
          background-color: white;
        }
      
        .sup-circ-lead[left] == #wiz-scope[left];            
        .sup-circ-tail[right] == #wiz-scope[right];        
        .sup-circ-top[center-y] == #wiz-section-top[top];
        .sup-circ-mid[center-y] == #wiz-section-mid[top];
        .sup-circ-mid2[center-y] == #wiz-section-mid[center-y];
        .sup-circ-mid22[center-y] == #wiz-section-mid2[top];                        
        
      /* top section */
                
        @horizontal |[#sup-plan-image(==[grid2])][#sup-plan-info]|
          in(#wiz-section-top);
        @vertical |[#sup-plan-image]|
          in(#wiz-section-top);        
        
        @horizontal |[#sup-plan-edit]-|
          gap([grid] / 2)
          in(#wiz-section-top);
        @vertical |[#sup-plan-edit]|
          in(#wiz-section-top);
      
        #sup-plan-info[height] == #sup-plan-info[line-height]
          == #sup-plan-edit[line-height] == #sup-plan-edit[height]; 
              
      
      
    
      /* mid2 section */
    
        @vertical |-[#wiz-section-mid2]|
          gap([grid2])
          in(#wiz-section-mid);
        
      /* user */
    
        #wiz-user-img[width] == #wiz-user-img[height]
          == [grid] + 3;
        #wiz-user-img[border-radius] == [grid] * 2;
      
        #wiz-user-img[center-y] == #wiz-section-top[center-y] + #wiz-section-top[height];
        #wiz-user-img[center-x] == #wiz-section-top[left] + [grid];
      
        #wiz-user-img {
          background-color: white;
          border: 2px solid hsl(0, 0%, 0%);
          box-shadow: 0 0 0 1px hsl(190, 90%, 50%);
        }
      
        @horizontal [#wiz-user-img]-[#wiz-user-info][#wiz-user-edit(==[grid2])]-|
          gap([grid]/2)
          chain-center-y
          in(#wiz-section-top);
        #wiz-user-info[height] == #wiz-user-info[line-height]
          == [grid];
        #wiz-user-edit[height] == #wiz-user-edit[line-height]
          == [grid];
        
    
      /* bottom section */
  
        @vertical |-[.wiz-but-next]-|
          gap([grid])
          in(#wiz-section-bot);
        .wiz-but-next[width] == [grid2] * 2;
        .wiz-but-next[height] == [grid2];
        .wiz-but-next[center-x] == #wiz-section-bot[center-x];
      
    
      
      
      
      /* mid section */
            
        @horizontal |-[#sup-services]-|
          in(#wiz-section-mid);     
        
        #sup-services[height] == [grid2];
    
        @horizontal |-3-[#sup-github]-18-[#sup-twitter]-6-|
          gap([grid2]) in(#sup-services)
          chain-top chain-width chain-height;
        
        @vertical |-3-[#sup-github]-5-|          
          in(#sup-services);
      
        @horizontal |-[#sup-email-label]-|
          in(#wiz-section-mid);
      
        @horizontal |-[#sup-email]-|
          in(#wiz-section-mid);
            
        @vertical |-[#sup-services-label]-18-[#sup-services]-36-[#sup-email-label]-18-[#sup-email]-| 
          gap([sup-mid-gap])
          in(#wiz-section-mid);
          [sup-mid-gap] >= [grid];
      
        #sup-services-label[height] == [grid];
        #sup-email-label[height] == [grid];
        #sup-email[height] == [grid2];
      
        #sup-logout {
          position: absolute;
          top: 3px;
          right: 3px;
          left: 3px;
          bottom: 3px;
        }
      
        .sup-service {
          border: none; /* 1px solid hsla(220, 20%, 84%, 0);*/
          -moz-border-radius: 8px;
          -webkit-border-radius: 8px;
          border-radius: 8px;
          background-color: hsla(0, 0%, 0%, 0);
          color: hsl(0, 100%, 100%);
          font-weight: bold;
          font-size: 16px;
        }
        .sup-service:hover, .sup-service.selected {
          background-color: hsla(190, 100%, 50%, .8);
          color: hsl(0, 100%, 0%);
        }
        .sup-service i {
          margin-right: 16px;
          font-size: 18px;
        }
      
        .sup-state {
          display:none;
        }
        html [data-sup-state="login"] .sup-state-login {
          display: block;
        }
        html [data-sup-state="logout"] .sup-state-logout {
          display: block;
        }
    
    
    
    
    

      /* payment types */
        @horizontal |[#pay-type1][#pay-type2]| in(#form-payment) gap([grid]) 
          chain-width chain-top;
        .pay-type[height] == [grid2];  
        .pay-type[line-height] == [grid2];
  
      /* form */          
        /*#form-payment[top] == #admin-buy[center-y];*/
      
        [subgrid] == [grid] * 1.5;
      
        input[height] == [subgrid] !strong;
        output[height] == [subgrid] !strong;
        label[height] == [subgrid] == label[line-height] !strong;
        input[width] >= [subgrid] !strong;
      
        [inputs-left] == #form-payment[left] + 144;
        @horizontal |[#label-card]-[#input-card]| 
          in(#form-payment) gap(9) chain-top chain-height;
        #input-card[x] == [inputs-left]; /* :first */
        @horizontal |[#label-exp][#input-month(==[grid2])]-18-[#input-year(==[grid2])]~[#label-cvc]-18-[#input-cvc(==[grid2])]| 
          in(#form-payment) gap(18) chain-top chain-bottom;
        #input-month[x] == [inputs-left]; /* :first */
      
        @horizontal |[#output-card(==[subgrid])]
          in(#input-card);
        #output-card[top] == #input-card[top];
      
        @vertical |-[#input-card]-36-[#input-month]-| 
          in(#form-payment) 
          gap([pay-input-gap]);
        [pay-input-gap] >= [grid];
    
        #input-month {
          border-radius-right: 0;
        }
        #input-year {
          border-radius-left: 0;
        }
        
      /* bc qr code */
    
        @vertical |-18-[#qrcode]-[#qrcode-link]~|
          in(#form-payment)
          gap([grid] / 2);
        #qrcode[width] == #qrcode[height];
        #qrcode[center-x] == #form-payment[center-x];
        @horizontal |[#qrcode-link]|
          in(#form-payment);
        #qrcode-link[height] == #qrcode-link[line-heigt]
          == [grid];
        #qrcode {
          background-color: white;
        }
    
      /* bc price */
    
      @vertical |[#bc-price]|
        in(#form-payment);
      @horizontal |[#bc-price]|
        in(#form-payment);
      #bc-price[line-height] == #bc-price[height];
    
      /* loader */
    
        @horizontal |-[#form-pay-loader]-|
          in(#form-payment)
          gap([grid]);
        @vertical |-[#form-pay-loader]
          in(#form-payment)
          gap([grid2]);
              

  
      /* layout */          
        /*@vertical [#admin-header-buy]-[#pay-type1]-[#form-payment]~80~[#pay-footer]| gap(40) in(#admin-buy);*/
            
        @vertical |-[#pay-type1]-18-[#form-payment]-|
          in(#wiz-section-mid2) 
          gap([pay-mid-gap]);
          [pay-mid-gap] >= [grid];
      
        @horizontal |-[#form-payment]-| in(#wiz-section-mid) gap([grid2]);
      
      
      
      
            
        #label-cvc{
          text-align:right;
        }
        #output-card {        
          background-position: 50% 50%;
          background-repeat: no-repeat;
        }
        #output-card.Visa {
          background-image: url('../assets/icon-visa.png');
        }
        #output-card.Mastercard {
          background-image: url('../assets/icon-mastercard.png');
        }
        #output-card.Amex {
          background-image: url('../assets/icon-amex.png');
        }
        .pay-type {
          opacity: .3;
          text-align:center;
        }
      
        .pay-type:not(.selected):hover {
          opacity: 1;
        }
        #pay-type1 {
          border-right: 1px solid hsla(192, 90%, 92%,.1);
        }
        html [data-pay-state="cc"] #pay-type1 {
          opacity: 1;
          color: hsl(190, 100%, 50%);
        }
        html [data-pay-state="bc"] #pay-type2, html [data-pay-state="bcqr"] #pay-type2 {
          opacity: 1;
          color: hsl(190, 100%, 50%);
        }
        .form-pay-state {
          display: none;
        }
        html [data-pay-state="cc"] .form-pay-state-cc {
          display: block;
        }
        html [data-pay-state="bc"] .form-pay-state-bc {
          display: block;
        }
        html [data-pay-state="bcqr"] .form-pay-state-bcqr {
          display: block;
        }
        html [data-pay-state="loading"] .form-pay-state-loading {
          display: block;
        }
      
      
      
      
        /* thanks */
        @horizontal .thanks-icon gap([grid]);
      
        @vertical |-72-[#thanks-title(==[grid])]-[.thanks-icon]
          in(#wiz-section-mid)
          gap([grid]);
      
        @horizontal |-[#thanks-title]-|
          in(#wiz-section-mid)
          gap([grid]);
      
        .thanks-icon[width] == 60;
        .thanks-icon[height] == 60;
        .thanks-icon[border-radius] == 30;      
        .thanks-icon[left] >= #wiz-section-mid[left] + [thanks235];
        .thanks-icon[right] <= #wiz-section-mid[right] - [thanks235];

          .thanks-icon {
          text-align: center;
          background-color: hsl(190, 100%, 50%);
          color: hsl(0, 0%, 0%);
          text-shadow: none;
          font-size: 24px;
          line-height: 48px;
          border: 6px solid hsl(0, 0%, 0%);
          box-shadow: 0 0 0 2px hsla(190, 100%, 90%, 0.1);
          box-sizing: border-box;
          }
      """
  
  