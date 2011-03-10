doctype 5
html ->
  head ->
    title "10,000 Questions | #{@title}"
    link rel: 'stylesheet', type: 'text/css', href: 'base.css'
    script src: 'http://code.jquery.com/jquery-latest.min.js'
  body ->
    div id: 'wrapper', ->
      div id: 'header', ->
        div id: 'logo', -> '10,000 Questions'
        div id: 'login', ->
          text 'Sign up or log in'
          div style: 'font-size: 12px;', -> 'No credit card required'
      div id: 'content', -> @content
      div id: 'footer', ->
        text '&copy; 2011 10,000 Questions. All rights reserved.'
        a href: '/about', -> 'About'
