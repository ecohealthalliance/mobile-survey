database = new MongoInternals.RemoteCollectionDriver(Meteor.settings.private.parseMongoUrl)
Users = new Meteor.Collection("_User", { _driver: database})
Surveys = new Meteor.Collection("Survey", { _driver: database })
Forms = new Meteor.Collection("Form", { _driver: database })
SurveyForms = new Meteor.Collection("_Join:forms:Survey", { _driver: database })
Triggers = new Meteor.Collection("Trigger", { _driver: database})
FormTriggers = new Meteor.Collection("_Join:triggers:Form", {_driver: database })
Notifications = new Meteor.Collection("Notification", { _driver: database }) #TODO, maybe make this a Parse.Object so its viewable in the dashboard
Invitations = new Meteor.Collection("Invitation", { _driver: database})

###
 user may only have one notification sent for each trigger
 @param {object} trigger, the unique id for the parse form record
 @param {object} user, the user that will receive the notification
###
genNotificationId = (trigger, user) ->
  return CryptoJS.MD5(trigger._id + user._id).toString()

###
 creates a notification object and inserts into the database
 @param {string} id, the MD5 unique id for record
 @param {object} trigger, the unique id for the parse form record
 @param {object} user, the user that will receive the notification
###
createNotification = (id, trigger, user) ->
  message = trigger.form.title + ' is ready'
  notification = Notifications.insert({
    _id: id
    userId: user._id
    triggerId: trigger._id
    sent: false
    message: message
    created_at: new Date()
  })
  if (!notification.sent)
    sendNotification(notification, trigger.form._id, message, user)

###
 sends a notification to parse-server
 @param {string} notificationId, the notification record id
 @param {string} formId, the object id of the form that the trigger belongs
 @param {string} message, the notification message
 @param {object} user, the user that will receive the notification
###
sendNotification = (notificationId, formId, message, user) ->
  installationQuery = new Parse.Query(Parse.Installation)
  installationQuery.equalTo 'userId', user._id
  opts =
    useMasterKey: true
  push =
    where: installationQuery
    data:
      alert: message
      formId: formId
      badge: "Increment"
  Parse.Push.send(push, opts).then(
      Meteor.bindEnvironment (s) ->
        Notifications.update(notificationId, {$set: {sent:  true, updated_at: new Date()}});
      Meteor.bindEnvironment (e) ->
        console.warn("[notificationService]: error sending push notification #{nodificationId}")
  )
  return

###
 get trigger relations from a form
 @param {object} form, the form that will contain trigger relations
###
getTriggersForForm = (form) ->
  formTriggers = FormTriggers.find({owningId: form._id}).fetch()
  triggerIds = _.map(formTriggers, (v,k) -> return v.relatedId)
  return Triggers.find({_id: {$in: triggerIds}, type: 'datetime'}).fetch()

###
 get form relations from a survey
 @param {object} survey, the survey that will contain form relations
###
getFormsForSurvey = (survey) ->
  surveyForms = SurveyForms.find({owningId: survey._id}).fetch()
  formIds = _.map(surveyForms, (v,k) -> return v.relatedId)
  return Forms.find({_id: {$in: formIds}}).fetch()

###
 get users who have accepted invitations for the survey
 @param {object} survey, the survey to search for invitations
###
getSurveyAcceptedUsers = (survey) ->
  invitations = Invitations.find({surveyId: survey._id, status: 'accepted'}).fetch()
  if invitations.length <= 0
    return []
  userIds = _.map(invitations, (invitation) -> invitation.userId)
  return Users.find({_id: {$in: userIds}}).fetch()

###
 the method that checks for notifications but filtering active surveys and
 user accepted invitations
###
checkForNotifications = () ->
  console.log '[notificationService]: checking for notifications'
  surveys = Surveys.find({active: true}).fetch()
  if surveys.length <= 0
    console.warn '[notificationService]: no active surveys'
    return

  now = new Date()
  past = new Date()
  past = past.setDate(past.getDate() - 2)

  surveys.forEach (s) ->
    activeTriggers = []
    users = getSurveyAcceptedUsers(s)

    if users.length <= 0
      console.warn "[notificationService]: no accepted users for survey #{s.title}"
      return

    forms = getFormsForSurvey(s)
    forms.forEach (form) ->
      triggers = getTriggersForForm(form)
      active = _.filter triggers, (t) ->
        triggerDate = new Date(t.properties.datetime)
        if (triggerDate < now && triggerDate > past)
          t.form = form
          return t
      activeTriggers = _.union(activeTriggers, active)

    if (activeTriggers.length <= 0)
      console.warn "[notificationService]: no active triggers for survey #{s.title}"
      return

    activeTriggers.forEach (trigger) ->
      users.forEach (user) ->
        id = genNotificationId(trigger, user)
        existingNotification = Notifications.findOne({_id: id})
        if (!existingNotification )
          createNotification(id, trigger, user)
        else
          if (!existingNotification.sent)
            sendNotification(existingNotification._id, form._id, existingNotification.message, user)
  return

Meteor.startup ->
  if Meteor.settings.private.enableNotifications
    Meteor.setInterval(checkForNotifications, Meteor.settings.private.notificationIntervalInMinutes * 60 * 1000);
    checkForNotifications()
