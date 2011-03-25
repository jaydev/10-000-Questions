home = ->
  h1 ->
    text 'Nervous about Step 1?'
    br ->
    text 'Crush the test with the system we used to score 250+'
  div id: 'col-left', ->
    p style: 'font-size: 25px;', ->
      text 'Flash cards organized and personally targeted to make '
      text 'sure that you learn and retain every First Aid fact most efficiently.'
    div style: 'margin: 5px 0px;', ->
    p style: 'font-size: 12px;', ->
      a href: '/science', -> 'More about our system'
    div style: 'margin: 20px 0px;', ->
    ul ->
      b -> 'Use 10,000 Questions to:'
      li -> 'Stay focused'
      li -> 'Increase your memory retention'
      li -> 'Chart your progress'
    a href: '/signup', -> 'Try it now'
  div id: 'col-right', ->
    p -> 'Thousands of questions, covering every page of the First Aid Step 1 book.'
    div style: 'margin: 10px 0px;', ->
    a href: '/signup', -> 'Try it free for 30 days'


about = ->
  h1 -> 'About'


flashcards = ->
  coffeescript ->
    $ ->
      $('input#save').click ->
        $.post(
          '/flashcards/next',
          {answer: $('#answer').val()},
          (data) ->
            $('#actions').html data
        )
        return false
  h1 -> 'Flashcards'
  div id: 'actions', -> @flashcard_content


answer = ->
  form action: '', method: 'post', id: 'answer-form', ->
    text @card.question
    span style: 'font-size: 11px;', -> " (pg. #{@card.page_number})"
    br ->
    textarea rows: '10', cols: '50', id: 'answer', name: 'answer', ->
    br ->
    input type: 'submit', name: 'save', id: 'save', value: 'Save Answer', ->


rate = ->
  form id: 'rating-form', ->
    input type: 'radio', name: 'rating', value: '1', ->
    text 'Nailed it!'
    br ->
    input type: 'radio', name: 'rating', value: '2', ->
    text 'I kinda knew the answer.'
    br ->
    input type: 'radio', name: 'rating', value: '3'
    text 'I need to review this question again.'
    br ->
    input type: 'submit', name: 'save', id: 'save', value: 'Next Question', ->


exports.home = home
exports.about = about
exports.flashcards = flashcards
exports.answer = answer
exports.rate = rate