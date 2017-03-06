{div} = React.DOM

class @DescriptionItem extends React.Component
  constructor: (props) ->
    super props

  handleClick: (e) ->
    @props.parent.descriptionClick @props.item, @props.index

  render: ->
    classN = 'panel panel-default panel-cursor'
    classN = "#{classN} panel-select" if @props.isSelected
    div { className: classN, onClick: ((e) => @handleClick(e)) },
      div { className: 'panel-body' }, @props.item
