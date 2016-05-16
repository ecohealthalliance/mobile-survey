geo = new GeoCoder(
  geocoderProvider: "google",
  httpAdapter: "https",
  apiKey: Meteor.settings.googleApiKey
)

Meteor.methods
  geocode: (address) ->
    geo.geocode(address)
