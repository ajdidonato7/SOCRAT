'use strict'

module.exports = class AppMessageMap
  constructor: () ->
    map: [
    #      msgFrom: 'add numbers'
    #      scopeFrom: ['qualRobEstView']
    #      msgTo: 'add numbers'
    #      scopeTo: ['qualRobEst']
    #    ,
    #      msgFrom: 'numbers added'
    #      scopeFrom: ['qualRobEst']
    #      msgTo: 'numbers added'
    #      scopeTo: ['qualRobEstView']
    #    ,
      msgFrom: 'save data'
      scopeFrom: ['app_analysis_getData', 'wrangleData']
      msgTo: 'save table'
      scopeTo: ['database']
    #    ,
    #      msgFrom:'table saved'
    #      scopeFrom: ['database']
    #      msgTo: '234'
    #      scopeTo: ['qualRobEst']
    #    ,
    #      msgFrom: 'upload csv'
    #      scopeFrom: ['getData']
    #      msgTo: 'upload csv'
    #      scopeTo: ['app.utils.importer']
    ,
    # TODO: make message mapping dynamic #SOCRFW-151
      msgFrom: 'get table'
      scopeFrom: ['instrPerfEval']
      msgTo: 'get table'
      scopeTo: ['database']
    ,
      msgFrom: 'take table'
      scopeFrom: ['database']
      msgTo: 'take table'
      scopeTo: ['instrPerfEval']
    #    ,
    #      msgFrom: 'get data'
    #      scopeFrom: ['kMeans']
    #      msgTo: 'get table'
    #      scopeTo: ['database']
    #    ,
    #      msgFrom: 'take table'
    #      scopeFrom: ['database']
    #      msgTo: 'take data'
    #      scopeTo: ['kMeans']
    ,
      msgFrom: 'getData'
      scopeFrom: ['app_analysis_cluster']
      msgTo: 'get table'
      scopeTo: ['database']
    ,
      msgFrom: 'take table'
      scopeFrom: ['database']
      msgTo: 'takeData'
      scopeTo: ['app_analysis_cluster']
    #    ,
    #      msgFrom: 'get data'
    #      scopeFrom: ['spectrClustr']
    #      msgTo: 'get table'
    #      scopeTo: ['database']
    #    ,
    #      msgFrom: 'take table'
    #      scopeFrom: ['database']
    #      msgTo: 'take data'
    #      scopeTo: ['spectrClustr']
    ,
      msgFrom: 'get data'
      scopeFrom: ['wrangleData']
      msgTo: 'get table'
      scopeTo: ['database']
    ,
      msgFrom: 'take table'
      scopeFrom: ['database']
      msgTo: 'wrangle data'
      scopeTo: ['wrangleData']
    ,
      msgFrom: 'get table'
      scopeFrom: ['charts']
      msgTo: 'get table'
      scopeTo: ['database']
    ,
      msgFrom: 'take table'
      scopeFrom: ['database']
      msgTo: 'take table'
      scopeTo: ['charts']

    ]
