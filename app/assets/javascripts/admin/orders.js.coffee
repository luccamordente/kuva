# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/


$ ->

  $('#orders a#destroy').bind 'click', (e) ->
    destroy = true

    destroy && (
      destroy = false
      destroy = window.confirm "Tem certeza que deseja excluir esta ordem? Isto não pode ser desfeito!"
    )
    destroy && (
      destroy = false
      a = Math.round(Math.random()*100)
      b = Math.round(Math.random()*100)
      x = a + b
      answer  = window.prompt "Quanto é #{a} + #{b}?"
      destroy = +answer == x
      destroy || alert 'Você não está em condições de apagar uma ordem de serviço agora. Volte mais tarde!'
    )
    destroy && (
      destroy = false
      destroy = window.confirm "Mesmo?"
    )

    destroy