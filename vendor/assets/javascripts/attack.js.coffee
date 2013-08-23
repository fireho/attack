#= require jquery
# TO BE COMMENTED!
#
do($=jQuery) ->
  $ ->
    setTimeout ->
      $.fireAllCreatedEvents()
    , 0

    # turbolinks
    $(document).on 'page:change', () ->
      $.fireAllCreatedEvents()

    $.fireAllCreatedEvents = ->
      for k of jQuery.cache
        if jQuery.cache[k]?.events?.created?
          for obj in jQuery.cache[k].events.created
            els = $(obj.selector, jQuery.cache[k].handle.elem)
            if els.length
              for el in els
                el.__triggered_created or= {}
                el.__triggered_created[k] or= []
                unless obj in el.__triggered_created[k]
                  el.__triggered_created[k].push(obj)
                  obj.handler.apply(el, [])



  parseDOMArguments = (args, i)->
    $(args).map (i2, arg) ->
      if arg instanceof $
        if i then arg.clone(true) else arg
      else if arg?.tagName
        $(arg)
      else if typeof(arg) == 'string' and /^\s*\</.test(arg) and (tmpArg=$(arg)).length
        tmpArg
      else if arg instanceof Array and arg.length
        parseDOMArguments(arg)
      else
        arg

  cascadeTrigger = (el, event)->
    #fode geral
    ###if el instanceof $
      $el = el
      el = el.get(0)
    else
      $el = $(el)

    if el and !el.hasOwnProperty('__triggered_'+event)
      el["__triggered_"+event] = true
      console.log 'cascade', el
      $el.trigger(event) # eh o mesmo
      for child in el.children
        cascadeTrigger(child, event)###

    return unless el
    ev = "__triggered_"+event

    $el = $(el)

    parents = $el.parents().toArray()
    return unless document.body in parents
    parents.push(window.document)

    children = $el.find('*').toArray()

    #don't touch, black magic'
    for k of jQuery.cache
      if jQuery.cache[k]?.events?[event]?
        element = jQuery.cache[k].handle?.elem
        continue unless element
        if element == el or element in parents
          for obj in jQuery.cache[k].events[event]
            childEls = $(obj.selector, element)
            childEls.push element
            for childEl in childEls
              childEl[ev] or= {}
              childEl[ev][k] or= []
              if (childEl == el or childEl in children)
                continue if obj in childEl[ev][k]
                childEl[ev][k].push(obj)
                obj.handler.apply(childEl, [])


  avoidCustom = false
  originalAppend = $.fn.append
  for methodName in ['append', 'prepend', 'before', 'after']
    do(originalMethod=$.fn[methodName]) ->
      $.fn[methodName] = ->
        if avoidCustom
          return originalMethod.apply(@, arguments)

        triggerAll = (targets)->
          if targets instanceof $ or targets instanceof Array
            for target in targets
              triggerAll(target)
          else if targets.tagName?
            cascadeTrigger(targets, 'created')

        div = $('<div></div>')
        avoidCustom = true
        originalAppend.apply(div, arguments)
        avoidCustom = false
        html = div.html()
        args = arguments
        hasElements = div.children().length
        @.each (i, self)->
          if hasElements
            if i == 0
              elements = div.children()
            else
              elements = $(html)
          else
            elements = args

          originalMethod.apply($(self), elements)

          triggerAll(elements)


  do(originalMethod=$.fn.html) ->
    $.fn.html = ->
      out = originalMethod.apply(@, arguments)
      unless avoidCustom
        if arguments.length
          for el in @.children()
            cascadeTrigger(el, 'created')
      out