module.exports = class LabelsFiltersToolView extends Mn.CompositeView

    template: require 'views/templates/labels/filters_tool'

    tagName: 'fieldset'

    childViewContainer: 'ul'

    childView: require 'views/labels/filter'
